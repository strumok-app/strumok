import 'dart:convert';
import 'dart:io';

import 'package:content_suppliers_api/model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/download/models.dart';
import 'package:strumok/utils/logger.dart';

class OfflineStorage {
  static final OfflineStorage _instance = OfflineStorage._internal();

  late String _downloadsDir;

  factory OfflineStorage() {
    return _instance;
  }

  OfflineStorage._internal();

  Future<void> init() async {
    _downloadsDir =
        "${(await getDownloadsDirectory())!.path}${Platform.pathSeparator}strumok";

    logger.info("Downloads directory: $_downloadsDir");
  }

  Future<List<OfflineContentInfo>> offlineContent() async {
    final root = Directory(_downloadsDir);

    if (!await root.exists()) {
      return [];
    }

    final result = <OfflineContentInfo>[];

    await for (final fsEntry in root.list()) {
      if (fsEntry is Directory) {
        final fsEntryName = fsEntry.path.substring(_downloadsDir.length + 1);
        final fsEntryNameParts = fsEntryName.split("_");
        if (fsEntryNameParts.length == 2) {
          final [supplier, id] = fsEntryNameParts;
          final detailsJson = await _readContentDetailsJson(fsEntry.path);

          int diskUsage = 0;
          await for (var entity in fsEntry.list(recursive: true)) {
            if (entity is File) {
              diskUsage += await entity.length();
            }
          }

          result.add(
            OfflineContentInfo.create(
              Uri.decodeComponent(id),
              supplier,
              detailsJson,
              diskUsage,
            ),
          );
        }
      }
    }

    return result;
  }

  Future<void> storeDetails(ContentDetails details, {overrride = false}) async {
    final contentDetailsPath = _getContentDetailsPath(
      details.supplier,
      details.id,
    );
    final contentDetailsFile = File(contentDetailsPath);
    if (!await contentDetailsFile.exists() || overrride) {
      await contentDetailsFile.create(recursive: true);
      await contentDetailsFile.writeAsString(
        _contentDetailsToJson(details),
        mode: FileMode.write,
      );
    }
  }

  Future<ContentDetails> getContentDetails(String supplier, String id) async {
    final contentDetailsPath = _getContentRootPath(supplier, id);
    final contentDetailsJson = await _readContentDetailsJson(
      contentDetailsPath,
    );

    if (contentDetailsJson == null) {
      throw Exception("Content details not found");
    }

    return OfflineContentDetails.create(id, supplier, contentDetailsJson);
  }

  Future<List<ContentMediaItem>> getMediaItems(
    String supplier,
    String id,
  ) async {
    final contentDetailsPath = _getContentRootPath(supplier, id);
    final contentDetailsDir = Directory(contentDetailsPath);
    final mediaItems = <ContentMediaItem>[];

    int index = 0;

    await for (final fsEntry in contentDetailsDir.list()) {
      if (fsEntry is Directory) {
        final fsEntryPath = fsEntry.path;
        final fsEntryName = fsEntryPath.substring(
          contentDetailsPath.length + 1,
        );

        final num = int.tryParse(fsEntryName);

        if (num != null) {
          mediaItems.add(
            OfflineContenMediaItem(supplier, id, "${num + 1}", index, num),
          );
        }
      }
    }

    return mediaItems;
  }

  Future<List<ContentMediaItemSource>> getSources(
    String supplier,
    String id,
    int number,
  ) async {
    final mediaItemPath = _getMediaItemPath(supplier, id, number);

    final dir = Directory(mediaItemPath);

    if (!(await dir.exists())) {
      return [];
    }

    final sources = <ContentMediaItemSource>[];

    await for (final fsEntry in dir.list()) {
      final fsEntryPath = fsEntry.path;
      final fsEntryName = fsEntryPath.substring(mediaItemPath.length + 1);
      if (fsEntry is File) {
        final extIndex = fsEntryName.lastIndexOf(".");
        if (extIndex != -1) {
          final name = fsEntryName.substring(0, extIndex);
          final ext = fsEntryName.substring(extIndex + 1);

          FileKind? kind = switch (ext) {
            "mp4" => FileKind.video,
            "vtt" => FileKind.subtitle,
            _ => null,
          };

          if (kind != null) {
            sources.add(
              OfflineContentMediaItemSource(
                description: Uri.decodeComponent(name),
                link: fsEntry.uri,
              ),
            );
          }
        }
      } else if (fsEntry is Directory) {
        if (fsEntryName.startsWith("pages_")) {
          final isComplete = await fsEntry.list().any(
            (e) => e.path.endsWith("/complete"),
          );

          if (!isComplete) {
            return [];
          }

          final name = fsEntryName.substring(6);
          sources.add(
            OfflineMangaMediaItemSource(
              description: Uri.decodeComponent(name),
              dir: fsEntryPath,
            ),
          );
        }
      }
    }

    return sources;
  }

  Future<void> storeSource(
    ContentDetails details,
    int number,
    ContentMediaItemSource source,
  ) async {
    await storeDetails(details);

    final request = await _createDownLoadRequest(details, number, source);
    if (request != null) {
      DownloadManager().download(request);
    }
  }

  Future<void> deleteContentDetails(String supplier, String id) async {
    final contentDetailsPath = _getContentRootPath(supplier, id);
    await Directory(contentDetailsPath).delete(recursive: true);
  }

  Future<void> deleteSource(
    String supplier,
    String id,
    int number,
    ContentMediaItemSource source,
  ) async {
    final sourcePath = getMediaItemSourcePath(supplier, id, number, source);

    if (source.kind == FileKind.manga) {
      await Directory(sourcePath).delete(recursive: true);
    } else {
      await File(sourcePath).delete();
    }

    final sourcesLeft = await getSources(supplier, id, number);
    if (sourcesLeft.isEmpty) {
      await Directory(
        _getMediaItemPath(supplier, id, number),
      ).delete(recursive: true);
    }
  }

  Future<bool> sourceExists(String supplier, String id, int number) async {
    final sources = await getSources(supplier, id, number);
    return sources.isNotEmpty;
  }

  String _getMediaItemPath(String supplier, String id, int number) =>
      "${_getContentRootPath(supplier, id)}${Platform.pathSeparator}$number";

  String _getContentDetailsPath(String supplier, String id) =>
      "${_getContentRootPath(supplier, id)}${Platform.pathSeparator}details.json";

  String _getContentRootPath(String supplier, String id) =>
      "$_downloadsDir${Platform.pathSeparator}${_getContentDetailsFolderName(supplier, id)}";

  String _getContentDetailsFolderName(String supplier, String id) =>
      "${supplier}_${Uri.encodeComponent(id)}";

  String getMediaItemSourcePath(
    String supplier,
    String id,
    int number,
    ContentMediaItemSource source,
  ) {
    final mediaItemPath = _getMediaItemPath(supplier, id, number);
    final sanitize = Uri.encodeComponent(source.description);
    final finalPart = switch (source.kind) {
      FileKind.video => "$sanitize.mp4",
      FileKind.manga => "pages_$sanitize",
      FileKind.subtitle => "$sanitize.vtt",
    };

    return [mediaItemPath, finalPart].join(Platform.pathSeparator);
  }

  String _contentDetailsToJson(ContentDetails contentDetails) {
    return json.encode({
      "title": contentDetails.title,
      "secondaryTitle": contentDetails.secondaryTitle,
      "image": contentDetails.image,
      "mediaType": contentDetails.mediaType.name,
      "additionalInfo": contentDetails.additionalInfo,
      "description": contentDetails.description,
    });
  }

  Future<Map<String, Object?>?> _readContentDetailsJson(
    String contentDetailsPath,
  ) async {
    final detailsFile = File(
      "$contentDetailsPath${Platform.pathSeparator}details.json",
    );

    Map<String, Object?>? detailsJson;
    if (await detailsFile.exists()) {
      final fileContent = await detailsFile.readAsString();

      try {
        detailsJson = json.decode(fileContent);
      } catch (e) {
        logger.warning("Cant decode details for : ${detailsFile.path}");
      }
    }

    return detailsJson;
  }

  Future<DownloadRequest?> _createDownLoadRequest(
    ContentInfo contentInfo,
    int number,
    ContentMediaItemSource source,
  ) async {
    final supplier = contentInfo.supplier;
    final id = contentInfo.id;
    final info = DownloadInfo(
      image: contentInfo.image,
      title: "${contentInfo.title} - ${number + 1}",
    );

    if (source.kind == FileKind.video) {
      final mediaSource = source as MediaFileItemSource;
      final link = await mediaSource.link;
      final sourcePath = OfflineStorage().getMediaItemSourcePath(
        supplier,
        id,
        number,
        source,
      );

      return VideoDownloadRequest(
        id: getMediaItemDownloadId(supplier, id, number),
        url: link.toString(),
        fileSrc: sourcePath,
        info: info,
        headers: mediaSource.headers,
      );
    } else if (source.kind == FileKind.manga) {
      final mediaSource = source as MangaMediaItemSource;
      final pages = await mediaSource.pages;

      final sourcePath = OfflineStorage().getMediaItemSourcePath(
        supplier,
        id,
        number,
        source,
      );

      return MangaDownloadRequest(
        id: getMediaItemDownloadId(supplier, id, number),
        pages: pages,
        folder: sourcePath,
        info: info,
        headers: mediaSource.headers,
      );
    }

    return null;
  }
}

bool hasAnyDownloadingItems(String supplier, String id) {
  final prefix = getContentDownloadIdPrefix(supplier, id);

  return DownloadManager()
      .getTasks()
      .where((task) => task.request.id.startsWith(prefix))
      .isNotEmpty;
}

String getContentDownloadIdPrefix(String supplier, String id) {
  return "${supplier}_$id";
}

String getMediaItemDownloadId(String supplier, String id, int number) {
  return "${getContentDownloadIdPrefix(supplier, id)}_$number";
}
