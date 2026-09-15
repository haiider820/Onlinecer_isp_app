// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) {
  return _InventoryItem.fromJson(json);
}

/// @nodoc
mixin _$InventoryItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_quantity')
  num? get stockQuantity => throw _privateConstructorUsedError;

  /// Serializes this InventoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryItemCopyWith<InventoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryItemCopyWith<$Res> {
  factory $InventoryItemCopyWith(
    InventoryItem value,
    $Res Function(InventoryItem) then,
  ) = _$InventoryItemCopyWithImpl<$Res, InventoryItem>;
  @useResult
  $Res call({
    String id,
    String name,
    String? unit,
    String? category,
    @JsonKey(name: 'stock_quantity') num? stockQuantity,
  });
}

/// @nodoc
class _$InventoryItemCopyWithImpl<$Res, $Val extends InventoryItem>
    implements $InventoryItemCopyWith<$Res> {
  _$InventoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? unit = freezed,
    Object? category = freezed,
    Object? stockQuantity = freezed,
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
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            stockQuantity: freezed == stockQuantity
                ? _value.stockQuantity
                : stockQuantity // ignore: cast_nullable_to_non_nullable
                      as num?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InventoryItemImplCopyWith<$Res>
    implements $InventoryItemCopyWith<$Res> {
  factory _$$InventoryItemImplCopyWith(
    _$InventoryItemImpl value,
    $Res Function(_$InventoryItemImpl) then,
  ) = __$$InventoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? unit,
    String? category,
    @JsonKey(name: 'stock_quantity') num? stockQuantity,
  });
}

/// @nodoc
class __$$InventoryItemImplCopyWithImpl<$Res>
    extends _$InventoryItemCopyWithImpl<$Res, _$InventoryItemImpl>
    implements _$$InventoryItemImplCopyWith<$Res> {
  __$$InventoryItemImplCopyWithImpl(
    _$InventoryItemImpl _value,
    $Res Function(_$InventoryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? unit = freezed,
    Object? category = freezed,
    Object? stockQuantity = freezed,
  }) {
    return _then(
      _$InventoryItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        stockQuantity: freezed == stockQuantity
            ? _value.stockQuantity
            : stockQuantity // ignore: cast_nullable_to_non_nullable
                  as num?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryItemImpl implements _InventoryItem {
  const _$InventoryItemImpl({
    required this.id,
    required this.name,
    this.unit,
    this.category,
    @JsonKey(name: 'stock_quantity') this.stockQuantity,
  });

  factory _$InventoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? unit;
  @override
  final String? category;
  @override
  @JsonKey(name: 'stock_quantity')
  final num? stockQuantity;

  @override
  String toString() {
    return 'InventoryItem(id: $id, name: $name, unit: $unit, category: $category, stockQuantity: $stockQuantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, unit, category, stockQuantity);

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryItemImplCopyWith<_$InventoryItemImpl> get copyWith =>
      __$$InventoryItemImplCopyWithImpl<_$InventoryItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryItemImplToJson(this);
  }
}

abstract class _InventoryItem implements InventoryItem {
  const factory _InventoryItem({
    required final String id,
    required final String name,
    final String? unit,
    final String? category,
    @JsonKey(name: 'stock_quantity') final num? stockQuantity,
  }) = _$InventoryItemImpl;

  factory _InventoryItem.fromJson(Map<String, dynamic> json) =
      _$InventoryItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get unit;
  @override
  String? get category;
  @override
  @JsonKey(name: 'stock_quantity')
  num? get stockQuantity;

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryItemImplCopyWith<_$InventoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InventoryItemList _$InventoryItemListFromJson(Map<String, dynamic> json) {
  return _InventoryItemList.fromJson(json);
}

/// @nodoc
mixin _$InventoryItemList {
  List<InventoryItem> get data => throw _privateConstructorUsedError;

  /// Serializes this InventoryItemList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InventoryItemList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryItemListCopyWith<InventoryItemList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryItemListCopyWith<$Res> {
  factory $InventoryItemListCopyWith(
    InventoryItemList value,
    $Res Function(InventoryItemList) then,
  ) = _$InventoryItemListCopyWithImpl<$Res, InventoryItemList>;
  @useResult
  $Res call({List<InventoryItem> data});
}

/// @nodoc
class _$InventoryItemListCopyWithImpl<$Res, $Val extends InventoryItemList>
    implements $InventoryItemListCopyWith<$Res> {
  _$InventoryItemListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryItemList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<InventoryItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InventoryItemListImplCopyWith<$Res>
    implements $InventoryItemListCopyWith<$Res> {
  factory _$$InventoryItemListImplCopyWith(
    _$InventoryItemListImpl value,
    $Res Function(_$InventoryItemListImpl) then,
  ) = __$$InventoryItemListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<InventoryItem> data});
}

/// @nodoc
class __$$InventoryItemListImplCopyWithImpl<$Res>
    extends _$InventoryItemListCopyWithImpl<$Res, _$InventoryItemListImpl>
    implements _$$InventoryItemListImplCopyWith<$Res> {
  __$$InventoryItemListImplCopyWithImpl(
    _$InventoryItemListImpl _value,
    $Res Function(_$InventoryItemListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InventoryItemList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$InventoryItemListImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<InventoryItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryItemListImpl implements _InventoryItemList {
  const _$InventoryItemListImpl({required final List<InventoryItem> data})
    : _data = data;

  factory _$InventoryItemListImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryItemListImplFromJson(json);

  final List<InventoryItem> _data;
  @override
  List<InventoryItem> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'InventoryItemList(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryItemListImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  /// Create a copy of InventoryItemList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryItemListImplCopyWith<_$InventoryItemListImpl> get copyWith =>
      __$$InventoryItemListImplCopyWithImpl<_$InventoryItemListImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryItemListImplToJson(this);
  }
}

abstract class _InventoryItemList implements InventoryItemList {
  const factory _InventoryItemList({required final List<InventoryItem> data}) =
      _$InventoryItemListImpl;

  factory _InventoryItemList.fromJson(Map<String, dynamic> json) =
      _$InventoryItemListImpl.fromJson;

  @override
  List<InventoryItem> get data;

  /// Create a copy of InventoryItemList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryItemListImplCopyWith<_$InventoryItemListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
