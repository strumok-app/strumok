import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

// Modified version of: https://github.com/yakagami/zoom_view

/// A controller for a [ZoomView] that allows programmatic control over the zoom level.
class ZoomViewController {
  _ZoomViewState? _state;

  void _attach(_ZoomViewState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  /// Whether the controller is currently attached to a [ZoomView].
  bool get isAttached => _state != null;

  /// The current scale of the attached [ZoomView].
  double get scale {
    if (!isAttached) return 1.0;
    return 1 / _state!._scale;
  }

  /// Returns the current [DragMode] of the [ZoomView]. When [ZoomView.onScaleEnd]
  /// is called, this will be the DragMode of the last gesture.
  DragMode get dragMode {
    if (!isAttached) {
      throw ("Controler is not attached to a ZoomView");
    }
    return _state!._dragMode;
  }

  /// Sets the scale of the attached [ZoomView].
  void setScale(double newScale, {Offset? focalPoint}) {
    if (!isAttached) return;
    final state = _state!;
    if (!state.mounted) return;
    final widget = state.widget;

    final size = state.context.size;
    if (size == null) return;
    final double height = size.height;
    final double width = size.width;

    final focus = focalPoint ?? Offset(width / 2, height / 2);

    final clampedUserScale = _clampDouble(
      newScale,
      widget.minScale,
      widget.maxScale,
    );
    final internalNewScale = 1 / clampedUserScale;
    final double currentInternalScale = state._scale;

    final effectiveHorizontalPixels = currentInternalScale > 1.0
        ? -(width * currentInternalScale - width) / 2.0
        : state._horizontalController.position.pixels;

    final effectiveVerticalPixels = state._verticalController.position.pixels;

    final newHorizontalPixels =
        effectiveHorizontalPixels +
        (currentInternalScale - internalNewScale) * focus.dx;
    final newVerticalPixels =
        effectiveVerticalPixels +
        (currentInternalScale - internalNewScale) * focus.dy;

    state._updateScale(internalNewScale);
    state._verticalController.jumpTo(newVerticalPixels);
    state._horizontalController.jumpTo(newHorizontalPixels);
    state._updateLastScale(internalNewScale);
  }

  /// Sets the scale of the attached [ZoomView] to a new value with an animation.
  void setScaleWithAnimation(
    double newScale, {
    Duration duration = const Duration(milliseconds: 150),
    Offset? focalPoint,
  }) {
    if (!isAttached) return;
    final state = _state!;
    if (!state.mounted) return;
    final widget = state.widget;

    final size = state.context.size;
    if (size == null) return;
    final double height = size.height;
    final double width = size.width;

    final focus = focalPoint ?? Offset(width / 2, height / 2);

    final clampedUserScale = _clampDouble(
      newScale,
      widget.minScale,
      widget.maxScale,
    );
    final internalNewScale = 1 / clampedUserScale;
    final double initialInternalScale = state._scale;

    if (duration <= Duration.zero) {
      setScale(newScale, focalPoint: focalPoint);
      return;
    }

    state._masterAnimationController.stop();
    state._masterAnimationController.duration = duration;

    final scaleAnimation =
        Tween<double>(
          begin: initialInternalScale,
          end: internalNewScale,
        ).animate(
          CurvedAnimation(
            parent: state._masterAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    double currentEffectiveHorizontalPixels = initialInternalScale > 1.0
        ? -(width * initialInternalScale - width) / 2.0
        : state._horizontalController.position.pixels;

    double currentEffectiveVerticalPixels =
        state._verticalController.position.pixels;
    bool firstFrame = true;
    bool secondFrame = false;
    void listener() {
      final double newAnimatedInternalScale = scaleAnimation.value;
      final double previousAnimatedInternalScale = state._scale;

      currentEffectiveHorizontalPixels +=
          (previousAnimatedInternalScale - newAnimatedInternalScale) * focus.dx;
      currentEffectiveVerticalPixels +=
          (previousAnimatedInternalScale - newAnimatedInternalScale) * focus.dy;
      state._updateScale(newAnimatedInternalScale);

      if (!firstFrame && !secondFrame) {
        state._verticalController.jumpTo(currentEffectiveVerticalPixels);
        state._horizontalController.jumpTo(currentEffectiveHorizontalPixels);
      }
      if (secondFrame) {
        secondFrame = false;
      }
      if (firstFrame) {
        //the first and second frame jumps have the same value,
        // so we only play the first frame but on the second tick,
        // otherwise the view crashes into the viewport and flickers
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.mounted) {
            state._verticalController.jumpTo(currentEffectiveVerticalPixels);
            state._horizontalController.jumpTo(
              currentEffectiveHorizontalPixels,
            );
          }
        });
        secondFrame = true;
      }
      firstFrame = false;
    }

    state._masterAnimationController.addListener(listener);

    void statusListener(status) {
      if (status == AnimationStatus.completed) {
        //ensure final value is correct
        setScale(1 / internalNewScale, focalPoint: focus);
        state._updateLastScale(internalNewScale);
        state._masterAnimationController.removeStatusListener(statusListener);
        state._masterAnimationController.removeListener(listener);
      }
    }

    state._masterAnimationController.addStatusListener(statusListener);
    state._masterAnimationController.forward(from: 0.0);
  }
}

enum DragMode { pan, doubleTapDrag, pinchScale, none }

///Details for the [ZoomView.onScaleEnd] callback.
final class ZoomViewScaleEndDetails {
  ///The number of pointers that were on the screen when the scale gesture ended.
  final int pointerCount;

  ///The final scale of the [ZoomView] when the gesture ended.
  final double scale;

  ZoomViewScaleEndDetails({required this.pointerCount, required this.scale});
}

///Allows a ListView or other Scrollables that implement ScrollPosition and
///jumpTo(offset) in their controller to be zoomed and scrolled.
class ZoomView extends StatefulWidget {
  const ZoomView({
    super.key,
    required this.child,
    required this.controller,
    this.zoomViewController,
    this.maxScale = 4.0,
    this.minScale = 1.0,
    this.onDoubleTap,
    this.onTap,
    this.scrollAxis = Axis.vertical,
    this.doubleTapDrag = false,
    this.forceHoldOnPointerDown = false,
    this.onScaleChanged,
    this.onScaleEnd,
  });

  /// Callback invoked after a tap.
  final void Function()? onTap;

  /// Callback invoked after a double tap.
  /// The [TapDownDetails] from the gesture are provided.
  /// This is commonly used with [ZoomViewGestureHandler.onDoubleTap].
  final void Function(TapDownDetails details)? onDoubleTap;
  final Widget child;
  final ScrollController controller;

  /// A controller to programmatically control the zoom level.
  final ZoomViewController? zoomViewController;

  ///scrollAxis must be set to Axis.horizontal if the Scrollable is horizontal
  final Axis scrollAxis;

  ///The maximum scale that the ZoomView can be zoomed to. Set to double.infinity to allow infinite zoom in
  final double maxScale;

  ///The minimum scale that the ZoomView can be zoomed to. Set to 0 to allow infinite zoom out
  final double minScale;

  ///If true, enables double tap dragging to zoom.
  final bool doubleTapDrag;

  ///Forces the vertical and horizontal scrollables to stop panning any time
  ///a pointer touches the screen. This is needed when the Scale gesture does
  ///not automatically win the arena and the scrollables are still scrolling
  ///from a previous fling gesture.
  final bool forceHoldOnPointerDown;

  ///Callback invoked any time the scale of the [ZoomView] changes.
  final void Function(double scale)? onScaleChanged;

  ///Callback invoked when a scale gesture ends.
  final void Function(ZoomViewScaleEndDetails details)? onScaleEnd;

  @override
  State<ZoomView> createState() => _ZoomViewState();
}

class _ZoomViewState extends State<ZoomView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    if (widget.scrollAxis == Axis.vertical) {
      _verticalController = widget.controller;
      _horizontalController = ScrollController();
    } else {
      _verticalController = ScrollController();
      _horizontalController = widget.controller;
    }
    _verticalTouchHandler = _TouchHandler(controller: _verticalController);
    _horizontalTouchHandler = _TouchHandler(controller: _horizontalController);

    _masterAnimationController = AnimationController(vsync: this);

    _maxScale = 1 / widget.maxScale;
    _minScale = 1 / widget.minScale;

    widget.zoomViewController?._attach(this);
  }

  @override
  void didUpdateWidget(ZoomView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.zoomViewController != oldWidget.zoomViewController) {
      oldWidget.zoomViewController?._detach();
      widget.zoomViewController?._attach(this);
    }
  }

  @override
  void dispose() {
    _masterAnimationController.dispose();
    if (widget.scrollAxis == Axis.vertical) {
      _horizontalController.dispose();
    } else {
      _verticalController.dispose();
    }
    widget.zoomViewController?._detach();
    super.dispose();
  }

  ///The current scale of the ZoomView
  double _scale = 1;

  ///The scale of the ZoomView before the last scale update event
  double _lastScale = 1;

  ///Used for trackpad pointerEvents to determine if the user is panning or scaling
  late TrackPadState _trackPadState;

  ///Total distance the trackpad has moved vertically since the last scale start event
  Size _globalTrackpadDistance = Size.zero;

  late final AnimationController _masterAnimationController;

  late final ScrollController _verticalController;
  late final ScrollController _horizontalController;

  late final _TouchHandler _verticalTouchHandler;
  late final _TouchHandler _horizontalTouchHandler;

  late final double _maxScale;
  late final double _minScale;

  Offset? _previousDragPosition;

  DragMode _dragMode = DragMode.none;

  late TapDownDetails _tapDownDetails;

  final VelocityTracker _tracker = VelocityTracker.withKind(
    PointerDeviceKind.touch,
  );

  ///The focal point of pointers at the start of a scale event
  late Offset _localFocalPoint;

  void _updateScale(double scale) {
    setState(() {
      _scale = scale;
    });
    widget.onScaleChanged?.call(1 / scale);
  }

  void _updateLastScale(double scale) {
    setState(() {
      _lastScale = scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double height = constraints.maxHeight;
        double width = constraints.maxWidth;
        //The listener is needed to determine the input type
        //and for forceHoldOnPointerDown and for reseting the DragMode.
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerUp: (PointerUpEvent event) {
            _dragMode = DragMode.none;
          },
          onPointerDown: widget.forceHoldOnPointerDown
              ? (_) {
                  if (widget.forceHoldOnPointerDown) {
                    _verticalController.position.hold(() {});
                    _horizontalController.position.hold(() {});
                  }
                }
              : null,
          onPointerPanZoomStart: widget.forceHoldOnPointerDown
              ? (_) {
                  _verticalController.position.hold(() {});
                  _horizontalController.position.hold(() {});
                }
              : null,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onScaleStart: (ScaleStartDetails details) {
              _masterAnimationController.stop();
              _trackPadState = details.kind == PointerDeviceKind.trackpad
                  ? TrackPadState.waiting
                  : TrackPadState.none;
              if (details.pointerCount == 1) {
                DragStartDetails dragDetails = DragStartDetails(
                  globalPosition: details.focalPoint,
                  kind: PointerDeviceKind.touch,
                );
                _verticalTouchHandler.handleDragStart(dragDetails);
                _horizontalTouchHandler.handleDragStart(dragDetails);
              } else {
                _localFocalPoint = details.localFocalPoint;
              }
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              if (_dragMode == DragMode.none) {
                if (_trackPadState == TrackPadState.waiting) {
                  if (details.scale != 1.0) {
                    _trackPadState = TrackPadState.scale;
                    _dragMode = DragMode.pinchScale;
                  } else {
                    _globalTrackpadDistance += details.focalPointDelta * _scale;
                    if (_globalTrackpadDistance.longestSide >
                        kPrecisePointerPanSlop) {
                      _trackPadState = TrackPadState.pan;
                      _dragMode = DragMode.pan;
                      DragStartDetails dragDetails = DragStartDetails(
                        globalPosition: details.focalPoint,
                        kind: PointerDeviceKind.touch,
                      );
                      _verticalTouchHandler.handleDragStart(dragDetails);
                      _horizontalTouchHandler.handleDragStart(dragDetails);
                    }
                  }
                } else if (details.pointerCount > 1) {
                  _dragMode = DragMode.pinchScale;
                } else {
                  _dragMode = DragMode.pan;
                }
              }
              switch (_dragMode) {
                case DragMode.doubleTapDrag:
                  final currentDragPosition = details.localFocalPoint;
                  final double dx =
                      (_previousDragPosition!.dx - currentDragPosition.dx);
                  double dy =
                      (_previousDragPosition!.dy - currentDragPosition.dy);

                  if (dx.abs() > dy.abs()) {
                    // Ignore horizontal drags
                    return;
                  }
                  final newScale = _clampDouble(
                    //divided by 2 so that dragging from the middle of the screen
                    //to the bottom results in 2x scale
                    _lastScale + (dy / (height / 2)),
                    _maxScale,
                    _minScale,
                  );
                  final verticalOffset =
                      _verticalController.position.pixels +
                      (_scale - newScale) * details.localFocalPoint.dy;
                  final horizontalOffset =
                      _horizontalController.position.pixels +
                      (_scale - newScale) * details.localFocalPoint.dx;

                  _updateScale(newScale);

                  _verticalController.jumpTo(verticalOffset);
                  _horizontalController.jumpTo(horizontalOffset);
                case DragMode.pan:
                  final correctedDelta = details.focalPointDelta * _scale;
                  final correctedOffset = details.focalPoint * _scale;
                  final time = details.sourceTimeStamp!;
                  _tracker.addPosition(time, correctedOffset);
                  final DragUpdateDetails verticalDetails = DragUpdateDetails(
                    globalPosition: correctedOffset,
                    sourceTimeStamp: time,
                    primaryDelta: correctedDelta.dy,
                    delta: Offset(0.0, correctedDelta.dy),
                  );
                  final DragUpdateDetails horizontalDetails = DragUpdateDetails(
                    globalPosition: correctedOffset,
                    sourceTimeStamp: time,
                    primaryDelta: correctedDelta.dx,
                    delta: Offset(correctedDelta.dx, 0.0),
                  );
                  _verticalTouchHandler.handleDragUpdate(verticalDetails);
                  _horizontalTouchHandler.handleDragUpdate(horizontalDetails);
                case DragMode.pinchScale:
                  final newScale = _clampDouble(
                    _lastScale / details.scale,
                    _maxScale,
                    _minScale,
                  );
                  final verticalOffset =
                      _verticalController.position.pixels +
                      (_scale - newScale) * _localFocalPoint.dy;
                  final horizontalOffset =
                      _horizontalController.position.pixels +
                      (_scale - newScale) * _localFocalPoint.dx;
                  //This is the main logic to actually perform the scaling
                  _updateScale(newScale);
                  _verticalController.jumpTo(verticalOffset);
                  _horizontalController.jumpTo(horizontalOffset);
                case DragMode.none:
                // do nothing
              }
            },
            onScaleEnd: (ScaleEndDetails details) {
              _trackPadState = TrackPadState.none;
              _globalTrackpadDistance = Size.zero;
              _lastScale = _scale;
              _previousDragPosition = null;

              Offset velocity = _tracker.getVelocity().pixelsPerSecond;
              DragEndDetails endDetails = DragEndDetails(
                velocity: Velocity(pixelsPerSecond: Offset(0.0, velocity.dy)),
                primaryVelocity: velocity.dy,
              );
              DragEndDetails hEndDetails = DragEndDetails(
                velocity: Velocity(pixelsPerSecond: Offset(velocity.dx, 0.0)),
                primaryVelocity: velocity.dx,
              );
              _verticalTouchHandler.handleDragEnd(endDetails);
              _horizontalTouchHandler.handleDragEnd(hEndDetails);
              widget.onScaleEnd?.call(
                ZoomViewScaleEndDetails(
                  pointerCount: details.pointerCount,
                  scale: 1 / _scale,
                ),
              );
              _dragMode = DragMode.none;
            },
            onTap: widget.onTap,
            onDoubleTapDown:
                widget.onDoubleTap == null && widget.doubleTapDrag == false
                ? null
                : (TapDownDetails details) {
                    if (widget.doubleTapDrag) {
                      _dragMode = DragMode.doubleTapDrag;
                      _previousDragPosition = details.localPosition;
                    }
                    _tapDownDetails = details;
                  },
            onDoubleTap: widget.onDoubleTap == null
                ? null
                : () {
                    _dragMode = DragMode.pan;
                    widget.onDoubleTap!(_tapDownDetails);
                  },
            child: Column(
              children: [
                Expanded(
                  //When scale decreases, the SizedBox will shrink and the FittedBox
                  //will scale the child to fit the maximum constraints of the ZoomView
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      height: height * _scale,
                      width: width * _scale,
                      child: Center(
                        child: ScrollConfiguration(
                          behavior: const ScrollBehavior().copyWith(
                            overscroll: false,
                            //Disable all inputs on the list as we will handle them
                            //ourselves using the gesture detector and scroll controllers
                            dragDevices: <PointerDeviceKind>{},
                            scrollbars: false,
                          ),
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            controller: widget.scrollAxis == Axis.vertical
                                ? _horizontalController
                                : _verticalController,
                            scrollDirection: widget.scrollAxis == Axis.vertical
                                ? Axis.horizontal
                                : Axis.vertical,
                            child: SizedBox(
                              width: widget.scrollAxis == Axis.vertical
                                  ? width
                                  : null,
                              height: widget.scrollAxis == Axis.vertical
                                  ? null
                                  : height,
                              child: widget.child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// keeps record of the state of a trackpad. Should be set to none if
/// the PointerDeviceKind is not a trackpad
enum TrackPadState { none, waiting, pan, scale }

/// Handles the logic for a double tap zoom.
/// This should be used with the [ZoomView.onDoubleTap] callback.
final class ZoomViewGestureHandler {
  int _index = 0;
  final List<double> zoomLevels;
  final Duration duration;
  final ZoomViewController controller;

  /// Creates a handler for double tap gestures.
  ///
  /// [controller] is the [ZoomViewController] that this handler will control.
  /// [zoomLevels] is a list of zoom scales to cycle through on each double tap.
  /// [duration] is the animation duration for the zoom.
  ZoomViewGestureHandler({
    required this.controller,
    required this.zoomLevels,
    this.duration = const Duration(milliseconds: 150),
  });

  /// The method to be passed to [ZoomView.onDoubleTap].
  void onDoubleTap(TapDownDetails details) {
    if (!controller.isAttached) return;

    final currentScale = controller.scale;
    late double newScale;

    if (currentScale < 1.0) {
      newScale = 1.0;
      _index = 0;
    } else {
      newScale = zoomLevels[_index];
      _index++;
      if (_index >= zoomLevels.length) {
        _index = 0;
      }
    }

    final focalPoint = details.localPosition;

    if (duration > Duration.zero) {
      controller.setScaleWithAnimation(
        newScale,
        duration: duration,
        focalPoint: focalPoint,
      );
    } else {
      controller.setScale(newScale, focalPoint: focalPoint);
    }
  }
}

/// Touch handlers copied from Flutter ScrollableState
final class _TouchHandler {
  final ScrollController controller;
  _TouchHandler({required this.controller});
  Drag? _drag;
  ScrollHoldController? _hold;

  void handleDragDown(DragDownDetails details) {
    assert(_drag == null);
    assert(_hold == null);
    _hold = controller.position.hold(disposeHold);
  }

  void handleDragStart(DragStartDetails details) {
    assert(_drag == null);
    _drag = controller.position.drag(details, disposeDrag);
    assert(_drag != null);
    assert(_hold == null);
  }

  void handleDragUpdate(DragUpdateDetails details) {
    assert(_hold == null || _drag == null);
    _drag?.update(details);
  }

  void handleDragEnd(DragEndDetails details) {
    assert(_hold == null || _drag == null);
    _drag?.end(details);
    assert(_drag == null);
  }

  void handleDragCancel() {
    assert(_hold == null || _drag == null);
    _hold?.cancel();
    _drag?.cancel();
    assert(_hold == null);
    assert(_drag == null);
  }

  void disposeHold() {
    _hold = null;
  }

  void disposeDrag() {
    _drag = null;
  }
}

double _clampDouble(double x, double min, double max) {
  if (x < min) {
    return min;
  }
  if (x > max) {
    return max;
  }
  return x;
}
