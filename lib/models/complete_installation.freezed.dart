// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complete_installation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CompleteInstallationResponse _$CompleteInstallationResponseFromJson(
  Map<String, dynamic> json,
) {
  return _CompleteInstallationResponse.fromJson(json);
}

/// @nodoc
mixin _$CompleteInstallationResponse {
  String? get message => throw _privateConstructorUsedError;
  InstallationSubmissionResult? get data => throw _privateConstructorUsedError;

  /// Serializes this CompleteInstallationResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompleteInstallationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompleteInstallationResponseCopyWith<CompleteInstallationResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompleteInstallationResponseCopyWith<$Res> {
  factory $CompleteInstallationResponseCopyWith(
    CompleteInstallationResponse value,
    $Res Function(CompleteInstallationResponse) then,
  ) =
      _$CompleteInstallationResponseCopyWithImpl<
        $Res,
        CompleteInstallationResponse
      >;
  @useResult
  $Res call({String? message, InstallationSubmissionResult? data});

  $InstallationSubmissionResultCopyWith<$Res>? get data;
}

/// @nodoc
class _$CompleteInstallationResponseCopyWithImpl<
  $Res,
  $Val extends CompleteInstallationResponse
>
    implements $CompleteInstallationResponseCopyWith<$Res> {
  _$CompleteInstallationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompleteInstallationResponse
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
                      as InstallationSubmissionResult?,
          )
          as $Val,
    );
  }

  /// Create a copy of CompleteInstallationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstallationSubmissionResultCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $InstallationSubmissionResultCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CompleteInstallationResponseImplCopyWith<$Res>
    implements $CompleteInstallationResponseCopyWith<$Res> {
  factory _$$CompleteInstallationResponseImplCopyWith(
    _$CompleteInstallationResponseImpl value,
    $Res Function(_$CompleteInstallationResponseImpl) then,
  ) = __$$CompleteInstallationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, InstallationSubmissionResult? data});

  @override
  $InstallationSubmissionResultCopyWith<$Res>? get data;
}

/// @nodoc
class __$$CompleteInstallationResponseImplCopyWithImpl<$Res>
    extends
        _$CompleteInstallationResponseCopyWithImpl<
          $Res,
          _$CompleteInstallationResponseImpl
        >
    implements _$$CompleteInstallationResponseImplCopyWith<$Res> {
  __$$CompleteInstallationResponseImplCopyWithImpl(
    _$CompleteInstallationResponseImpl _value,
    $Res Function(_$CompleteInstallationResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompleteInstallationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed, Object? data = freezed}) {
    return _then(
      _$CompleteInstallationResponseImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as InstallationSubmissionResult?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompleteInstallationResponseImpl
    implements _CompleteInstallationResponse {
  const _$CompleteInstallationResponseImpl({this.message, this.data});

  factory _$CompleteInstallationResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CompleteInstallationResponseImplFromJson(json);

  @override
  final String? message;
  @override
  final InstallationSubmissionResult? data;

  @override
  String toString() {
    return 'CompleteInstallationResponse(message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompleteInstallationResponseImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, data);

  /// Create a copy of CompleteInstallationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompleteInstallationResponseImplCopyWith<
    _$CompleteInstallationResponseImpl
  >
  get copyWith =>
      __$$CompleteInstallationResponseImplCopyWithImpl<
        _$CompleteInstallationResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompleteInstallationResponseImplToJson(this);
  }
}

abstract class _CompleteInstallationResponse
    implements CompleteInstallationResponse {
  const factory _CompleteInstallationResponse({
    final String? message,
    final InstallationSubmissionResult? data,
  }) = _$CompleteInstallationResponseImpl;

  factory _CompleteInstallationResponse.fromJson(Map<String, dynamic> json) =
      _$CompleteInstallationResponseImpl.fromJson;

  @override
  String? get message;
  @override
  InstallationSubmissionResult? get data;

  /// Create a copy of CompleteInstallationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompleteInstallationResponseImplCopyWith<
    _$CompleteInstallationResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

InstallationSubmissionResult _$InstallationSubmissionResultFromJson(
  Map<String, dynamic> json,
) {
  return _InstallationSubmissionResult.fromJson(json);
}

/// @nodoc
mixin _$InstallationSubmissionResult {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'request_number')
  String? get requestNumber => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_team')
  Team? get currentTeam => throw _privateConstructorUsedError;
  InstallationTimestamps? get timestamps => throw _privateConstructorUsedError;

  /// Serializes this InstallationSubmissionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InstallationSubmissionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InstallationSubmissionResultCopyWith<InstallationSubmissionResult>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstallationSubmissionResultCopyWith<$Res> {
  factory $InstallationSubmissionResultCopyWith(
    InstallationSubmissionResult value,
    $Res Function(InstallationSubmissionResult) then,
  ) =
      _$InstallationSubmissionResultCopyWithImpl<
        $Res,
        InstallationSubmissionResult
      >;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'request_number') String? requestNumber,
    String? status,
    @JsonKey(name: 'current_team') Team? currentTeam,
    InstallationTimestamps? timestamps,
  });

  $TeamCopyWith<$Res>? get currentTeam;
  $InstallationTimestampsCopyWith<$Res>? get timestamps;
}

/// @nodoc
class _$InstallationSubmissionResultCopyWithImpl<
  $Res,
  $Val extends InstallationSubmissionResult
>
    implements $InstallationSubmissionResultCopyWith<$Res> {
  _$InstallationSubmissionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InstallationSubmissionResult
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
                      as InstallationTimestamps?,
          )
          as $Val,
    );
  }

  /// Create a copy of InstallationSubmissionResult
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

  /// Create a copy of InstallationSubmissionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstallationTimestampsCopyWith<$Res>? get timestamps {
    if (_value.timestamps == null) {
      return null;
    }

    return $InstallationTimestampsCopyWith<$Res>(_value.timestamps!, (value) {
      return _then(_value.copyWith(timestamps: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InstallationSubmissionResultImplCopyWith<$Res>
    implements $InstallationSubmissionResultCopyWith<$Res> {
  factory _$$InstallationSubmissionResultImplCopyWith(
    _$InstallationSubmissionResultImpl value,
    $Res Function(_$InstallationSubmissionResultImpl) then,
  ) = __$$InstallationSubmissionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'request_number') String? requestNumber,
    String? status,
    @JsonKey(name: 'current_team') Team? currentTeam,
    InstallationTimestamps? timestamps,
  });

  @override
  $TeamCopyWith<$Res>? get currentTeam;
  @override
  $InstallationTimestampsCopyWith<$Res>? get timestamps;
}

/// @nodoc
class __$$InstallationSubmissionResultImplCopyWithImpl<$Res>
    extends
        _$InstallationSubmissionResultCopyWithImpl<
          $Res,
          _$InstallationSubmissionResultImpl
        >
    implements _$$InstallationSubmissionResultImplCopyWith<$Res> {
  __$$InstallationSubmissionResultImplCopyWithImpl(
    _$InstallationSubmissionResultImpl _value,
    $Res Function(_$InstallationSubmissionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InstallationSubmissionResult
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
      _$InstallationSubmissionResultImpl(
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
                  as InstallationTimestamps?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InstallationSubmissionResultImpl
    implements _InstallationSubmissionResult {
  const _$InstallationSubmissionResultImpl({
    this.id,
    @JsonKey(name: 'request_number') this.requestNumber,
    this.status,
    @JsonKey(name: 'current_team') this.currentTeam,
    this.timestamps,
  });

  factory _$InstallationSubmissionResultImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$InstallationSubmissionResultImplFromJson(json);

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
  final InstallationTimestamps? timestamps;

  @override
  String toString() {
    return 'InstallationSubmissionResult(id: $id, requestNumber: $requestNumber, status: $status, currentTeam: $currentTeam, timestamps: $timestamps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InstallationSubmissionResultImpl &&
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

  /// Create a copy of InstallationSubmissionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InstallationSubmissionResultImplCopyWith<
    _$InstallationSubmissionResultImpl
  >
  get copyWith =>
      __$$InstallationSubmissionResultImplCopyWithImpl<
        _$InstallationSubmissionResultImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InstallationSubmissionResultImplToJson(this);
  }
}

abstract class _InstallationSubmissionResult
    implements InstallationSubmissionResult {
  const factory _InstallationSubmissionResult({
    final String? id,
    @JsonKey(name: 'request_number') final String? requestNumber,
    final String? status,
    @JsonKey(name: 'current_team') final Team? currentTeam,
    final InstallationTimestamps? timestamps,
  }) = _$InstallationSubmissionResultImpl;

  factory _InstallationSubmissionResult.fromJson(Map<String, dynamic> json) =
      _$InstallationSubmissionResultImpl.fromJson;

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
  InstallationTimestamps? get timestamps;

  /// Create a copy of InstallationSubmissionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InstallationSubmissionResultImplCopyWith<
    _$InstallationSubmissionResultImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

InstallationTimestamps _$InstallationTimestampsFromJson(
  Map<String, dynamic> json,
) {
  return _InstallationTimestamps.fromJson(json);
}

/// @nodoc
mixin _$InstallationTimestamps {
  @JsonKey(name: 'installed_at')
  String? get installedAt => throw _privateConstructorUsedError;

  /// Serializes this InstallationTimestamps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InstallationTimestamps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InstallationTimestampsCopyWith<InstallationTimestamps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstallationTimestampsCopyWith<$Res> {
  factory $InstallationTimestampsCopyWith(
    InstallationTimestamps value,
    $Res Function(InstallationTimestamps) then,
  ) = _$InstallationTimestampsCopyWithImpl<$Res, InstallationTimestamps>;
  @useResult
  $Res call({@JsonKey(name: 'installed_at') String? installedAt});
}

/// @nodoc
class _$InstallationTimestampsCopyWithImpl<
  $Res,
  $Val extends InstallationTimestamps
>
    implements $InstallationTimestampsCopyWith<$Res> {
  _$InstallationTimestampsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InstallationTimestamps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? installedAt = freezed}) {
    return _then(
      _value.copyWith(
            installedAt: freezed == installedAt
                ? _value.installedAt
                : installedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InstallationTimestampsImplCopyWith<$Res>
    implements $InstallationTimestampsCopyWith<$Res> {
  factory _$$InstallationTimestampsImplCopyWith(
    _$InstallationTimestampsImpl value,
    $Res Function(_$InstallationTimestampsImpl) then,
  ) = __$$InstallationTimestampsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'installed_at') String? installedAt});
}

/// @nodoc
class __$$InstallationTimestampsImplCopyWithImpl<$Res>
    extends
        _$InstallationTimestampsCopyWithImpl<$Res, _$InstallationTimestampsImpl>
    implements _$$InstallationTimestampsImplCopyWith<$Res> {
  __$$InstallationTimestampsImplCopyWithImpl(
    _$InstallationTimestampsImpl _value,
    $Res Function(_$InstallationTimestampsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InstallationTimestamps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? installedAt = freezed}) {
    return _then(
      _$InstallationTimestampsImpl(
        installedAt: freezed == installedAt
            ? _value.installedAt
            : installedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InstallationTimestampsImpl implements _InstallationTimestamps {
  const _$InstallationTimestampsImpl({
    @JsonKey(name: 'installed_at') this.installedAt,
  });

  factory _$InstallationTimestampsImpl.fromJson(Map<String, dynamic> json) =>
      _$$InstallationTimestampsImplFromJson(json);

  @override
  @JsonKey(name: 'installed_at')
  final String? installedAt;

  @override
  String toString() {
    return 'InstallationTimestamps(installedAt: $installedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InstallationTimestampsImpl &&
            (identical(other.installedAt, installedAt) ||
                other.installedAt == installedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, installedAt);

  /// Create a copy of InstallationTimestamps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InstallationTimestampsImplCopyWith<_$InstallationTimestampsImpl>
  get copyWith =>
      __$$InstallationTimestampsImplCopyWithImpl<_$InstallationTimestampsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InstallationTimestampsImplToJson(this);
  }
}

abstract class _InstallationTimestamps implements InstallationTimestamps {
  const factory _InstallationTimestamps({
    @JsonKey(name: 'installed_at') final String? installedAt,
  }) = _$InstallationTimestampsImpl;

  factory _InstallationTimestamps.fromJson(Map<String, dynamic> json) =
      _$InstallationTimestampsImpl.fromJson;

  @override
  @JsonKey(name: 'installed_at')
  String? get installedAt;

  /// Create a copy of InstallationTimestamps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InstallationTimestampsImplCopyWith<_$InstallationTimestampsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
