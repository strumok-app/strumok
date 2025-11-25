import 'package:auto_route/auto_route.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/home/recommendations/recommendations_provider.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/settings/suppliers/suppliers_settings_provider.dart';
import 'package:strumok/widgets/horizontal_list.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/widgets/horizontal_list_card.dart';
import 'package:strumok/widgets/nothing_to_show.dart';
import 'package:strumok/widgets/set_recommendations_hint.dart';

class Recommendations extends ConsumerWidget {
  const Recommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(suppliersSettingsProvider);
    final offlineMode = ref.watch(offlineModeProvider);
    final enabledSuppliers = ref.watch(enabledSuppliersProvider);

    if (offlineMode) {
      return SizedBox.shrink();
    }

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
        key: Key("empty"),
        onTap: () {
          context.navigateTo(const SuppliersSettingsRoute());
        },
        child: const SetRecommendationsHint(),
      ),
      itemCount: 1,
    );
  }
}

class _RecommendationChannel extends ConsumerWidget {
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
    final asyncState = ref.watch(provider);

    final res = asyncState.when(
      skipLoadingOnRefresh: false,
      data: (state) => HorizontalList(
        title: _renderChannelTitle(false, provider, context, ref),
        itemBuilder: (context, index) {
          final item = state.recommendations[index];

          return ContentInfoCard(
            key: ValueKey("${item.supplier}/${item.id}"),
            contentInfo: item,
            showSupplier: false,
          );
        },
        itemCount: state.recommendations.length,
        trailing: state.hasMore
            ? LoadMoreItems(
                label: AppLocalizations.of(context)!.loadMore,
                onTap: () => ref.read(provider.notifier).loadNext(),
                loading: state.isLoading,
              )
            : null,
      ),
      loading: () => HorizontalList(
        title: _renderChannelTitle(true, provider, context, ref),
        itemBuilder: (context, index) => HorizontalListCard(
          key: Key("loading"),
          onTap: () {},
          child: const Center(child: CircularProgressIndicator()),
        ),
        itemCount: 1,
      ),
      error: (e, s) => HorizontalList(
        title: _renderChannelTitle(false, provider, context, ref),
        itemBuilder: (context, index) => HorizontalListCard(
          key: Key("error"),
          onTap: () {},
          child: const Center(child: NothingToShow()),
        ),
        itemCount: 1,
      ),
    );

    if (channelIdx == 0) {
      final theme = Theme.of(context);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(supplierName, style: theme.textTheme.titleLarge),
          ),
          res,
        ],
      );
    }

    return res;
  }

  Widget _renderChannelTitle(
    bool loading,
    RecommendationChannelProvider provider,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        SizedBox(
          height: 48,
          child: Center(
            child: Text(
              channel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        Spacer(),
        if (!loading)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              constraints: BoxConstraints(),
              onPressed: () => ref.refresh(provider.future),
              icon: Icon(Icons.refresh),
            ),
          ),
      ],
    );
  }
}
