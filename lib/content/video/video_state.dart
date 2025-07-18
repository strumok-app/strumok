import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:strumok/content/video/video_subtitles.dart';

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
  @override
  void setSubtitleViewPadding(
    EdgeInsets padding, {
    Duration duration = const Duration(milliseconds: 100),
  }) {
    PlayerSubtitleView.paddings = padding;
  }
}
