// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'waiting_onu.freezed.dart';
part 'waiting_onu.g.dart';

/// A waiting (unconfigured) ONU on a direct OLT, from
/// `GET /lookups/direct-olts/{olt}/waiting-onus` (ISPFINAL §7) and the
/// discover response (ISPFINAL §6).
@freezed
class WaitingOnu with _$WaitingOnu {
  const factory WaitingOnu({
    required String id,
    @JsonKey(name: 'serial_number') String? serialNumber,
    @JsonKey(name: 'pon_port') String? ponPort,
    @JsonKey(name: 'detected_onu_type') String? detectedOnuType,
    @JsonKey(name: 'authorization_status') String? authorizationStatus,
    @JsonKey(name: 'authorization_reason') String? authorizationReason,
    @JsonKey(name: 'last_discovered_at') String? lastDiscoveredAt,
  }) = _WaitingOnu;

  factory WaitingOnu.fromJson(Map<String, Object?> json) => _$WaitingOnuFromJson(json);
}

/// Envelope returned by `GET /lookups/direct-olts/{olt}/waiting-onus`
/// (cached list, ISPFINAL §7).
@freezed
class WaitingOnuList with _$WaitingOnuList {
  const factory WaitingOnuList({
    required List<WaitingOnu> data,
  }) = _WaitingOnuList;

  factory WaitingOnuList.fromJson(Map<String, Object?> json) =>
      _$WaitingOnuListFromJson(json);
}

/// Envelope returned by `POST /lookups/direct-olts/{olt}/discover-waiting-onus`
/// (ISPFINAL §6). `source` tells whether the rows came from a live OLT
/// discovery or the cache; `seen_count` is how many ONUs the OLT reported.
@freezed
class DiscoverWaitingOnusResponse with _$DiscoverWaitingOnusResponse {
  const factory DiscoverWaitingOnusResponse({
    String? message,
    String? source,
    @JsonKey(name: 'seen_count') int? seenCount,
    List<WaitingOnu>? data,
  }) = _DiscoverWaitingOnusResponse;

  factory DiscoverWaitingOnusResponse.fromJson(Map<String, Object?> json) =>
      _$DiscoverWaitingOnusResponseFromJson(json);
}
