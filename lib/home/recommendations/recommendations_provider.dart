import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recommendations_provider.g.dart';

class RecommendationChannelState {
  final List<ContentInfo> recommendations;
  final bool hasNext;
  final int page;
  final bool loading;

  RecommendationChannelState({
    required this.recommendations,
    this.hasNext = true,
    this.page = 1,
    this.loading = false,
  });

  RecommendationChannelState copyWith({
    List<ContentInfo>? recommendations,
    bool? hasNext,
    int? page,
    bool? loading,
  }) {
    return RecommendationChannelState(
      recommendations: recommendations ?? this.recommendations,
      hasNext: hasNext ?? this.hasNext,
      page: page ?? this.page,
      loading: loading ?? this.loading,
    );
  }
}

@Riverpod(keepAlive: true)
class RecommendationChannel extends _$RecommendationChannel {
  @override
  FutureOr<RecommendationChannelState> build(String supplierName, String channel) async {
    final recommendations = await ContentSuppliers().loadRecommendationsChannel(supplierName, channel);
    return RecommendationChannelState(recommendations: recommendations);
  }

  void loadNext() async {
    final current = state.requireValue;

    if (!current.hasNext || current.loading) {
      return;
    }

    state = AsyncValue.data(
      current.copyWith(loading: true),
    );

    final nextPage = current.page + 1;
    final nextRecommendations =
        await ContentSuppliers().loadRecommendationsChannel(supplierName, channel, page: nextPage);

    if (nextRecommendations.isEmpty) {
      state = AsyncValue.data(
        current.copyWith(
          loading: false,
          hasNext: false,
        ),
      );
    } else {
      state = AsyncValue.data(
        current.copyWith(
          loading: false,
          recommendations: current.recommendations + nextRecommendations,
          page: nextPage,
        ),
      );
    }
  }
}
