import 'package:academyapp/core/services/firebase/firebase_bootstrap_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirebaseBootstrapClient implements FirebaseBootstrapClient {
  MockFirebaseBootstrapClient({required this.hasInitializedApp});

  @override
  bool hasInitializedApp;

  int initializeCalls = 0;
  FirebaseOptions? lastOptions;

  @override
  Future<void> initialize({required FirebaseOptions options}) async {
    initializeCalls++;
    lastOptions = options;
    hasInitializedApp = true;
  }
}

void main() {
  group('FirebaseBootstrapService', () {
    const options = FirebaseOptions(
      apiKey: 'api-key',
      appId: 'app-id',
      messagingSenderId: 'sender-id',
      projectId: 'project-id',
    );

    test('inicializa o firebase quando ainda nao existe app', () async {
      final client = MockFirebaseBootstrapClient(hasInitializedApp: false);
      final service = FirebaseBootstrapService(client: client);

      await service.initialize(options: options);

      expect(client.initializeCalls, 1);
      expect(client.lastOptions, options);
    });

    test('nao reinicializa quando o app ja existe', () async {
      final client = MockFirebaseBootstrapClient(hasInitializedApp: true);
      final service = FirebaseBootstrapService(client: client);

      await service.initialize(options: options);

      expect(client.initializeCalls, 0);
    });
  });
}
