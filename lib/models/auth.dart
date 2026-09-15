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
  }) = _Employee;

  factory Employee.fromJson(Map<String, Object?> json) => _$EmployeeFromJson(json);
}