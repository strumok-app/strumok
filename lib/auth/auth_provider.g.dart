// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(auth)
const authProvider = AuthProvider._();

final class AuthProvider extends $FunctionalProvider<Auth, Auth, Auth>
    with $Provider<Auth> {
  const AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  $ProviderElement<Auth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Auth create(Ref ref) {
    return auth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Auth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Auth>(value),
    );
  }
}

String _$authHash() => r'bdbda8b2b536217917227b604f9fd99bc2bb3527';

@ProviderFor(user)
const userProvider = UserProvider._();

final class UserProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  const UserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return user(ref);
  }
}

String _$userHash() => r'a47fd82d15ea15bad0639df1c9d0764e5f285d6d';
