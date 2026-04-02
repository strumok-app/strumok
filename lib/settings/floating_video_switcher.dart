import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/settings/settings_provider.dart';

class FloatingVideoSwitcher extends ConsumerWidget {
  const FloatingVideoSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final floatingVideoPlayerEnabled = ref.watch(
      floatingVideoPlayerEnabledProvider,
    );

    return Switch(
      value: floatingVideoPlayerEnabled,
      onChanged: (value) {
        ref.read(floatingVideoPlayerEnabledProvider.notifier).toggle(value);
      },
    );
  }
}
