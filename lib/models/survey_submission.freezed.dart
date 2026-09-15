// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'survey_submission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CompleteSurveyResponse _$CompleteSurveyResponseFromJson(
  Map<String, dynamic> json,
) {
  return _CompleteSurveyResponse.fromJson(json);
}

/// @nodoc
mixin _$CompleteSurveyResponse {
  String? get message => throw _privateConstructorUsedError;
  SurveySubmissionResult? get data => throw _privateConstructorUsedError;

  /// Serializes this CompleteSurveyResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompleteSurveyResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompleteSurveyResponseCopyWith<CompleteSurveyResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompleteSurveyResponseCopyWith<$Res> {
  factory $CompleteSurveyResponseCopyWith(
    CompleteSurveyResponse value,
    $Res Function(CompleteSurveyResponse) then,
  ) = _$CompleteSurveyResponseCopyWithImpl<$Res, CompleteSurveyResponse>;
  @useResult
  $Res call({String? message, SurveySubmissionResult? data});

  $SurveySubmissionResultCopyWith<$Res>? get data;
}

/// @nodoc
class _$CompleteSurveyResponseCopyWithImpl<
  $Res,
  $Val extends CompleteSurveyResponse
>
    implements $CompleteSurveyResponseCopyWith<$Res> {
  _$CompleteSurveyResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompleteSurveyResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed, Object? data = freezed}) {
    return _then(
      _value.copyWith(
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as SurveySubmissionResult?,
          )
          as $Val,
    );
  }

  /// Create a copy of CompleteSurveyResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SurveySubmissionResultCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $SurveySubmissionResultCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CompleteSurveyResponseImplCopyWith<$Res>
    implements $CompleteSurveyResponseCopyWith<$Res> {
  factory _$$CompleteSurveyResponseImplCopyWith(
    _$CompleteSurveyResponseImpl value,
    $Res Function(_$CompleteSurveyResponseImpl) then,
  ) = __$$CompleteSurveyResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, SurveySubmissionResult? data});

  @override
  $SurveySubmissionResultCopyWith<$Res>? get data;
}

/// @nodoc
class __$$CompleteSurveyResponseImplCopyWithImpl<$Res>
    extends
        _$CompleteSurveyResponseCopyWithImpl<$Res, _$CompleteSurveyResponseImpl>
    implements _$$CompleteSurveyResponseImplCopyWith<$Res> {
  __$$CompleteSurveyResponseImplCopyWithImpl(
    _$CompleteSurveyResponseImpl _value,
    $Res Function(_$CompleteSurveyResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompleteSurveyResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed, Object? data = freezed}) {
    return _then(
      _$CompleteSurveyResponseImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as SurveySubmissionResult?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompleteSurveyResponseImpl implements _CompleteSurveyResponse {
  const _$CompleteSurveyResponseImpl({this.message, this.data});

  factory _$CompleteSurveyResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompleteSurveyResponseImplFromJson(json);

  @override
  final String? message;
  @override
  final SurveySubmissionResult? data;

  @override
  String toString() {
    return 'CompleteSurveyResponse(message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompleteSurveyResponseImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, data);

  /// Create a copy of CompleteSurveyResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompleteSurveyResponseImplCopyWith<_$CompleteSurveyResponseImpl>
  get copyWith =>
      __$$CompleteSurveyResponseImplCopyWithImpl<_$CompleteSurveyResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CompleteSurveyResponseImplToJson(this);
  }
}

abstract class _CompleteSurveyResponse implements CompleteSurveyResponse {
  const factory _CompleteSurveyResponse({
    final String? message,
    final SurveySubmissionResult? data,
  }) = _$CompleteSurveyResponseImpl;

  factory _CompleteSurveyResponse.fromJson(Map<String, dynamic> json) =
      _$CompleteSurveyResponseImpl.fromJson;

  @override
  String? get message;
  @override
  SurveySubmissionResult? get data;

  /// Create a copy of CompleteSurveyResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompleteSurveyResponseImplCopyWith<_$CompleteSurveyResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SurveySubmissionResult _$SurveySubmissionResultFromJson(
  Map<String, dynamic> json,
) {
  return _SurveySubmissionResult.fromJson(json);
}

/// @nodoc
mixin _$SurveySubmissionResult {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'request_number')
  String? get requestNumber => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_team')
  Team? get currentTeam => throw _privateConstructorUsedError;
  SurveyTimestamps? get timestamps => throw _privateConstructorUsedError;

  /// Serializes this SurveySubmissionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SurveySubmissionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SurveySubmissionResultCopyWith<SurveySubmissionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SurveySubmissionResultCopyWith<$Res> {
  factory $SurveySubmissionResultCopyWith(
    SurveySubmissionResult value,
    $Res Function(SurveySubmissionResult) then,
  ) = _$SurveySubmissionResultCopyWithImpl<$Res, SurveySubmissionResult>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'request_number') String? requestNumber,
    String? status,
    @JsonKey(name: 'current_team') Team? currentTeam,
    SurveyTimestamps? timestamps,
  });

  $TeamCopyWith<$Res>? get currentTeam;
  $SurveyTimestampsCopyWith<$Res>? get timestamps;
}

/// @nodoc
class _$SurveySubmissionResultCopyWithImpl<
  $Res,
  $Val extends SurveySubmissionResult
>
    implements $SurveySubmissionResultCopyWith<$Res> {
  _$SurveySubmissionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SurveySubmissionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? requestNumber = freezed,
    Object? status = freezed,
    Object? currentTeam = freezed,
    Object? timestamps = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            requestNumber: freezed == requestNumber
                ? _value.requestNumber
                : requestNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentTeam: freezed == currentTeam
                ? _value.currentTeam
                : currentTeam // ignore: cast_nullable_to_non_nullable
                      as Team?,
            timestamps: freezed == timestamps
                ? _value.timestamps
                : timestamps // ignore: cast_nullable_to_non_nullable
                      as SurveyTimestamps?,
          )
          as $Val,
    );
  }

  /// Create a copy of SurveySubmissionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamCopyWith<$Res>? get currentTeam {
    if (_value.currentTeam == null) {
      return null;
    }

    return $TeamCopyWith<$Res>(_value.currentTeam!, (value) {
      return _then(_value.copyWith(currentTeam: value) as $Val);
    });
  }

  /// Create a copy of SurveySubmissionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SurveyTimestampsCopyWith<$Res>? get timestamps {
    if (_value.timestamps == null) {
      return null;
    }

    return $SurveyTimestampsCopyWith<$Res>(_value.timestamps!, (value) {
      return _then(_value.copyWith(timestamps: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SurveySubmissionResultImplCopyWith<$Res>
    implements $SurveySubmissionResultCopyWith<$Res> {
  factory _$$SurveySubmissionResultImplCopyWith(
    _$SurveySubmissionResultImpl value,
    $Res Function(_$SurveySubmissionResultImpl) then,
  ) = __$$SurveySubmissionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'request_number') String? requestNumber,
    String? status,
    @JsonKey(name: 'current_team') Team? currentTeam,
    SurveyTimestamps? timestamps,
  });

  @override
  $TeamCopyWith<$Res>? get currentTeam;
  @override
  $SurveyTimestampsCopyWith<$Res>? get timestamps;
}

/// @nodoc
class __$$SurveySubmissionResultImplCopyWithImpl<$Res>
    extends
        _$SurveySubmissionResultCopyWithImpl<$Res, _$SurveySubmissionResultImpl>
    implements _$$SurveySubmissionResultImplCopyWith<$Res> {
  __$$SurveySubmissionResultImplCopyWithImpl(
    _$SurveySubmissionResultImpl _value,
    $Res Function(_$SurveySubmissionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SurveySubmissionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? requestNumber = freezed,
    Object? status = freezed,
    Object? currentTeam = freezed,
    Object? timestamps = freezed,
  }) {
    return _then(
      _$SurveySubmissionResultImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        requestNumber: freezed == requestNumber
            ? _value.requestNumber
            : requestNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentTeam: freezed == currentTeam
            ? _value.currentTeam
            : currentTeam // ignore: cast_nullable_to_non_nullable
                  as Team?,
        timestamps: freezed == timestamps
            ? _value.timestamps
            : timestamps // ignore: cast_nullable_to_non_nullable
                  as SurveyTimestamps?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SurveySubmissionResultImpl implements _SurveySubmissionResult {
  const _$SurveySubmissionResultImpl({
    this.id,
    @JsonKey(name: 'request_number') this.requestNumber,
    this.status,
    @JsonKey(name: 'current_team') this.currentTeam,
    this.timestamps,
  });

  factory _$SurveySubmissionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SurveySubmissionResultImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'request_number')
  final String? requestNumber;
  @override
  final String? status;
  @override
  @JsonKey(name: 'current_team')
  final Team? currentTeam;
  @override
  final SurveyTimestamps? timestamps;

  @override
  String toString() {
    return 'SurveySubmissionResult(id: $id, requestNumber: $requestNumber, status: $status, currentTeam: $currentTeam, timestamps: $timestamps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SurveySubmissionResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.requestNumber, requestNumber) ||
                other.requestNumber == requestNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentTeam, currentTeam) ||
                other.currentTeam == currentTeam) &&
            (identical(other.timestamps, timestamps) ||
                other.timestamps == timestamps));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    requestNumber,
    status,
    currentTeam,
    timestamps,
  );

  /// Create a copy of SurveySubmissionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SurveySubmissionResultImplCopyWith<_$SurveySubmissionResultImpl>
  get copyWith =>
      __$$SurveySubmissionResultImplCopyWithImpl<_$SurveySubmissionResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SurveySubmissionResultImplToJson(this);
  }
}

abstract class _SurveySubmissionResult implements SurveySubmissionResult {
  const factory _SurveySubmissionResult({
    final String? id,
    @JsonKey(name: 'request_number') final String? requestNumber,
    final String? status,
    @JsonKey(name: 'current_team') final Team? currentTeam,
    final SurveyTimestamps? timestamps,
  }) = _$SurveySubmissionResultImpl;

  factory _SurveySubmissionResult.fromJson(Map<String, dynamic> json) =
      _$SurveySubmissionResultImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'request_number')
  String? get requestNumber;
  @override
  String? get status;
  @override
  @JsonKey(name: 'current_team')
  Team? get currentTeam;
  @override
  SurveyTimestamps? get timestamps;

  /// Create a copy of SurveySubmissionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SurveySubmissionResultImplCopyWith<_$SurveySubmissionResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SurveyTimestamps _$SurveyTimestampsFromJson(Map<String, dynamic> json) {
  return _SurveyTimestamps.fromJson(json);
}

/// @nodoc
mixin _$SurveyTimestamps {
  @JsonKey(name: 'surveyed_at')
  String? get surveyedAt => throw _privateConstructorUsedError;

  /// Serializes this SurveyTimestamps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SurveyTimestamps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SurveyTimestampsCopyWith<SurveyTimestamps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SurveyTimestampsCopyWith<$Res> {
  factory $SurveyTimestampsCopyWith(
    SurveyTimestamps value,
    $Res Function(SurveyTimestamps) then,
  ) = _$SurveyTimestampsCopyWithImpl<$Res, SurveyTimestamps>;
  @useResult
  $Res call({@JsonKey(name: 'surveyed_at') String? surveyedAt});
}

/// @nodoc
class _$SurveyTimestampsCopyWithImpl<$Res, $Val extends SurveyTimestamps>
    implements $SurveyTimestampsCopyWith<$Res> {
  _$SurveyTimestampsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SurveyTimestamps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? surveyedAt = freezed}) {
    return _then(
      _value.copyWith(
            surveyedAt: freezed == surveyedAt
                ? _value.surveyedAt
                : surveyedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SurveyTimestampsImplCopyWith<$Res>
    implements $SurveyTimestampsCopyWith<$Res> {
  factory _$$SurveyTimestampsImplCopyWith(
    _$SurveyTimestampsImpl value,
    $Res Function(_$SurveyTimestampsImpl) then,
  ) = __$$SurveyTimestampsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'surveyed_at') String? surveyedAt});
}

/// @nodoc
class __$$SurveyTimestampsImplCopyWithImpl<$Res>
    extends _$SurveyTimestampsCopyWithImpl<$Res, _$SurveyTimestampsImpl>
    implements _$$SurveyTimestampsImplCopyWith<$Res> {
  __$$SurveyTimestampsImplCopyWithImpl(
    _$SurveyTimestampsImpl _value,
    $Res Function(_$SurveyTimestampsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SurveyTimestamps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? surveyedAt = freezed}) {
    return _then(
      _$SurveyTimestampsImpl(
        surveyedAt: freezed == surveyedAt
            ? _value.surveyedAt
            : surveyedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SurveyTimestampsImpl implements _SurveyTimestamps {
  const _$SurveyTimestampsImpl({@JsonKey(name: 'surveyed_at') this.surveyedAt});

  factory _$SurveyTimestampsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SurveyTimestampsImplFromJson(json);

  @override
  @JsonKey(name: 'surveyed_at')
  final String? surveyedAt;

  @override
  String toString() {
    return 'SurveyTimestamps(surveyedAt: $surveyedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SurveyTimestampsImpl &&
            (identical(other.surveyedAt, surveyedAt) ||
                other.surveyedAt == surveyedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, surveyedAt);

  /// Create a copy of SurveyTimestamps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SurveyTimestampsImplCopyWith<_$SurveyTimestampsImpl> get copyWith =>
      __$$SurveyTimestampsImplCopyWithImpl<_$SurveyTimestampsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SurveyTimestampsImplToJson(this);
  }
}

abstract class _SurveyTimestamps implements SurveyTimestamps {
  const factory _SurveyTimestamps({
    @JsonKey(name: 'surveyed_at') final String? surveyedAt,
  }) = _$SurveyTimestampsImpl;

  factory _SurveyTimestamps.fromJson(Map<String, dynamic> json) =
      _$SurveyTimestampsImpl.fromJson;

  @override
  @JsonKey(name: 'surveyed_at')
  String? get surveyedAt;

  /// Create a copy of SurveyTimestamps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SurveyTimestampsImplCopyWith<_$SurveyTimestampsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
