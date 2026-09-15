// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'team.freezed.dart';
part 'team.g.dart';

/// The employee's team, returned nested in [LoginResponse] and [DashboardResponse].
/// The team record appears in two shapes across the API:
/// - Login: full record (`code`, `flow_order`, `is_active` present).
/// - List/detail `current_team`: only `id`, `name`, `functional_team_type`.
/// The latter three fields are therefore nullable.
@freezed
class Team with _$Team {
  const factory Team({
    required String id,
    required String name,
    String? code,
    @JsonKey(name: 'functional_team_type') required String functionalTeamType,
    @JsonKey(name: 'flow_order') int? flowOrder,
    @JsonKey(name: 'is_active') bool? isActive,
  }) = _Team;

  factory Team.fromJson(Map<String, Object?> json) => _$TeamFromJson(json);
}

/// The optional user record nested inside [LoginResponse].
@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required int id,
    required String name,
    required String email,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, Object?> json) => _$AuthUserFromJson(json);
}
