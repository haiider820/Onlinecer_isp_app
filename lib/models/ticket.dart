import 'connection_request.dart' show PaginationMeta;

/// Ticket summary returned by the dashboard and ticket list API.
class Ticket {
  const Ticket({
    required this.id,
    this.ticketNumber,
    this.subject,
    this.priority,
    this.status,
    this.customerName,
    this.updatedAt,
  });

  final String id;
  final String? ticketNumber;
  final String? subject;
  final String? priority;
  final String? status;
  final String? customerName;
  final String? updatedAt;

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: '${json['id'] ?? ''}',
        ticketNumber: json['ticket_number']?.toString(),
        subject: json['subject']?.toString(),
        priority: json['priority']?.toString(),
        status: json['status']?.toString(),
        customerName: json['customer_name']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );
}

/// Typed dashboard/list representation. Kept as an aliasing wrapper type so
/// a future ticket-detail response can extend [Ticket] independently.
class TicketSummary {
  const TicketSummary({required this.data, required this.meta});
  final List<Ticket> data;
  final PaginationMeta meta;

  factory TicketSummary.fromJson(Map<String, dynamic> json) => TicketSummary(
        data: (json['data'] as List? ?? const [])
            .whereType<Map>()
            .map((item) => Ticket.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false),
        meta: PaginationMeta.fromJson(
          Map<String, Object?>.from(json['meta'] as Map? ?? const {}),
        ),
      );
}

/// Full response from `GET /tickets/{id}`. `next_status` deliberately lives
/// on the outer response envelope, as defined by the tickets API.
class TicketDetail {
  const TicketDetail({
    required this.ticket,
    this.description,
    this.customerName,
    this.category,
    this.channel,
    this.assignedTeam,
    this.activities = const [],
    this.nextStatus,
  });

  final Ticket ticket;
  final String? description;
  final String? customerName;
  final String? category;
  final String? channel;
  final String? assignedTeam;
  final List<TicketActivity> activities;
  final String? nextStatus;

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final assignedTeam = data['assigned_team'];
    final category = data['category'];
    return TicketDetail(
      ticket: Ticket.fromJson(data),
      description: data['description']?.toString(),
      customerName: data['customer_name']?.toString(),
      category: category is Map ? category['name']?.toString() : category?.toString(),
      channel: data['channel']?.toString(),
      assignedTeam: assignedTeam is Map
          ? assignedTeam['name']?.toString()
          : assignedTeam?.toString(),
      activities: (data['activities'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => TicketActivity.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      nextStatus: json['next_status']?.toString(),
    );
  }
}

class TicketActivity {
  const TicketActivity({
    this.type,
    this.oldValue,
    this.newValue,
    this.message,
    this.isInternal = false,
    this.userName,
    this.employeeName,
    this.createdAt,
  });

  final String? type;
  final String? oldValue;
  final String? newValue;
  final String? message;
  final bool isInternal;
  final String? userName;
  final String? employeeName;
  final String? createdAt;

  bool get isStatusChange => type == 'status_change';
  String? get author => employeeName ?? userName;

  factory TicketActivity.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final employee = json['employee'];
    return TicketActivity(
      type: json['type']?.toString(),
      oldValue: json['old_value']?.toString(),
      newValue: json['new_value']?.toString(),
      message: json['message']?.toString(),
      isInternal: json['is_internal'] == true || json['is_internal'] == 1,
      userName: user is Map ? user['name']?.toString() : null,
      employeeName: employee is Map ? employee['name']?.toString() : null,
      createdAt: json['created_at']?.toString(),
    );
  }
}

/// Result returned after advancing a ticket to its next workflow status.
class TicketAdvanceResult {
  const TicketAdvanceResult({this.status});

  final String? status;

  factory TicketAdvanceResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic>
        ? data
        : data is Map
            ? Map<String, dynamic>.from(data)
            : json;
    return TicketAdvanceResult(status: payload['status']?.toString());
  }
}
