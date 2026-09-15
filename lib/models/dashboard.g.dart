// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardSummaryImpl _$$DashboardSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardSummaryImpl(
  employee: json['employee'] == null
      ? null
      : Employee.fromJson(json['employee'] as Map<String, dynamic>),
  stats: json['stats'] == null
      ? null
      : DashboardStats.fromJson(json['stats'] as Map<String, dynamic>),
  recentConnectionRequests:
      (json['recent_connection_requests'] as List<dynamic>?)
          ?.map((e) => ConnectionRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
  recentTickets: json['recent_tickets'] as List<dynamic>?,
);

Map<String, dynamic> _$$DashboardSummaryImplToJson(
  _$DashboardSummaryImpl instance,
) => <String, dynamic>{
  'employee': instance.employee,
  'stats': instance.stats,
  'recent_connection_requests': instance.recentConnectionRequests,
  'recent_tickets': instance.recentTickets,
};

_$DashboardCountsImpl _$$DashboardCountsImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardCountsImpl(
  total: (json['total'] as num?)?.toInt(),
  pending: (json['pending'] as num?)?.toInt(),
  completed: (json['completed'] as num?)?.toInt(),
);

Map<String, dynamic> _$$DashboardCountsImplToJson(
  _$DashboardCountsImpl instance,
) => <String, dynamic>{
  'total': instance.total,
  'pending': instance.pending,
  'completed': instance.completed,
};

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(Map<String, dynamic> json) =>
    _$DashboardStatsImpl(
      connectionRequests: json['connection_requests'] == null
          ? null
          : DashboardCounts.fromJson(
              json['connection_requests'] as Map<String, dynamic>,
            ),
      tickets: json['tickets'] == null
          ? null
          : DashboardCounts.fromJson(json['tickets'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DashboardStatsImplToJson(
  _$DashboardStatsImpl instance,
) => <String, dynamic>{
  'connection_requests': instance.connectionRequests,
  'tickets': instance.tickets,
};
