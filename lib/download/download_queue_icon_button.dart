import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/download/download_queue_provider.dart';

class DownloadQueueIconButton extends ConsumerWidget {
  final IconData icon;

  const DownloadQueueIconButton(this.icon, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(downloadTasksProvider);

    return tasks.isEmpty
        ? Icon(icon)
        : Badge.count(count: tasks.length, child: Icon(icon));
  }
}
