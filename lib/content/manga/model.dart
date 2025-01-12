import 'package:flutter/material.dart';

enum MangaReaderScale {
  fit,
  fitHeight,
  fitWidth,
}

enum MangaReaderMode {
  vericalScroll(
    scroll: true,
    direction: Axis.vertical,
    scaleModes: [MangaReaderScale.fitHeight, MangaReaderScale.fitWidth],
  ),
  hotizontalScroll(scroll: true),
  hotizontalRtlScroll(
    scroll: true,
    rtl: true,
  ),
  vertical(
    direction: Axis.vertical,
    scaleModes: [],
  ),
  leftToRight(scaleModes: []),
  rightToLeft(rtl: true, scaleModes: []);

  final bool scroll;
  final Axis direction;
  final bool rtl;
  final List<MangaReaderScale> scaleModes;

  const MangaReaderMode({
    this.scroll = false,
    this.direction = Axis.horizontal,
    this.rtl = false,
    this.scaleModes = const [],
  });
}

enum MangaReaderBackground {
  light,
  dark,
}
