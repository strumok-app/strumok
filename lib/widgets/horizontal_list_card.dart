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
    final imageWidth = mobile ? _calcMobileSize(context) : 200.0;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        side:
            !mobile && focused.value
                ? BorderSide(color: theme.colorScheme.primary, width: 1)
                : BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          if (background != null) _buildBackground(imageWidth),
          if (badge != null) _buildBadge(),
          _buildContent(mobile, focused),
          if (corner != null) _buildCorner(),
        ],
      ),
    );
  }

  Widget _buildContent(bool mobile, ValueNotifier<bool> focused) {
    return Positioned.fill(
      child: InkWell(
        focusNode: focusNode,
        onTap: onTap,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: mobile ? null : (value) => focused.value = value,
        child: Material(color: Colors.transparent, child: child),
      ),
    );
  }

  Widget _buildCorner() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(alignment: Alignment.topRight, child: corner),
    );
  }

  Widget _buildBackground(double imageWidth) {
    return SizedBox(width: imageWidth, child: background);
  }

  Widget _buildBadge() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(padding: const EdgeInsets.all(4.0), child: badge),
      ),
    );
  }

  double _calcMobileSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth - 36) / 2;
  }
}
