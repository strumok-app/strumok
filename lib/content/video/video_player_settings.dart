import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/content/video/model.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/layouts/app_theme.dart';
import 'package:strumok/widgets/dropdown.dart';
import 'package:strumok/widgets/settings_section.dart';

class PlayerSettingsButton extends StatelessWidget {
  const PlayerSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const PlayerSettingsDialog(),
        );
      },
      tooltip: AppLocalizations.of(context)!.settings,
      icon: const Icon(Icons.settings),
      color: Colors.white,
      focusColor: Colors.white.withOpacity(0.4),
      disabledColor: Colors.white.withOpacity(0.7),
    );
  }
}

class PlayerSettingsDialog extends StatelessWidget {
  const PlayerSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(8),
        child: FocusScope(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ShuffleModeSwitcher(),
              _OnVideoEndsActionSettingsSection(),
              _StarVideoPositionSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShuffleModeSwitcher extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shuffleMode = ref.watch(shuffleModeSettingsProvider);

    return SettingsSection(
      label: Text(
        AppLocalizations.of(context)!.videoPlayerSettingShuffleMode,
        style: theme.textTheme.headlineSmall,
      ),
      section: Switch(
        value: shuffleMode,
        onChanged: (value) {
          ref.read(shuffleModeSettingsProvider.notifier).select(value);
        },
      ),
    );
  }
}

class _OnVideoEndsActionSettingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final action = ref.watch(onVideoEndsActionSettingsProvider);

    return SettingsSection(
      label: Text(
        AppLocalizations.of(context)!.videoPlayerSettingEndsAction,
        style: theme.textTheme.headlineSmall,
      ),
      section: Dropdown.button(
        label: videoPlayerSettingEndsAction(context, action),
        menuChildrenBulder: (focusNode) => OnVideoEndsAction.values
            .mapIndexed(
              (index, value) => MenuItemButton(
                focusNode: index == 0 ? focusNode : null,
                onPressed: () {
                  ref
                      .read(onVideoEndsActionSettingsProvider.notifier)
                      .select(value);
                },
                child: Text(videoPlayerSettingEndsAction(context, value)),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StarVideoPositionSettingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final starVideoPosition = ref.watch(starVideoPositionSettingsProvider);
    final fixedPosition = ref.watch(fixedPositionSettingsProvider);

    return SettingsSection(
      label: Text(
        AppLocalizations.of(context)!.videoPlayerSettingStarFrom,
        style: theme.textTheme.headlineSmall,
      ),
      section: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Dropdown.button(
            label: videoPlayerSettingStarFrom(context, starVideoPosition),
            menuChildrenBulder: (focusNode) => StarVideoPosition.values
                .mapIndexed(
                  (index, value) => MenuItemButton(
                    focusNode: index == 0 ? focusNode : null,
                    onPressed: () {
                      ref
                          .read(starVideoPositionSettingsProvider.notifier)
                          .select(value);
                    },
                    child: Text(videoPlayerSettingStarFrom(context, value)),
                  ),
                )
                .toList(),
          ),
          if (starVideoPosition == StarVideoPosition.fromFixedPosition) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 52,
              height: 32,
              child: TextFormField(
                initialValue: fixedPosition.toString(),
                onChanged: (value) {
                  ref
                      .read(fixedPositionSettingsProvider.notifier)
                      .select(int.parse(value));
                },
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
                buildCounter: (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) =>
                    const SizedBox.shrink(),
              ),
            )
          ]
        ],
      ),
    );
  }
}
