import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:strumok/video_backend/video_backend.dart';
import 'package:subtitle/subtitle.dart';

class VideoSubtitles extends ConsumerWidget {
  const VideoSubtitles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitlesOffset = ref.watch(subtitlesOffsetProvider);
    final subtitlesSize = ref.watch(subtitlesSizeSettingsProvider);

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
              subtitlesSize: subtitlesSize,
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
  final double subtitlesSize;

  const PlayerSubtitleView({
    super.key,
    required this.subtitleController,
    required this.subtitlesOffset,
    required this.subtitlesSize,
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

    return _SubtitleText(text: text, fontSize: widget.subtitlesSize);
  }
}

class _SubtitleText extends StatelessWidget {
  const _SubtitleText({required this.text, this.fontSize = 26.0});

  final String text;
  final double fontSize;

  double _fitFontSize(BuildContext context, double availableWidth) {
    final maximumWidth = availableWidth.clamp(80.0, double.infinity);
    var fittedSize = fontSize;

    while (fittedSize > 14.0) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            height: 1.4,
            fontSize: fittedSize,
            letterSpacing: 0.0,
            wordSpacing: 0.0,
            color: Color(0xffffffff),
            fontWeight: FontWeight.normal,
          ),
        ),
        textDirection: Directionality.of(context),
        textAlign: TextAlign.center,
        maxLines: 3,
        ellipsis: '…',
      )..layout(maxWidth: maximumWidth);

      final exceedsWidth = painter.maxIntrinsicWidth > maximumWidth;
      final exceedsLines = painter.didExceedMaxLines;
      if (!exceedsWidth && !exceedsLines) {
        return fittedSize;
      }

      fittedSize -= 1.0;
    }

    return 14.0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: videoContentController(context).subtitlePaddings,
      builder: (context, value, child) {
        print('Subtitle paddings: $value');
        return Container(
          padding: const EdgeInsets.only(bottom: 16) + value,
          alignment: Alignment.bottomCenter,
          child: child!,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth == double.infinity
              ? MediaQuery.sizeOf(context).width * 0.9
              : constraints.maxWidth * 0.9;
          final effectiveFontSize = _fitFontSize(context, availableWidth);

          return RoundedBackgroundText(
            text,
            maxLines: 3,
            ellipsis: '…',
            style: TextStyle(
              height: 1.4,
              fontSize: effectiveFontSize,
              letterSpacing: 0.0,
              wordSpacing: 0.0,
              color: Color(0xffffffff),
              fontWeight: FontWeight.normal,
            ),
            backgroundColor: Color(0xaa000000),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}
