import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/widgets/horizontal_list_card.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

const maxImageWidth = 320.0;

class ContentInfoCard extends StatelessWidget {
  final bool autofocus;

  final ValueChanged<bool>? onHover;
  final GestureLongPressCallback? onLongPress;

  const ContentInfoCard({
    super.key,
    required this.contentInfo,
    this.corner,
    required this.onTap,
    this.onHover,
    this.onLongPress,
    this.autofocus = false,
  });

  final Widget? corner;
  final ContentInfo contentInfo;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context).textTheme.;
    return HorizontalListCard(
      autofocus: autofocus,
      onTap: onTap,
      onHover: onHover,
      onLongPress: onLongPress,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FastCachedImageProvider(contentInfo.image),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      corner: corner,
      child: Column(
        children: [
          const Spacer(),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent],
                stops: [.5, 1.0],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              title: Text(
                contentInfo.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, inherit: true),
                maxLines: 2,
              ),
              subtitle: contentInfo.subtitle == null
                  ? null
                  : Text(
                      contentInfo.subtitle!,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white, inherit: true),
                      maxLines: 2,
                    ),
            ),
          )
        ],
      ),
    );
  }
}
