// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'organization.dart';
import 'team.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

/// Response from `POST /login`.
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String message,
    @JsonKey(name: 'token_type') required String tokenType,
    required String token,
    @JsonKey(name: 'expires_at') String? expiresAt,
    // ISPFINAL §1: distinguishes the employee mobile app from the
    // device-scanner account flow. Nullable: old payloads omit it, and a
    // missing value must NEVER fail login (employee fallback).
    @JsonKey(name: 'account_type') String? accountType,
    @JsonKey(name: 'user') AuthUser? user,
    Employee? employee,
    List<String>? permissions,
    @JsonKey(name: 'permission_labels') List<String>? permissionLabels,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, Object?> json) => _$LoginResponseFromJson(json);
}

/// The employee record as returned inside the login response.
@freezed
class Employee with _$Employee {
  const factory Employee({
    required String id,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'employee_code') String? employeeCode,
    required String name,
    // Nullable: the dashboard endpoint may return the employee without email.
    String? email,
    String? phone,
    @JsonKey(name: 'is_active') bool? isActive,
    Organization? organization,
    Team? team,
    // ISPFINAL §1: the guide shows employee.branch / employee.sub_branch.
    // Parsed leniently as maps (same shape as ConnectionRequest.subBranch):
    // only the `name` is stored (employee.branch_name /
    // employee.sub_branch_name); an unexpected shape must never break login.
    @JsonKey(fromJson: _lenientMap) Map<String, Object?>? branch,
    @JsonKey(name: 'sub_branch', fromJson: _lenientMap)
    Map<String, Object?>? subBranch,
  }) = _Employee;

  factory Employee.fromJson(Map<String, Object?> json) => _$EmployeeFromJson(json);
}

/// Returns the value as a map, or null for anything else (a wrong-typed
/// branch/sub_branch in the payload must never break login parsing).
Map<String, Object?>? _lenientMap(Object? value) {
  if (value is Map) return Map<String, Object?>.from(value);
  return null;
}