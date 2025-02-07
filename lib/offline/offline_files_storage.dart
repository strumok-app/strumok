import 'dart:io';

import 'package:content_suppliers_api/model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/offline/offline_content_details.dart';
import 'package:strumok/utils/logger.dart';

class OfflineFilesStorage {
  static final OfflineFilesStorage _instance = OfflineFilesStorage._internal();

  late String _downloadsDir;

  factory OfflineFilesStorage() {
    return _instance;
  }

  OfflineFilesStorage._internal();

  Future<void> init() async {
    _downloadsDir = "${(await getDownloadsDirectory())!.path}${Platform.pathSeparator}strumok";

    logger.i("Downloads directory: $_downloadsDir");
  }

  Future<List<ContentMediaItemSource>> getSources(
    String supplier,
    String id,
    int number,
  ) async {
    final mediaItemPath = getMediaItemPath(supplier, id, number);

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
            sources.add(OfflineContentMediaItemSource(
              description: Uri.decodeComponent(name),
              link: fsEntry.uri,
            ));
          }
        }
      } else if (fsEntry is Directory) {
        if (fsEntryName.startsWith("pages_")) {
          final name = fsEntryName.substring(6);
          sources.add(OfflineMangaMediaItemSource(
            description: Uri.decodeComponent(name),
            dir: fsEntryPath,
          ));
        }
      }
    }

    return sources;
  }

  Future<void> deleteSource(String supplier, String id, int number, ContentMediaItemSource source) async {
    final sourcePath = getMediaItemSourcePath(supplier, id, number, source);

    if (source.kind == FileKind.manga) {
      await Directory(sourcePath).delete(recursive: true);
    } else {
      await File(sourcePath).delete();
    }

    final sourcesLeft = await getSources(supplier, id, number);
    if (sourcesLeft.isEmpty) {
      await Directory(getMediaItemPath(supplier, id, number)).delete(recursive: true);
    }
  }

  Future<bool> isSourceExists(
    String supplier,
    String id,
    int number,
  ) async {
    final sources = await getSources(supplier, id, number);
    return sources.isNotEmpty;
  }

  String getMediaItemPath(String supplier, String id, int number) => [
        _downloadsDir,
        "${supplier}_${Uri.encodeComponent(id)}",
        number.toString(),
      ].join(Platform.pathSeparator);

  String getMediaItemSourcePath(String supplier, String id, int number, ContentMediaItemSource source) {
    final mediaItemPath = getMediaItemPath(supplier, id, number);
    final sanitize = Uri.encodeComponent(source.description);
    final finalPart = switch (source.kind) {
      FileKind.video => "$sanitize.mp4",
      FileKind.manga => "pages_$sanitize",
      FileKind.subtitle => "$sanitize.vtt",
    };

    return [mediaItemPath, finalPart].join(Platform.pathSeparator);
  }
}

String getMediaItemId(String supplier, String id, int number) {
  return [supplier, id, number.toString()].join("_");
}

Future<DownloadRequest?> createDownLoadRequest(
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
    final sourcePath = OfflineFilesStorage().getMediaItemSourcePath(supplier, id, number, source);

    return VideoDownloadRequest(
      id: getMediaItemId(supplier, id, number),
      url: link.toString(),
      fileSrc: sourcePath,
      info: info,
      headers: mediaSource.headers,
    );
  } else if (source.kind == FileKind.manga) {
    final mediaSource = source as MangaMediaItemSource;
    final pages = await mediaSource.pages;

    final sourcePath = OfflineFilesStorage().getMediaItemSourcePath(supplier, id, number, source);

    return MangaDownloadRequest(
      id: getMediaItemId(supplier, id, number),
      pages: pages,
      folder: sourcePath,
      info: info,
    );
  }

  return null;
}
