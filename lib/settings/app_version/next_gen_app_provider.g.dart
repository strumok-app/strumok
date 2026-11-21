// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_gen_app_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextGenAppInfo _$NextGenAppInfoFromJson(Map<String, dynamic> json) =>
    NextGenAppInfo(
      name: json['name'] as String?,
      tagName: json['tag_name'] as String,
      htmlUrl: json['html_url'] as String,
      assets:
          (json['assets'] as List<dynamic>?)
              ?.map(
                (e) => AppVersionDownloadAssets.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nextGenAppInfo)
final nextGenAppInfoProvider = NextGenAppInfoProvider._();

final class NextGenAppInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<NextGenAppInfo?>,
          NextGenAppInfo?,
          FutureOr<NextGenAppInfo?>
        >
    with $FutureModifier<NextGenAppInfo?>, $FutureProvider<NextGenAppInfo?> {
  NextGenAppInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextGenAppInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextGenAppInfoHash();

  @$internal
  @override
  $FutureProviderElement<NextGenAppInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NextGenAppInfo?> create(Ref ref) {
    return nextGenAppInfo(ref);
  }
}

String _$nextGenAppInfoHash() => r'654d75b1943d56cf3370191bd1a0518475b34839';

@ProviderFor(NextGenAppInstall)
final nextGenAppInstallProvider = NextGenAppInstallProvider._();

final class NextGenAppInstallProvider
    extends $NotifierProvider<NextGenAppInstall, DownloadState> {
  NextGenAppInstallProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextGenAppInstallProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextGenAppInstallHash();

  @$internal
  @override
  NextGenAppInstall create() => NextGenAppInstall();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadState>(value),
    );
  }
}

String _$nextGenAppInstallHash() => r'3e2da5874c918047b5835569fcbd716f2620f4de';

abstract class _$NextGenAppInstall extends $Notifier<DownloadState> {
  DownloadState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DownloadState, DownloadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DownloadState, DownloadState>,
              DownloadState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
