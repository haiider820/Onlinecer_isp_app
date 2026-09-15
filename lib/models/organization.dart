import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization.freezed.dart';
part 'organization.g.dart';

/// Shared within both [LoginResponse.employee] and [ConnectionRequestDetail.requestedPlan].
@freezed
class Organization with _$Organization {
  const factory Organization({
    required String id,
    required String name,
  }) = _Organization;

  factory Organization.fromJson(Map<String, Object?> json) => _$OrganizationFromJson(json);
}
