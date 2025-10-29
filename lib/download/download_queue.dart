import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/download/download_queue_provider.dart';
import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/utils/text.dart';

class DownloadingQueue extends ConsumerStatefulWidget {
  const DownloadingQueue({super.key});

  @override
  ConsumerState<DownloadingQueue> createState() => _DownloadingQueueState();
}

class _DownloadingQueueState extends ConsumerState<DownloadingQueue> {
  final focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(downloadTasksProvider);

    if (tasks.isEmpty) {
      return SizedBox.shrink();
    }

    return MenuAnchor(
      builder: (context, controller, child) => Badge.count(
        count: tasks.length,
        child: IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
              focusNode.previousFocus();
            } else {
              focusNode.requestFocus();
              controller.open();
            }
          },
          icon: Icon(Icons.downloading_outlined),
        ),
      ),
      alignmentOffset: Offset(0, 12),
      menuChildren: [
        Container(
          constraints: BoxConstraints(minWidth: 320),
          child: DownloadsTasksList(tasks: tasks, focusNode: focusNode),
        ),
      ],
    );
  }
}

class DownloadsTasksList extends StatelessWidget {
  final Iterable<DownloadTask> tasks;
  final FocusNode? focusNode;

  const DownloadsTasksList({super.key, required this.tasks, this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tasks
          .mapIndexed(
            (idx, task) => ValueListenableBuilder(
              valueListenable: task.progress,
              builder: (context, value, child) => ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                title: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            context.router.popAndPush(
                              const OfflineItemsRoute(),
                            );
                          },
                          child: Text(downloadTaskDescription(task)),
                        ),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: task.status,
                      builder: (context, value, child) {
                        if (value == DownloadStatus.canceled) {
                          return SizedBox.shrink();
                        }

                        return IconButton(
                          focusNode: idx == 0 ? focusNode : null,
                          onPressed: () {
                            DownloadManager().cancel(task.request.id);
                          },
                          icon: Icon(Icons.cancel_outlined),
                        );
                      },
                    ),
                  ],
                ),
                subtitle: LinearProgressIndicator(value: value),
              ),
            ),
          )
          .toList(),
    );
  }
}
