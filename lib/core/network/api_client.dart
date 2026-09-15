import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import 'api_exceptions.dart';

/// Central wrapper around [Dio] for the mobile REST API.
///
/// Responsibilities:
/// - Build the single dio instance pointed at [AppConstants.baseUrl].
/// - Attach `Authorization: Bearer <token>` via [AuthInterceptor].
/// - Log requests/responses in debug builds only.
/// - Convert every failure into a typed [ApiException] for the UI layer.
class ApiClient {
  ApiClient._(this._dio, this._storage);

  factory ApiClient({required SecureStorage storage}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (AppConstants.isDebug) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }

    final client = ApiClient._(dio, storage);
    dio.interceptors.add(AuthInterceptor(storage));
    return client;
  }

  final Dio _dio;
  final SecureStorage _storage;

  /// Whether an automatic logout is in progress (guards against retries
  /// triggering repeated 401 handling).
  bool _loggingOut = false;

  Dio get dio => _dio;

  /// Executes a unary GET expecting a [Map] body.
  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _guard(() => _dio.get<Object?>(path, queryParameters: query));
    return _asMap(response);
  }

  /// Executes a unary GET expecting a [List] body.
  Future<Object?> getRaw(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _guard(() => _dio.get<Object?>(path, queryParameters: query));
    return response.data;
  }

  /// Executes a POST with a JSON body, expecting a [Map].
  Future<Map<String, dynamic>> postMap(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    final response = await _guard(() => _dio.post<Object?>(path, data: data, queryParameters: query));
    return _asMap(response);
  }

  /// Executes a multipart POST (for voice-note uploads), expecting a [Map].
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    FormData? data,
    Map<String, dynamic>? query,
  }) async {
    final response =
        await _guard(() => _dio.post<Object?>(path, data: data, queryParameters: query));
    return _asMap(response);
  }

  Future<Response<Object?>> _guard(Future<Response<Object?>> Function() send) async {
    try {
      return await send();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Extracts the server `message` from a dio error response.
  Object? _serverMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) return data['message'];
    return null;
  }

  ApiException _mapDioError(DioException e) {
    final isNetwork = e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown && e.error is! Map;

    final raw = _serverMessage(e);

    final exception = ApiErrorMapper.surfacing(
      serverMessage: raw?.toString(),
      statusCode: e.response?.statusCode,
      isNetworkError: isNetwork,
    );

    // Central 401 handling: clear the session so the router can redirect
    // to login instead of every screen handling it independently.
    if (exception.isUnauthorized && !_loggingOut) {
      _loggingOut = true;
      // Fire-and-forget; failures here (rare) shouldn't crash the request.
      unawaited(_storage.clearSession());
      _loggingOut = false;
    }

    return exception;
  }

  Map<String, dynamic> _asMap(Response<Object?> response) {
    final data = response.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw const ServerFromException();
  }
}

/// Adds `Authorization: Bearer <token>` to every request and leaves requests
/// unauthenticated when no token is stored (e.g. before login).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

