import 'dart:async';
import 'dart:convert';

import 'package:firebase_dart/firebase_dart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:strumok/app_init_firebase.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/trace.dart';
import 'package:strumok/utils/visual.dart';
import 'package:url_launcher/url_launcher.dart';

const scopes = [
  "https://www.googleapis.com/auth/userinfo.profile",
  "https://www.googleapis.com/auth/userinfo.email",
];

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

class Auth {
  User? _currentUser;
  late final Stream<User?> _userStream;
  final StreamController<User?> _userStreamController = StreamController();

  late final PlatformSignIn platformSignIn;

  static final Auth _instance = Auth._();
  factory Auth() => _instance;

  User? get currentUser => _currentUser;
  Stream<User?> get userUpdate => _userStream;

  Auth._() {
    _userStream = _userStreamController.stream.asBroadcastStream();

    if (isDesktopDevice()) {
      platformSignIn = DesktopPlatformSignIn();
    } else {
      platformSignIn = AndroidPlatformSignIn();
    }

    platformSignIn.authCredential.listen((event) {
      FirebaseAuth.instance.signInWithCredential(event);
    });

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
  }

  Future<void> signIn() async {
    platformSignIn.signIn();
  }

  Future<void> singOut() async {
    await FirebaseAuth.instance.signOut();
    platformSignIn.signOut();
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
}

abstract class PlatformSignIn {
  Stream<AuthCredential> get authCredential;
  void signIn();
  void signOut();
}

class AndroidPlatformSignIn extends PlatformSignIn {
  final StreamController<AuthCredential> _authCredentialStreamController =
      StreamController();

  @override
  Stream<AuthCredential> get authCredential =>
      _authCredentialStreamController.stream;

  AndroidPlatformSignIn() {
    final GoogleSignIn signIn = GoogleSignIn.instance;
    unawaited(
      signIn.initialize().then((_) {
        signIn.authenticationEvents
            .listen(_handleAuthenticationEvent)
            .onError(_handleAuthenticationError);

        signIn.attemptLightweightAuthentication();
      }),
    );
  }

  @override
  void signIn() async {
    await GoogleSignIn.instance.authenticate();
  }

  @override
  void signOut() async {
    await GoogleSignIn.instance.disconnect();
  }

  void _handleAuthenticationError(dynamic error) {
    logger.e("Google suck dick again: $error");
    traceError(error: error);
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    final user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    if (user == null) {
      return;
    }

    final authorization = await user.authorizationClient.authorizeScopes(
      scopes,
    );

    _authCredentialStreamController.sink.add(
      GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: user.authentication.idToken,
      ),
    );
  }
}

class DesktopPlatformSignIn extends PlatformSignIn {
  static ClientId? desktopClientId;

  final StreamController<AuthCredential> _authCredentialStreamController =
      StreamController();

  @override
  Stream<AuthCredential> get authCredential =>
      _authCredentialStreamController.stream;

  @override
  void signIn() async {
    final clientId = await _loadDesktopClientId();
    final credentials = await obtainAccessCredentialsViaUserConsent(
      clientId,
      scopes,
      Client(),
      (uri) {
        launchUrl(Uri.parse(uri));
      },
    );

    _authCredentialStreamController.sink.add(
      GoogleAuthProvider.credential(
        accessToken: credentials.accessToken.data,
        idToken: credentials.idToken,
      ),
    );
  }

  @override
  void signOut() {
    // noop
  }

  static Future<ClientId> _loadDesktopClientId() async {
    const clientSecret = String.fromEnvironment("GOOGLE_AUTH");
    if (desktopClientId == null) {
      final clientSecretJson = json.decode(clientSecret);
      desktopClientId = ClientId.fromJson(clientSecretJson);
    }

    return desktopClientId!;
  }
}
