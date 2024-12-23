import 'package:strumok/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// ignore: must_be_immutable
class HorizontalListCard extends HookWidget {
  final GestureTapCallback onTap;
  final ValueChanged<bool>? onHover;
  final GestureLongPressCallback? onLongPress;
  final Decoration? decoration;
  final Widget? child;
  final Widget? corner;
  final Widget? badge;
  final FocusNode? focusNode;

  const HorizontalListCard({
    super.key,
    required this.onTap,
    this.onHover,
    this.onLongPress,
    this.decoration,
    this.child,
    this.corner,
    this.badge,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focused = useState(false);

    var imageWidth = isMobile(context) ? 165.0 : 195.0;
    final imageHeight = imageWidth * 1.5;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        side: focused.value
            ? BorderSide(color: theme.colorScheme.primary, width: 1)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          _buildBackground(imageHeight, imageWidth),
          if (badge != null) _buildBadge(),
          _buildContent(focused),
        ],
      ),
    );
  }

  Widget _buildContent(ValueNotifier<bool> focused) {
    return Positioned.fill(
      child: InkWell(
        focusNode: focusNode,
        onTap: onTap,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: (value) => focused.value = value,
        child: Material(
          color: Colors.transparent,
          child: corner != null
              ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: corner,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBackground(double imageHeight, double imageWidth) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: imageHeight,
        maxWidth: imageWidth,
      ),
      decoration: decoration,
      child: SizedBox.expand(child: child),
    );
  }

  Widget _buildBadge() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: badge,
        ),
      ),
    );
  }
}
