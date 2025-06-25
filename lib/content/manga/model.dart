import 'package:flutter/material.dart';

enum MangaReaderMode {
  vericalScroll(scroll: true, direction: Axis.vertical),
  hotizontalScroll(scroll: true),
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
