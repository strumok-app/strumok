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
    final mobile = isMobile(context);
    var size = calcSize(context);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
          focusNode: focusNode,
          onTap: onTap,
          onLongPress: onLongPress,
          onHover: onHover,
          child: Stack(
            children: [
              if (background != null) Positioned.fill(child: background!),
              _buildContent(mobile),
              if (badge != null) _buildBadge(),
              if (corner != null) _buildCorner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool mobile) {
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

class LoadMoreItems extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  final String label;

  const LoadMoreItems({
    super.key,
    required this.onTap,
    required this.label,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return HorizontalListCard(
      key: Key("load_more"),
      focusNode: FocusNode(canRequestFocus: !loading),
      onTap: () {
        FocusManager.instance.primaryFocus?.previousFocus();
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          loading
              ? CircularProgressIndicator()
              : const Icon(Icons.double_arrow, size: 48),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
