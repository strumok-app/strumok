import 'package:strumok/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// ignore: must_be_immutable
class HorizontalListCard extends HookWidget {
  final GestureTapCallback onTap;
  final ValueChanged<bool>? onHover;
  final GestureLongPressCallback? onLongPress;
  final Widget? background;
  final Widget? child;
  final Widget? corner;
  final Widget? badge;
  final FocusNode? focusNode;

  const HorizontalListCard({
    super.key,
    required this.onTap,
    this.onHover,
    this.onLongPress,
    this.background,
    this.child,
    this.corner,
    this.badge,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focused = useState(false);
    final mobile = isMobile(context);
    var size = calcSize(context);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          side:
              !mobile && focused.value
                  ? BorderSide(color: Colors.white54, width: 2)
                  : BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: !mobile && focused.value ? 16 : 0,
        child: InkWell(
          focusNode: focusNode,
          onTap: onTap,
          onLongPress: onLongPress,
          onHover: onHover,
          onFocusChange: mobile ? null : (value) => focused.value = value,
          child: Stack(
            children: [
              if (background != null) Positioned.fill(child: background!),
              _buildContent(mobile, focused),
              if (badge != null) _buildBadge(),
              if (corner != null) _buildCorner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool mobile, ValueNotifier<bool> focused) {
    return Positioned.fill(
      child: Material(color: Colors.transparent, child: child),
    );
  }

  Widget _buildCorner() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(alignment: Alignment.topRight, child: corner),
    );
  }

  Widget _buildBadge() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(padding: const EdgeInsets.all(4.0), child: badge),
      ),
    );
  }

  static Size calcSize(BuildContext context) {
    var width = 200.0;

    if (isMobile(context)) {
      var screenWidth = MediaQuery.of(context).size.width;
      width = (screenWidth - 24) / 2;
    }

    return Size(width, width * 1.3);
  }
}
