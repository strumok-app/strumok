import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum MangaReaderMode {
  longStrip(scroll: true, direction: Axis.vertical),
  // longStripHorizontal(scroll: true),
  vertical(direction: Axis.vertical),
  leftToRight();

  final bool scroll;
  final Axis direction;

  const MangaReaderMode({
    this.scroll = false,
    this.direction = Axis.horizontal,
  });
}

enum MangaReaderBackground { light, dark }

class MangaPageInfo extends Equatable {
  final String supplier;
  final String id;
  final int itemNum;
  final MangaMediaItemSource source;
  final int pageNum;
  final String url;

  const MangaPageInfo({
    required this.supplier,
    required this.id,
    required this.itemNum,
    required this.source,
    required this.pageNum,
    required this.url,
  });

  @override
  List<Object?> get props => [supplier, id, itemNum, source, pageNum, url];

  @override
  String toString() =>
      'MangaPageInfo(supplier: $supplier, id: $id, itemNum: $itemNum, source: $source, pageNum: $pageNum, url: $url)';
}
