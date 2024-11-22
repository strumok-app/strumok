import 'package:flutter/material.dart';

enum MangaReaderScale {
  fit,
  fitHeight,
  fitWidth,
}

enum MangaReaderMode {
  vertical(
    direction: Axis.vertical,
    scaleModes: MangaReaderScale.values,
  ),
  leftToRight(scaleModes: MangaReaderScale.values),
  rightToLeft(rtl: true, scaleModes: MangaReaderScale.values),
  vericalScroll(
    scroll: true,
    direction: Axis.vertical,
    scaleModes: [MangaReaderScale.fitHeight, MangaReaderScale.fitWidth],
  ),
  hotizontalScroll(scroll: true),
  hotizontalRtlScroll(
    scroll: true,
    rtl: true,
  );

  final bool scroll;
  final Axis direction;
  final bool rtl;
  final List<MangaReaderScale> scaleModes;

  const MangaReaderMode(
      {this.scroll = false,
      this.direction = Axis.horizontal,
      this.rtl = false,
      this.scaleModes = const []});
}

enum MangaReaderBackground {
  light,
  dark,
}
