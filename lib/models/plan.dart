// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan.freezed.dart';
part 'plan.g.dart';

/// A connection plan (e.g. "20 Mbps"). Kept minimal to the fields the mobile
/// app displays. `price_minor` is the price in the smallest currency unit.
@freezed
class Plan with _$Plan {
  const factory Plan({
    required String id,
    required String name,
    @JsonKey(name: 'price_minor') int? priceMinor,
  }) = _Plan;

  factory Plan.fromJson(Map<String, Object?> json) => _$PlanFromJson(json);
}