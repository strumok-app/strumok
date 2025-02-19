import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/download/downloading_provider.dart';

class DownloadingIcon extends ConsumerWidget {
  final IconData icon;

  const DownloadingIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(downloadTasksProvider);

    return tasks.isEmpty
        ? Icon(icon)
        : Badge.count(
            count: tasks.length,
            child: Icon(icon),
          );
  }
}
