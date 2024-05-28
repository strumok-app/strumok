import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/home/recomendations/recomendations_provider.dart';
import 'package:cloud_hook/settings/recomendations/recomendations_settings_provider.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:cloud_hook/widgets/horizontal_list.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Recommendations extends ConsumerWidget {
  const Recommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(recomendationSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: settings.configs.entries
          .where((e) => e.value.enabled && e.value.channels.isNotEmpty)
          .mapIndexed(
            (groupIdx, e) => [
              ...e.value.channels.mapIndexed(
                (channelIdx, channel) => _RecomendationChannel(
                  channelIdx: channelIdx,
                  supplierName: e.key,
                  channel: channel,
                ),
              ),
            ],
          )
          .expand((e) => e)
          .toList(),
    );
  }
}

class _RecomendationChannel extends HookConsumerWidget {
  final int channelIdx;
  final String supplierName;
  final String channel;

  const _RecomendationChannel({
    required this.channelIdx,
    required this.supplierName,
    required this.channel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = recomendationChannelProvider(supplierName, channel);
    final state = ref.watch(provider).valueOrNull;

    if (state == null) {
      return const SizedBox.shrink();
    }

    final scrollController = useScrollController();

    useEffect(() {
      void onScroll() {
        var position = scrollController.position;
        if (position.pixels == scrollController.position.maxScrollExtent) {
          ref.read(provider.notifier).loadNext();
        }
      }

      scrollController.addListener(onScroll);

      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    final list = HorizontalList(
      scrollController: scrollController,
      title: Text(
        channel,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      itemBuilder: (context, index) {
        final item = state.recomendations[index];

        return ContentInfoCard(
          contentInfo: item,
        );
      },
      itemCount: state.recomendations.length,
    );

    if (channelIdx == 0) {
      final theme = Theme.of(context);
      final paddings = getPadding(context);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddings),
            child: Text(supplierName, style: theme.textTheme.titleLarge),
          ),
          list
        ],
      );
    }

    return list;
  }
}
