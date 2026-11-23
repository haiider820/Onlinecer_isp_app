// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authorization_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuthorizationJob _$AuthorizationJobFromJson(Map<String, dynamic> json) {
  return _AuthorizationJob.fromJson(json);
}

/// @nodoc
mixin _$AuthorizationJob {
  String get id => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'serial_number')
  String? get serialNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'pon_port')
  String? get ponPort => throw _privateConstructorUsedError;
  @JsonKey(name: 'ont_id')
  String? get ontId => throw _privateConstructorUsedError;
  @JsonKey(name: 'line_profile')
  String? get lineProfile => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_profile')
  String? get serviceProfile => throw _privateConstructorUsedError;
  int? get vlan => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_vlan')
  int? get userVlan => throw _privateConstructorUsedError;
  int? get gemport => throw _privateConstructorUsedError;
  @JsonKey(name: 'error_message')
  String? get errorMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'started_at')
  String? get startedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'finished_at')
  String? get finishedAt => throw _privateConstructorUsedError;

  /// Serializes this AuthorizationJob to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthorizationJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthorizationJobCopyWith<AuthorizationJob> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthorizationJobCopyWith<$Res> {
  factory $AuthorizationJobCopyWith(
    AuthorizationJob value,
    $Res Function(AuthorizationJob) then,
  ) = _$AuthorizationJobCopyWithImpl<$Res, AuthorizationJob>;
  @useResult
  $Res call({
    String id,
    String? status,
    @JsonKey(name: 'serial_number') String? serialNumber,
    @JsonKey(name: 'pon_port') String? ponPort,
    @JsonKey(name: 'ont_id') String? ontId,
    @JsonKey(name: 'line_profile') String? lineProfile,
    @JsonKey(name: 'service_profile') String? serviceProfile,
    int? vlan,
    @JsonKey(name: 'user_vlan') int? userVlan,
    int? gemport,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'started_at') String? startedAt,
    @JsonKey(name: 'finished_at') String? finishedAt,
  });
}

/// @nodoc
class _$AuthorizationJobCopyWithImpl<$Res, $Val extends AuthorizationJob>
    implements $AuthorizationJobCopyWith<$Res> {
  _$AuthorizationJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthorizationJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = freezed,
    Object? serialNumber = freezed,
    Object? ponPort = freezed,
    Object? ontId = freezed,
    Object? lineProfile = freezed,
    Object? serviceProfile = freezed,
    Object? vlan = freezed,
    Object? userVlan = freezed,
    Object? gemport = freezed,
    Object? errorMessage = freezed,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            serialNumber: freezed == serialNumber
                ? _value.serialNumber
                : serialNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            ponPort: freezed == ponPort
                ? _value.ponPort
                : ponPort // ignore: cast_nullable_to_non_nullable
                      as String?,
            ontId: freezed == ontId
                ? _value.ontId
                : ontId // ignore: cast_nullable_to_non_nullable
                      as String?,
            lineProfile: freezed == lineProfile
                ? _value.lineProfile
                : lineProfile // ignore: cast_nullable_to_non_nullable
                      as String?,
            serviceProfile: freezed == serviceProfile
                ? _value.serviceProfile
                : serviceProfile // ignore: cast_nullable_to_non_nullable
                      as String?,
            vlan: freezed == vlan
                ? _value.vlan
                : vlan // ignore: cast_nullable_to_non_nullable
                      as int?,
            userVlan: freezed == userVlan
                ? _value.userVlan
                : userVlan // ignore: cast_nullable_to_non_nullable
                      as int?,
            gemport: freezed == gemport
                ? _value.gemport
                : gemport // ignore: cast_nullable_to_non_nullable
                      as int?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            finishedAt: freezed == finishedAt
                ? _value.finishedAt
                : finishedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthorizationJobImplCopyWith<$Res>
    implements $AuthorizationJobCopyWith<$Res> {
  factory _$$AuthorizationJobImplCopyWith(
    _$AuthorizationJobImpl value,
    $Res Function(_$AuthorizationJobImpl) then,
  ) = __$$AuthorizationJobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? status,
    @JsonKey(name: 'serial_number') String? serialNumber,
    @JsonKey(name: 'pon_port') String? ponPort,
    @JsonKey(name: 'ont_id') String? ontId,
    @JsonKey(name: 'line_profile') String? lineProfile,
    @JsonKey(name: 'service_profile') String? serviceProfile,
    int? vlan,
    @JsonKey(name: 'user_vlan') int? userVlan,
    int? gemport,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'started_at') String? startedAt,
    @JsonKey(name: 'finished_at') String? finishedAt,
  });
}

/// @nodoc
class __$$AuthorizationJobImplCopyWithImpl<$Res>
    extends _$AuthorizationJobCopyWithImpl<$Res, _$AuthorizationJobImpl>
    implements _$$AuthorizationJobImplCopyWith<$Res> {
  __$$AuthorizationJobImplCopyWithImpl(
    _$AuthorizationJobImpl _value,
    $Res Function(_$AuthorizationJobImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthorizationJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = freezed,
    Object? serialNumber = freezed,
    Object? ponPort = freezed,
    Object? ontId = freezed,
    Object? lineProfile = freezed,
    Object? serviceProfile = freezed,
    Object? vlan = freezed,
    Object? userVlan = freezed,
    Object? gemport = freezed,
    Object? errorMessage = freezed,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
  }) {
    return _then(
      _$AuthorizationJobImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        serialNumber: freezed == serialNumber
            ? _value.serialNumber
            : serialNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        ponPort: freezed == ponPort
            ? _value.ponPort
            : ponPort // ignore: cast_nullable_to_non_nullable
                  as String?,
        ontId: freezed == ontId
            ? _value.ontId
            : ontId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lineProfile: freezed == lineProfile
            ? _value.lineProfile
            : lineProfile // ignore: cast_nullable_to_non_nullable
                  as String?,
        serviceProfile: freezed == serviceProfile
            ? _value.serviceProfile
            : serviceProfile // ignore: cast_nullable_to_non_nullable
                  as String?,
        vlan: freezed == vlan
            ? _value.vlan
            : vlan // ignore: cast_nullable_to_non_nullable
                  as int?,
        userVlan: freezed == userVlan
            ? _value.userVlan
            : userVlan // ignore: cast_nullable_to_non_nullable
                  as int?,
        gemport: freezed == gemport
            ? _value.gemport
            : gemport // ignore: cast_nullable_to_non_nullable
                  as int?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        finishedAt: freezed == finishedAt
            ? _value.finishedAt
            : finishedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthorizationJobImpl extends _AuthorizationJob {
  const _$AuthorizationJobImpl({
    required this.id,
    this.status,
    @JsonKey(name: 'serial_number') this.serialNumber,
    @JsonKey(name: 'pon_port') this.ponPort,
    @JsonKey(name: 'ont_id') this.ontId,
    @JsonKey(name: 'line_profile') this.lineProfile,
    @JsonKey(name: 'service_profile') this.serviceProfile,
    this.vlan,
    @JsonKey(name: 'user_vlan') this.userVlan,
    this.gemport,
    @JsonKey(name: 'error_message') this.errorMessage,
    @JsonKey(name: 'started_at') this.startedAt,
    @JsonKey(name: 'finished_at') this.finishedAt,
  }) : super._();

  factory _$AuthorizationJobImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthorizationJobImplFromJson(json);

  @override
  final String id;
  @override
  final String? status;
  @override
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  @override
  @JsonKey(name: 'pon_port')
  final String? ponPort;
  @override
  @JsonKey(name: 'ont_id')
  final String? ontId;
  @override
  @JsonKey(name: 'line_profile')
  final String? lineProfile;
  @override
  @JsonKey(name: 'service_profile')
  final String? serviceProfile;
  @override
  final int? vlan;
  @override
  @JsonKey(name: 'user_vlan')
  final int? userVlan;
  @override
  final int? gemport;
  @override
  @JsonKey(name: 'error_message')
  final String? errorMessage;
  @override
  @JsonKey(name: 'started_at')
  final String? startedAt;
  @override
  @JsonKey(name: 'finished_at')
  final String? finishedAt;

  @override
  String toString() {
    return 'AuthorizationJob(id: $id, status: $status, serialNumber: $serialNumber, ponPort: $ponPort, ontId: $ontId, lineProfile: $lineProfile, serviceProfile: $serviceProfile, vlan: $vlan, userVlan: $userVlan, gemport: $gemport, errorMessage: $errorMessage, startedAt: $startedAt, finishedAt: $finishedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthorizationJobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.ponPort, ponPort) || other.ponPort == ponPort) &&
            (identical(other.ontId, ontId) || other.ontId == ontId) &&
            (identical(other.lineProfile, lineProfile) ||
                other.lineProfile == lineProfile) &&
            (identical(other.serviceProfile, serviceProfile) ||
                other.serviceProfile == serviceProfile) &&
            (identical(other.vlan, vlan) || other.vlan == vlan) &&
            (identical(other.userVlan, userVlan) ||
                other.userVlan == userVlan) &&
            (identical(other.gemport, gemport) || other.gemport == gemport) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    status,
    serialNumber,
    ponPort,
    ontId,
    lineProfile,
    serviceProfile,
    vlan,
    userVlan,
    gemport,
    errorMessage,
    startedAt,
    finishedAt,
  );

  /// Create a copy of AuthorizationJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthorizationJobImplCopyWith<_$AuthorizationJobImpl> get copyWith =>
      __$$AuthorizationJobImplCopyWithImpl<_$AuthorizationJobImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthorizationJobImplToJson(this);
  }
}

abstract class _AuthorizationJob extends AuthorizationJob {
  const factory _AuthorizationJob({
    required final String id,
    final String? status,
    @JsonKey(name: 'serial_number') final String? serialNumber,
    @JsonKey(name: 'pon_port') final String? ponPort,
    @JsonKey(name: 'ont_id') final String? ontId,
    @JsonKey(name: 'line_profile') final String? lineProfile,
    @JsonKey(name: 'service_profile') final String? serviceProfile,
    final int? vlan,
    @JsonKey(name: 'user_vlan') final int? userVlan,
    final int? gemport,
    @JsonKey(name: 'error_message') final String? errorMessage,
    @JsonKey(name: 'started_at') final String? startedAt,
    @JsonKey(name: 'finished_at') final String? finishedAt,
  }) = _$AuthorizationJobImpl;
  const _AuthorizationJob._() : super._();

  factory _AuthorizationJob.fromJson(Map<String, dynamic> json) =
      _$AuthorizationJobImpl.fromJson;

  @override
  String get id;
  @override
  String? get status;
  @override
  @JsonKey(name: 'serial_number')
  String? get serialNumber;
  @override
  @JsonKey(name: 'pon_port')
  String? get ponPort;
  @override
  @JsonKey(name: 'ont_id')
  String? get ontId;
  @override
  @JsonKey(name: 'line_profile')
  String? get lineProfile;
  @override
  @JsonKey(name: 'service_profile')
  String? get serviceProfile;
  @override
  int? get vlan;
  @override
  @JsonKey(name: 'user_vlan')
  int? get userVlan;
  @override
  int? get gemport;
  @override
  @JsonKey(name: 'error_message')
  String? get errorMessage;
  @override
  @JsonKey(name: 'started_at')
  String? get startedAt;
  @override
  @JsonKey(name: 'finished_at')
  String? get finishedAt;

  /// Create a copy of AuthorizationJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthorizationJobImplCopyWith<_$AuthorizationJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthorizationJobResponse _$AuthorizationJobResponseFromJson(
  Map<String, dynamic> json,
) {
  return _AuthorizationJobResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthorizationJobResponse {
  @JsonKey(name: 'data')
  AuthorizationJob? get data => throw _privateConstructorUsedError;

  /// Serializes this AuthorizationJobResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthorizationJobResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthorizationJobResponseCopyWith<AuthorizationJobResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthorizationJobResponseCopyWith<$Res> {
  factory $AuthorizationJobResponseCopyWith(
    AuthorizationJobResponse value,
    $Res Function(AuthorizationJobResponse) then,
  ) = _$AuthorizationJobResponseCopyWithImpl<$Res, AuthorizationJobResponse>;
  @useResult
  $Res call({@JsonKey(name: 'data') AuthorizationJob? data});

  $AuthorizationJobCopyWith<$Res>? get data;
}

/// @nodoc
class _$AuthorizationJobResponseCopyWithImpl<
  $Res,
  $Val extends AuthorizationJobResponse
>
    implements $AuthorizationJobResponseCopyWith<$Res> {
  _$AuthorizationJobResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthorizationJobResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = freezed}) {
    return _then(
      _value.copyWith(
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as AuthorizationJob?,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthorizationJobResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthorizationJobCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $AuthorizationJobCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthorizationJobResponseImplCopyWith<$Res>
    implements $AuthorizationJobResponseCopyWith<$Res> {
  factory _$$AuthorizationJobResponseImplCopyWith(
    _$AuthorizationJobResponseImpl value,
    $Res Function(_$AuthorizationJobResponseImpl) then,
  ) = __$$AuthorizationJobResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'data') AuthorizationJob? data});

  @override
  $AuthorizationJobCopyWith<$Res>? get data;
}

/// @nodoc
class __$$AuthorizationJobResponseImplCopyWithImpl<$Res>
    extends
        _$AuthorizationJobResponseCopyWithImpl<
          $Res,
          _$AuthorizationJobResponseImpl
        >
    implements _$$AuthorizationJobResponseImplCopyWith<$Res> {
  __$$AuthorizationJobResponseImplCopyWithImpl(
    _$AuthorizationJobResponseImpl _value,
    $Res Function(_$AuthorizationJobResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthorizationJobResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = freezed}) {
    return _then(
      _$AuthorizationJobResponseImpl(
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as AuthorizationJob?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthorizationJobResponseImpl implements _AuthorizationJobResponse {
  const _$AuthorizationJobResponseImpl({@JsonKey(name: 'data') this.data});

  factory _$AuthorizationJobResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthorizationJobResponseImplFromJson(json);

  @override
  @JsonKey(name: 'data')
  final AuthorizationJob? data;

  @override
  String toString() {
    return 'AuthorizationJobResponse(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthorizationJobResponseImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of AuthorizationJobResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthorizationJobResponseImplCopyWith<_$AuthorizationJobResponseImpl>
  get copyWith =>
      __$$AuthorizationJobResponseImplCopyWithImpl<
        _$AuthorizationJobResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthorizationJobResponseImplToJson(this);
  }
}

abstract class _AuthorizationJobResponse implements AuthorizationJobResponse {
  const factory _AuthorizationJobResponse({
    @JsonKey(name: 'data') final AuthorizationJob? data,
  }) = _$AuthorizationJobResponseImpl;

  factory _AuthorizationJobResponse.fromJson(Map<String, dynamic> json) =
      _$AuthorizationJobResponseImpl.fromJson;

  @override
  @JsonKey(name: 'data')
  AuthorizationJob? get data;

  /// Create a copy of AuthorizationJobResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthorizationJobResponseImplCopyWith<_$AuthorizationJobResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
