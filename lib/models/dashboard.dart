// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth.dart';
import 'connection_request.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

/// Response from `GET /dashboard`.
///
/// Named `DashboardSummary` to avoid clashing with the `dashboard` feature
/// folders and widgets.
@freezed
class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    Employee? employee,
    DashboardStats? stats,
    @JsonKey(name: 'recent_connection_requests')
    List<ConnectionRequest>? recentConnectionRequests,
    @JsonKey(name: 'recent_tickets') List<Object?>? recentTickets,
  }) = _DashboardSummary;

  factory DashboardSummary.fromJson(Map<String, Object?> json) => _$DashboardSummaryFromJson(json);
}

/// Numeric counts per entity type, e.g. `stats.connection_requests`.
@freezed
class DashboardCounts with _$DashboardCounts {
  const factory DashboardCounts({
    int? total,
    int? pending,
    int? completed,
  }) = _DashboardCounts;

  factory DashboardCounts.fromJson(Map<String, Object?> json) => _$DashboardCountsFromJson(json);
}

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @JsonKey(name: 'connection_requests') DashboardCounts? connectionRequests,
    DashboardCounts? tickets,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, Object?> json) => _$DashboardStatsFromJson(json);
}
