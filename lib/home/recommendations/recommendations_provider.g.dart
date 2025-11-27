// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecommendationChannel)
const recommendationChannelProvider = RecommendationChannelFamily._();

final class RecommendationChannelProvider
    extends
        $AsyncNotifierProvider<
          RecommendationChannel,
          RecommendationChannelState
        > {
  const RecommendationChannelProvider._({
    required RecommendationChannelFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'recommendationChannelProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recommendationChannelHash();

  @override
  String toString() {
    return r'recommendationChannelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  RecommendationChannel create() => RecommendationChannel();

  @override
  bool operator ==(Object other) {
    return other is RecommendationChannelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recommendationChannelHash() =>
    r'5373945d9ae3f854ea36a1939eae566fb732db8e';

final class RecommendationChannelFamily extends $Family
    with
        $ClassFamilyOverride<
          RecommendationChannel,
          AsyncValue<RecommendationChannelState>,
          RecommendationChannelState,
          FutureOr<RecommendationChannelState>,
          (String, String)
        > {
  const RecommendationChannelFamily._()
    : super(
        retry: null,
        name: r'recommendationChannelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  RecommendationChannelProvider call(String supplierName, String channel) =>
      RecommendationChannelProvider._(
        argument: (supplierName, channel),
        from: this,
      );

  @override
  String toString() => r'recommendationChannelProvider';
}

abstract class _$RecommendationChannel
    extends $AsyncNotifier<RecommendationChannelState> {
  late final _$args = ref.$arg as (String, String);
  String get supplierName => _$args.$1;
  String get channel => _$args.$2;

  FutureOr<RecommendationChannelState> build(
    String supplierName,
    String channel,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, _$args.$2);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<RecommendationChannelState>,
              RecommendationChannelState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RecommendationChannelState>,
                RecommendationChannelState
              >,
              AsyncValue<RecommendationChannelState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
