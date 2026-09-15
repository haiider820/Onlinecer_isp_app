// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'locations.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GeoPoint _$GeoPointFromJson(Map<String, dynamic> json) {
  return _GeoPoint.fromJson(json);
}

/// @nodoc
mixin _$GeoPoint {
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'node_id')
  String? get nodeId => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;

  /// Serializes this GeoPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeoPointCopyWith<GeoPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeoPointCopyWith<$Res> {
  factory $GeoPointCopyWith(GeoPoint value, $Res Function(GeoPoint) then) =
      _$GeoPointCopyWithImpl<$Res, GeoPoint>;
  @useResult
  $Res call({
    double? latitude,
    double? longitude,
    @JsonKey(name: 'node_id') String? nodeId,
    String? address,
  });
}

/// @nodoc
class _$GeoPointCopyWithImpl<$Res, $Val extends GeoPoint>
    implements $GeoPointCopyWith<$Res> {
  _$GeoPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? nodeId = freezed,
    Object? address = freezed,
  }) {
    return _then(
      _value.copyWith(
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            nodeId: freezed == nodeId
                ? _value.nodeId
                : nodeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GeoPointImplCopyWith<$Res>
    implements $GeoPointCopyWith<$Res> {
  factory _$$GeoPointImplCopyWith(
    _$GeoPointImpl value,
    $Res Function(_$GeoPointImpl) then,
  ) = __$$GeoPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double? latitude,
    double? longitude,
    @JsonKey(name: 'node_id') String? nodeId,
    String? address,
  });
}

/// @nodoc
class __$$GeoPointImplCopyWithImpl<$Res>
    extends _$GeoPointCopyWithImpl<$Res, _$GeoPointImpl>
    implements _$$GeoPointImplCopyWith<$Res> {
  __$$GeoPointImplCopyWithImpl(
    _$GeoPointImpl _value,
    $Res Function(_$GeoPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? nodeId = freezed,
    Object? address = freezed,
  }) {
    return _then(
      _$GeoPointImpl(
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        nodeId: freezed == nodeId
            ? _value.nodeId
            : nodeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GeoPointImpl implements _GeoPoint {
  const _$GeoPointImpl({
    this.latitude,
    this.longitude,
    @JsonKey(name: 'node_id') this.nodeId,
    this.address,
  });

  factory _$GeoPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeoPointImplFromJson(json);

  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey(name: 'node_id')
  final String? nodeId;
  @override
  final String? address;

  @override
  String toString() {
    return 'GeoPoint(latitude: $latitude, longitude: $longitude, nodeId: $nodeId, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeoPointImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.nodeId, nodeId) || other.nodeId == nodeId) &&
            (identical(other.address, address) || other.address == address));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, latitude, longitude, nodeId, address);

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeoPointImplCopyWith<_$GeoPointImpl> get copyWith =>
      __$$GeoPointImplCopyWithImpl<_$GeoPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeoPointImplToJson(this);
  }
}

abstract class _GeoPoint implements GeoPoint {
  const factory _GeoPoint({
    final double? latitude,
    final double? longitude,
    @JsonKey(name: 'node_id') final String? nodeId,
    final String? address,
  }) = _$GeoPointImpl;

  factory _GeoPoint.fromJson(Map<String, dynamic> json) =
      _$GeoPointImpl.fromJson;

  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  @JsonKey(name: 'node_id')
  String? get nodeId;
  @override
  String? get address;

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeoPointImplCopyWith<_$GeoPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Locations _$LocationsFromJson(Map<String, dynamic> json) {
  return _Locations.fromJson(json);
}

/// @nodoc
mixin _$Locations {
  GeoPoint? get installation => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_device')
  GeoPoint? get userDevice => throw _privateConstructorUsedError;
  GeoPoint? get dp => throw _privateConstructorUsedError;
  @JsonKey(name: 'fat_node')
  GeoPoint? get fatNode => throw _privateConstructorUsedError;

  /// Serializes this Locations to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Locations
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationsCopyWith<Locations> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationsCopyWith<$Res> {
  factory $LocationsCopyWith(Locations value, $Res Function(Locations) then) =
      _$LocationsCopyWithImpl<$Res, Locations>;
  @useResult
  $Res call({
    GeoPoint? installation,
    @JsonKey(name: 'user_device') GeoPoint? userDevice,
    GeoPoint? dp,
    @JsonKey(name: 'fat_node') GeoPoint? fatNode,
  });

  $GeoPointCopyWith<$Res>? get installation;
  $GeoPointCopyWith<$Res>? get userDevice;
  $GeoPointCopyWith<$Res>? get dp;
  $GeoPointCopyWith<$Res>? get fatNode;
}

/// @nodoc
class _$LocationsCopyWithImpl<$Res, $Val extends Locations>
    implements $LocationsCopyWith<$Res> {
  _$LocationsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Locations
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? installation = freezed,
    Object? userDevice = freezed,
    Object? dp = freezed,
    Object? fatNode = freezed,
  }) {
    return _then(
      _value.copyWith(
            installation: freezed == installation
                ? _value.installation
                : installation // ignore: cast_nullable_to_non_nullable
                      as GeoPoint?,
            userDevice: freezed == userDevice
                ? _value.userDevice
                : userDevice // ignore: cast_nullable_to_non_nullable
                      as GeoPoint?,
            dp: freezed == dp
                ? _value.dp
                : dp // ignore: cast_nullable_to_non_nullable
                      as GeoPoint?,
            fatNode: freezed == fatNode
                ? _value.fatNode
                : fatNode // ignore: cast_nullable_to_non_nullable
                      as GeoPoint?,
          )
          as $Val,
    );
  }

  /// Create a copy of Locations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeoPointCopyWith<$Res>? get installation {
    if (_value.installation == null) {
      return null;
    }

    return $GeoPointCopyWith<$Res>(_value.installation!, (value) {
      return _then(_value.copyWith(installation: value) as $Val);
    });
  }

  /// Create a copy of Locations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeoPointCopyWith<$Res>? get userDevice {
    if (_value.userDevice == null) {
      return null;
    }

    return $GeoPointCopyWith<$Res>(_value.userDevice!, (value) {
      return _then(_value.copyWith(userDevice: value) as $Val);
    });
  }

  /// Create a copy of Locations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeoPointCopyWith<$Res>? get dp {
    if (_value.dp == null) {
      return null;
    }

    return $GeoPointCopyWith<$Res>(_value.dp!, (value) {
      return _then(_value.copyWith(dp: value) as $Val);
    });
  }

  /// Create a copy of Locations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeoPointCopyWith<$Res>? get fatNode {
    if (_value.fatNode == null) {
      return null;
    }

    return $GeoPointCopyWith<$Res>(_value.fatNode!, (value) {
      return _then(_value.copyWith(fatNode: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LocationsImplCopyWith<$Res>
    implements $LocationsCopyWith<$Res> {
  factory _$$LocationsImplCopyWith(
    _$LocationsImpl value,
    $Res Function(_$LocationsImpl) then,
  ) = __$$LocationsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    GeoPoint? installation,
    @JsonKey(name: 'user_device') GeoPoint? userDevice,
    GeoPoint? dp,
    @JsonKey(name: 'fat_node') GeoPoint? fatNode,
  });

  @override
  $GeoPointCopyWith<$Res>? get installation;
  @override
  $GeoPointCopyWith<$Res>? get userDevice;
  @override
  $GeoPointCopyWith<$Res>? get dp;
  @override
  $GeoPointCopyWith<$Res>? get fatNode;
}

/// @nodoc
class __$$LocationsImplCopyWithImpl<$Res>
    extends _$LocationsCopyWithImpl<$Res, _$LocationsImpl>
    implements _$$LocationsImplCopyWith<$Res> {
  __$$LocationsImplCopyWithImpl(
    _$LocationsImpl _value,
    $Res Function(_$LocationsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Locations
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? installation = freezed,
    Object? userDevice = freezed,
    Object? dp = freezed,
    Object? fatNode = freezed,
  }) {
    return _then(
      _$LocationsImpl(
        installation: freezed == installation
            ? _value.installation
            : installation // ignore: cast_nullable_to_non_nullable
                  as GeoPoint?,
        userDevice: freezed == userDevice
            ? _value.userDevice
            : userDevice // ignore: cast_nullable_to_non_nullable
                  as GeoPoint?,
        dp: freezed == dp
            ? _value.dp
            : dp // ignore: cast_nullable_to_non_nullable
                  as GeoPoint?,
        fatNode: freezed == fatNode
            ? _value.fatNode
            : fatNode // ignore: cast_nullable_to_non_nullable
                  as GeoPoint?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationsImpl implements _Locations {
  const _$LocationsImpl({
    this.installation,
    @JsonKey(name: 'user_device') this.userDevice,
    this.dp,
    @JsonKey(name: 'fat_node') this.fatNode,
  });

  factory _$LocationsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationsImplFromJson(json);

  @override
  final GeoPoint? installation;
  @override
  @JsonKey(name: 'user_device')
  final GeoPoint? userDevice;
  @override
  final GeoPoint? dp;
  @override
  @JsonKey(name: 'fat_node')
  final GeoPoint? fatNode;

  @override
  String toString() {
    return 'Locations(installation: $installation, userDevice: $userDevice, dp: $dp, fatNode: $fatNode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationsImpl &&
            (identical(other.installation, installation) ||
                other.installation == installation) &&
            (identical(other.userDevice, userDevice) ||
                other.userDevice == userDevice) &&
            (identical(other.dp, dp) || other.dp == dp) &&
            (identical(other.fatNode, fatNode) || other.fatNode == fatNode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, installation, userDevice, dp, fatNode);

  /// Create a copy of Locations
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationsImplCopyWith<_$LocationsImpl> get copyWith =>
      __$$LocationsImplCopyWithImpl<_$LocationsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationsImplToJson(this);
  }
}

abstract class _Locations implements Locations {
  const factory _Locations({
    final GeoPoint? installation,
    @JsonKey(name: 'user_device') final GeoPoint? userDevice,
    final GeoPoint? dp,
    @JsonKey(name: 'fat_node') final GeoPoint? fatNode,
  }) = _$LocationsImpl;

  factory _Locations.fromJson(Map<String, dynamic> json) =
      _$LocationsImpl.fromJson;

  @override
  GeoPoint? get installation;
  @override
  @JsonKey(name: 'user_device')
  GeoPoint? get userDevice;
  @override
  GeoPoint? get dp;
  @override
  @JsonKey(name: 'fat_node')
  GeoPoint? get fatNode;

  /// Create a copy of Locations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationsImplCopyWith<_$LocationsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
