import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../features/auth/presentation/providers.dart' show secureStorageProvider;
import '../../../models/auth.dart';
import '../data/scanner_network.dart';
import '../data/scanner_repository.dart';

/// The scanner-session dio client: same base URL, interceptor reads
/// `scanner.token` (never the employee token).
final scannerApiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.scanner(storage: ref.watch(secureStorageProvider));
});

/// Real HTTP-backed scanner network.
final scannerNetworkProvider = Provider<ScannerNetwork>((ref) {
  return DioScannerNetwork(ref.watch(scannerApiClientProvider));
});

/// Scanner repository wiring the scanner network + storage.
final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return ScannerRepository(
    network: ref.watch(scannerNetworkProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

/// Immutable scanner-login form state (mirrors AuthState).
class ScannerAuthState {
  const ScannerAuthState({this.isSubmitting = false, this.errorMessage});

  const ScannerAuthState.initial() : this();

  final bool isSubmitting;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  ScannerAuthState copyWith({bool? isSubmitting, String? errorMessage, bool clearError = false}) {
    return ScannerAuthState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Drives the scanner login flow (mirrors AuthController).
class ScannerAuthController extends Notifier<ScannerAuthState> {
  @override
  ScannerAuthState build() => const ScannerAuthState.initial();

  /// Attempts scanner login and, on success, keeps the state error-free so
  /// the UI can navigate. Exceptions are mapped into
  /// [ScannerAuthState.errorMessage].
  Future<LoginResponse?> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final repo = ref.read(scannerRepositoryProvider);
      final response =
          await repo.login(email: email, password: password, deviceName: deviceName);
      state = state.copyWith(isSubmitting: false);
      return response;
    } catch (e) {
      final message = e is ApiException ? e.message : 'Something went wrong. Please try again.';
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      return null;
    }
  }

  /// Signs the scanner session out (scanner keys only) and resets the form
  /// state. Returns false only if the local clear itself throws.
  Future<bool> logout() async {
    try {
      await ref.read(scannerRepositoryProvider).logout();
      state = const ScannerAuthState.initial();
      return true;
    } catch (e) {
      final message = e is ApiException ? e.message : 'Something went wrong. Please try again.';
      state = state.copyWith(errorMessage: message);
      return false;
    }
  }
}

final scannerAuthControllerProvider =
    NotifierProvider<ScannerAuthController, ScannerAuthState>(ScannerAuthController.new);

/// Silent restore of the scanner session (`GET /me`): a stored token that
/// verifies yields the session; no token / 401 yields null (show the form).
final scannerSessionProvider = FutureProvider<ScannerSession?>((ref) async {
  return ref.watch(scannerRepositoryProvider).restoreSession();
});
