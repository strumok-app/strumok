import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:strumok/content/video/video_content_view.dart';
import 'package:subtitle/subtitle.dart';

class WithSubtitles extends StatelessWidget {
  final Widget child;
  final PlayerController playerController;

  const WithSubtitles({
    super.key,
    required this.playerController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: playerController.subtitlesController,
          builder:
              (context, value, child) =>
                  value != null
                      ? Positioned.fill(
                        child: SubtitleView(
                          player: playerController.player,
                          subtitleController: value,
                        ),
                      )
                      : SizedBox.shrink(),
        ),
        child,
      ],
    );
  }
}

class SubtitleView extends StatefulWidget {
  final Player player;
  final SubtitleController subtitleController;

  const SubtitleView({
    super.key,
    required this.player,
    required this.subtitleController,
  });

  @override
  State<SubtitleView> createState() => _SubtitleViewState();
}

class _SubtitleViewState extends State<SubtitleView> {
  late final StreamSubscription subscription;
  Subtitle? _subtitle;

  @override
  void initState() {
    super.initState();

    subscription = widget.player.stream.position.listen((position) {
      if (_subtitle?.inRange(position) == true) {
        return;
      }

      final sub = widget.subtitleController.durationSearch(position);

      setState(() {
        _subtitle = sub;
      });
    });
  }

  @override
  void dispose() {
    subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_subtitle == null) {
      return SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      alignment: Alignment.bottomCenter,
      child: RoundedBackgroundText(
        _subtitle!.data,
        style: TextStyle(
          height: 1.4,
          fontSize: 32.0,
          letterSpacing: 0.0,
          wordSpacing: 0.0,
          color: Color(0xffffffff),
          fontWeight: FontWeight.normal,
        ),
        backgroundColor: Color(0xaa000000),
        textAlign: TextAlign.center,
      ),
    );
  }
}
