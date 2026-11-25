/// Builds a real [ApiClient] whose Dio short-circuits every request: the
/// request is captured and a canned 200 map is returned — no live server is
/// ever touched.
///
/// Lets tests assert on the exact wire payload the Dio network
/// implementations build (JSON bodies and FormData fields), which the
/// interface-level fakes in the repository tests cannot see.
import 'package:dio/dio.dart';
import 'package:isp_onlinecer/core/network/api_client.dart';

import '../ispfinal_adversarial/helpers.dart';

class CapturedRequest {
  String? path;
  Object? data;
}

class CapturingApiClient {
  CapturingApiClient(this.responseMap) {
    client = ApiClient(storage: freshStorage(InMemoryFlutterSecureStorage()));
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured.path = options.path;
          captured.data = options.data;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: responseMap,
            ),
          );
        },
      ),
    );
  }

  final Map<String, dynamic> responseMap;
  late final ApiClient client;
  final captured = CapturedRequest();
}

/// Text fields of a captured [FormData] as a plain map.
Map<String, String> formFields(FormData form) => Map.fromEntries(form.fields);

/// File field names of a captured [FormData].
Set<String> formFileFields(FormData form) =>
    form.files.map((entry) => entry.key).toSet();
