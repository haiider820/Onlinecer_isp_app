// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fat_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FatNode _$FatNodeFromJson(Map<String, dynamic> json) {
  return _FatNode.fromJson(json);
}

/// @nodoc
mixin _$FatNode {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'node_type')
  String get nodeType => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this FatNode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FatNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FatNodeCopyWith<FatNode> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FatNodeCopyWith<$Res> {
  factory $FatNodeCopyWith(FatNode value, $Res Function(FatNode) then) =
      _$FatNodeCopyWithImpl<$Res, FatNode>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'node_type') String nodeType,
    double latitude,
    double longitude,
  });
}

/// @nodoc
class _$FatNodeCopyWithImpl<$Res, $Val extends FatNode>
    implements $FatNodeCopyWith<$Res> {
  _$FatNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FatNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nodeType = null,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            nodeType: null == nodeType
                ? _value.nodeType
                : nodeType // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FatNodeImplCopyWith<$Res> implements $FatNodeCopyWith<$Res> {
  factory _$$FatNodeImplCopyWith(
    _$FatNodeImpl value,
    $Res Function(_$FatNodeImpl) then,
  ) = __$$FatNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'node_type') String nodeType,
    double latitude,
    double longitude,
  });
}

/// @nodoc
class __$$FatNodeImplCopyWithImpl<$Res>
    extends _$FatNodeCopyWithImpl<$Res, _$FatNodeImpl>
    implements _$$FatNodeImplCopyWith<$Res> {
  __$$FatNodeImplCopyWithImpl(
    _$FatNodeImpl _value,
    $Res Function(_$FatNodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FatNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nodeType = null,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(
      _$FatNodeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        nodeType: null == nodeType
            ? _value.nodeType
            : nodeType // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FatNodeImpl implements _FatNode {
  const _$FatNodeImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'node_type') required this.nodeType,
    required this.latitude,
    required this.longitude,
  });

  factory _$FatNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$FatNodeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'node_type')
  final String nodeType;
  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'FatNode(id: $id, name: $name, nodeType: $nodeType, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FatNodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nodeType, nodeType) ||
                other.nodeType == nodeType) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, nodeType, latitude, longitude);

  /// Create a copy of FatNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FatNodeImplCopyWith<_$FatNodeImpl> get copyWith =>
      __$$FatNodeImplCopyWithImpl<_$FatNodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FatNodeImplToJson(this);
  }
}

abstract class _FatNode implements FatNode {
  const factory _FatNode({
    required final String id,
    required final String name,
    @JsonKey(name: 'node_type') required final String nodeType,
    required final double latitude,
    required final double longitude,
  }) = _$FatNodeImpl;

  factory _FatNode.fromJson(Map<String, dynamic> json) = _$FatNodeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'node_type')
  String get nodeType;
  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of FatNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FatNodeImplCopyWith<_$FatNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FatNodeList _$FatNodeListFromJson(Map<String, dynamic> json) {
  return _FatNodeList.fromJson(json);
}

/// @nodoc
mixin _$FatNodeList {
  List<FatNode> get data => throw _privateConstructorUsedError;

  /// Serializes this FatNodeList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FatNodeList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FatNodeListCopyWith<FatNodeList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FatNodeListCopyWith<$Res> {
  factory $FatNodeListCopyWith(
    FatNodeList value,
    $Res Function(FatNodeList) then,
  ) = _$FatNodeListCopyWithImpl<$Res, FatNodeList>;
  @useResult
  $Res call({List<FatNode> data});
}

/// @nodoc
class _$FatNodeListCopyWithImpl<$Res, $Val extends FatNodeList>
    implements $FatNodeListCopyWith<$Res> {
  _$FatNodeListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FatNodeList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<FatNode>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FatNodeListImplCopyWith<$Res>
    implements $FatNodeListCopyWith<$Res> {
  factory _$$FatNodeListImplCopyWith(
    _$FatNodeListImpl value,
    $Res Function(_$FatNodeListImpl) then,
  ) = __$$FatNodeListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<FatNode> data});
}

/// @nodoc
class __$$FatNodeListImplCopyWithImpl<$Res>
    extends _$FatNodeListCopyWithImpl<$Res, _$FatNodeListImpl>
    implements _$$FatNodeListImplCopyWith<$Res> {
  __$$FatNodeListImplCopyWithImpl(
    _$FatNodeListImpl _value,
    $Res Function(_$FatNodeListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FatNodeList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$FatNodeListImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<FatNode>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FatNodeListImpl implements _FatNodeList {
  const _$FatNodeListImpl({required final List<FatNode> data}) : _data = data;

  factory _$FatNodeListImpl.fromJson(Map<String, dynamic> json) =>
      _$$FatNodeListImplFromJson(json);

  final List<FatNode> _data;
  @override
  List<FatNode> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'FatNodeList(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FatNodeListImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  /// Create a copy of FatNodeList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FatNodeListImplCopyWith<_$FatNodeListImpl> get copyWith =>
      __$$FatNodeListImplCopyWithImpl<_$FatNodeListImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FatNodeListImplToJson(this);
  }
}

abstract class _FatNodeList implements FatNodeList {
  const factory _FatNodeList({required final List<FatNode> data}) =
      _$FatNodeListImpl;

  factory _FatNodeList.fromJson(Map<String, dynamic> json) =
      _$FatNodeListImpl.fromJson;

  @override
  List<FatNode> get data;

  /// Create a copy of FatNodeList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FatNodeListImplCopyWith<_$FatNodeListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
