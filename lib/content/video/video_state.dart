import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

class CustomVideo extends Video {
  const CustomVideo({
    super.key,
    required super.controller,
    required super.controls,
    super.pauseUponEnteringBackgroundMode,
  });

  @override
  State<Video> createState() {
    return CustomVideoState();
  }
}

class CustomVideoState extends VideoState {
  final subtitlePadding = ValueNotifier(EdgeInsets.zero);

  @override
  void setSubtitleViewPadding(
    EdgeInsets padding, {
    Duration duration = const Duration(milliseconds: 100),
  }) {
    subtitlePadding.value = padding;
  }
}
