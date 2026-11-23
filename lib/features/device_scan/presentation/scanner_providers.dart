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

  /// Login currently in flight, if any — same double-tap guard as
  /// [AuthController]: a second call while one is running returns this same
  /// future instead of firing a second POST /login. Cleared when the
  /// attempt finishes, so a failed attempt can always be retried.
  Future<LoginResponse?>? _loginInFlight;

  /// Attempts scanner login and, on success, keeps the state error-free so
  /// the UI can navigate. Exceptions are mapped into
  /// [ScannerAuthState.errorMessage]. While a login is in flight, a second
  /// call returns the in-flight future.
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
      final repo = ref.read(scannerRepositoryProvider);
      final response =
          await repo.login(email: email, password: password, deviceName: deviceName);
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

  /// Signs the scanner session out (scanner keys only) and resets the form
  /// state. Returns false only if the local clear itself throws.
  ///
  /// D1: the session provider is a plain (non-autoDispose) FutureProvider,
  /// so it must be forced to re-run restore on logout — otherwise it keeps
  /// serving the pre-logout session until the app restarts and the scanner
  /// form bounces away from itself.
  ///
  /// Two steps, in this order, and the order matters:
  /// 1. `ref.refresh` BEFORE the storage clear forces a synchronous
  /// rebuild while the token is still stored, so the re-run restore
  /// actually reaches the network (`GET /me`). A post-clear invalidate
  /// alone can never do that: `restoreSession` returns early when no
  /// token is stored, so the re-run would complete without a network
  /// call and the provider would never be proven fresh.
  /// 2. `ref.invalidate` AFTER the clear marks the provider stale, so
  /// the next read re-runs restore with no token stored and yields
  /// null (the form) instead of the cached session.
  /// (`ref.invalidate` alone only schedules a refresh at the end of the
  /// event loop, and any read flushes it synchronously — neither timing
  /// can produce a network re-run after the token is gone.)
  Future<bool> logout() async {
    try {
      // The refresh is wanted for its side effect only (a synchronous
      // rebuild while the token is still stored); its result is discarded.
      final _ = ref.refresh(scannerSessionProvider);
      await ref.read(scannerRepositoryProvider).logout();
      ref.invalidate(scannerSessionProvider);
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
