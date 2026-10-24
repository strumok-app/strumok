import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:strumok/content/video/pip/pip.dart';
import 'package:window_manager/window_manager.dart';

void _closePlayerAndApp(WidgetRef ref) {
  ref.read(videoPlayerProvider.notifier).dispose();
  Pip.instance.closeApp();
}

/// Keeps platform PIP in sync with the player and handles platform PIP actions.
class VideoPipBinding extends ConsumerStatefulWidget {
  final VideoPlayerController controller;
  final Widget child;

  const VideoPipBinding({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  ConsumerState<VideoPipBinding> createState() => _VideoPipBindingState();
}

class _VideoPipBindingState extends ConsumerState<VideoPipBinding> {
  StreamSubscription<PipAction>? _actionsSubscription;
  StreamSubscription? _playerSubscription;
  PipPlaybackState? _lastState;

  @override
  void initState() {
    super.initState();
    _actionsSubscription = Pip.instance.actions.listen(_onAction);
    _subscribePlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didUpdateWidget(covariant VideoPipBinding oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _subscribePlayer();
      _sync();
    }
  }

  @override
  void dispose() {
    _actionsSubscription?.cancel();
    _playerSubscription?.cancel();
    // Prevents auto enter with stale playing state.
    Pip.instance.updatePlayback(const PipPlaybackState());
    super.dispose();
  }

  void _subscribePlayer() {
    _playerSubscription?.cancel();
    _playerSubscription = widget.controller.videoBackendStateStream.listen(
      (_) => _sync(),
    );
  }

  void _onAction(PipAction action) {
    final controller = widget.controller;
    switch (action) {
      case PipAction.playPause:
        controller.playOrPause();
      case PipAction.next:
        controller.nextItem();
      case PipAction.prev:
        controller.prevItem();
      case PipAction.dismissed:
        controller.pause();
    }
  }

  void _sync() {
    if (!mounted) return;

    final controller = widget.controller;
    final playerState = controller.videoBackendState;
    final itemsCount = controller.mediaItems.length;
    final currentItem = ref
        .read(collectionItemCurrentItemProvider(controller.contentDetails))
        .value;
    final shuffleMode = ref.read(shuffleModeSettingsProvider);

    final state = PipPlaybackState(
      isPlaying: playerState.isPlaying,
      showSkipButtons: itemsCount > 1,
      hasPrev: currentItem != null && currentItem > 0 && !shuffleMode,
      hasNext:
          currentItem != null && (currentItem < itemsCount - 1 || shuffleMode),
      aspectRatio: playerState.isInitialized ? playerState.aspectRatio : 16 / 9,
    );

    if (state == _lastState) return;
    _lastState = state;
    Pip.instance.updatePlayback(state);
  }

  @override
  Widget build(BuildContext context) {
    final contentDetails = widget.controller.contentDetails;
    ref.listen(
      collectionItemCurrentItemProvider(contentDetails),
      (_, _) => _sync(),
    );
    ref.listen(shuffleModeSettingsProvider, (_, _) => _sync());

    return widget.child;
  }
}

class PipButton extends StatelessWidget {
  final double? iconSize;

  const PipButton({super.key, this.iconSize});

  @override
  Widget build(BuildContext context) {
    if (!Pip.instance.isSupported) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: Pip.instance.enter,
      icon: const Icon(Icons.picture_in_picture_alt),
      iconSize: iconSize,
      color: Colors.white,
    );
  }
}

/// Controls shown while the app is in PIP mode.
///
/// Platforms with system drawn PIP controls (Android) don't pass input to
/// the app, so [interactive] is disabled there and only the video is shown.
class PipVideoControls extends StatefulWidget {
  final bool interactive;

  const PipVideoControls({super.key, required this.interactive});

  @override
  State<PipVideoControls> createState() => _PipVideoControlsState();
}

class _PipVideoControlsState extends State<PipVideoControls> {
  static const _hideDelay = Duration(seconds: 2);
  static const _fadeDuration = Duration(milliseconds: 200);

  bool _uiVisible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    // Controls of the regular player may have shifted subtitles up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        videoContentController(context).subtitlePaddings.value =
            EdgeInsets.zero;
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showUI() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDelay, _hideUI);
    if (!_uiVisible) {
      setState(() => _uiVisible = true);
    }
  }

  void _hideUI() {
    _hideTimer?.cancel();
    if (mounted && _uiVisible) {
      setState(() => _uiVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.interactive) {
      return const IgnorePointer(child: BufferingIndicator());
    }

    final controller = videoContentController(context);
    final showSkipButtons = controller.mediaItems.length > 1;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          controller.playOrPause();
          _showUI();
        },
        const SingleActivator(LogicalKeyboardKey.escape): Pip.instance.exit,
      },
      child: Focus(
        autofocus: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) => windowManager.startDragging(),
          onTap: _showUI,
          child: MouseRegion(
            onEnter: (_) => _showUI(),
            onHover: (_) => _showUI(),
            onExit: (_) => _hideUI(),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: IgnorePointer(child: BufferingIndicator()),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !_uiVisible,
                    child: AnimatedOpacity(
                      opacity: _uiVisible ? 1.0 : 0.0,
                      duration: _fadeDuration,
                      child: Listener(
                        onPointerDown: (_) => _showUI(),
                        child: _PipControlsOverlay(
                          showSkipButtons: showSkipButtons,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PipControlsOverlay extends StatelessWidget {
  final bool showSkipButtons;

  const _PipControlsOverlay({required this.showSkipButtons});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black45,
      child: Stack(
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showSkipButtons) ...const [
                  SkipPrevButton(iconSize: 32),
                  SizedBox(width: 16),
                ],
                const PlayOrPauseButton(iconSize: 48),
                if (showSkipButtons) ...const [
                  SizedBox(width: 16),
                  SkipNextButton(iconSize: 32),
                ],
              ],
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: IconButton(
              color: Colors.white,
              onPressed: Pip.instance.exit,
              icon: const Icon(Icons.pin_end),
            ),
          ),
          const Positioned(top: 4, right: 4, child: _PipCloseButton()),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: SimpleVideoProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

class _PipCloseButton extends ConsumerWidget {
  const _PipCloseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      color: Colors.white,
      onPressed: () => _closePlayerAndApp(ref),
      icon: const Icon(Icons.close),
    );
  }
}
