import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/auth/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
Auth auth(Ref ref) {
  return Auth();
}

@Riverpod(keepAlive: true)
Stream<User?> user(Ref ref) {
  return Auth().userUpdate;
}
