/// Shared detail contract used by Verification and Closing. The parser accepts
/// documented direct and nested field shapes to keep future screens thin.
class TeamStageDetail {
  const TeamStageDetail({
    required this.id,
    required this.requestNumber,
    required this.status,
    this.allowedAction,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.customerArea,
    this.requestedPlanName,
    this.currentTeamName,
    this.fatNode,
    this.locations = const {},
    this.assignedUsers = const [],
    this.notes = const [],
    this.items = const [],
    this.documents = const [],
    this.charges,
    this.timestamps = const {},
    this.stageData = const {},
  });

  final String id;
  final String requestNumber;
  final String status;
  final String? allowedAction;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? customerArea;
  final String? requestedPlanName;
  final String? currentTeamName;
  final TeamStageFatNode? fatNode;
  final Map<String, TeamStageLocation> locations;
  final List<TeamStageUser> assignedUsers;
  final List<TeamStageNote> notes;
  final List<TeamStageItem> items;
  final List<TeamStageDocument> documents;
  final TeamStageCharges? charges;
  final Map<String, String> timestamps;
  final Map<String, String> stageData;

  bool allows(String action) => allowedAction == action;

  factory TeamStageDetail.fromJson(Map<String, dynamic> json) {
    final data = _map(json['data']) ?? json;
    final assigned = _map(data['assigned_users']) ?? const <String, dynamic>{};
    final timestamps = _map(data['timestamps']) ?? const <String, dynamic>{};
    final locations = _map(data['locations']) ?? const <String, dynamic>{};
    final stageData = _map(data['stage_data']) ?? const <String, dynamic>{};
    return TeamStageDetail(
      id: '${data['id'] ?? ''}',
      requestNumber: '${data['request_number'] ?? data['id'] ?? ''}',
      status: '${data['status'] ?? ''}',
      allowedAction: _string(json['allowed_action']) ?? _string(data['allowed_action']),
      customerName: _string(data['customer_name']),
      customerPhone: _string(data['customer_phone']),
      customerAddress: _string(data['customer_address']),
      customerArea: _string(data['customer_area']),
      requestedPlanName: _string(_map(data['requested_plan'])?['name']),
      currentTeamName: _string(_map(data['current_team'])?['name']),
      fatNode: TeamStageFatNode.fromJsonOrNull(
        _map(data['connection_fat_node']) ??
            _map(data['fat_node']) ??
            _map(_map(data['locations'])?['fat_node']),
      ),
      assignedUsers: _assignedUsers(assigned, data),
      locations: {
        for (final entry in locations.entries)
          if (TeamStageLocation.fromJsonOrNull(_map(entry.value)) case final location?) entry.key: location,
      },
      notes: _list(data['notes']).map(TeamStageNote.fromJson).toList(growable: false),
      items: _list(data['items']).map(TeamStageItem.fromJson).toList(growable: false),
      documents: TeamStageDocument.listFrom(data['documents']),
      charges: TeamStageCharges.fromJsonOrNull(_map(data['charges']) ?? data),
      timestamps: {for (final entry in timestamps.entries) if (_string(entry.value) != null) entry.key: _string(entry.value)!},
      stageData: {
        for (final entry in stageData.entries)
          if (entry.value != null && entry.value is! Map && entry.value is! List) entry.key: '${entry.value}',
      },
    );
  }

  static List<TeamStageUser> _assignedUsers(Map<String, dynamic> assigned, Map<String, dynamic> data) {
    const roles = {'surveyor': 'Surveyor', 'technician': 'Technician', 'splicer': 'Splicer'};
    return [
      for (final entry in roles.entries)
        if (TeamStageUser.fromJsonOrNull(entry.value, _map(assigned[entry.key]) ?? _map(data[entry.key])) case final user?) user,
    ];
  }
}

class TeamStageLocation {
  const TeamStageLocation({this.latitude, this.longitude, this.name, this.id});
  final double? latitude;
  final double? longitude;
  final String? name;
  final String? id;
  static TeamStageLocation? fromJsonOrNull(Map<String, dynamic>? json) => json == null
      ? null
      : TeamStageLocation(
          latitude: _number(json['latitude']), longitude: _number(json['longitude']),
          name: _string(json['name']), id: _string(json['id']));
}

class TeamStageFatNode {
  const TeamStageFatNode({this.id, this.name, this.latitude, this.longitude});
  final String? id;
  final String? name;
  final double? latitude;
  final double? longitude;
  static TeamStageFatNode? fromJsonOrNull(Map<String, dynamic>? json) => json == null ? null : TeamStageFatNode(
    id: _string(json['id']), name: _string(json['name']), latitude: _number(json['latitude']), longitude: _number(json['longitude']));
}

class TeamStageUser {
  const TeamStageUser({required this.role, required this.name, this.id});
  final String role;
  final String name;
  final String? id;
  static TeamStageUser? fromJsonOrNull(String role, Map<String, dynamic>? json) {
    final name = _string(json?['name']);
    return name == null || name.isEmpty ? null : TeamStageUser(role: role, name: name, id: _string(json?['id']));
  }
}

class TeamStageNote {
  const TeamStageNote({this.type, this.text, this.voiceNoteUrl});
  final String? type;
  final String? text;
  final String? voiceNoteUrl;
  factory TeamStageNote.fromJson(Map<String, dynamic> json) => TeamStageNote(
    type: _string(json['type']), text: _string(json['note']) ?? _string(json['text']) ?? _string(json['notes']),
    voiceNoteUrl: _string(json['voice_note_url']));
}

class TeamStageItem {
  const TeamStageItem(this.values);
  final Map<String, String> values;
  factory TeamStageItem.fromJson(Map<String, dynamic> json) => TeamStageItem({
    for (final entry in json.entries) if (entry.value != null && entry.value is! Map && entry.value is! List) entry.key: '${entry.value}',
  });
}

class TeamStageDocument {
  const TeamStageDocument({this.name, this.url, this.type});
  final String? name;
  final String? url;
  final String? type;
  factory TeamStageDocument.fromJson(Map<String, dynamic> json) => TeamStageDocument(
    name: _string(json['name']) ?? _string(json['file_name']), url: _string(json['url']) ?? _string(json['document_url']), type: _string(json['type']));

  static List<TeamStageDocument> listFrom(Object? raw) {
    if (raw is List) return _list(raw).map(TeamStageDocument.fromJson).toList(growable: false);
    final map = _map(raw);
    if (map == null) return const [];
    return [
      for (final entry in map.entries)
        if (_string(entry.value)?.isNotEmpty == true)
          TeamStageDocument(name: entry.key.replaceAll('_url', '').replaceAll('_', ' '), url: _string(entry.value)),
    ];
  }
}

class TeamStageCharges {
  const TeamStageCharges({this.connectionChargesMinor, this.subscriptionChargesMinor, this.inventoryCostMinor});
  final int? connectionChargesMinor;
  final int? subscriptionChargesMinor;
  final int? inventoryCostMinor;
  bool get hasAny => connectionChargesMinor != null || subscriptionChargesMinor != null || inventoryCostMinor != null;
  static TeamStageCharges? fromJsonOrNull(Map<String, dynamic>? json) {
    if (json == null) return null;
    final result = TeamStageCharges(
      connectionChargesMinor: _integer(json['connection_charges_minor']), subscriptionChargesMinor: _integer(json['subscription_charges_minor']), inventoryCostMinor: _integer(json['inventory_cost_minor']));
    return result.hasAny ? result : null;
  }
}

Map<String, dynamic>? _map(Object? value) => value is Map ? Map<String, dynamic>.from(value) : null;
List<Map<String, dynamic>> _list(Object? value) => value is List ? value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList() : const [];
String? _string(Object? value) => value?.toString();
double? _number(Object? value) => value is num ? value.toDouble() : double.tryParse('$value');
int? _integer(Object? value) => value is num ? value.toInt() : int.tryParse('$value');
