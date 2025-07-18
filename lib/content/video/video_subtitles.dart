import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:subtitle/subtitle.dart';

class PlayerSubtitles extends ConsumerWidget {
  const PlayerSubtitles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSubtitleController = ref.watch(
      currentSubtitleControllerProvider,
    );
    final subtitlesOffset = ref.watch(subtitlesOffsetProvider);

    return asyncSubtitleController.when(
      data: (subtitleController) {
        if (subtitleController == null) {
          return SizedBox.shrink();
        }

        return PlayerSubtitleView(
          player: controller(context).player,
          subtitleController: subtitleController,
          subtitlesOffset: subtitlesOffset,
        );
      },
      error: (_, _) => _SubtitleText(
        text: AppLocalizations.of(context)!.videoSubtitlesLoadingError,
      ),
      loading: () => _SubtitleText(
        text: AppLocalizations.of(context)!.videoSubtitlesLoading,
      ),
    );
  }
}

class PlayerSubtitleView extends StatefulWidget {
  static final _key = GlobalKey<PlayerSubtitleViewState>();

  final Player player;
  final SubtitleController subtitleController;
  final Duration subtitlesOffset;

  static set paddings(EdgeInsets padding) {
    _key.currentState?.setPaddings(padding);
  }

  PlayerSubtitleView({
    required this.player,
    required this.subtitleController,
    required this.subtitlesOffset,
  }) : super(key: _key);

  @override
  State<PlayerSubtitleView> createState() => PlayerSubtitleViewState();
}

class PlayerSubtitleViewState extends State<PlayerSubtitleView> {
  static final _htmlCharsEntries = RegExp(r'&([^;]+);');

  EdgeInsets _paddings = EdgeInsets.zero;
  StreamSubscription? _subscription;
  List<Subtitle> _subtitles = List.empty();

  @override
  void initState() {
    super.initState();

    _subscription = widget.player.stream.position.listen(_updateSubtitles);

    _updateSubtitles(widget.player.state.position);
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlayerSubtitleView oldWidget) {
    _updateSubtitles(widget.player.state.position);

    super.didUpdateWidget(oldWidget);
  }

  void _updateSubtitles(Duration position) {
    final time = position + widget.subtitlesOffset;

    if (_subtitles.firstOrNull?.inRange(time) == true) {
      return;
    }

    final subs = widget.subtitleController.multiDurationSearch(time);
    setState(() {
      _subtitles = subs;
    });
  }

  void setPaddings(EdgeInsets padding) {
    setState(() {
      _paddings = padding;
    });
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

    return Padding(
      padding: _paddings,
      child: _SubtitleText(text: text),
    );
  }
}

class _SubtitleText extends StatelessWidget {
  const _SubtitleText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
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
