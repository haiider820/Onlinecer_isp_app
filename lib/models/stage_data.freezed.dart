// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stage_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StageData _$StageDataFromJson(Map<String, dynamic> json) {
  return _StageData.fromJson(json);
}

/// @nodoc
mixin _$StageData {
  @JsonKey(name: 'survey_notes')
  String? get surveyNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'installation_notes')
  String? get installationNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'olt_device_ownership')
  String? get oltDeviceOwnership => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_wire_used')
  num? get totalWireUsed => throw _privateConstructorUsedError;

  /// Serializes this StageData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StageData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StageDataCopyWith<StageData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StageDataCopyWith<$Res> {
  factory $StageDataCopyWith(StageData value, $Res Function(StageData) then) =
      _$StageDataCopyWithImpl<$Res, StageData>;
  @useResult
  $Res call({
    @JsonKey(name: 'survey_notes') String? surveyNotes,
    @JsonKey(name: 'installation_notes') String? installationNotes,
    @JsonKey(name: 'olt_device_ownership') String? oltDeviceOwnership,
    @JsonKey(name: 'total_wire_used') num? totalWireUsed,
  });
}

/// @nodoc
class _$StageDataCopyWithImpl<$Res, $Val extends StageData>
    implements $StageDataCopyWith<$Res> {
  _$StageDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StageData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? surveyNotes = freezed,
    Object? installationNotes = freezed,
    Object? oltDeviceOwnership = freezed,
    Object? totalWireUsed = freezed,
  }) {
    return _then(
      _value.copyWith(
            surveyNotes: freezed == surveyNotes
                ? _value.surveyNotes
                : surveyNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            installationNotes: freezed == installationNotes
                ? _value.installationNotes
                : installationNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            oltDeviceOwnership: freezed == oltDeviceOwnership
                ? _value.oltDeviceOwnership
                : oltDeviceOwnership // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalWireUsed: freezed == totalWireUsed
                ? _value.totalWireUsed
                : totalWireUsed // ignore: cast_nullable_to_non_nullable
                      as num?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StageDataImplCopyWith<$Res>
    implements $StageDataCopyWith<$Res> {
  factory _$$StageDataImplCopyWith(
    _$StageDataImpl value,
    $Res Function(_$StageDataImpl) then,
  ) = __$$StageDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'survey_notes') String? surveyNotes,
    @JsonKey(name: 'installation_notes') String? installationNotes,
    @JsonKey(name: 'olt_device_ownership') String? oltDeviceOwnership,
    @JsonKey(name: 'total_wire_used') num? totalWireUsed,
  });
}

/// @nodoc
class __$$StageDataImplCopyWithImpl<$Res>
    extends _$StageDataCopyWithImpl<$Res, _$StageDataImpl>
    implements _$$StageDataImplCopyWith<$Res> {
  __$$StageDataImplCopyWithImpl(
    _$StageDataImpl _value,
    $Res Function(_$StageDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StageData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? surveyNotes = freezed,
    Object? installationNotes = freezed,
    Object? oltDeviceOwnership = freezed,
    Object? totalWireUsed = freezed,
  }) {
    return _then(
      _$StageDataImpl(
        surveyNotes: freezed == surveyNotes
            ? _value.surveyNotes
            : surveyNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        installationNotes: freezed == installationNotes
            ? _value.installationNotes
            : installationNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        oltDeviceOwnership: freezed == oltDeviceOwnership
            ? _value.oltDeviceOwnership
            : oltDeviceOwnership // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalWireUsed: freezed == totalWireUsed
            ? _value.totalWireUsed
            : totalWireUsed // ignore: cast_nullable_to_non_nullable
                  as num?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StageDataImpl implements _StageData {
  const _$StageDataImpl({
    @JsonKey(name: 'survey_notes') this.surveyNotes,
    @JsonKey(name: 'installation_notes') this.installationNotes,
    @JsonKey(name: 'olt_device_ownership') this.oltDeviceOwnership,
    @JsonKey(name: 'total_wire_used') this.totalWireUsed,
  });

  factory _$StageDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StageDataImplFromJson(json);

  @override
  @JsonKey(name: 'survey_notes')
  final String? surveyNotes;
  @override
  @JsonKey(name: 'installation_notes')
  final String? installationNotes;
  @override
  @JsonKey(name: 'olt_device_ownership')
  final String? oltDeviceOwnership;
  @override
  @JsonKey(name: 'total_wire_used')
  final num? totalWireUsed;

  @override
  String toString() {
    return 'StageData(surveyNotes: $surveyNotes, installationNotes: $installationNotes, oltDeviceOwnership: $oltDeviceOwnership, totalWireUsed: $totalWireUsed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StageDataImpl &&
            (identical(other.surveyNotes, surveyNotes) ||
                other.surveyNotes == surveyNotes) &&
            (identical(other.installationNotes, installationNotes) ||
                other.installationNotes == installationNotes) &&
            (identical(other.oltDeviceOwnership, oltDeviceOwnership) ||
                other.oltDeviceOwnership == oltDeviceOwnership) &&
            (identical(other.totalWireUsed, totalWireUsed) ||
                other.totalWireUsed == totalWireUsed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    surveyNotes,
    installationNotes,
    oltDeviceOwnership,
    totalWireUsed,
  );

  /// Create a copy of StageData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StageDataImplCopyWith<_$StageDataImpl> get copyWith =>
      __$$StageDataImplCopyWithImpl<_$StageDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StageDataImplToJson(this);
  }
}

abstract class _StageData implements StageData {
  const factory _StageData({
    @JsonKey(name: 'survey_notes') final String? surveyNotes,
    @JsonKey(name: 'installation_notes') final String? installationNotes,
    @JsonKey(name: 'olt_device_ownership') final String? oltDeviceOwnership,
    @JsonKey(name: 'total_wire_used') final num? totalWireUsed,
  }) = _$StageDataImpl;

  factory _StageData.fromJson(Map<String, dynamic> json) =
      _$StageDataImpl.fromJson;

  @override
  @JsonKey(name: 'survey_notes')
  String? get surveyNotes;
  @override
  @JsonKey(name: 'installation_notes')
  String? get installationNotes;
  @override
  @JsonKey(name: 'olt_device_ownership')
  String? get oltDeviceOwnership;
  @override
  @JsonKey(name: 'total_wire_used')
  num? get totalWireUsed;

  /// Create a copy of StageData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StageDataImplCopyWith<_$StageDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
