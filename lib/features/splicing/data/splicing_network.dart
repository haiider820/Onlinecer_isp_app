import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

abstract interface class SplicingNetwork {
  Future<Map<String, dynamic>> fetchDetail(String id);
  Future<Map<String, dynamic>> completeSplicingMultipart(
    String id, {
    String? voiceNotePath,
    String? voiceNoteMimeType,
  });
}

/// The splicing endpoint is intentionally always multipart, including an
/// empty form when no voice note is attached, per the current API contract.
class DioSplicingNetwork implements SplicingNetwork {
  DioSplicingNetwork(this._client);
  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) =>
      _client.getMap(Endpoints.connectionRequestDetail(id));

  @override
  Future<Map<String, dynamic>> completeSplicingMultipart(
    String id, {
    String? voiceNotePath,
    String? voiceNoteMimeType,
  }) {
    final form = FormData.fromMap({
      if (voiceNotePath != null)
        'voice_note': MultipartFile.fromFileSync(
          voiceNotePath,
          contentType: MediaType.parse(voiceNoteMimeType ?? 'audio/mp4'),
        ),
    });
    return _client.postMultipart(Endpoints.completeSplicing(id), data: form);
  }
}
