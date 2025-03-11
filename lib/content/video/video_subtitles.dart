import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:strumok/content/video/video_content_view.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:subtitle/subtitle.dart';

class WithSubtitles extends ConsumerWidget {
  final Widget child;
  final PlayerController playerController;

  const WithSubtitles({
    super.key,
    required this.playerController,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(children: [Positioned.fill(child: _PlayerSubtitles()), child]);
  }
}

class _PlayerSubtitles extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleController = ref.watch(currentSubtitleControllerProvider);
    final subtitlesOffset = ref.watch(subtitlesOffsetProvider);

    if (subtitleController == null) {
      return SizedBox.expand();
    }

    return _SubtitleView(
      player: controller(context).player,
      subtitleController: subtitleController,
      subtitlesOffset: subtitlesOffset,
    );
  }
}

class _SubtitleView extends StatefulWidget {
  final Player player;
  final SubtitleController subtitleController;
  final Duration subtitlesOffset;

  const _SubtitleView({
    required this.player,
    required this.subtitleController,
    required this.subtitlesOffset,
  });

  @override
  State<_SubtitleView> createState() => _SubtitleViewState();
}

class _SubtitleViewState extends State<_SubtitleView> {
  StreamSubscription? _subscription;
  Subtitle? _subtitle;

  @override
  void initState() {
    super.initState();

    _subscription = widget.player.stream.position.listen((position) {
      final time = position + widget.subtitlesOffset;

      if (_subtitle?.inRange(time) == true) {
        return;
      }

      final sub = widget.subtitleController.durationSearch(time);

      setState(() {
        _subtitle = sub;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SubtitleView oldWidget) {
    final time = widget.player.state.position + widget.subtitlesOffset;
    final sub = widget.subtitleController.durationSearch(time);

    _subtitle = sub;

    super.didUpdateWidget(oldWidget);
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
