import 'direct_olt.dart';

/// OLT profiles + VLANs from `GET /lookups/direct-olts/{olt}/profiles`
/// (guide §15, Rev 1.0).
///
/// Hand-written lenient parsing (like [TeamStageDetail], no codegen): the
/// guide's shape is a flat envelope — `{olt, line_profiles[],
/// service_profiles[], vlans[], authorization_preset}` — and the app must
/// never crash on a missing or oddly-shaped list. `value` is the payload
/// value, `label` is the display text; both VLAN dropdowns use the same
/// `vlans` array with independent selections.
class OltProfiles {
  const OltProfiles({
    this.olt,
    this.lineProfiles = const [],
    this.serviceProfiles = const [],
    this.vlans = const [],
    this.authorizationPreset,
  });

  final OltSummary? olt;
  final List<OltProfileOption> lineProfiles;
  final List<OltProfileOption> serviceProfiles;
  final List<OltVlanOption> vlans;
  final AuthorizationPreset? authorizationPreset;

  factory OltProfiles.fromJson(Map<String, dynamic> json) {
    // Defensive unwrap: some Laravel resource responses nest the envelope
    // under `data`; the documented shape is flat, so only unwrap when the
    // flat shape has no profile lists at all.
    var map = json;
    if (map['line_profiles'] == null &&
        map['service_profiles'] == null &&
        map['vlans'] == null &&
        map['data'] is Map<String, dynamic>) {
      map = map['data'] as Map<String, dynamic>;
    }
    return OltProfiles(
      olt: OltSummary.fromJsonOrNull(_map(map['olt'])),
      lineProfiles: _list(map['line_profiles'])
          .map(OltProfileOption.fromJsonOrNull)
          .whereType<OltProfileOption>()
          .toList(growable: false),
      serviceProfiles: _list(map['service_profiles'])
          .map(OltProfileOption.fromJsonOrNull)
          .whereType<OltProfileOption>()
          .toList(growable: false),
      vlans: _list(map['vlans'])
          .map(OltVlanOption.fromJsonOrNull)
          .whereType<OltVlanOption>()
          .toList(growable: false),
      authorizationPreset: map['authorization_preset'] is Map<String, dynamic>
          ? AuthorizationPreset.fromJson(
              Map<String, Object?>.from(
                map['authorization_preset'] as Map,
              ),
            )
          : null,
    );
  }
}

class OltSummary {
  const OltSummary({this.id, this.name, this.vendor});

  final String? id;
  final String? name;
  final String? vendor;

  static OltSummary? fromJsonOrNull(Map<String, dynamic>? json) {
    if (json == null) return null;
    return OltSummary(
      id: _string(json['id']),
      name: _string(json['name']),
      vendor: _string(json['vendor']),
    );
  }
}

/// One line/service profile option: `value` goes in the authorize payload,
/// `label` is shown in the dropdown.
class OltProfileOption {
  const OltProfileOption({
    required this.value,
    required this.label,
    this.huaweiProfileId,
  });

  final String value;
  final String label;
  final int? huaweiProfileId;

  static OltProfileOption? fromJsonOrNull(Map<String, dynamic> json) {
    final value = _string(json['value']);
    if (value == null || value.isEmpty) return null;
    return OltProfileOption(
      value: value,
      label: _string(json['label']) ?? value,
      huaweiProfileId: _integer(json['huawei_profile_id']),
    );
  }
}

/// One VLAN option: `value` (int) goes in the authorize payload, `label` is
/// shown in the dropdown. A string-encoded value (`"346"`) is accepted too.
class OltVlanOption {
  const OltVlanOption({
    required this.value,
    required this.label,
    this.vlanId,
    this.name,
  });

  final int value;
  final String label;
  final int? vlanId;
  final String? name;

  static OltVlanOption? fromJsonOrNull(Map<String, dynamic> json) {
    final value = _integer(json['value']) ?? _integer(json['vlan_id']);
    if (value == null) return null;
    return OltVlanOption(
      value: value,
      label: _string(json['label']) ?? 'VLAN $value',
      vlanId: _integer(json['vlan_id']),
      name: _string(json['name']),
    );
  }
}

Map<String, dynamic>? _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;
List<Map<String, dynamic>> _list(Object? value) => value is List
    ? value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
    : const [];
String? _string(Object? value) => value?.toString();
int? _integer(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value');
