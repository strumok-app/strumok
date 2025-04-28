import 'dart:async';
import 'dart:convert';

import 'package:firebase_dart/firebase_dart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:strumok/app_init_firebase.dart';
import 'package:strumok/utils/trace.dart';
import 'package:strumok/utils/visual.dart';
import 'package:url_launcher/url_launcher.dart';

class User {
  final String id;
  final String? name;
  final String? picture;

  const User({required this.id, required this.name, required this.picture});

  factory User.fromIdToken(String idToken) {
    final [_, encodedPayload, _] = idToken.split('.');

    final payload =
        json.decode(String.fromCharCodes(base64.decode(encodedPayload)))
            as Map<String, dynamic>;

    return User(
      id: payload["sub"].toString(),
      name: payload["name"].toString(),
      picture: payload["picture"].toString(),
    );
  }
}

const scopes = [
  "https://www.googleapis.com/auth/userinfo.profile",
  "https://www.googleapis.com/auth/userinfo.email",
];

class Auth {
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

    if (isDesktopDevice()) {
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

  Future<void> signInWithPairCode(String code) async {
    final endpoint = AppInitFirebase().getEndpoint("exchangecodefortoken");

    final res = await Client().post(Uri.parse(endpoint), body: {"code": code});

    if (res.statusCode >= 400) {
      final ex = Exception("Fail to exchange code for token: ${res.body}");
      traceError(error: ex);
      throw ex;
    }

    String token = jsonDecode(res.body)["token"];

    await FirebaseAuth.instance.signInWithCustomToken(token);
  }

  Future<void> singOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<String?> getPairCode() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final token = await user.getIdToken();
    final endpoint = AppInitFirebase().getEndpoint("generatecode");

    final res = await Client().post(
      Uri.parse(endpoint),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode >= 400) {
      traceError(error: Exception("Fail to generate pair code: ${res.body}"));
      return null;
    }

    return jsonDecode(res.body)["code"];
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
    if (!isDesktopDevice()) {
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
