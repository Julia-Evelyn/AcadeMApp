import 'package:firebase_core/firebase_core.dart';

abstract class FirebaseBootstrapClient {
  bool get hasInitializedApp;

  Future<void> initialize({required FirebaseOptions options});
}

class FirebaseCoreBootstrapClient implements FirebaseBootstrapClient {
  @override
  bool get hasInitializedApp => Firebase.apps.isNotEmpty;

  @override
  Future<void> initialize({required FirebaseOptions options}) {
    return Firebase.initializeApp(options: options);
  }
}

class FirebaseBootstrapService {
  FirebaseBootstrapService({FirebaseBootstrapClient? client})
    : _client = client ?? FirebaseCoreBootstrapClient();

  final FirebaseBootstrapClient _client;

  Future<void> initialize({required FirebaseOptions options}) async {
    if (_client.hasInitializedApp) {
      return;
    }

    await _client.initialize(options: options);
  }
}
