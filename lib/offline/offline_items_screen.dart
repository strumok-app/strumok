import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:strumok/app_localizations.dart';
import 'package:strumok/download/downloading_indicator.dart';
import 'package:strumok/download/downloading_provider.dart';
import 'package:strumok/layouts/general_layout.dart';
import 'package:strumok/offline/offline_content_details.dart';
import 'package:strumok/offline/offline_items_screen_provider.dart';
import 'package:strumok/offline/offline_storage.dart';
import 'package:strumok/utils/nav.dart';
import 'package:strumok/utils/text.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/confirm_dialog.dart';
import 'package:strumok/widgets/horizontal_list_card.dart';

@RoutePage()
class OfflineItemsScreen extends StatelessWidget {
  const OfflineItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GeneralLayout(
      child: Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OfflineItemsTitle(),
                if (isMobile(context)) _InprogressDownloads(),
                _OfflineItemsView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OfflineItemsTitle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            AppLocalizations.of(context)!.downloads,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              ref.invalidate(offlineContentProvider);
            },
            icon: Icon(Icons.refresh_rounded),
          )
        ],
      ),
    );
  }
}

class _OfflineItemsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineContentAsync = ref.watch(offlineContentProvider);

    ref.listen(downloadsUpdateStreamProvider, (_, next) {
      final task = next.valueOrNull;
      if (task != null && task.status.value.isCompleted) {
        ref.invalidate(offlineContentProvider);
      }
    });

    return offlineContentAsync.when(
        data: (data) => SingleChildScrollView(
              child: Wrap(
                runSpacing: 4,
                children: data.map((info) => OfflineItem(info: info)).toList(),
              ),
            ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())));
  }
}

class _InprogressDownloads extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(downloadTasksProvider);

    if (tasks.isEmpty) {
      return SizedBox.shrink();
    }

    return DownloadsTasksList(tasks: tasks);
  }
}

class OfflineItem extends ConsumerWidget {
  final OfflineContentInfo info;

  const OfflineItem({super.key, required this.info});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 260,
      child: HorizontalListCard(
        onTap: () => navigateToContentDetails(context, info),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(info.image),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        badge: Badge(
          label: Text(info.supplier),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          backgroundColor: theme.colorScheme.primary,
          textColor: theme.colorScheme.onPrimary,
        ),
        corner: IconButton.filledTonal(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                content: Text(
                  AppLocalizations.of(context)!.downloadsDeleteConfimation(info.title),
                ),
                confimAction: () async {
                  if (hasAnyDownloadingAitems(info.supplier, info.id)) {
                    return;
                  }

                  await OfflineStorage().deleteAll(info.supplier, info.id);
                  ref.invalidate(offlineContentProvider);
                },
              ),
            );
          },
          icon: Icon(Icons.delete),
        ),
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
                  info.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, inherit: true),
                  maxLines: 2,
                ),
                subtitle: Text(formatBytes(info.diskUsage)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
