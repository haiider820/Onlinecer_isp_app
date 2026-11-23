// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_branch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubBranch _$SubBranchFromJson(Map<String, dynamic> json) {
  return _SubBranch.fromJson(json);
}

/// @nodoc
mixin _$SubBranch {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_id')
  String? get organizationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'company_id')
  String? get companyId => throw _privateConstructorUsedError;
  @JsonKey(name: 'branch_id')
  String? get branchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'parent_id')
  String? get parentId => throw _privateConstructorUsedError;

  /// Serializes this SubBranch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubBranch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubBranchCopyWith<SubBranch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubBranchCopyWith<$Res> {
  factory $SubBranchCopyWith(SubBranch value, $Res Function(SubBranch) then) =
      _$SubBranchCopyWithImpl<$Res, SubBranch>;
  @useResult
  $Res call({
    String id,
    String name,
    String? type,
    @JsonKey(name: 'organization_id') String? organizationId,
    @JsonKey(name: 'company_id') String? companyId,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'parent_id') String? parentId,
  });
}

/// @nodoc
class _$SubBranchCopyWithImpl<$Res, $Val extends SubBranch>
    implements $SubBranchCopyWith<$Res> {
  _$SubBranchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubBranch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = freezed,
    Object? organizationId = freezed,
    Object? companyId = freezed,
    Object? branchId = freezed,
    Object? parentId = freezed,
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
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            organizationId: freezed == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                      as String?,
            companyId: freezed == companyId
                ? _value.companyId
                : companyId // ignore: cast_nullable_to_non_nullable
                      as String?,
            branchId: freezed == branchId
                ? _value.branchId
                : branchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubBranchImplCopyWith<$Res>
    implements $SubBranchCopyWith<$Res> {
  factory _$$SubBranchImplCopyWith(
    _$SubBranchImpl value,
    $Res Function(_$SubBranchImpl) then,
  ) = __$$SubBranchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? type,
    @JsonKey(name: 'organization_id') String? organizationId,
    @JsonKey(name: 'company_id') String? companyId,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'parent_id') String? parentId,
  });
}

/// @nodoc
class __$$SubBranchImplCopyWithImpl<$Res>
    extends _$SubBranchCopyWithImpl<$Res, _$SubBranchImpl>
    implements _$$SubBranchImplCopyWith<$Res> {
  __$$SubBranchImplCopyWithImpl(
    _$SubBranchImpl _value,
    $Res Function(_$SubBranchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubBranch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = freezed,
    Object? organizationId = freezed,
    Object? companyId = freezed,
    Object? branchId = freezed,
    Object? parentId = freezed,
  }) {
    return _then(
      _$SubBranchImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        organizationId: freezed == organizationId
            ? _value.organizationId
            : organizationId // ignore: cast_nullable_to_non_nullable
                  as String?,
        companyId: freezed == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String?,
        branchId: freezed == branchId
            ? _value.branchId
            : branchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubBranchImpl implements _SubBranch {
  const _$SubBranchImpl({
    required this.id,
    required this.name,
    this.type,
    @JsonKey(name: 'organization_id') this.organizationId,
    @JsonKey(name: 'company_id') this.companyId,
    @JsonKey(name: 'branch_id') this.branchId,
    @JsonKey(name: 'parent_id') this.parentId,
  });

  factory _$SubBranchImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubBranchImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? type;
  @override
  @JsonKey(name: 'organization_id')
  final String? organizationId;
  @override
  @JsonKey(name: 'company_id')
  final String? companyId;
  @override
  @JsonKey(name: 'branch_id')
  final String? branchId;
  @override
  @JsonKey(name: 'parent_id')
  final String? parentId;

  @override
  String toString() {
    return 'SubBranch(id: $id, name: $name, type: $type, organizationId: $organizationId, companyId: $companyId, branchId: $branchId, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubBranchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    organizationId,
    companyId,
    branchId,
    parentId,
  );

  /// Create a copy of SubBranch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubBranchImplCopyWith<_$SubBranchImpl> get copyWith =>
      __$$SubBranchImplCopyWithImpl<_$SubBranchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubBranchImplToJson(this);
  }
}

abstract class _SubBranch implements SubBranch {
  const factory _SubBranch({
    required final String id,
    required final String name,
    final String? type,
    @JsonKey(name: 'organization_id') final String? organizationId,
    @JsonKey(name: 'company_id') final String? companyId,
    @JsonKey(name: 'branch_id') final String? branchId,
    @JsonKey(name: 'parent_id') final String? parentId,
  }) = _$SubBranchImpl;

  factory _SubBranch.fromJson(Map<String, dynamic> json) =
      _$SubBranchImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get type;
  @override
  @JsonKey(name: 'organization_id')
  String? get organizationId;
  @override
  @JsonKey(name: 'company_id')
  String? get companyId;
  @override
  @JsonKey(name: 'branch_id')
  String? get branchId;
  @override
  @JsonKey(name: 'parent_id')
  String? get parentId;

  /// Create a copy of SubBranch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubBranchImplCopyWith<_$SubBranchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubBranchList _$SubBranchListFromJson(Map<String, dynamic> json) {
  return _SubBranchList.fromJson(json);
}

/// @nodoc
mixin _$SubBranchList {
  String? get mode => throw _privateConstructorUsedError;
  @JsonKey(name: 'selected_sub_branch_id')
  String? get selectedSubBranchId => throw _privateConstructorUsedError;
  List<SubBranch> get data => throw _privateConstructorUsedError;

  /// Serializes this SubBranchList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubBranchList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubBranchListCopyWith<SubBranchList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubBranchListCopyWith<$Res> {
  factory $SubBranchListCopyWith(
    SubBranchList value,
    $Res Function(SubBranchList) then,
  ) = _$SubBranchListCopyWithImpl<$Res, SubBranchList>;
  @useResult
  $Res call({
    String? mode,
    @JsonKey(name: 'selected_sub_branch_id') String? selectedSubBranchId,
    List<SubBranch> data,
  });
}

/// @nodoc
class _$SubBranchListCopyWithImpl<$Res, $Val extends SubBranchList>
    implements $SubBranchListCopyWith<$Res> {
  _$SubBranchListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubBranchList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = freezed,
    Object? selectedSubBranchId = freezed,
    Object? data = null,
  }) {
    return _then(
      _value.copyWith(
            mode: freezed == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as String?,
            selectedSubBranchId: freezed == selectedSubBranchId
                ? _value.selectedSubBranchId
                : selectedSubBranchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<SubBranch>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubBranchListImplCopyWith<$Res>
    implements $SubBranchListCopyWith<$Res> {
  factory _$$SubBranchListImplCopyWith(
    _$SubBranchListImpl value,
    $Res Function(_$SubBranchListImpl) then,
  ) = __$$SubBranchListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? mode,
    @JsonKey(name: 'selected_sub_branch_id') String? selectedSubBranchId,
    List<SubBranch> data,
  });
}

/// @nodoc
class __$$SubBranchListImplCopyWithImpl<$Res>
    extends _$SubBranchListCopyWithImpl<$Res, _$SubBranchListImpl>
    implements _$$SubBranchListImplCopyWith<$Res> {
  __$$SubBranchListImplCopyWithImpl(
    _$SubBranchListImpl _value,
    $Res Function(_$SubBranchListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubBranchList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = freezed,
    Object? selectedSubBranchId = freezed,
    Object? data = null,
  }) {
    return _then(
      _$SubBranchListImpl(
        mode: freezed == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedSubBranchId: freezed == selectedSubBranchId
            ? _value.selectedSubBranchId
            : selectedSubBranchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<SubBranch>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubBranchListImpl extends _SubBranchList {
  const _$SubBranchListImpl({
    this.mode,
    @JsonKey(name: 'selected_sub_branch_id') this.selectedSubBranchId,
    required final List<SubBranch> data,
  }) : _data = data,
       super._();

  factory _$SubBranchListImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubBranchListImplFromJson(json);

  @override
  final String? mode;
  @override
  @JsonKey(name: 'selected_sub_branch_id')
  final String? selectedSubBranchId;
  final List<SubBranch> _data;
  @override
  List<SubBranch> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'SubBranchList(mode: $mode, selectedSubBranchId: $selectedSubBranchId, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubBranchListImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.selectedSubBranchId, selectedSubBranchId) ||
                other.selectedSubBranchId == selectedSubBranchId) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    mode,
    selectedSubBranchId,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of SubBranchList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubBranchListImplCopyWith<_$SubBranchListImpl> get copyWith =>
      __$$SubBranchListImplCopyWithImpl<_$SubBranchListImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubBranchListImplToJson(this);
  }
}

abstract class _SubBranchList extends SubBranchList {
  const factory _SubBranchList({
    final String? mode,
    @JsonKey(name: 'selected_sub_branch_id') final String? selectedSubBranchId,
    required final List<SubBranch> data,
  }) = _$SubBranchListImpl;
  const _SubBranchList._() : super._();

  factory _SubBranchList.fromJson(Map<String, dynamic> json) =
      _$SubBranchListImpl.fromJson;

  @override
  String? get mode;
  @override
  @JsonKey(name: 'selected_sub_branch_id')
  String? get selectedSubBranchId;
  @override
  List<SubBranch> get data;

  /// Create a copy of SubBranchList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubBranchListImplCopyWith<_$SubBranchListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
