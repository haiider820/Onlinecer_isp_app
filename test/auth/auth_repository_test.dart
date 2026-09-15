import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/data/auth_network.dart';
import 'package:isp_onlinecer/features/auth/data/auth_repository.dart';

/// In-memory [FlutterSecureStorage] so [SecureStorage] can be tested headlessly.
class _FakeFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.clear();
  }
}

/// Serves a serialized login response and records what was sent.
class _FakeAuthNetwork implements AuthNetwork {
  _FakeAuthNetwork(this.serializedResponse);

  final Map<String, Object?> serializedResponse;
  final List<Map<String, Object?>> requests = <Map<String, Object?>>[];

  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) async {
    requests.add(body);
    return serializedResponse;
  }

  @override
  Future<Map<String, dynamic>> getMe() async => <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> postLogout() async => <String, dynamic>{};
}

Map<String, Object?> loginJson() => <String, Object?>{
      'message': 'Login successful.',
      'token_type': 'Bearer',
      'token': 'plain_token_here',
      'expires_at': '2026-10-10T11:00:00.000000Z',
      'user': <String, Object?>{'id': 25, 'name': 'Ahmed Raza', 'email': 'a@b.pk'},
      'employee': <String, Object?>{
        'id': 'employee_uuid',
        'user_id': 25,
        'name': 'Ahmed Raza',
        'email': 'a@b.pk',
        'team': <String, Object?>{
          'id': 'team_uuid',
          'name': 'Survey Team',
          'functional_team_type': 'survey',
        },
      },
      'permissions': <Object?>[],
      'permission_labels': <Object?>[],
    };

void main() {
  late _FakeFlutterSecureStorage backing;
  late SecureStorage storage;
  late _FakeAuthNetwork network;

  setUp(() {
    backing = _FakeFlutterSecureStorage();
    storage = SecureStorage(backing);
    network = _FakeAuthNetwork(loginJson());
  });

  AuthRepository buildRepo() => AuthRepository(network: network, storage: storage);

  group('AuthRepository.login', () {
    test('sends exact login body (email trimmed, device_name when present)', () async {
      await buildRepo().login(
        email: '  ahmed.raza@malikfiber.pk  ',
        password: 'MF!Survey#26A',
        deviceName: 'Survey Android',
      );

      expect(network.requests, hasLength(1));
      final body = network.requests.single;
      expect(body['email'], 'ahmed.raza@malikfiber.pk');
      expect(body['password'], 'MF!Survey#26A');
      expect(body['device_name'], 'Survey Android');
    });

    test('omits device_name when not provided', () async {
      await buildRepo().login(email: 'a@b.pk', password: 'pw');

      final body = network.requests.single;
      expect(body.containsKey('device_name'), isFalse);
    });

    test('persists token, token_type, and functional_team_type', () async {
      await buildRepo().login(email: 'a@b.pk', password: 'pw');

      expect(await storage.getToken(), 'plain_token_here');
      expect(await storage.getTokenType(), 'Bearer');
      expect(await storage.isLoggedIn(), isTrue);
      expect(await storage.getFunctionalTeamType(), 'survey');
    });

    test('propagates network exceptions (not swallowed)', () async {
      final throwing = _ThrowingAuthNetwork();
      final repo = AuthRepository(network: throwing, storage: storage);

      expect(
        () => repo.login(email: 'a@b.pk', password: 'pw'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

class _ThrowingAuthNetwork implements AuthNetwork {
  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) async {
    throw Exception('server unreachable');
  }

  @override
  Future<Map<String, dynamic>> getMe() async {
    throw Exception('server unreachable');
  }

  @override
  Future<Map<String, dynamic>> postLogout() async {
    throw Exception('server unreachable');
  }
}