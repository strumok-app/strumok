import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:strumok/app_preferences.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class AuthTokenStore {
  FutureOr<void> write(AccessCredentials? credentials);
  FutureOr<AccessCredentials?> read();
  FutureOr<void> delete();
}

class PerferenceTokenStore extends AuthTokenStore {
  final String key = "access_credentials";

  @override
  FutureOr<void> delete() => AppPreferences.instance.remove(key);

  @override
  FutureOr<AccessCredentials?> read() {
    final accessCredentialsJson = AppPreferences.instance.getString(key);

    if (accessCredentialsJson != null) {
      return AccessCredentials.fromJson(json.decode(accessCredentialsJson));
    }

    return null;
  }

  @override
  FutureOr<void> write(AccessCredentials? credentials) {
    AppPreferences.instance.setString(key, json.encode(credentials));
  }
}

class User {
  final String id;
  final String? name;
  final String? picture;

  const User({
    required this.id,
    required this.name,
    required this.picture,
  });

  factory User.fromIdToken(String idToken) {
    final [_, encodedPayload, _] = idToken.split('.');

    final payload = json.decode(String.fromCharCodes(base64.decode(encodedPayload))) as Map<String, dynamic>;

    return User(
      id: payload["sub"].toString(),
      name: payload["name"].toString(),
      picture: payload["picture"].toString(),
    );
  }
}

const scopes = ["https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/userinfo.email"];

class Auth {
  final AuthTokenStore _tokenStore = PerferenceTokenStore();
  final StreamController<User?> _userStreamController = StreamController();
  late Stream<User?> _userStream;

  static ClientId? desktopClientId;
  User? _currentUser;

  static final Auth _instance = Auth._();

  factory Auth() => _instance;

  Auth._() {
    _userStream = _userStreamController.stream.asBroadcastStream();

    FirebaseAuth.instance.userChanges().listen((event) {
      if (event != null) {
        _currentUser = User(
          id: event.uid,
          name: event.displayName,
          picture: event.photoURL,
        );
      } else {
        _currentUser = null;
      }
      _userStreamController.add(_currentUser);
    });

    restore();
  }

  User? get currentUser => _currentUser;
  Stream<User?> get userUpdate => _userStream;

  Future<void> signIn() async {
    final clientId = await _loadDesktopClientId();

    if (Platform.isLinux || Platform.isWindows) {
      final credentials = await obtainAccessCredentialsViaUserConsent(
        clientId,
        scopes,
        Client(),
        (uri) {
          launchUrl(Uri.parse(uri));
        },
      );

      _setAccessCredentials(credentials);
    } else {
      final googleSign = await GoogleSignIn(scopes: scopes).signIn();

      _setGoogleSignInAccount(googleSign);
    }
  }

  Future<void> singOut() async {
    if (Platform.isLinux || Platform.isWindows) {
      await _tokenStore.delete();
    }
    await FirebaseAuth.instance.signOut();
  }

  static Future<ClientId> _loadDesktopClientId() async {
    const clientSecret = String.fromEnvironment("GOOGLE_AUTH");
    if (desktopClientId == null) {
      final clientSecretJson = json.decode(clientSecret);
      desktopClientId = ClientId.fromJson(clientSecretJson);
    }

    return desktopClientId!;
  }

  Future<void> restore() async {
    if (Platform.isLinux || Platform.isWindows) {
      final clientId = await _loadDesktopClientId();
      var credentials = await _tokenStore.read();

      if (credentials != null) {
        if (credentials.accessToken.hasExpired) {
          credentials = await refreshCredentials(clientId, credentials, Client());
        }
        _setAccessCredentials(credentials);
      }
    } else {
      final googleSign = await GoogleSignIn(scopes: scopes).signInSilently();
      _setGoogleSignInAccount(googleSign);
    }
  }

  void _setGoogleSignInAccount(GoogleSignInAccount? account) async {
    if (account != null) {
      final auth = await account.authentication;
      if (auth.accessToken != null) {
        _setCredentials(auth.accessToken!, auth.idToken);
      }
    }
  }

  void _setAccessCredentials(AccessCredentials credentials) {
    _setCredentials(credentials.accessToken.data, credentials.idToken);
  }

  void _setCredentials(String accessToken, String? idToken) {
    FirebaseAuth.instance.signInWithCredential(
      GoogleAuthProvider.credential(accessToken: accessToken, idToken: idToken),
    );
  }
}
