import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:strumok/video_backend/video_backend.dart';
import 'package:subtitle/subtitle.dart';

class VideoSubtitles extends ConsumerWidget {
  const VideoSubtitles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitlesOffset = ref.watch(subtitlesOffsetProvider);

    return ValueListenableBuilder(
      valueListenable: videoContentController(context).subtitleController,
      builder: (context, asyncSubtitleController, _) {
        return asyncSubtitleController.when(
          data: (subtitleController) {
            if (subtitleController == null) {
              return SizedBox.shrink();
            }

            return PlayerSubtitleView(
              subtitleController: subtitleController,
              subtitlesOffset: subtitlesOffset,
            );
          },
          error: (e, _) => _SubtitleText(
            text: AppLocalizations.of(context)!.videoSubtitlesLoadingError,
          ),
          loading: () => _SubtitleText(
            text: AppLocalizations.of(context)!.videoSubtitlesLoading,
          ),
        );
      },
    );
  }
}

class PlayerSubtitleView extends StatefulWidget {
  final SubtitleController subtitleController;
  final Duration subtitlesOffset;

  const PlayerSubtitleView({
    super.key,
    required this.subtitleController,
    required this.subtitlesOffset,
  });

  @override
  State<PlayerSubtitleView> createState() => PlayerSubtitleViewState();
}

class PlayerSubtitleViewState extends State<PlayerSubtitleView> {
  static final _htmlCharsEntries = RegExp(r'&([^;]+);');

  StreamSubscription? _subscription;
  List<Subtitle> _subtitles = List.empty();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_subscription == null) {
      final controller = videoContentController(context);
      _subscription = controller.videoBackendStateStream.listen(
        _updateSubtitles,
      );

      _updateSubtitles(controller.videoBackendState, true);
    }
  }

  @override
  void didUpdateWidget(covariant PlayerSubtitleView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final controller = videoContentController(context);
    _updateSubtitles(controller.videoBackendState, true);
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  void _updateSubtitles(VideoBackendState state, [forceUpdate = false]) {
    final time = state.position + widget.subtitlesOffset;

    if (!forceUpdate && _subtitles.firstOrNull?.inRange(time) == true) {
      return;
    }

    final subs = widget.subtitleController.multiDurationSearch(time);
    setState(() {
      _subtitles = subs;
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

    return _SubtitleText(text: text);
  }
}

class _SubtitleText extends StatelessWidget {
  const _SubtitleText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: videoContentController(context).subtitlePaddings,
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.only(bottom: 16) + value,
          alignment: Alignment.bottomCenter,
          child: child!,
        );
      },
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
