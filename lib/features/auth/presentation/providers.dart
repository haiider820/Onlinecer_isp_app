import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../models/auth.dart';
import '../data/auth_network.dart';
import '../data/auth_repository.dart';

/// Single app-wide instance of the secure storage wrapper.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage(const FlutterSecureStorage());
});

/// The shared dio-backed API client (adds bearer token, maps errors).
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(storage: ref.watch(secureStorageProvider));
});

/// Real HTTP-backed auth network.
final authNetworkProvider = Provider<AuthNetwork>((ref) {
  return DioAuthNetwork(ref.watch(apiClientProvider));
});

/// Auth repository wiring the auth network + storage.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    network: ref.watch(authNetworkProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

/// Immutable login form state.
class AuthState {
  const AuthState({this.isSubmitting = false, this.errorMessage});

  const AuthState.initial() : this();

  final bool isSubmitting;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  AuthState copyWith({bool? isSubmitting, String? errorMessage, bool clearError = false}) {
    return AuthState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Drives the login flow.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  /// Login currently in flight, if any. A second call while one is running
  /// returns this same future instead of firing a second POST /login — a
  /// double-tap must not double-submit. The field is cleared when the
  /// attempt finishes (success or failure), so a failed attempt can always
  /// be retried.
  Future<LoginResponse?>? _loginInFlight;

  /// Attempts login and, on success, keeps the state error-free so the UI can
  /// navigate. Exceptions are mapped into [AuthState.errorMessage]. While a
  /// login is in flight, a second call returns the in-flight future.
  Future<LoginResponse?> login({
    required String email,
    required String password,
    String? deviceName,
  }) {
    final inFlight = _loginInFlight;
    if (inFlight != null) return inFlight;
    final future = _performLogin(
      email: email,
      password: password,
      deviceName: deviceName,
    );
    _loginInFlight = future;
    return future;
  }

  Future<LoginResponse?> _performLogin({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.login(email: email, password: password, deviceName: deviceName);
      state = state.copyWith(isSubmitting: false);
      return response;
    } catch (e) {
      final message = e is ApiException ? e.message : 'Something went wrong. Please try again.';
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      return null;
    } finally {
      _loginInFlight = null;
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);