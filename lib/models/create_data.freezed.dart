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

CreateDataTeam _$CreateDataTeamFromJson(Map<String, dynamic> json) {
  return _CreateDataTeam.fromJson(json);
}

/// @nodoc
mixin _$CreateDataTeam {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'functional_team_type')
  String? get functionalTeamType => throw _privateConstructorUsedError;
  @JsonKey(name: 'functional_team_types')
  List<String>? get functionalTeamTypes => throw _privateConstructorUsedError;
  @JsonKey(name: 'flow_order')
  int? get flowOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;

  /// Serializes this CreateDataTeam to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateDataTeam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateDataTeamCopyWith<CreateDataTeam> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDataTeamCopyWith<$Res> {
  factory $CreateDataTeamCopyWith(
    CreateDataTeam value,
    $Res Function(CreateDataTeam) then,
  ) = _$CreateDataTeamCopyWithImpl<$Res, CreateDataTeam>;
  @useResult
  $Res call({
    String? id,
    String? name,
    String? code,
    @JsonKey(name: 'functional_team_type') String? functionalTeamType,
    @JsonKey(name: 'functional_team_types') List<String>? functionalTeamTypes,
    @JsonKey(name: 'flow_order') int? flowOrder,
    @JsonKey(name: 'is_active') bool? isActive,
  });
}

/// @nodoc
class _$CreateDataTeamCopyWithImpl<$Res, $Val extends CreateDataTeam>
    implements $CreateDataTeamCopyWith<$Res> {
  _$CreateDataTeamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateDataTeam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? code = freezed,
    Object? functionalTeamType = freezed,
    Object? functionalTeamTypes = freezed,
    Object? flowOrder = freezed,
    Object? isActive = freezed,
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
            code: freezed == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String?,
            functionalTeamType: freezed == functionalTeamType
                ? _value.functionalTeamType
                : functionalTeamType // ignore: cast_nullable_to_non_nullable
                      as String?,
            functionalTeamTypes: freezed == functionalTeamTypes
                ? _value.functionalTeamTypes
                : functionalTeamTypes // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            flowOrder: freezed == flowOrder
                ? _value.flowOrder
                : flowOrder // ignore: cast_nullable_to_non_nullable
                      as int?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateDataTeamImplCopyWith<$Res>
    implements $CreateDataTeamCopyWith<$Res> {
  factory _$$CreateDataTeamImplCopyWith(
    _$CreateDataTeamImpl value,
    $Res Function(_$CreateDataTeamImpl) then,
  ) = __$$CreateDataTeamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String? name,
    String? code,
    @JsonKey(name: 'functional_team_type') String? functionalTeamType,
    @JsonKey(name: 'functional_team_types') List<String>? functionalTeamTypes,
    @JsonKey(name: 'flow_order') int? flowOrder,
    @JsonKey(name: 'is_active') bool? isActive,
  });
}

/// @nodoc
class __$$CreateDataTeamImplCopyWithImpl<$Res>
    extends _$CreateDataTeamCopyWithImpl<$Res, _$CreateDataTeamImpl>
    implements _$$CreateDataTeamImplCopyWith<$Res> {
  __$$CreateDataTeamImplCopyWithImpl(
    _$CreateDataTeamImpl _value,
    $Res Function(_$CreateDataTeamImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateDataTeam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? code = freezed,
    Object? functionalTeamType = freezed,
    Object? functionalTeamTypes = freezed,
    Object? flowOrder = freezed,
    Object? isActive = freezed,
  }) {
    return _then(
      _$CreateDataTeamImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        functionalTeamType: freezed == functionalTeamType
            ? _value.functionalTeamType
            : functionalTeamType // ignore: cast_nullable_to_non_nullable
                  as String?,
        functionalTeamTypes: freezed == functionalTeamTypes
            ? _value._functionalTeamTypes
            : functionalTeamTypes // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        flowOrder: freezed == flowOrder
            ? _value.flowOrder
            : flowOrder // ignore: cast_nullable_to_non_nullable
                  as int?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateDataTeamImpl implements _CreateDataTeam {
  const _$CreateDataTeamImpl({
    this.id,
    this.name,
    this.code,
    @JsonKey(name: 'functional_team_type') this.functionalTeamType,
    @JsonKey(name: 'functional_team_types')
    final List<String>? functionalTeamTypes,
    @JsonKey(name: 'flow_order') this.flowOrder,
    @JsonKey(name: 'is_active') this.isActive,
  }) : _functionalTeamTypes = functionalTeamTypes;

  factory _$CreateDataTeamImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDataTeamImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? code;
  @override
  @JsonKey(name: 'functional_team_type')
  final String? functionalTeamType;
  final List<String>? _functionalTeamTypes;
  @override
  @JsonKey(name: 'functional_team_types')
  List<String>? get functionalTeamTypes {
    final value = _functionalTeamTypes;
    if (value == null) return null;
    if (_functionalTeamTypes is EqualUnmodifiableListView)
      return _functionalTeamTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'flow_order')
  final int? flowOrder;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;

  @override
  String toString() {
    return 'CreateDataTeam(id: $id, name: $name, code: $code, functionalTeamType: $functionalTeamType, functionalTeamTypes: $functionalTeamTypes, flowOrder: $flowOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDataTeamImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.functionalTeamType, functionalTeamType) ||
                other.functionalTeamType == functionalTeamType) &&
            const DeepCollectionEquality().equals(
              other._functionalTeamTypes,
              _functionalTeamTypes,
            ) &&
            (identical(other.flowOrder, flowOrder) ||
                other.flowOrder == flowOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    code,
    functionalTeamType,
    const DeepCollectionEquality().hash(_functionalTeamTypes),
    flowOrder,
    isActive,
  );

  /// Create a copy of CreateDataTeam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateDataTeamImplCopyWith<_$CreateDataTeamImpl> get copyWith =>
      __$$CreateDataTeamImplCopyWithImpl<_$CreateDataTeamImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateDataTeamImplToJson(this);
  }
}

abstract class _CreateDataTeam implements CreateDataTeam {
  const factory _CreateDataTeam({
    final String? id,
    final String? name,
    final String? code,
    @JsonKey(name: 'functional_team_type') final String? functionalTeamType,
    @JsonKey(name: 'functional_team_types')
    final List<String>? functionalTeamTypes,
    @JsonKey(name: 'flow_order') final int? flowOrder,
    @JsonKey(name: 'is_active') final bool? isActive,
  }) = _$CreateDataTeamImpl;

  factory _CreateDataTeam.fromJson(Map<String, dynamic> json) =
      _$CreateDataTeamImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  String? get code;
  @override
  @JsonKey(name: 'functional_team_type')
  String? get functionalTeamType;
  @override
  @JsonKey(name: 'functional_team_types')
  List<String>? get functionalTeamTypes;
  @override
  @JsonKey(name: 'flow_order')
  int? get flowOrder;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;

  /// Create a copy of CreateDataTeam
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateDataTeamImplCopyWith<_$CreateDataTeamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateDataStageAssignment _$CreateDataStageAssignmentFromJson(
  Map<String, dynamic> json,
) {
  return _CreateDataStageAssignment.fromJson(json);
}

/// @nodoc
mixin _$CreateDataStageAssignment {
  @JsonKey(name: 'stage_key')
  String? get stageKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'stage_label')
  String? get stageLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'stage_order')
  int? get stageOrder => throw _privateConstructorUsedError;
  CreateDataTeam? get team => throw _privateConstructorUsedError;

  /// Serializes this CreateDataStageAssignment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateDataStageAssignment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateDataStageAssignmentCopyWith<CreateDataStageAssignment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDataStageAssignmentCopyWith<$Res> {
  factory $CreateDataStageAssignmentCopyWith(
    CreateDataStageAssignment value,
    $Res Function(CreateDataStageAssignment) then,
  ) = _$CreateDataStageAssignmentCopyWithImpl<$Res, CreateDataStageAssignment>;
  @useResult
  $Res call({
    @JsonKey(name: 'stage_key') String? stageKey,
    @JsonKey(name: 'stage_label') String? stageLabel,
    @JsonKey(name: 'stage_order') int? stageOrder,
    CreateDataTeam? team,
  });

  $CreateDataTeamCopyWith<$Res>? get team;
}

/// @nodoc
class _$CreateDataStageAssignmentCopyWithImpl<
  $Res,
  $Val extends CreateDataStageAssignment
>
    implements $CreateDataStageAssignmentCopyWith<$Res> {
  _$CreateDataStageAssignmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateDataStageAssignment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stageKey = freezed,
    Object? stageLabel = freezed,
    Object? stageOrder = freezed,
    Object? team = freezed,
  }) {
    return _then(
      _value.copyWith(
            stageKey: freezed == stageKey
                ? _value.stageKey
                : stageKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            stageLabel: freezed == stageLabel
                ? _value.stageLabel
                : stageLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            stageOrder: freezed == stageOrder
                ? _value.stageOrder
                : stageOrder // ignore: cast_nullable_to_non_nullable
                      as int?,
            team: freezed == team
                ? _value.team
                : team // ignore: cast_nullable_to_non_nullable
                      as CreateDataTeam?,
          )
          as $Val,
    );
  }

  /// Create a copy of CreateDataStageAssignment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreateDataTeamCopyWith<$Res>? get team {
    if (_value.team == null) {
      return null;
    }

    return $CreateDataTeamCopyWith<$Res>(_value.team!, (value) {
      return _then(_value.copyWith(team: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateDataStageAssignmentImplCopyWith<$Res>
    implements $CreateDataStageAssignmentCopyWith<$Res> {
  factory _$$CreateDataStageAssignmentImplCopyWith(
    _$CreateDataStageAssignmentImpl value,
    $Res Function(_$CreateDataStageAssignmentImpl) then,
  ) = __$$CreateDataStageAssignmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'stage_key') String? stageKey,
    @JsonKey(name: 'stage_label') String? stageLabel,
    @JsonKey(name: 'stage_order') int? stageOrder,
    CreateDataTeam? team,
  });

  @override
  $CreateDataTeamCopyWith<$Res>? get team;
}

/// @nodoc
class __$$CreateDataStageAssignmentImplCopyWithImpl<$Res>
    extends
        _$CreateDataStageAssignmentCopyWithImpl<
          $Res,
          _$CreateDataStageAssignmentImpl
        >
    implements _$$CreateDataStageAssignmentImplCopyWith<$Res> {
  __$$CreateDataStageAssignmentImplCopyWithImpl(
    _$CreateDataStageAssignmentImpl _value,
    $Res Function(_$CreateDataStageAssignmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateDataStageAssignment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stageKey = freezed,
    Object? stageLabel = freezed,
    Object? stageOrder = freezed,
    Object? team = freezed,
  }) {
    return _then(
      _$CreateDataStageAssignmentImpl(
        stageKey: freezed == stageKey
            ? _value.stageKey
            : stageKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        stageLabel: freezed == stageLabel
            ? _value.stageLabel
            : stageLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        stageOrder: freezed == stageOrder
            ? _value.stageOrder
            : stageOrder // ignore: cast_nullable_to_non_nullable
                  as int?,
        team: freezed == team
            ? _value.team
            : team // ignore: cast_nullable_to_non_nullable
                  as CreateDataTeam?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateDataStageAssignmentImpl implements _CreateDataStageAssignment {
  const _$CreateDataStageAssignmentImpl({
    @JsonKey(name: 'stage_key') this.stageKey,
    @JsonKey(name: 'stage_label') this.stageLabel,
    @JsonKey(name: 'stage_order') this.stageOrder,
    this.team,
  });

  factory _$CreateDataStageAssignmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDataStageAssignmentImplFromJson(json);

  @override
  @JsonKey(name: 'stage_key')
  final String? stageKey;
  @override
  @JsonKey(name: 'stage_label')
  final String? stageLabel;
  @override
  @JsonKey(name: 'stage_order')
  final int? stageOrder;
  @override
  final CreateDataTeam? team;

  @override
  String toString() {
    return 'CreateDataStageAssignment(stageKey: $stageKey, stageLabel: $stageLabel, stageOrder: $stageOrder, team: $team)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDataStageAssignmentImpl &&
            (identical(other.stageKey, stageKey) ||
                other.stageKey == stageKey) &&
            (identical(other.stageLabel, stageLabel) ||
                other.stageLabel == stageLabel) &&
            (identical(other.stageOrder, stageOrder) ||
                other.stageOrder == stageOrder) &&
            (identical(other.team, team) || other.team == team));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, stageKey, stageLabel, stageOrder, team);

  /// Create a copy of CreateDataStageAssignment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateDataStageAssignmentImplCopyWith<_$CreateDataStageAssignmentImpl>
  get copyWith =>
      __$$CreateDataStageAssignmentImplCopyWithImpl<
        _$CreateDataStageAssignmentImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateDataStageAssignmentImplToJson(this);
  }
}

abstract class _CreateDataStageAssignment implements CreateDataStageAssignment {
  const factory _CreateDataStageAssignment({
    @JsonKey(name: 'stage_key') final String? stageKey,
    @JsonKey(name: 'stage_label') final String? stageLabel,
    @JsonKey(name: 'stage_order') final int? stageOrder,
    final CreateDataTeam? team,
  }) = _$CreateDataStageAssignmentImpl;

  factory _CreateDataStageAssignment.fromJson(Map<String, dynamic> json) =
      _$CreateDataStageAssignmentImpl.fromJson;

  @override
  @JsonKey(name: 'stage_key')
  String? get stageKey;
  @override
  @JsonKey(name: 'stage_label')
  String? get stageLabel;
  @override
  @JsonKey(name: 'stage_order')
  int? get stageOrder;
  @override
  CreateDataTeam? get team;

  /// Create a copy of CreateDataStageAssignment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateDataStageAssignmentImplCopyWith<_$CreateDataStageAssignmentImpl>
  get copyWith => throw _privateConstructorUsedError;
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
  @JsonKey(name: 'stage_assignments')
  List<CreateDataStageAssignment>? get stageAssignments =>
      throw _privateConstructorUsedError;
  List<CreateDataTeam>? get teams => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'stage_assignments')
    List<CreateDataStageAssignment>? stageAssignments,
    List<CreateDataTeam>? teams,
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
    Object? stageAssignments = freezed,
    Object? teams = freezed,
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
            stageAssignments: freezed == stageAssignments
                ? _value.stageAssignments
                : stageAssignments // ignore: cast_nullable_to_non_nullable
                      as List<CreateDataStageAssignment>?,
            teams: freezed == teams
                ? _value.teams
                : teams // ignore: cast_nullable_to_non_nullable
                      as List<CreateDataTeam>?,
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
    @JsonKey(name: 'stage_assignments')
    List<CreateDataStageAssignment>? stageAssignments,
    List<CreateDataTeam>? teams,
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
    Object? stageAssignments = freezed,
    Object? teams = freezed,
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
        stageAssignments: freezed == stageAssignments
            ? _value._stageAssignments
            : stageAssignments // ignore: cast_nullable_to_non_nullable
                  as List<CreateDataStageAssignment>?,
        teams: freezed == teams
            ? _value._teams
            : teams // ignore: cast_nullable_to_non_nullable
                  as List<CreateDataTeam>?,
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
    @JsonKey(name: 'stage_assignments')
    final List<CreateDataStageAssignment>? stageAssignments,
    final List<CreateDataTeam>? teams,
  }) : _stageAssignments = stageAssignments,
       _teams = teams;

  factory _$CreateDataTeamFlowImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDataTeamFlowImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  @JsonKey(name: 'functional_team_type')
  final String? functionalTeamType;
  final List<CreateDataStageAssignment>? _stageAssignments;
  @override
  @JsonKey(name: 'stage_assignments')
  List<CreateDataStageAssignment>? get stageAssignments {
    final value = _stageAssignments;
    if (value == null) return null;
    if (_stageAssignments is EqualUnmodifiableListView)
      return _stageAssignments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<CreateDataTeam>? _teams;
  @override
  List<CreateDataTeam>? get teams {
    final value = _teams;
    if (value == null) return null;
    if (_teams is EqualUnmodifiableListView) return _teams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CreateDataTeamFlow(id: $id, name: $name, functionalTeamType: $functionalTeamType, stageAssignments: $stageAssignments, teams: $teams)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDataTeamFlowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.functionalTeamType, functionalTeamType) ||
                other.functionalTeamType == functionalTeamType) &&
            const DeepCollectionEquality().equals(
              other._stageAssignments,
              _stageAssignments,
            ) &&
            const DeepCollectionEquality().equals(other._teams, _teams));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    functionalTeamType,
    const DeepCollectionEquality().hash(_stageAssignments),
    const DeepCollectionEquality().hash(_teams),
  );

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
    @JsonKey(name: 'stage_assignments')
    final List<CreateDataStageAssignment>? stageAssignments,
    final List<CreateDataTeam>? teams,
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
  @override
  @JsonKey(name: 'stage_assignments')
  List<CreateDataStageAssignment>? get stageAssignments;
  @override
  List<CreateDataTeam>? get teams;

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
  @JsonKey(name: 'default_team_flow_id')
  String? get defaultTeamFlowId => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'default_team_flow_id') String? defaultTeamFlowId,
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
    Object? defaultTeamFlowId = freezed,
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
            defaultTeamFlowId: freezed == defaultTeamFlowId
                ? _value.defaultTeamFlowId
                : defaultTeamFlowId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
    @JsonKey(name: 'default_team_flow_id') String? defaultTeamFlowId,
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
    Object? defaultTeamFlowId = freezed,
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
        defaultTeamFlowId: freezed == defaultTeamFlowId
            ? _value.defaultTeamFlowId
            : defaultTeamFlowId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
    @JsonKey(name: 'default_team_flow_id') this.defaultTeamFlowId,
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
  @JsonKey(name: 'default_team_flow_id')
  final String? defaultTeamFlowId;

  @override
  String toString() {
    return 'CreateData(customerTypes: $customerTypes, plans: $plans, fatNodes: $fatNodes, teamFlows: $teamFlows, defaultTeamFlowId: $defaultTeamFlowId)';
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
            ) &&
            (identical(other.defaultTeamFlowId, defaultTeamFlowId) ||
                other.defaultTeamFlowId == defaultTeamFlowId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_customerTypes),
    const DeepCollectionEquality().hash(_plans),
    const DeepCollectionEquality().hash(_fatNodes),
    const DeepCollectionEquality().hash(_teamFlows),
    defaultTeamFlowId,
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
    @JsonKey(name: 'default_team_flow_id') final String? defaultTeamFlowId,
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
  @override
  @JsonKey(name: 'default_team_flow_id')
  String? get defaultTeamFlowId;

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
