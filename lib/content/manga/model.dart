import 'package:flutter/material.dart';

enum MangaReaderMode {
  vericalScroll(scroll: true, direction: Axis.vertical),
  hotizontalScroll(scroll: true),
  hotizontalRtlScroll(scroll: true, rtl: true),
  vertical(direction: Axis.vertical),
  leftToRight(),
  rightToLeft(rtl: true);

  final bool scroll;
  final Axis direction;
  final bool rtl;

  const MangaReaderMode({
    this.scroll = false,
    this.direction = Axis.horizontal,
    this.rtl = false,
  });
}

enum MangaReaderBackground { light, dark }
