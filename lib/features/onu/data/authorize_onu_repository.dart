import '../../../models/authorization_job.dart';
import 'authorize_onu_network.dart';

/// Result of `POST /connection-requests/{request}/authorize-onu` (201).
///
/// The 201 envelope shape is lenient by design: the job id is read from
/// `data.id` / `data.job_id` / top-level `job_id` / top-level `id`, in that
/// order, and the job itself is parsed when the payload carries one.
class AuthorizeOnuResult {
  const AuthorizeOnuResult({this.jobId, this.message, this.job});

  /// The authorization job id the client polls (`null` only when the
  /// backend's 201 carries no id at all — the screen then shows the raw
  /// message instead of guessing).
  final String? jobId;

  /// The backend's message, e.g. "ONU authorization queued".
  final String? message;

  /// The job as returned in the 201, when the backend embeds one.
  final AuthorizationJob? job;

  factory AuthorizeOnuResult.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic> ? rawData : null;
    final nestedJob = data?['authorization_job'];
    final jobMap = nestedJob is Map<String, dynamic>
        ? nestedJob
        : (data != null && data['status'] is String ? data : null);
    final jobId = _asString(data?['id']) ??
        _asString(data?['job_id']) ??
        _asString(json['job_id']) ??
        _asString(json['id']);
    return AuthorizeOnuResult(
      jobId: jobId,
      message: _asString(json['message']) ?? _asString(data?['message']),
      job: jobMap == null ? null : AuthorizationJob.fromJson(jobMap),
    );
  }

  static String? _asString(Object? value) => value?.toString();
}

/// Posts ONU authorizations and polls their jobs (ISPFINAL §9–§10).
///
/// Both request shapes from guide §9 are built here — never in the screen —
/// so the shapes are unit-testable and the screen cannot drift from them.
class AuthorizeOnuRepository {
  AuthorizeOnuRepository({required this.network});

  final AuthorizeOnuNetwork network;

  /// Shape 1 — discovered ONU: exactly
  /// `{direct_olt_id, direct_olt_unconfigured_onu_id, description}`.
  Future<AuthorizeOnuResult> authorizeDiscovered({
    required String requestId,
    required String directOltId,
    required String onuId,
    required String description,
  }) async {
    final map = await network.authorizeOnu(requestId, {
      'direct_olt_id': directOltId,
      'direct_olt_unconfigured_onu_id': onuId,
      'description': description,
    });
    return AuthorizeOnuResult.fromJson(map);
  }

  /// Shape 2 — serial fallback:
  /// `{direct_olt_id, serial_number, line_profile, service_profile, vlan,
  /// user_vlan, gemport, description}`.
  ///
  /// `line_profile` / `service_profile` are sent only when non-empty
  /// (optional when the OLT preset is ready, required otherwise — enforced
  /// by the form, not by dropping them silently here). `vlan` /
  /// `user_vlan` are sent only when given. `gemport` defaults to 1 when
  /// neither a caller value nor a saved preset value is supplied (the
  /// caller passes the preset's gemport when it has one).
  Future<AuthorizeOnuResult> authorizeBySerial({
    required String requestId,
    required String directOltId,
    required String serialNumber,
    String? lineProfile,
    String? serviceProfile,
    int? vlan,
    int? userVlan,
    int? gemport,
    required String description,
  }) async {
    final map = await network.authorizeOnu(requestId, {
      'direct_olt_id': directOltId,
      'serial_number': serialNumber,
      if (lineProfile != null && lineProfile.trim().isNotEmpty)
        'line_profile': lineProfile.trim(),
      if (serviceProfile != null && serviceProfile.trim().isNotEmpty)
        'service_profile': serviceProfile.trim(),
      if (vlan != null) 'vlan': vlan,
      if (userVlan != null) 'user_vlan': userVlan,
      'gemport': gemport ?? 1,
      'description': description,
    });
    return AuthorizeOnuResult.fromJson(map);
  }

  /// `GET /connection-requests/{request}/authorization-jobs/{job}`.
  Future<AuthorizationJob> fetchJob(String requestId, String jobId) async {
    final map = await network.fetchAuthorizationJob(requestId, jobId);
    final rawData = map['data'];
    final data = rawData is Map<String, dynamic> ? rawData : map;
    return AuthorizationJob.fromJson(data);
  }
}
