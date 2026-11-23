// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'waiting_onu.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WaitingOnu _$WaitingOnuFromJson(Map<String, dynamic> json) {
  return _WaitingOnu.fromJson(json);
}

/// @nodoc
mixin _$WaitingOnu {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'serial_number')
  String? get serialNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'pon_port')
  String? get ponPort => throw _privateConstructorUsedError;
  @JsonKey(name: 'detected_onu_type')
  String? get detectedOnuType => throw _privateConstructorUsedError;
  @JsonKey(name: 'authorization_status')
  String? get authorizationStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'authorization_reason')
  String? get authorizationReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_discovered_at')
  String? get lastDiscoveredAt => throw _privateConstructorUsedError;

  /// Serializes this WaitingOnu to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WaitingOnu
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WaitingOnuCopyWith<WaitingOnu> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WaitingOnuCopyWith<$Res> {
  factory $WaitingOnuCopyWith(
    WaitingOnu value,
    $Res Function(WaitingOnu) then,
  ) = _$WaitingOnuCopyWithImpl<$Res, WaitingOnu>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'serial_number') String? serialNumber,
    @JsonKey(name: 'pon_port') String? ponPort,
    @JsonKey(name: 'detected_onu_type') String? detectedOnuType,
    @JsonKey(name: 'authorization_status') String? authorizationStatus,
    @JsonKey(name: 'authorization_reason') String? authorizationReason,
    @JsonKey(name: 'last_discovered_at') String? lastDiscoveredAt,
  });
}

/// @nodoc
class _$WaitingOnuCopyWithImpl<$Res, $Val extends WaitingOnu>
    implements $WaitingOnuCopyWith<$Res> {
  _$WaitingOnuCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WaitingOnu
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serialNumber = freezed,
    Object? ponPort = freezed,
    Object? detectedOnuType = freezed,
    Object? authorizationStatus = freezed,
    Object? authorizationReason = freezed,
    Object? lastDiscoveredAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            serialNumber: freezed == serialNumber
                ? _value.serialNumber
                : serialNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            ponPort: freezed == ponPort
                ? _value.ponPort
                : ponPort // ignore: cast_nullable_to_non_nullable
                      as String?,
            detectedOnuType: freezed == detectedOnuType
                ? _value.detectedOnuType
                : detectedOnuType // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorizationStatus: freezed == authorizationStatus
                ? _value.authorizationStatus
                : authorizationStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorizationReason: freezed == authorizationReason
                ? _value.authorizationReason
                : authorizationReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastDiscoveredAt: freezed == lastDiscoveredAt
                ? _value.lastDiscoveredAt
                : lastDiscoveredAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WaitingOnuImplCopyWith<$Res>
    implements $WaitingOnuCopyWith<$Res> {
  factory _$$WaitingOnuImplCopyWith(
    _$WaitingOnuImpl value,
    $Res Function(_$WaitingOnuImpl) then,
  ) = __$$WaitingOnuImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'serial_number') String? serialNumber,
    @JsonKey(name: 'pon_port') String? ponPort,
    @JsonKey(name: 'detected_onu_type') String? detectedOnuType,
    @JsonKey(name: 'authorization_status') String? authorizationStatus,
    @JsonKey(name: 'authorization_reason') String? authorizationReason,
    @JsonKey(name: 'last_discovered_at') String? lastDiscoveredAt,
  });
}

/// @nodoc
class __$$WaitingOnuImplCopyWithImpl<$Res>
    extends _$WaitingOnuCopyWithImpl<$Res, _$WaitingOnuImpl>
    implements _$$WaitingOnuImplCopyWith<$Res> {
  __$$WaitingOnuImplCopyWithImpl(
    _$WaitingOnuImpl _value,
    $Res Function(_$WaitingOnuImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WaitingOnu
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serialNumber = freezed,
    Object? ponPort = freezed,
    Object? detectedOnuType = freezed,
    Object? authorizationStatus = freezed,
    Object? authorizationReason = freezed,
    Object? lastDiscoveredAt = freezed,
  }) {
    return _then(
      _$WaitingOnuImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        serialNumber: freezed == serialNumber
            ? _value.serialNumber
            : serialNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        ponPort: freezed == ponPort
            ? _value.ponPort
            : ponPort // ignore: cast_nullable_to_non_nullable
                  as String?,
        detectedOnuType: freezed == detectedOnuType
            ? _value.detectedOnuType
            : detectedOnuType // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorizationStatus: freezed == authorizationStatus
            ? _value.authorizationStatus
            : authorizationStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorizationReason: freezed == authorizationReason
            ? _value.authorizationReason
            : authorizationReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastDiscoveredAt: freezed == lastDiscoveredAt
            ? _value.lastDiscoveredAt
            : lastDiscoveredAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WaitingOnuImpl implements _WaitingOnu {
  const _$WaitingOnuImpl({
    required this.id,
    @JsonKey(name: 'serial_number') this.serialNumber,
    @JsonKey(name: 'pon_port') this.ponPort,
    @JsonKey(name: 'detected_onu_type') this.detectedOnuType,
    @JsonKey(name: 'authorization_status') this.authorizationStatus,
    @JsonKey(name: 'authorization_reason') this.authorizationReason,
    @JsonKey(name: 'last_discovered_at') this.lastDiscoveredAt,
  });

  factory _$WaitingOnuImpl.fromJson(Map<String, dynamic> json) =>
      _$$WaitingOnuImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  @override
  @JsonKey(name: 'pon_port')
  final String? ponPort;
  @override
  @JsonKey(name: 'detected_onu_type')
  final String? detectedOnuType;
  @override
  @JsonKey(name: 'authorization_status')
  final String? authorizationStatus;
  @override
  @JsonKey(name: 'authorization_reason')
  final String? authorizationReason;
  @override
  @JsonKey(name: 'last_discovered_at')
  final String? lastDiscoveredAt;

  @override
  String toString() {
    return 'WaitingOnu(id: $id, serialNumber: $serialNumber, ponPort: $ponPort, detectedOnuType: $detectedOnuType, authorizationStatus: $authorizationStatus, authorizationReason: $authorizationReason, lastDiscoveredAt: $lastDiscoveredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WaitingOnuImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.ponPort, ponPort) || other.ponPort == ponPort) &&
            (identical(other.detectedOnuType, detectedOnuType) ||
                other.detectedOnuType == detectedOnuType) &&
            (identical(other.authorizationStatus, authorizationStatus) ||
                other.authorizationStatus == authorizationStatus) &&
            (identical(other.authorizationReason, authorizationReason) ||
                other.authorizationReason == authorizationReason) &&
            (identical(other.lastDiscoveredAt, lastDiscoveredAt) ||
                other.lastDiscoveredAt == lastDiscoveredAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    serialNumber,
    ponPort,
    detectedOnuType,
    authorizationStatus,
    authorizationReason,
    lastDiscoveredAt,
  );

  /// Create a copy of WaitingOnu
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WaitingOnuImplCopyWith<_$WaitingOnuImpl> get copyWith =>
      __$$WaitingOnuImplCopyWithImpl<_$WaitingOnuImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WaitingOnuImplToJson(this);
  }
}

abstract class _WaitingOnu implements WaitingOnu {
  const factory _WaitingOnu({
    required final String id,
    @JsonKey(name: 'serial_number') final String? serialNumber,
    @JsonKey(name: 'pon_port') final String? ponPort,
    @JsonKey(name: 'detected_onu_type') final String? detectedOnuType,
    @JsonKey(name: 'authorization_status') final String? authorizationStatus,
    @JsonKey(name: 'authorization_reason') final String? authorizationReason,
    @JsonKey(name: 'last_discovered_at') final String? lastDiscoveredAt,
  }) = _$WaitingOnuImpl;

  factory _WaitingOnu.fromJson(Map<String, dynamic> json) =
      _$WaitingOnuImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'serial_number')
  String? get serialNumber;
  @override
  @JsonKey(name: 'pon_port')
  String? get ponPort;
  @override
  @JsonKey(name: 'detected_onu_type')
  String? get detectedOnuType;
  @override
  @JsonKey(name: 'authorization_status')
  String? get authorizationStatus;
  @override
  @JsonKey(name: 'authorization_reason')
  String? get authorizationReason;
  @override
  @JsonKey(name: 'last_discovered_at')
  String? get lastDiscoveredAt;

  /// Create a copy of WaitingOnu
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WaitingOnuImplCopyWith<_$WaitingOnuImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WaitingOnuList _$WaitingOnuListFromJson(Map<String, dynamic> json) {
  return _WaitingOnuList.fromJson(json);
}

/// @nodoc
mixin _$WaitingOnuList {
  List<WaitingOnu> get data => throw _privateConstructorUsedError;

  /// Serializes this WaitingOnuList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WaitingOnuList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WaitingOnuListCopyWith<WaitingOnuList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WaitingOnuListCopyWith<$Res> {
  factory $WaitingOnuListCopyWith(
    WaitingOnuList value,
    $Res Function(WaitingOnuList) then,
  ) = _$WaitingOnuListCopyWithImpl<$Res, WaitingOnuList>;
  @useResult
  $Res call({List<WaitingOnu> data});
}

/// @nodoc
class _$WaitingOnuListCopyWithImpl<$Res, $Val extends WaitingOnuList>
    implements $WaitingOnuListCopyWith<$Res> {
  _$WaitingOnuListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WaitingOnuList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<WaitingOnu>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WaitingOnuListImplCopyWith<$Res>
    implements $WaitingOnuListCopyWith<$Res> {
  factory _$$WaitingOnuListImplCopyWith(
    _$WaitingOnuListImpl value,
    $Res Function(_$WaitingOnuListImpl) then,
  ) = __$$WaitingOnuListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<WaitingOnu> data});
}

/// @nodoc
class __$$WaitingOnuListImplCopyWithImpl<$Res>
    extends _$WaitingOnuListCopyWithImpl<$Res, _$WaitingOnuListImpl>
    implements _$$WaitingOnuListImplCopyWith<$Res> {
  __$$WaitingOnuListImplCopyWithImpl(
    _$WaitingOnuListImpl _value,
    $Res Function(_$WaitingOnuListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WaitingOnuList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$WaitingOnuListImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<WaitingOnu>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WaitingOnuListImpl implements _WaitingOnuList {
  const _$WaitingOnuListImpl({required final List<WaitingOnu> data})
    : _data = data;

  factory _$WaitingOnuListImpl.fromJson(Map<String, dynamic> json) =>
      _$$WaitingOnuListImplFromJson(json);

  final List<WaitingOnu> _data;
  @override
  List<WaitingOnu> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'WaitingOnuList(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WaitingOnuListImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  /// Create a copy of WaitingOnuList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WaitingOnuListImplCopyWith<_$WaitingOnuListImpl> get copyWith =>
      __$$WaitingOnuListImplCopyWithImpl<_$WaitingOnuListImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WaitingOnuListImplToJson(this);
  }
}

abstract class _WaitingOnuList implements WaitingOnuList {
  const factory _WaitingOnuList({required final List<WaitingOnu> data}) =
      _$WaitingOnuListImpl;

  factory _WaitingOnuList.fromJson(Map<String, dynamic> json) =
      _$WaitingOnuListImpl.fromJson;

  @override
  List<WaitingOnu> get data;

  /// Create a copy of WaitingOnuList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WaitingOnuListImplCopyWith<_$WaitingOnuListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiscoverWaitingOnusResponse _$DiscoverWaitingOnusResponseFromJson(
  Map<String, dynamic> json,
) {
  return _DiscoverWaitingOnusResponse.fromJson(json);
}

/// @nodoc
mixin _$DiscoverWaitingOnusResponse {
  String? get message => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  @JsonKey(name: 'seen_count')
  int? get seenCount => throw _privateConstructorUsedError;
  List<WaitingOnu>? get data => throw _privateConstructorUsedError;

  /// Serializes this DiscoverWaitingOnusResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscoverWaitingOnusResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscoverWaitingOnusResponseCopyWith<DiscoverWaitingOnusResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoverWaitingOnusResponseCopyWith<$Res> {
  factory $DiscoverWaitingOnusResponseCopyWith(
    DiscoverWaitingOnusResponse value,
    $Res Function(DiscoverWaitingOnusResponse) then,
  ) =
      _$DiscoverWaitingOnusResponseCopyWithImpl<
        $Res,
        DiscoverWaitingOnusResponse
      >;
  @useResult
  $Res call({
    String? message,
    String? source,
    @JsonKey(name: 'seen_count') int? seenCount,
    List<WaitingOnu>? data,
  });
}

/// @nodoc
class _$DiscoverWaitingOnusResponseCopyWithImpl<
  $Res,
  $Val extends DiscoverWaitingOnusResponse
>
    implements $DiscoverWaitingOnusResponseCopyWith<$Res> {
  _$DiscoverWaitingOnusResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscoverWaitingOnusResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? source = freezed,
    Object? seenCount = freezed,
    Object? data = freezed,
  }) {
    return _then(
      _value.copyWith(
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            seenCount: freezed == seenCount
                ? _value.seenCount
                : seenCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<WaitingOnu>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiscoverWaitingOnusResponseImplCopyWith<$Res>
    implements $DiscoverWaitingOnusResponseCopyWith<$Res> {
  factory _$$DiscoverWaitingOnusResponseImplCopyWith(
    _$DiscoverWaitingOnusResponseImpl value,
    $Res Function(_$DiscoverWaitingOnusResponseImpl) then,
  ) = __$$DiscoverWaitingOnusResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? message,
    String? source,
    @JsonKey(name: 'seen_count') int? seenCount,
    List<WaitingOnu>? data,
  });
}

/// @nodoc
class __$$DiscoverWaitingOnusResponseImplCopyWithImpl<$Res>
    extends
        _$DiscoverWaitingOnusResponseCopyWithImpl<
          $Res,
          _$DiscoverWaitingOnusResponseImpl
        >
    implements _$$DiscoverWaitingOnusResponseImplCopyWith<$Res> {
  __$$DiscoverWaitingOnusResponseImplCopyWithImpl(
    _$DiscoverWaitingOnusResponseImpl _value,
    $Res Function(_$DiscoverWaitingOnusResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscoverWaitingOnusResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? source = freezed,
    Object? seenCount = freezed,
    Object? data = freezed,
  }) {
    return _then(
      _$DiscoverWaitingOnusResponseImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        seenCount: freezed == seenCount
            ? _value.seenCount
            : seenCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        data: freezed == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<WaitingOnu>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscoverWaitingOnusResponseImpl
    implements _DiscoverWaitingOnusResponse {
  const _$DiscoverWaitingOnusResponseImpl({
    this.message,
    this.source,
    @JsonKey(name: 'seen_count') this.seenCount,
    final List<WaitingOnu>? data,
  }) : _data = data;

  factory _$DiscoverWaitingOnusResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$DiscoverWaitingOnusResponseImplFromJson(json);

  @override
  final String? message;
  @override
  final String? source;
  @override
  @JsonKey(name: 'seen_count')
  final int? seenCount;
  final List<WaitingOnu>? _data;
  @override
  List<WaitingOnu>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'DiscoverWaitingOnusResponse(message: $message, source: $source, seenCount: $seenCount, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoverWaitingOnusResponseImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.seenCount, seenCount) ||
                other.seenCount == seenCount) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    source,
    seenCount,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of DiscoverWaitingOnusResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoverWaitingOnusResponseImplCopyWith<_$DiscoverWaitingOnusResponseImpl>
  get copyWith =>
      __$$DiscoverWaitingOnusResponseImplCopyWithImpl<
        _$DiscoverWaitingOnusResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscoverWaitingOnusResponseImplToJson(this);
  }
}

abstract class _DiscoverWaitingOnusResponse
    implements DiscoverWaitingOnusResponse {
  const factory _DiscoverWaitingOnusResponse({
    final String? message,
    final String? source,
    @JsonKey(name: 'seen_count') final int? seenCount,
    final List<WaitingOnu>? data,
  }) = _$DiscoverWaitingOnusResponseImpl;

  factory _DiscoverWaitingOnusResponse.fromJson(Map<String, dynamic> json) =
      _$DiscoverWaitingOnusResponseImpl.fromJson;

  @override
  String? get message;
  @override
  String? get source;
  @override
  @JsonKey(name: 'seen_count')
  int? get seenCount;
  @override
  List<WaitingOnu>? get data;

  /// Create a copy of DiscoverWaitingOnusResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscoverWaitingOnusResponseImplCopyWith<_$DiscoverWaitingOnusResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
