import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:content_suppliers_api/model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/download/offline_content_models.dart';
import 'package:strumok/utils/logger.dart';

/// Singleton that manages persistence of offline content on disk.
///
/// Responsibilities:
/// - Store and retrieve `details.json` for each downloaded content.
/// - Enumerate media items and their sources for offline playback.
/// - Create download requests for media sources.
///
/// Call [init] once before using this service to ensure the downloads
/// directory is configured.
class OfflineStorage {
  static const String _detailsFileName = 'details.json';

  static const String _videoExtension = 'mp4';
  static const String _subtitleExtension = 'vtt';
  static const String _mangaExtension = 'manga';

  static final OfflineStorage _instance = OfflineStorage._internal();

  late String _downloadsDir;

  factory OfflineStorage() {
    return _instance;
  }

  OfflineStorage._internal();

  /// Initialize storage paths.
  ///
  /// If a custom downloads directory is configured in preferences it will
  /// be used; otherwise the platform downloads directory with a `strumok`
  /// subfolder is used.
  Future<void> init() async {
    final downloadDirFromPreferences = AppPreferences.offlineDownloadsDirectory;

    if (downloadDirFromPreferences != null &&
        downloadDirFromPreferences.isNotEmpty) {
      _downloadsDir = downloadDirFromPreferences;
    } else {
      _downloadsDir = path.join(
        (await getDownloadsDirectory())!.path,
        'strumok',
      );
    }

    logger.info("Downloads directory: $_downloadsDir");
  }

  /// Retrieves a list of offline content information from the downloads directory.
  Future<List<OfflineContentInfo>> offlineContent() async {
    final root = Directory(_downloadsDir);

    if (!await root.exists()) {
      return [];
    }

    final result = <OfflineContentInfo>[];

    await for (final fsEntry in root.list()) {
      if (fsEntry is Directory) {
        // Use the basename to get the folder name without depending on
        // string lengths of the parent path.
        final fsEntryName = path.basename(fsEntry.path);
        final fsEntryNameParts = fsEntryName.split("_");
        if (fsEntryNameParts.length == 2) {
          final [supplier, id] = fsEntryNameParts;
          final detailsJson = await _readContentDetailsJson(fsEntry.path);
          final diskUsage = await _calculateDiskUsage(fsEntry);

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

  /// Stores content details to disk.
  /// If [override] is true, overwrites existing file.
  Future<void> storeDetails(
    ContentDetails details, {
    bool override = false,
  }) async {
    final contentDetailsPath = _getContentDetailsPath(
      details.supplier,
      details.id,
    );
    final contentDetailsFile = File(contentDetailsPath);
    if (!await contentDetailsFile.exists() || override) {
      await contentDetailsFile.create(recursive: true);
      await contentDetailsFile.writeAsString(
        _contentDetailsToJson(details),
        mode: FileMode.write,
      );
    }
  }

  /// Load [ContentDetails] for a piece of content from disk.
  ///
  /// Throws if there are no persisted details for the given `supplier` and `id`.
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

  /// Enumerate media items (by index) for the given content.
  ///
  /// Media items are represented by numeric subfolders under the content root.
  Future<List<ContentMediaItem>> getMediaItems(
    String supplier,
    String id,
  ) async {
    final contentDetailsPath = _getContentRootPath(supplier, id);
    final contentDetailsDir = Directory(contentDetailsPath);
    final mediaItems = <ContentMediaItem>[];

    await for (final fsEntry in contentDetailsDir.list()) {
      if (fsEntry is Directory) {
        // Get the folder name (expected to be numeric for media items).
        final fsEntryName = path.basename(fsEntry.path);

        final num = int.tryParse(fsEntryName);

        if (num != null) {
          mediaItems.add(
            OfflineContenMediaItem(supplier, id, "${num + 1}", num),
          );
        }
      }
    }

    return mediaItems.sortedBy((item) => item.number);
  }

  /// Return list of locally available sources for a media item.
  ///
  /// The returned list may include video files, subtitles or manga page folders.
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
      final fsEntryName = path.basename(fsEntry.path);
      if (fsEntry is File) {
        final extIndex = fsEntryName.lastIndexOf(".");
        if (extIndex != -1) {
          final name = fsEntryName.substring(0, extIndex);
          final ext = fsEntryName.substring(extIndex + 1);

          FileKind? kind = switch (ext) {
            _videoExtension => FileKind.video,
            _subtitleExtension => FileKind.subtitle,
            _mangaExtension => FileKind.manga,
            _ => null,
          };

          switch (kind) {
            case FileKind.video:
            case FileKind.subtitle:
              sources.add(
                OfflineContentMediaItemSource(
                  description: Uri.decodeComponent(name),
                  link: fsEntry.uri,
                ),
              );
            case FileKind.manga:
              await _readMangaSource(dir, name, sources);
            default:
            // nothing
          }
        }
      }
    }

    return sources;
  }

  /// Add a new source to disk (via downloading it) and ensure details are stored.
  Future<void> storeSource(
    ContentDetails details,
    int number,
    ContentMediaItemSource source,
  ) async {
    await storeDetails(details);

    final request = await _createDownloadRequest(details, number, source);
    if (request != null) {
      DownloadManager().download(request);
    }
  }

  /// Deletes content details and all associated files.
  ///
  /// If any tasks for this content are currently downloading the operation
  /// is a no-op and a warning is logged instead of throwing.
  Future<void> deleteContentDetails(String supplier, String id) async {
    if (hasAnyDownloadingItems(supplier, id)) {
      logger.warning(
        'Attempted to delete content that is currently downloading: $supplier, $id',
      );
      return;
    }

    final contentDetailsPath = _getContentRootPath(supplier, id);
    await Directory(contentDetailsPath).delete(recursive: true);
  }

  /// Delete a single source (file or manga folder) for a media item.
  ///
  /// If no sources remain after deletion the media item folder will be removed.
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

  /// Returns true when at least one source exists for the media item.
  Future<bool> sourceExists(String supplier, String id, int number) async {
    final sources = await getSources(supplier, id, number);
    return sources.isNotEmpty;
  }

  String _getMediaItemPath(String supplier, String id, int number) =>
      path.join(_getContentRootPath(supplier, id), number.toString());

  String _getContentDetailsPath(String supplier, String id) =>
      path.join(_getContentRootPath(supplier, id), _detailsFileName);

  String _getContentRootPath(String supplier, String id) =>
      path.join(_downloadsDir, _getContentDetailsFolderName(supplier, id));

  String _getContentDetailsFolderName(String supplier, String id) =>
      "${supplier}_${Uri.encodeComponent(id)}";

  /// Build the filesystem path for a given `source` of a media item.
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

    return path.join(mediaItemPath, finalPart);
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

  /// Read and decode the content details JSON file if present.
  ///
  /// Returns `null` if file is missing or cannot be decoded.
  Future<Map<String, Object?>?> _readContentDetailsJson(
    String contentDetailsPath,
  ) async {
    final detailsFile = File(path.join(contentDetailsPath, _detailsFileName));

    Map<String, Object?>? detailsJson;
    if (await detailsFile.exists()) {
      final fileContent = await detailsFile.readAsString();

      try {
        detailsJson = json.decode(fileContent);
      } catch (e) {
        logger.warning("Can't decode details for: ${detailsFile.path}");
      }
    }

    return detailsJson;
  }

  /// Create a concrete [DownloadRequest] for the provided source.
  Future<DownloadRequest?> _createDownloadRequest(
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
      final sourcePath = getMediaItemSourcePath(supplier, id, number, source);

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

      final sourcePath = getMediaItemSourcePath(supplier, id, number, source);

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

  /// Calculate total size in bytes of files under [dir].
  Future<int> _calculateDiskUsage(Directory dir) async {
    int size = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }

  /// Read a manga pages folder (named `pages_<name>`) and add it as a source.
  Future<void> _readMangaSource(
    Directory dir,
    String name,
    List<ContentMediaItemSource> sources,
  ) async {
    final pagesDir = Directory(path.join(dir.path, name));
    if (await pagesDir.exists()) {
      final sourceName = name.substring(6);
      sources.add(
        OfflineMangaMediaItemSource(
          description: Uri.decodeComponent(sourceName),
          dir: pagesDir.path,
        ),
      );
    }
  }
}

/// Returns true when there are active download tasks for the content.
bool hasAnyDownloadingItems(String supplier, String id) {
  final prefix = getContentDownloadIdPrefix(supplier, id);

  return DownloadManager()
      .getTasks()
      .where((task) => task.request.id.startsWith(prefix))
      .isNotEmpty;
}

/// Helper to build download id prefix used for download task ids.
String getContentDownloadIdPrefix(String supplier, String id) {
  return "${supplier}_$id";
}

/// Full download id for a media item (includes media item index).
String getMediaItemDownloadId(String supplier, String id, int number) {
  return "${getContentDownloadIdPrefix(supplier, id)}_$number";
}
