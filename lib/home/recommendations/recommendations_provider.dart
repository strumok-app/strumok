import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/utils/trace.dart';

part 'recommendations_provider.g.dart';

class RecommendationChannelState {
  final List<ContentInfo> recommendations;
  final bool hasMore;
  final int page;
  final bool isLoading;

  RecommendationChannelState({
    required this.recommendations,
    this.hasMore = true,
    this.page = 1,
    this.isLoading = false,
  });

  RecommendationChannelState copyWith({
    List<ContentInfo>? recommendations,
    bool? hasMore,
    int? page,
    bool? isLoading,
  }) {
    return RecommendationChannelState(
      recommendations: recommendations ?? this.recommendations,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@Riverpod(keepAlive: true)
class RecommendationChannel extends _$RecommendationChannel {
  @override
  FutureOr<RecommendationChannelState> build(
    String supplierName,
    String channel,
  ) async {
    final recommendations = await ContentSuppliers().loadRecommendationsChannel(
      supplierName,
      channel,
    );

    return RecommendationChannelState(recommendations: recommendations);
  }

  void loadNext() async {
    final current = state.requireValue;

    if (!current.hasMore || current.isLoading) {
      return;
    }

    state = AsyncValue.data(current.copyWith(isLoading: true));

    final nextPage = current.page + 1;
    List<ContentInfo> nextRecommendations;
    try {
      nextRecommendations = await ContentSuppliers().loadRecommendationsChannel(
        supplierName,
        channel,
        page: nextPage,
      );
    } catch (e, stackTrace) {
      final msg =
          "Failed to load recommendations channel: $supplierName $channel";
      traceError(error: e, stackTrace: stackTrace, message: msg);
      state = AsyncValue.error(msg, stackTrace);
      return;
    }

    if (nextRecommendations.isEmpty) {
      state = AsyncValue.data(
        current.copyWith(isLoading: false, hasMore: false),
      );
    } else {
      state = AsyncValue.data(
        current.copyWith(
          isLoading: false,
          recommendations: current.recommendations + nextRecommendations,
          page: nextPage,
        ),
      );
    }
  }
}
