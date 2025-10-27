import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/content/video/model.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/layouts/app_theme.dart';
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
      disabledColor: Colors.white.withValues(alpha: 0.7),
    );
  }
}

class PlayerSettingsDialog extends StatefulWidget {
  const PlayerSettingsDialog({super.key});

  @override
  State<PlayerSettingsDialog> createState() => PlayerSettingsDialogState();
}

class PlayerSettingsDialogState extends State<PlayerSettingsDialog>
    with SingleTickerProviderStateMixin {
  _MenuLocation _location = _MenuLocation.root;

  late AnimationController _controller;
  late Animation<double> _animation1;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation1 = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      child: Dialog(
        child: FocusScope(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AnimatedBuilder(
              animation: _animation1,
              builder: (BuildContext context, Widget? child) {
                return Stack(
                  children: [
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset.zero,
                        end: Offset(-1.0, 0.0),
                      ).animate(_animation1),
                      child: _location == _MenuLocation.root
                          ? _MenuRoot(onNav: _navTo)
                          : SizedBox.shrink(),
                    ),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(_animation1),
                      child: switch (_location) {
                        _MenuLocation.subtitlesOffset => _MenuSubtitlesOffset(
                          onNav: _navTo,
                        ),
                        _MenuLocation.equalizer => _MenuEqualizer(
                          onNav: _navTo,
                        ),
                        _MenuLocation.startFrom => _MenuStartFrom(
                          onNav: _navTo,
                        ),
                        _MenuLocation.onEnds => _MenuOnVideoEnds(onNav: _navTo),
                        _ => SizedBox.shrink(),
                      },
                    ),
                  ],
                );
              },
            ),
            // AnimatedSwitcher(
            //   duration: const Duration(milliseconds: 300),
            //   transitionBuilder: (child, animation) {
            //     final offsetAnimation =
            //         Tween<Offset>(
            //           begin: const Offset(1.0, 0.0),
            //           end: Offset.zero,
            //         ).animate(
            //           CurvedAnimation(
            //             parent: animation,
            //             curve: Curves.easeInOut,
            //           ),
            //         );

            //     return SlideTransition(position: offsetAnimation, child: child);
            //   },
            //   child: switch (_location) {
            //     _MenuLocation.subtitlesOffset => _MenuSubtitlesOffset(
            //       onNav: _navTo,
            //     ),
            //     _MenuLocation.equalizer => _MenuEqualizer(onNav: _navTo),
            //     _MenuLocation.startFrom => _MenuStartFrom(onNav: _navTo),
            //     _MenuLocation.onEnds => _MenuOnVideoEnds(onNav: _navTo),
            //     _ => _MenuRoot(onNav: _navTo),
            //   },
            // ),
          ),
        ),
      ),
    );
  }

  void _navTo(_MenuLocation location) async {
    if (location == _MenuLocation.root) {
      setState(() {
        _location = location;
      });
      _controller.reverse();
    } else {
      await _controller.forward();
      setState(() {
        _location = location;
      });
    }
  }
}

typedef _MenuLocationCallback = Function(_MenuLocation);

enum _MenuLocation { root, onEnds, startFrom, subtitlesOffset, equalizer }

class _MenuEqualizer extends ConsumerWidget {
  final _MenuLocationCallback onNav;

  const _MenuEqualizer({required this.onNav});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final equalizerBands = ref.watch(equalizerBandsSettingsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_back),
          onTap: () {
            onNav(_MenuLocation.root);
          },
          title: Text('Equalizer', style: theme.textTheme.bodyLarge),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _EqualizerBand(
                label: 'Bass',
                value: equalizerBands[0],
                onChanged: (value) {
                  ref
                      .read(equalizerBandsSettingsProvider.notifier)
                      .updateBand(0, value);
                },
              ),
              _EqualizerBand(
                label: 'Low Mid',
                value: equalizerBands[1],
                onChanged: (value) {
                  ref
                      .read(equalizerBandsSettingsProvider.notifier)
                      .updateBand(1, value);
                },
              ),
              _EqualizerBand(
                label: 'Mid',
                value: equalizerBands[2],
                onChanged: (value) {
                  ref
                      .read(equalizerBandsSettingsProvider.notifier)
                      .updateBand(2, value);
                },
              ),
              _EqualizerBand(
                label: 'High Mid',
                value: equalizerBands[3],
                onChanged: (value) {
                  ref
                      .read(equalizerBandsSettingsProvider.notifier)
                      .updateBand(3, value);
                },
              ),
              _EqualizerBand(
                label: 'Treble',
                value: equalizerBands[4],
                onChanged: (value) {
                  ref
                      .read(equalizerBandsSettingsProvider.notifier)
                      .updateBand(4, value);
                },
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              child: Text('Clear Dialogue'),
              onPressed: () {
                ref
                    .read(equalizerBandsSettingsProvider.notifier)
                    .setPreset(AppConstances.equalizerClearDialogBands);
              },
            ),
            OutlinedButton(
              child: Text('Cinema'),
              onPressed: () {
                ref
                    .read(equalizerBandsSettingsProvider.notifier)
                    .setPreset(AppConstances.equalizerCinemaBands);
              },
            ),
            OutlinedButton(
              child: Text('Night Mode'),
              onPressed: () {
                ref
                    .read(equalizerBandsSettingsProvider.notifier)
                    .setPreset(AppConstances.equalizerNightModeBands);
              },
            ),
            OutlinedButton(
              child: Text('Action'),
              onPressed: () {
                ref
                    .read(equalizerBandsSettingsProvider.notifier)
                    .setPreset(AppConstances.equalizerActionBands);
              },
            ),
            OutlinedButton(
              child: Text('Reset'),
              onPressed: () {
                ref
                    .read(equalizerBandsSettingsProvider.notifier)
                    .setPreset(AppConstances.equalizerDefaultBands);
              },
            ),
            OutlinedButton(
              child: Text('Max'),
              onPressed: () {
                ref
                    .read(equalizerBandsSettingsProvider.notifier)
                    .setPreset(AppConstances.equalizerMaxBands);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _EqualizerBand extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _EqualizerBand({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_EqualizerBand> createState() => _EqualizerBandState();
}

class _EqualizerBandState extends State<_EqualizerBand> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant _EqualizerBand oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          width: 60,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                allowedInteraction: SliderInteraction.tapAndSlide,
                value: _currentValue,
                min: -12,
                max: 12,
                divisions: 24,
                label: '${_currentValue.toStringAsFixed(1)}dB',
                onChanged: (value) {
                  setState(() {
                    _currentValue = value;
                  });
                },
                onChangeEnd: (value) {
                  widget.onChanged(value);
                },
              ),
            ),
          ),
        ),
        Text(
          '${_currentValue.toStringAsFixed(1)}dB',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MenuSubtitlesOffset extends ConsumerWidget {
  final _MenuLocationCallback onNav;

  const _MenuSubtitlesOffset({required this.onNav});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subtitlesOffset = ref.watch(subtitlesOffsetProvider);

    return SizedBox(
      width: 280,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              onNav(_MenuLocation.root);
            },
            icon: const Icon(Icons.arrow_back),
          ),

          IconButton(
            onPressed: () {
              ref
                  .read(subtitlesOffsetProvider.notifier)
                  .setOffset(subtitlesOffset.inSeconds - 1);
            },
            icon: const Icon(Icons.remove_circle),
          ),
          const SizedBox(width: 16),
          Text(
            '${subtitlesOffset.inSeconds}s',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              ref
                  .read(subtitlesOffsetProvider.notifier)
                  .setOffset(subtitlesOffset.inSeconds + 1);
            },
            icon: const Icon(Icons.add_circle),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              ref.read(subtitlesOffsetProvider.notifier).setOffset(0);
            },
            icon: const Icon(Icons.restore),
          ),
        ],
      ),
    );
  }
}

class _MenuOnVideoEnds extends ConsumerWidget {
  final _MenuLocationCallback onNav;

  const _MenuOnVideoEnds({required this.onNav});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onVideoEndsAction = ref.watch(onVideoEndsActionSettingsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_back),
          onTap: () {
            onNav(_MenuLocation.root);
          },
          title: Text(
            AppLocalizations.of(context)!.videoPlayerSettingEndsAction,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        ...OnVideoEndsAction.values.map((action) {
          return ListTile(
            title: Text(videoPlayerSettingEndsAction(context, action)),
            leading: Icon(onVideoEndsAction == action ? Icons.check : null),
            onTap: () {
              ref
                  .read(onVideoEndsActionSettingsProvider.notifier)
                  .select(action);
            },
          );
        }),
      ],
    );
  }
}

class _MenuStartFrom extends ConsumerWidget {
  final _MenuLocationCallback onNav;

  const _MenuStartFrom({required this.onNav});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final starVideoPosition = ref.watch(startVideoPositionSettingsProvider);
    final fixedPosition = ref.watch(fixedPositionSettingsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_back),
          onTap: () {
            onNav(_MenuLocation.root);
          },
          title: Text(
            AppLocalizations.of(context)!.videoPlayerSettingStartFrom,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        ...StartVideoPosition.values.map((position) {
          return ListTile(
            title: Text(videoPlayerSettingStartFrom(context, position)),
            leading: Icon(starVideoPosition == position ? Icons.check : null),
            onTap: () {
              ref
                  .read(startVideoPositionSettingsProvider.notifier)
                  .select(position);
            },
            trailing: position == StartVideoPosition.fromFixedPosition
                ? _FixedSecondInput(fixedPosition: fixedPosition)
                : null,
          );
        }),
      ],
    );
  }
}

class _MenuRoot extends ConsumerWidget {
  final _MenuLocationCallback onNav;

  const _MenuRoot({required this.onNav});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shuffleMode = ref.watch(shuffleModeSettingsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          onTap: () {
            onNav(_MenuLocation.equalizer);
          },
          title: const Text('Equalizer'),
        ),
        ListTile(
          onTap: () {
            onNav(_MenuLocation.subtitlesOffset);
          },
          title: Text(AppLocalizations.of(context)!.videoSubtitlesOffset),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: SettingsSection(
            labelWidth: 200,
            label: Text(
              AppLocalizations.of(context)!.videoPlayerSettingShuffleMode,
              style: theme.textTheme.bodyLarge,
            ),
            section: Switch(
              value: shuffleMode,
              onChanged: (value) {
                ref.read(shuffleModeSettingsProvider.notifier).select(value);
              },
            ),
          ),
        ),
        ListTile(
          onTap: () {
            onNav(_MenuLocation.startFrom);
          },
          title: Text(
            AppLocalizations.of(context)!.videoPlayerSettingStartFrom,
          ),
        ),
        ListTile(
          onTap: () {
            onNav(_MenuLocation.onEnds);
          },
          title: Text(
            AppLocalizations.of(context)!.videoPlayerSettingEndsAction,
          ),
        ),
      ],
    );
  }
}

class _FixedSecondInput extends ConsumerStatefulWidget {
  const _FixedSecondInput({required this.fixedPosition});

  final int fixedPosition;

  @override
  ConsumerState<_FixedSecondInput> createState() => _FixedSecondInputState();
}

class _FixedSecondInputState extends ConsumerState<_FixedSecondInput> {
  late final FocusNode focusNode;

  @override
  void initState() {
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 32,
      child: BackButtonListener(
        onBackButtonPressed: () async {
          focusNode.previousFocus();
          return true;
        },
        child: TextFormField(
          focusNode: focusNode,
          initialValue: widget.fixedPosition.toString(),
          onChanged: (value) {
            ref
                .read(fixedPositionSettingsProvider.notifier)
                .select(int.tryParse(value) ?? 0);
          },
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          ),
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                required maxLength,
              }) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
