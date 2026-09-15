// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'stage_data.freezed.dart';
part 'stage_data.g.dart';

/// Per-stage working data captured on a connection request, surfaced by the
/// detail endpoint's `stage_data` block.
///
/// Every field is nullable because the block fills in progressively: a survey
/// runs before an installation, so an installation-stage request may already
/// carry `survey_notes` while its `installation_*` fields are still unknown.
@freezed
class StageData with _$StageData {
  const factory StageData({
    @JsonKey(name: 'survey_notes') String? surveyNotes,
    @JsonKey(name: 'installation_notes') String? installationNotes,
    @JsonKey(name: 'olt_device_ownership') String? oltDeviceOwnership,
    @JsonKey(name: 'total_wire_used') num? totalWireUsed,
  }) = _StageData;

  factory StageData.fromJson(Map<String, Object?> json) => _$StageDataFromJson(json);
}