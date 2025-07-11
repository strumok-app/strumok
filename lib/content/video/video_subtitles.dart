import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:subtitle/subtitle.dart';

class PlayerSubtitles extends ConsumerWidget {
  const PlayerSubtitles({super.key});

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
  static final _htmlCharsEntries = RegExp(r'&([^;]+);');
  StreamSubscription? _subscription;
  List<Subtitle> _subtitles = List.empty();

  @override
  void initState() {
    super.initState();

    _subscription = widget.player.stream.position.listen((position) {
      final time = position + widget.subtitlesOffset;

      if (_subtitles.firstOrNull?.inRange(time) == true) {
        return;
      }

      final subs = widget.subtitleController.multiDurationSearch(time);
      setState(() {
        _subtitles = subs;
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
    final subs = widget.subtitleController.multiDurationSearch(time);

    _subtitles = subs;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (_subtitles.isEmpty) {
      return SizedBox.shrink();
    }

    final text = _subtitles
        .map((s) => s.data)
        .nonNulls
        .join('\n')
        .replaceAllMapped(_htmlCharsEntries, (match) {
          return switch (match.group(1)) {
            'lt' => '<',
            'gt' => '>',
            'quot' => '"',
            _ => match.group(1) ?? '',
          };
        });

    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      alignment: Alignment.bottomCenter,
      child: RoundedBackgroundText(
        text,
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
