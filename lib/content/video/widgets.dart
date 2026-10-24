import 'dart:async';

import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/video_backend/video_backend.dart';

// Title
class MediaTitle extends ConsumerWidget {
  const MediaTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = videoContentController(context);
    final contentDetails = controller.contentDetails;
    final playlistSize = controller.mediaItems.length;

    final currentItem = ref
        .watch(collectionItemCurrentItemProvider(contentDetails))
        .value;

    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    var title = contentDetails.title;

    if (playlistSize > 1) {
      title += " - ${currentItem + 1} / $playlistSize";
    }

    return Expanded(
      child: Text(
        title,
        style: const TextStyle(
          height: 1.0,
          fontSize: 22.0,
          color: Colors.white,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class BufferingIndicator extends StatefulWidget {
  const BufferingIndicator({super.key});

  @override
  State<BufferingIndicator> createState() => _BufferingIndicatorState();
}

class _BufferingIndicatorState extends State<BufferingIndicator> {
  late bool _buffering = false;
  StreamSubscription? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = videoContentController(context);
    _buffering = controller.videoBackendState.showBuffering;
    _subscription?.cancel();
    _subscription = controller.videoBackendStateStream.listen((event) {
      if (_buffering != event.showBuffering) {
        setState(() {
          _buffering = event.showBuffering;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: _buffering ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 150),
        builder: (context, value, child) {
          if (value > 0.0) {
            return Opacity(opacity: value, child: child!);
          }
          return const SizedBox.shrink();
        },
        child: const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class PlaybackStateBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, VideoBackendState state) builder;

  const PlaybackStateBuilder({required this.builder});

  @override
  Widget build(BuildContext context) {
    final controller = videoContentController(context);
    return StreamBuilder<VideoBackendState>(
      stream: controller.videoBackendStateStream,
      initialData: controller.videoBackendState,
      builder: (context, snapshot) =>
          builder(context, snapshot.data ?? controller.videoBackendState),
    );
  }
}

class CircleBackdrop extends StatelessWidget {
  final Widget child;

  const CircleBackdrop({super.key, required this.child});

  static const _scrimColor = Color(0x99000000);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _scrimColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class SimpleVideoProgressIndicator extends StatelessWidget {
  final double height;

  const SimpleVideoProgressIndicator({super.key, this.height = 2.0});

  static const _barColor = Color(0x3DFFFFFF);

  double _fraction(Duration value, Duration total) {
    if (total.inMilliseconds <= 0) return 0.0;
    return (value.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return IgnorePointer(
      child: SizedBox(
        height: height,
        child: PlaybackStateBuilder(
          builder: (context, state) {
            final value = _fraction(state.position, state.duration);
            final buffered = _fraction(state.buffered, state.duration);

            return Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: _barColor),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: buffered,
                  child: const ColoredBox(color: _barColor),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: ColoredBox(color: primary),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
