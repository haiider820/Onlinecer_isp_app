// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateDataOption _$CreateDataOptionFromJson(Map<String, dynamic> json) {
  return _CreateDataOption.fromJson(json);
}

/// @nodoc
mixin _$CreateDataOption {
  String? get value => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;

  /// Serializes this CreateDataOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateDataOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateDataOptionCopyWith<CreateDataOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDataOptionCopyWith<$Res> {
  factory $CreateDataOptionCopyWith(
    CreateDataOption value,
    $Res Function(CreateDataOption) then,
  ) = _$CreateDataOptionCopyWithImpl<$Res, CreateDataOption>;
  @useResult
  $Res call({String? value, String? label});
}

/// @nodoc
class _$CreateDataOptionCopyWithImpl<$Res, $Val extends CreateDataOption>
    implements $CreateDataOptionCopyWith<$Res> {
  _$CreateDataOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateDataOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = freezed, Object? label = freezed}) {
    return _then(
      _value.copyWith(
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String?,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateDataOptionImplCopyWith<$Res>
    implements $CreateDataOptionCopyWith<$Res> {
  factory _$$CreateDataOptionImplCopyWith(
    _$CreateDataOptionImpl value,
    $Res Function(_$CreateDataOptionImpl) then,
  ) = __$$CreateDataOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? value, String? label});
}

/// @nodoc
class __$$CreateDataOptionImplCopyWithImpl<$Res>
    extends _$CreateDataOptionCopyWithImpl<$Res, _$CreateDataOptionImpl>
    implements _$$CreateDataOptionImplCopyWith<$Res> {
  __$$CreateDataOptionImplCopyWithImpl(
    _$CreateDataOptionImpl _value,
    $Res Function(_$CreateDataOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateDataOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = freezed, Object? label = freezed}) {
    return _then(
      _$CreateDataOptionImpl(
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String?,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateDataOptionImpl implements _CreateDataOption {
  const _$CreateDataOptionImpl({this.value, this.label});

  factory _$CreateDataOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDataOptionImplFromJson(json);

  @override
  final String? value;
  @override
  final String? label;

  @override
  String toString() {
    return 'CreateDataOption(value: $value, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDataOptionImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, label);

  /// Create a copy of CreateDataOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateDataOptionImplCopyWith<_$CreateDataOptionImpl> get copyWith =>
      __$$CreateDataOptionImplCopyWithImpl<_$CreateDataOptionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateDataOptionImplToJson(this);
  }
}

abstract class _CreateDataOption implements CreateDataOption {
  const factory _CreateDataOption({final String? value, final String? label}) =
      _$CreateDataOptionImpl;

  factory _CreateDataOption.fromJson(Map<String, dynamic> json) =
      _$CreateDataOptionImpl.fromJson;

  @override
  String? get value;
  @override
  String? get label;

  /// Create a copy of CreateDataOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateDataOptionImplCopyWith<_$CreateDataOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateDataPlan _$CreateDataPlanFromJson(Map<String, dynamic> json) {
  return _CreateDataPlan.fromJson(json);
}

/// @nodoc
mixin _$CreateDataPlan {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_minor')
  int? get priceMinor => throw _privateConstructorUsedError;

  /// Serializes this CreateDataPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateDataPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateDataPlanCopyWith<CreateDataPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDataPlanCopyWith<$Res> {
  factory $CreateDataPlanCopyWith(
    CreateDataPlan value,
    $Res Function(CreateDataPlan) then,
  ) = _$CreateDataPlanCopyWithImpl<$Res, CreateDataPlan>;
  @useResult
  $Res call({
    String? id,
    String? name,
    @JsonKey(name: 'price_minor') int? priceMinor,
  });
}

/// @nodoc
class _$CreateDataPlanCopyWithImpl<$Res, $Val extends CreateDataPlan>
    implements $CreateDataPlanCopyWith<$Res> {
  _$CreateDataPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateDataPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? priceMinor = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            priceMinor: freezed == priceMinor
                ? _value.priceMinor
                : priceMinor // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateDataPlanImplCopyWith<$Res>
    implements $CreateDataPlanCopyWith<$Res> {
  factory _$$CreateDataPlanImplCopyWith(
    _$CreateDataPlanImpl value,
    $Res Function(_$CreateDataPlanImpl) then,
  ) = __$$CreateDataPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String? name,
    @JsonKey(name: 'price_minor') int? priceMinor,
  });
}

/// @nodoc
class __$$CreateDataPlanImplCopyWithImpl<$Res>
    extends _$CreateDataPlanCopyWithImpl<$Res, _$CreateDataPlanImpl>
    implements _$$CreateDataPlanImplCopyWith<$Res> {
  __$$CreateDataPlanImplCopyWithImpl(
    _$CreateDataPlanImpl _value,
    $Res Function(_$CreateDataPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateDataPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? priceMinor = freezed,
  }) {
    return _then(
      _$CreateDataPlanImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        priceMinor: freezed == priceMinor
            ? _value.priceMinor
            : priceMinor // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateDataPlanImpl implements _CreateDataPlan {
  const _$CreateDataPlanImpl({
    this.id,
    this.name,
    @JsonKey(name: 'price_minor') this.priceMinor,
  });

  factory _$CreateDataPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDataPlanImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  @JsonKey(name: 'price_minor')
  final int? priceMinor;

  @override
  String toString() {
    return 'CreateDataPlan(id: $id, name: $name, priceMinor: $priceMinor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDataPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.priceMinor, priceMinor) ||
                other.priceMinor == priceMinor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, priceMinor);

  /// Create a copy of CreateDataPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateDataPlanImplCopyWith<_$CreateDataPlanImpl> get copyWith =>
      __$$CreateDataPlanImplCopyWithImpl<_$CreateDataPlanImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateDataPlanImplToJson(this);
  }
}

abstract class _CreateDataPlan implements CreateDataPlan {
  const factory _CreateDataPlan({
    final String? id,
    final String? name,
    @JsonKey(name: 'price_minor') final int? priceMinor,
  }) = _$CreateDataPlanImpl;

  factory _CreateDataPlan.fromJson(Map<String, dynamic> json) =
      _$CreateDataPlanImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  @JsonKey(name: 'price_minor')
  int? get priceMinor;

  /// Create a copy of CreateDataPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateDataPlanImplCopyWith<_$CreateDataPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateDataFatNode _$CreateDataFatNodeFromJson(Map<String, dynamic> json) {
  return _CreateDataFatNode.fromJson(json);
}

/// @nodoc
mixin _$CreateDataFatNode {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'node_type')
  String? get nodeType => throw _privateConstructorUsedError;

  /// Serializes this CreateDataFatNode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateDataFatNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateDataFatNodeCopyWith<CreateDataFatNode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDataFatNodeCopyWith<$Res> {
  factory $CreateDataFatNodeCopyWith(
    CreateDataFatNode value,
    $Res Function(CreateDataFatNode) then,
  ) = _$CreateDataFatNodeCopyWithImpl<$Res, CreateDataFatNode>;
  @useResult
  $Res call({
    String? id,
    String? name,
    @JsonKey(name: 'node_type') String? nodeType,
  });
}

/// @nodoc
class _$CreateDataFatNodeCopyWithImpl<$Res, $Val extends CreateDataFatNode>
    implements $CreateDataFatNodeCopyWith<$Res> {
  _$CreateDataFatNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateDataFatNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? nodeType = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            nodeType: freezed == nodeType
                ? _value.nodeType
                : nodeType // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateDataFatNodeImplCopyWith<$Res>
    implements $CreateDataFatNodeCopyWith<$Res> {
  factory _$$CreateDataFatNodeImplCopyWith(
    _$CreateDataFatNodeImpl value,
    $Res Function(_$CreateDataFatNodeImpl) then,
  ) = __$$CreateDataFatNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String? name,
    @JsonKey(name: 'node_type') String? nodeType,
  });
}

/// @nodoc
class __$$CreateDataFatNodeImplCopyWithImpl<$Res>
    extends _$CreateDataFatNodeCopyWithImpl<$Res, _$CreateDataFatNodeImpl>
    implements _$$CreateDataFatNodeImplCopyWith<$Res> {
  __$$CreateDataFatNodeImplCopyWithImpl(
    _$CreateDataFatNodeImpl _value,
    $Res Function(_$CreateDataFatNodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateDataFatNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? nodeType = freezed,
  }) {
    return _then(
      _$CreateDataFatNodeImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        nodeType: freezed == nodeType
            ? _value.nodeType
            : nodeType // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateDataFatNodeImpl implements _CreateDataFatNode {
  const _$CreateDataFatNodeImpl({
    this.id,
    this.name,
    @JsonKey(name: 'node_type') this.nodeType,
  });

  factory _$CreateDataFatNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDataFatNodeImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  @JsonKey(name: 'node_type')
  final String? nodeType;

  @override
  String toString() {
    return 'CreateDataFatNode(id: $id, name: $name, nodeType: $nodeType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDataFatNodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nodeType, nodeType) ||
                other.nodeType == nodeType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, nodeType);

  /// Create a copy of CreateDataFatNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateDataFatNodeImplCopyWith<_$CreateDataFatNodeImpl> get copyWith =>
      __$$CreateDataFatNodeImplCopyWithImpl<_$CreateDataFatNodeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateDataFatNodeImplToJson(this);
  }
}

abstract class _CreateDataFatNode implements CreateDataFatNode {
  const factory _CreateDataFatNode({
    final String? id,
    final String? name,
    @JsonKey(name: 'node_type') final String? nodeType,
  }) = _$CreateDataFatNodeImpl;

  factory _CreateDataFatNode.fromJson(Map<String, dynamic> json) =
      _$CreateDataFatNodeImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  @JsonKey(name: 'node_type')
  String? get nodeType;

  /// Create a copy of CreateDataFatNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateDataFatNodeImplCopyWith<_$CreateDataFatNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateDataTeamFlow _$CreateDataTeamFlowFromJson(Map<String, dynamic> json) {
  return _CreateDataTeamFlow.fromJson(json);
}

/// @nodoc
mixin _$CreateDataTeamFlow {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'functional_team_type')
  String? get functionalTeamType => throw _privateConstructorUsedError;

  /// Serializes this CreateDataTeamFlow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateDataTeamFlow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateDataTeamFlowCopyWith<CreateDataTeamFlow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDataTeamFlowCopyWith<$Res> {
  factory $CreateDataTeamFlowCopyWith(
    CreateDataTeamFlow value,
    $Res Function(CreateDataTeamFlow) then,
  ) = _$CreateDataTeamFlowCopyWithImpl<$Res, CreateDataTeamFlow>;
  @useResult
  $Res call({
    String? id,
    String? name,
    @JsonKey(name: 'functional_team_type') String? functionalTeamType,
  });
}

/// @nodoc
class _$CreateDataTeamFlowCopyWithImpl<$Res, $Val extends CreateDataTeamFlow>
    implements $CreateDataTeamFlowCopyWith<$Res> {
  _$CreateDataTeamFlowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateDataTeamFlow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? functionalTeamType = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            functionalTeamType: freezed == functionalTeamType
                ? _value.functionalTeamType
                : functionalTeamType // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateDataTeamFlowImplCopyWith<$Res>
    implements $CreateDataTeamFlowCopyWith<$Res> {
  factory _$$CreateDataTeamFlowImplCopyWith(
    _$CreateDataTeamFlowImpl value,
    $Res Function(_$CreateDataTeamFlowImpl) then,
  ) = __$$CreateDataTeamFlowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String? name,
    @JsonKey(name: 'functional_team_type') String? functionalTeamType,
  });
}

/// @nodoc
class __$$CreateDataTeamFlowImplCopyWithImpl<$Res>
    extends _$CreateDataTeamFlowCopyWithImpl<$Res, _$CreateDataTeamFlowImpl>
    implements _$$CreateDataTeamFlowImplCopyWith<$Res> {
  __$$CreateDataTeamFlowImplCopyWithImpl(
    _$CreateDataTeamFlowImpl _value,
    $Res Function(_$CreateDataTeamFlowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateDataTeamFlow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? functionalTeamType = freezed,
  }) {
    return _then(
      _$CreateDataTeamFlowImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        functionalTeamType: freezed == functionalTeamType
            ? _value.functionalTeamType
            : functionalTeamType // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateDataTeamFlowImpl implements _CreateDataTeamFlow {
  const _$CreateDataTeamFlowImpl({
    this.id,
    this.name,
    @JsonKey(name: 'functional_team_type') this.functionalTeamType,
  });

  factory _$CreateDataTeamFlowImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDataTeamFlowImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  @JsonKey(name: 'functional_team_type')
  final String? functionalTeamType;

  @override
  String toString() {
    return 'CreateDataTeamFlow(id: $id, name: $name, functionalTeamType: $functionalTeamType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDataTeamFlowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.functionalTeamType, functionalTeamType) ||
                other.functionalTeamType == functionalTeamType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, functionalTeamType);

  /// Create a copy of CreateDataTeamFlow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateDataTeamFlowImplCopyWith<_$CreateDataTeamFlowImpl> get copyWith =>
      __$$CreateDataTeamFlowImplCopyWithImpl<_$CreateDataTeamFlowImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateDataTeamFlowImplToJson(this);
  }
}

abstract class _CreateDataTeamFlow implements CreateDataTeamFlow {
  const factory _CreateDataTeamFlow({
    final String? id,
    final String? name,
    @JsonKey(name: 'functional_team_type') final String? functionalTeamType,
  }) = _$CreateDataTeamFlowImpl;

  factory _CreateDataTeamFlow.fromJson(Map<String, dynamic> json) =
      _$CreateDataTeamFlowImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  @JsonKey(name: 'functional_team_type')
  String? get functionalTeamType;

  /// Create a copy of CreateDataTeamFlow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateDataTeamFlowImplCopyWith<_$CreateDataTeamFlowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateData _$CreateDataFromJson(Map<String, dynamic> json) {
  return _CreateData.fromJson(json);
}

/// @nodoc
mixin _$CreateData {
  @JsonKey(name: 'customer_types')
  List<CreateDataOption>? get customerTypes =>
      throw _privateConstructorUsedError;
  List<CreateDataPlan>? get plans => throw _privateConstructorUsedError;
  @JsonKey(name: 'fat_nodes')
  List<CreateDataFatNode>? get fatNodes => throw _privateConstructorUsedError;
  @JsonKey(name: 'team_flows')
  List<CreateDataTeamFlow>? get teamFlows => throw _privateConstructorUsedError;

  /// Serializes this CreateData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateDataCopyWith<CreateData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDataCopyWith<$Res> {
  factory $CreateDataCopyWith(
    CreateData value,
    $Res Function(CreateData) then,
  ) = _$CreateDataCopyWithImpl<$Res, CreateData>;
  @useResult
  $Res call({
    @JsonKey(name: 'customer_types') List<CreateDataOption>? customerTypes,
    List<CreateDataPlan>? plans,
    @JsonKey(name: 'fat_nodes') List<CreateDataFatNode>? fatNodes,
    @JsonKey(name: 'team_flows') List<CreateDataTeamFlow>? teamFlows,
  });
}

/// @nodoc
class _$CreateDataCopyWithImpl<$Res, $Val extends CreateData>
    implements $CreateDataCopyWith<$Res> {
  _$CreateDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerTypes = freezed,
    Object? plans = freezed,
    Object? fatNodes = freezed,
    Object? teamFlows = freezed,
  }) {
    return _then(
      _value.copyWith(
            customerTypes: freezed == customerTypes
                ? _value.customerTypes
                : customerTypes // ignore: cast_nullable_to_non_nullable
                      as List<CreateDataOption>?,
            plans: freezed == plans
                ? _value.plans
                : plans // ignore: cast_nullable_to_non_nullable
                      as List<CreateDataPlan>?,
            fatNodes: freezed == fatNodes
                ? _value.fatNodes
                : fatNodes // ignore: cast_nullable_to_non_nullable
                      as List<CreateDataFatNode>?,
            teamFlows: freezed == teamFlows
                ? _value.teamFlows
                : teamFlows // ignore: cast_nullable_to_non_nullable
                      as List<CreateDataTeamFlow>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateDataImplCopyWith<$Res>
    implements $CreateDataCopyWith<$Res> {
  factory _$$CreateDataImplCopyWith(
    _$CreateDataImpl value,
    $Res Function(_$CreateDataImpl) then,
  ) = __$$CreateDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'customer_types') List<CreateDataOption>? customerTypes,
    List<CreateDataPlan>? plans,
    @JsonKey(name: 'fat_nodes') List<CreateDataFatNode>? fatNodes,
    @JsonKey(name: 'team_flows') List<CreateDataTeamFlow>? teamFlows,
  });
}

/// @nodoc
class __$$CreateDataImplCopyWithImpl<$Res>
    extends _$CreateDataCopyWithImpl<$Res, _$CreateDataImpl>
    implements _$$CreateDataImplCopyWith<$Res> {
  __$$CreateDataImplCopyWithImpl(
    _$CreateDataImpl _value,
    $Res Function(_$CreateDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerTypes = freezed,
    Object? plans = freezed,
    Object? fatNodes = freezed,
    Object? teamFlows = freezed,
  }) {
    return _then(
      _$CreateDataImpl(
        customerTypes: freezed == customerTypes
            ? _value._customerTypes
            : customerTypes // ignore: cast_nullable_to_non_nullable
                  as List<CreateDataOption>?,
        plans: freezed == plans
            ? _value._plans
            : plans // ignore: cast_nullable_to_non_nullable
                  as List<CreateDataPlan>?,
        fatNodes: freezed == fatNodes
            ? _value._fatNodes
            : fatNodes // ignore: cast_nullable_to_non_nullable
                  as List<CreateDataFatNode>?,
        teamFlows: freezed == teamFlows
            ? _value._teamFlows
            : teamFlows // ignore: cast_nullable_to_non_nullable
                  as List<CreateDataTeamFlow>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateDataImpl implements _CreateData {
  const _$CreateDataImpl({
    @JsonKey(name: 'customer_types')
    final List<CreateDataOption>? customerTypes,
    final List<CreateDataPlan>? plans,
    @JsonKey(name: 'fat_nodes') final List<CreateDataFatNode>? fatNodes,
    @JsonKey(name: 'team_flows') final List<CreateDataTeamFlow>? teamFlows,
  }) : _customerTypes = customerTypes,
       _plans = plans,
       _fatNodes = fatNodes,
       _teamFlows = teamFlows;

  factory _$CreateDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDataImplFromJson(json);

  final List<CreateDataOption>? _customerTypes;
  @override
  @JsonKey(name: 'customer_types')
  List<CreateDataOption>? get customerTypes {
    final value = _customerTypes;
    if (value == null) return null;
    if (_customerTypes is EqualUnmodifiableListView) return _customerTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<CreateDataPlan>? _plans;
  @override
  List<CreateDataPlan>? get plans {
    final value = _plans;
    if (value == null) return null;
    if (_plans is EqualUnmodifiableListView) return _plans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<CreateDataFatNode>? _fatNodes;
  @override
  @JsonKey(name: 'fat_nodes')
  List<CreateDataFatNode>? get fatNodes {
    final value = _fatNodes;
    if (value == null) return null;
    if (_fatNodes is EqualUnmodifiableListView) return _fatNodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<CreateDataTeamFlow>? _teamFlows;
  @override
  @JsonKey(name: 'team_flows')
  List<CreateDataTeamFlow>? get teamFlows {
    final value = _teamFlows;
    if (value == null) return null;
    if (_teamFlows is EqualUnmodifiableListView) return _teamFlows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CreateData(customerTypes: $customerTypes, plans: $plans, fatNodes: $fatNodes, teamFlows: $teamFlows)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDataImpl &&
            const DeepCollectionEquality().equals(
              other._customerTypes,
              _customerTypes,
            ) &&
            const DeepCollectionEquality().equals(other._plans, _plans) &&
            const DeepCollectionEquality().equals(other._fatNodes, _fatNodes) &&
            const DeepCollectionEquality().equals(
              other._teamFlows,
              _teamFlows,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_customerTypes),
    const DeepCollectionEquality().hash(_plans),
    const DeepCollectionEquality().hash(_fatNodes),
    const DeepCollectionEquality().hash(_teamFlows),
  );

  /// Create a copy of CreateData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateDataImplCopyWith<_$CreateDataImpl> get copyWith =>
      __$$CreateDataImplCopyWithImpl<_$CreateDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateDataImplToJson(this);
  }
}

abstract class _CreateData implements CreateData {
  const factory _CreateData({
    @JsonKey(name: 'customer_types')
    final List<CreateDataOption>? customerTypes,
    final List<CreateDataPlan>? plans,
    @JsonKey(name: 'fat_nodes') final List<CreateDataFatNode>? fatNodes,
    @JsonKey(name: 'team_flows') final List<CreateDataTeamFlow>? teamFlows,
  }) = _$CreateDataImpl;

  factory _CreateData.fromJson(Map<String, dynamic> json) =
      _$CreateDataImpl.fromJson;

  @override
  @JsonKey(name: 'customer_types')
  List<CreateDataOption>? get customerTypes;
  @override
  List<CreateDataPlan>? get plans;
  @override
  @JsonKey(name: 'fat_nodes')
  List<CreateDataFatNode>? get fatNodes;
  @override
  @JsonKey(name: 'team_flows')
  List<CreateDataTeamFlow>? get teamFlows;

  /// Create a copy of CreateData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateDataImplCopyWith<_$CreateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateDataResponse _$CreateDataResponseFromJson(Map<String, dynamic> json) {
  return _CreateDataResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateDataResponse {
  @JsonKey(name: 'data')
  CreateData? get data => throw _privateConstructorUsedError;

  /// Serializes this CreateDataResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateDataResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateDataResponseCopyWith<CreateDataResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDataResponseCopyWith<$Res> {
  factory $CreateDataResponseCopyWith(
    CreateDataResponse value,
    $Res Function(CreateDataResponse) then,
  ) = _$CreateDataResponseCopyWithImpl<$Res, CreateDataResponse>;
  @useResult
  $Res call({@JsonKey(name: 'data') CreateData? data});

  $CreateDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$CreateDataResponseCopyWithImpl<$Res, $Val extends CreateDataResponse>
    implements $CreateDataResponseCopyWith<$Res> {
  _$CreateDataResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateDataResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = freezed}) {
    return _then(
      _value.copyWith(
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as CreateData?,
          )
          as $Val,
    );
  }

  /// Create a copy of CreateDataResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreateDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $CreateDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateDataResponseImplCopyWith<$Res>
    implements $CreateDataResponseCopyWith<$Res> {
  factory _$$CreateDataResponseImplCopyWith(
    _$CreateDataResponseImpl value,
    $Res Function(_$CreateDataResponseImpl) then,
  ) = __$$CreateDataResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'data') CreateData? data});

  @override
  $CreateDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$CreateDataResponseImplCopyWithImpl<$Res>
    extends _$CreateDataResponseCopyWithImpl<$Res, _$CreateDataResponseImpl>
    implements _$$CreateDataResponseImplCopyWith<$Res> {
  __$$CreateDataResponseImplCopyWithImpl(
    _$CreateDataResponseImpl _value,
    $Res Function(_$CreateDataResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateDataResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = freezed}) {
    return _then(
      _$CreateDataResponseImpl(
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as CreateData?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateDataResponseImpl implements _CreateDataResponse {
  const _$CreateDataResponseImpl({@JsonKey(name: 'data') this.data});

  factory _$CreateDataResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDataResponseImplFromJson(json);

  @override
  @JsonKey(name: 'data')
  final CreateData? data;

  @override
  String toString() {
    return 'CreateDataResponse(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDataResponseImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of CreateDataResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateDataResponseImplCopyWith<_$CreateDataResponseImpl> get copyWith =>
      __$$CreateDataResponseImplCopyWithImpl<_$CreateDataResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateDataResponseImplToJson(this);
  }
}

abstract class _CreateDataResponse implements CreateDataResponse {
  const factory _CreateDataResponse({
    @JsonKey(name: 'data') final CreateData? data,
  }) = _$CreateDataResponseImpl;

  factory _CreateDataResponse.fromJson(Map<String, dynamic> json) =
      _$CreateDataResponseImpl.fromJson;

  @override
  @JsonKey(name: 'data')
  CreateData? get data;

  /// Create a copy of CreateDataResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateDataResponseImplCopyWith<_$CreateDataResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
