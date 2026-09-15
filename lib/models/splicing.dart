import 'team.dart';

/// Splicing-stage detail uses fields that do not occur in the survey and
/// installation detail contracts. Keep it separate rather than overloading
/// [ConnectionRequest] with stage-specific nullable fields.
class SplicingDetail {
  const SplicingDetail({
    required this.id,
    required this.requestNumber,
    required this.status,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.connectionFatNode,
    this.splicer,
    this.splicedAt,
    this.installationLatitude,
    this.installationLongitude,
    this.surveyNotes,
    this.installationNotes,
    this.notes = const [],
    this.allowedAction,
  });

  final String id;
  final String requestNumber;
  final String status;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final SplicingFatNode? connectionFatNode;
  final SplicingPerson? splicer;
  final String? splicedAt;
  final double? installationLatitude;
  final double? installationLongitude;
  final String? surveyNotes;
  final String? installationNotes;
  final List<SplicingNote> notes;
  final String? allowedAction;

  bool get canComplete => allowedAction == 'complete_splicing';

  factory SplicingDetail.fromJson(Map<String, dynamic> json) {
    final data = _map(json['data']) ?? json;
    return SplicingDetail(
      id: '${data['id'] ?? ''}',
      requestNumber: '${data['request_number'] ?? data['id'] ?? ''}',
      status: '${data['status'] ?? ''}',
      customerName: _string(data['customer_name']),
      customerPhone: _string(data['customer_phone']),
      customerAddress: _string(data['customer_address']),
      connectionFatNode: SplicingFatNode.fromJsonOrNull(_map(data['connection_fat_node'])),
      splicer: SplicingPerson.fromJsonOrNull(_map(data['splicer'])),
      splicedAt: _string(data['spliced_at']),
      installationLatitude: _number(data['installation_latitude']),
      installationLongitude: _number(data['installation_longitude']),
      surveyNotes: _string(data['survey_notes']) ?? _string(_map(data['stage_data'])?['survey_notes']),
      installationNotes: _string(data['installation_notes']) ??
          _string(_map(data['stage_data'])?['installation_notes']),
      notes: (data['notes'] as List? ?? const [])
          .whereType<Map>()
          .map((note) => SplicingNote.fromJson(Map<String, dynamic>.from(note)))
          .toList(growable: false),
      allowedAction: _string(json['allowed_action']) ?? _string(data['allowed_action']),
    );
  }
}

class SplicingFatNode {
  const SplicingFatNode({this.id, this.name, this.latitude, this.longitude});
  final String? id;
  final String? name;
  final double? latitude;
  final double? longitude;
  static SplicingFatNode? fromJsonOrNull(Map<String, dynamic>? json) => json == null
      ? null
      : SplicingFatNode(
          id: _string(json['id']), name: _string(json['name']),
          latitude: _number(json['latitude']), longitude: _number(json['longitude']));
}

class SplicingPerson {
  const SplicingPerson({this.id, this.name});
  final String? id;
  final String? name;
  static SplicingPerson? fromJsonOrNull(Map<String, dynamic>? json) => json == null
      ? null
      : SplicingPerson(id: _string(json['id']), name: _string(json['name']));
}

class SplicingNote {
  const SplicingNote({this.type, this.note, this.voiceNoteUrl});
  final String? type;
  final String? note;
  final String? voiceNoteUrl;
  factory SplicingNote.fromJson(Map<String, dynamic> json) => SplicingNote(
      type: _string(json['type']), note: _string(json['note']) ?? _string(json['notes']),
      voiceNoteUrl: _string(json['voice_note_url']));
}

class CompleteSplicingResponse {
  const CompleteSplicingResponse({this.message, this.status, this.splicedAt, this.currentTeam});
  final String? message;
  final String? status;
  final String? splicedAt;
  final Team? currentTeam;
  factory CompleteSplicingResponse.fromJson(Map<String, dynamic> json) {
    final data = _map(json['data']) ?? const <String, dynamic>{};
    final timestamps = _map(data['timestamps']);
    return CompleteSplicingResponse(
      message: _string(json['message']), status: _string(data['status']),
      splicedAt: _string(data['spliced_at']) ?? _string(timestamps?['spliced_at']),
      currentTeam: _map(data['current_team']) == null ? null : Team.fromJson(_map(data['current_team'])!),
    );
  }
}

Map<String, dynamic>? _map(Object? value) => value is Map ? Map<String, dynamic>.from(value) : null;
String? _string(Object? value) => value?.toString();
double? _number(Object? value) => value is num ? value.toDouble() : double.tryParse('$value');
