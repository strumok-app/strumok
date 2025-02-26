import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/download/downloading_provider.dart';
import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/download/manager/models.dart';

class DownloadingQueue extends ConsumerWidget {
  const DownloadingQueue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            } else {
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
          child: DownloadsTasksList(tasks: tasks),
        ),
      ],
    );
  }
}

class DownloadsTasksList extends StatelessWidget {
  final Iterable<DownloadTask> tasks;

  const DownloadsTasksList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tasks
          .map((task) => ValueListenableBuilder(
                valueListenable: task.progress,
                builder: (context, value, child) => ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  title: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(child: Text(getTaskDescription(task))),
                      IconButton(
                        onPressed: () {
                          DownloadManager().cancel(task.request.id);
                        },
                        icon: Icon(Icons.cancel_outlined),
                      ),
                    ],
                  ),
                  subtitle: LinearProgressIndicator(value: value),
                ),
              ))
          .toList(),
    );
  }

  String getTaskDescription(DownloadTask task) {
    final title = (task.request as ContentDownloadRequest).info.title;
    final speed = task.speed();

    if (speed != null) {
      return "$title $speed/s";
    }

    return title;
  }
}
