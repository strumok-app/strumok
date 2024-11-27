import 'package:auto_route/auto_route.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/home/recommendations/recommendations_provider.dart';
import 'package:strumok/settings/suppliers/suppliers_settings_provider.dart';
import 'package:strumok/widgets/horizontal_list.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/widgets/horizontal_list_card.dart';
import 'package:strumok/widgets/set_recommendations_hint.dart';

class Recommendations extends ConsumerWidget {
  const Recommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(suppliersSettingsProvider);
    final enabledSuppliers = ref.watch(enabledSuppliersProvider);

    final recommendations = enabledSuppliers
        .map((s) => (s, settings.getConfig(s)))
        .where((e) => e.$2.channels.isNotEmpty)
        .mapIndexed(
          (groupIdx, e) => [
            ...e.$2.channels.mapIndexed(
              (channelIdx, channel) => _RecommendationChannel(
                channelIdx: channelIdx,
                supplierName: e.$1,
                channel: channel,
              ),
            ),
          ],
        )
        .expand((e) => e)
        .toList();

    if (recommendations.isEmpty) {
      return _renderEmptyRecommendations(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recommendations,
    );
  }

  Widget _renderEmptyRecommendations(BuildContext context) {
    return HorizontalList(
      title: const SizedBox.shrink(),
      itemBuilder: (context, index) => HorizontalListCard(
        onTap: () {
          context.router.push(const SuppliersSettingsRoute());
        },
        child: const SetRecommendationsHint(),
      ),
      itemCount: 1,
    );
  }
}

class _RecommendationChannel extends HookConsumerWidget {
  final int channelIdx;
  final String supplierName;
  final String channel;

  const _RecommendationChannel({
    required this.channelIdx,
    required this.supplierName,
    required this.channel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = recommendationChannelProvider(supplierName, channel);
    final state = ref.watch(provider).valueOrNull;

    if (state == null || state.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    final scrollController = useScrollController();

    useEffect(() {
      void onScroll() {
        var position = scrollController.position;
        if (position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
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
        final item = state.recommendations[index];

        return ContentInfoCard(
          contentInfo: item,
          showSupplier: false,
        );
      },
      itemCount: state.recommendations.length,
    );

    if (channelIdx == 0) {
      final theme = Theme.of(context);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(supplierName, style: theme.textTheme.titleLarge),
          ),
          list,
        ],
      );
    }

    return list;
  }
}
