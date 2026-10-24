import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:strumok/content/video/subtitles/subtitle_track.dart';
import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:strumok/video_backend/video_backend.dart';

/// Subtitles overlay. In views narrower than [_minLayoutWidth] (PIP, floating
/// player) subtitles are laid out as on a wider screen and scaled down to fit.
class VideoSubtitles extends StatelessWidget {
  static const _minLayoutWidth = 640.0;

  const VideoSubtitles({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (!width.isFinite ||
            !height.isFinite ||
            height <= 0 ||
            width >= _minLayoutWidth) {
          return const _VideoSubtitlesContent();
        }

        final scale = width / _minLayoutWidth;
        return FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: _minLayoutWidth,
            height: height / scale,
            child: const _VideoSubtitlesContent(),
          ),
        );
      },
    );
  }
}

class _VideoSubtitlesContent extends ConsumerWidget {
  const _VideoSubtitlesContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitlesOffset = ref.watch(subtitlesOffsetProvider);
    final subtitlesSize = ref.watch(subtitlesSizeSettingsProvider);

    return ValueListenableBuilder(
      valueListenable: videoContentController(context).subtitleTrack,
      builder: (context, asyncSubtitleTrack, _) {
        return asyncSubtitleTrack.when(
          data: (subtitleTrack) {
            if (subtitleTrack == null || subtitleTrack.isEmpty) {
              return SizedBox.shrink();
            }

            return PlayerSubtitleView(
              subtitleTrack: subtitleTrack,
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
  final SubtitleTrack subtitleTrack;
  final Duration subtitlesOffset;
  final double subtitlesSize;

  const PlayerSubtitleView({
    super.key,
    required this.subtitleTrack,
    required this.subtitlesOffset,
    required this.subtitlesSize,
  });

  @override
  State<PlayerSubtitleView> createState() => PlayerSubtitleViewState();
}

class PlayerSubtitleViewState extends State<PlayerSubtitleView> {
  StreamSubscription? _subscription;
  List<SubtitleCue> _cues = List.empty();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_subscription == null) {
      final controller = videoContentController(context);
      _subscription = controller.videoBackendStateStream.listen(
        _onBackendState,
      );

      _cues = _cuesAt(controller.videoBackendState);
    }
  }

  @override
  void didUpdateWidget(covariant PlayerSubtitleView oldWidget) {
    super.didUpdateWidget(oldWidget);

    _cues = _cuesAt(videoContentController(context).videoBackendState);
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  List<SubtitleCue> _cuesAt(VideoBackendState state) {
    return widget.subtitleTrack.cuesAt(state.position + widget.subtitlesOffset);
  }

  void _onBackendState(VideoBackendState state) {
    final cues = _cuesAt(state);
    if (!mounted || listEquals(cues, _cues)) {
      return;
    }

    setState(() {
      _cues = cues;
    });
  }

  static String _joinCues(Iterable<SubtitleCue> cues) {
    // Set keeps order and drops duplicated overlapping cues.
    return cues.map((c) => c.text).toSet().join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final bottomText = _joinCues(_cues.where((c) => !c.alignTop));
    final topText = _joinCues(_cues.where((c) => c.alignTop));

    final bottom = bottomText.isEmpty
        ? null
        : _SubtitleText(text: bottomText, fontSize: widget.subtitlesSize);
    final top = topText.isEmpty
        ? null
        : _SubtitleText(
            text: topText,
            fontSize: widget.subtitlesSize,
            alignTop: true,
          );

    if (top == null || bottom == null) {
      return top ?? bottom ?? SizedBox.shrink();
    }

    return Stack(fit: StackFit.expand, children: [top, bottom]);
  }
}

class _SubtitleText extends StatelessWidget {
  const _SubtitleText({
    required this.text,
    this.fontSize = 26.0,
    this.alignTop = false,
  });

  final String text;
  final double fontSize;
  final bool alignTop;

  TextStyle _textStyle(double fontSize) => TextStyle(
    height: 1.4,
    fontSize: fontSize,
    letterSpacing: 0.0,
    wordSpacing: 0.0,
    color: Color(0xffffffff),
    fontWeight: FontWeight.normal,
  );

  double _fitFontSize(TextDirection textDirection, double availableWidth) {
    final maximumWidth = availableWidth.clamp(80.0, double.infinity);
    var fittedSize = fontSize;

    while (fittedSize > 14.0) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: _textStyle(fittedSize)),
        textDirection: textDirection,
        textAlign: TextAlign.center,
        maxLines: 3,
        ellipsis: '…',
      )..layout(maxWidth: maximumWidth);

      final exceedsWidth = painter.maxIntrinsicWidth > maximumWidth;
      final exceedsLines = painter.didExceedMaxLines;
      painter.dispose();

      if (!exceedsWidth && !exceedsLines) {
        return fittedSize;
      }

      fittedSize -= 1.0;
    }

    return 14.0;
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;

    return ValueListenableBuilder(
      valueListenable: videoContentController(context).subtitlePaddings,
      builder: (context, value, child) {
        return Container(
          padding: alignTop
              ? EdgeInsets.fromLTRB(value.left, 16 + value.top, value.right, 0)
              : const EdgeInsets.only(bottom: 16) + value,
          alignment: alignTop ? Alignment.topCenter : Alignment.bottomCenter,
          child: child!,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth == double.infinity
              ? MediaQuery.sizeOf(context).width * 0.9
              : constraints.maxWidth * 0.9;

          final effectiveFontSize = _fitFontSize(textDirection, availableWidth);

          return RoundedBackgroundText(
            text,
            maxLines: 3,
            ellipsis: '…',
            innerRadius: 0,
            style: _textStyle(effectiveFontSize),
            backgroundColor: Color(0xaa000000),
            textAlign: TextAlign.center,
            textDirection: textDirection,
          );
        },
      ),
    );
  }
}
