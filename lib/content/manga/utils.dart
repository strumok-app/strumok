import 'dart:io';

import 'package:strumok/content/manga/model.dart';
import 'package:strumok/download/offline_storage.dart';

File getPageFile(MangaPageInfo page) {
  final sourcePath = OfflineStorage().getMediaItemSourcePath(
    page.supplier,
    page.id,
    page.itemNum,
    page.source,
  );
  return File('$sourcePath/${page.pageNum}.jpg');
}
