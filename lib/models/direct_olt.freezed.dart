// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'direct_olt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuthorizationPreset _$AuthorizationPresetFromJson(Map<String, dynamic> json) {
  return _AuthorizationPreset.fromJson(json);
}

/// @nodoc
mixin _$AuthorizationPreset {
  bool? get ready => throw _privateConstructorUsedError;
  @JsonKey(name: 'line_profile')
  String? get lineProfile => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_profile')
  String? get serviceProfile => throw _privateConstructorUsedError;
  int? get vlan => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_vlan')
  int? get userVlan => throw _privateConstructorUsedError;
  int? get gemport => throw _privateConstructorUsedError;

  /// Serializes this AuthorizationPreset to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthorizationPreset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthorizationPresetCopyWith<AuthorizationPreset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthorizationPresetCopyWith<$Res> {
  factory $AuthorizationPresetCopyWith(
    AuthorizationPreset value,
    $Res Function(AuthorizationPreset) then,
  ) = _$AuthorizationPresetCopyWithImpl<$Res, AuthorizationPreset>;
  @useResult
  $Res call({
    bool? ready,
    @JsonKey(name: 'line_profile') String? lineProfile,
    @JsonKey(name: 'service_profile') String? serviceProfile,
    int? vlan,
    @JsonKey(name: 'user_vlan') int? userVlan,
    int? gemport,
  });
}

/// @nodoc
class _$AuthorizationPresetCopyWithImpl<$Res, $Val extends AuthorizationPreset>
    implements $AuthorizationPresetCopyWith<$Res> {
  _$AuthorizationPresetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthorizationPreset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ready = freezed,
    Object? lineProfile = freezed,
    Object? serviceProfile = freezed,
    Object? vlan = freezed,
    Object? userVlan = freezed,
    Object? gemport = freezed,
  }) {
    return _then(
      _value.copyWith(
            ready: freezed == ready
                ? _value.ready
                : ready // ignore: cast_nullable_to_non_nullable
                      as bool?,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthorizationPresetImplCopyWith<$Res>
    implements $AuthorizationPresetCopyWith<$Res> {
  factory _$$AuthorizationPresetImplCopyWith(
    _$AuthorizationPresetImpl value,
    $Res Function(_$AuthorizationPresetImpl) then,
  ) = __$$AuthorizationPresetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool? ready,
    @JsonKey(name: 'line_profile') String? lineProfile,
    @JsonKey(name: 'service_profile') String? serviceProfile,
    int? vlan,
    @JsonKey(name: 'user_vlan') int? userVlan,
    int? gemport,
  });
}

/// @nodoc
class __$$AuthorizationPresetImplCopyWithImpl<$Res>
    extends _$AuthorizationPresetCopyWithImpl<$Res, _$AuthorizationPresetImpl>
    implements _$$AuthorizationPresetImplCopyWith<$Res> {
  __$$AuthorizationPresetImplCopyWithImpl(
    _$AuthorizationPresetImpl _value,
    $Res Function(_$AuthorizationPresetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthorizationPreset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ready = freezed,
    Object? lineProfile = freezed,
    Object? serviceProfile = freezed,
    Object? vlan = freezed,
    Object? userVlan = freezed,
    Object? gemport = freezed,
  }) {
    return _then(
      _$AuthorizationPresetImpl(
        ready: freezed == ready
            ? _value.ready
            : ready // ignore: cast_nullable_to_non_nullable
                  as bool?,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthorizationPresetImpl implements _AuthorizationPreset {
  const _$AuthorizationPresetImpl({
    this.ready,
    @JsonKey(name: 'line_profile') this.lineProfile,
    @JsonKey(name: 'service_profile') this.serviceProfile,
    this.vlan,
    @JsonKey(name: 'user_vlan') this.userVlan,
    this.gemport,
  });

  factory _$AuthorizationPresetImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthorizationPresetImplFromJson(json);

  @override
  final bool? ready;
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
  String toString() {
    return 'AuthorizationPreset(ready: $ready, lineProfile: $lineProfile, serviceProfile: $serviceProfile, vlan: $vlan, userVlan: $userVlan, gemport: $gemport)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthorizationPresetImpl &&
            (identical(other.ready, ready) || other.ready == ready) &&
            (identical(other.lineProfile, lineProfile) ||
                other.lineProfile == lineProfile) &&
            (identical(other.serviceProfile, serviceProfile) ||
                other.serviceProfile == serviceProfile) &&
            (identical(other.vlan, vlan) || other.vlan == vlan) &&
            (identical(other.userVlan, userVlan) ||
                other.userVlan == userVlan) &&
            (identical(other.gemport, gemport) || other.gemport == gemport));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    ready,
    lineProfile,
    serviceProfile,
    vlan,
    userVlan,
    gemport,
  );

  /// Create a copy of AuthorizationPreset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthorizationPresetImplCopyWith<_$AuthorizationPresetImpl> get copyWith =>
      __$$AuthorizationPresetImplCopyWithImpl<_$AuthorizationPresetImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthorizationPresetImplToJson(this);
  }
}

abstract class _AuthorizationPreset implements AuthorizationPreset {
  const factory _AuthorizationPreset({
    final bool? ready,
    @JsonKey(name: 'line_profile') final String? lineProfile,
    @JsonKey(name: 'service_profile') final String? serviceProfile,
    final int? vlan,
    @JsonKey(name: 'user_vlan') final int? userVlan,
    final int? gemport,
  }) = _$AuthorizationPresetImpl;

  factory _AuthorizationPreset.fromJson(Map<String, dynamic> json) =
      _$AuthorizationPresetImpl.fromJson;

  @override
  bool? get ready;
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

  /// Create a copy of AuthorizationPreset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthorizationPresetImplCopyWith<_$AuthorizationPresetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DirectOlt _$DirectOltFromJson(Map<String, dynamic> json) {
  return _DirectOlt.fromJson(json);
}

/// @nodoc
mixin _$DirectOlt {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get vendor => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  @JsonKey(name: 'management_ip')
  String? get managementIp => throw _privateConstructorUsedError;
  @JsonKey(name: 'connection_status')
  String? get connectionStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'company_id')
  String? get companyId => throw _privateConstructorUsedError;
  @JsonKey(name: 'branch_id')
  String? get branchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sub_branch_id')
  String? get subBranchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'authorization_preset')
  AuthorizationPreset? get authorizationPreset =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'running_authorizations_count')
  int? get runningAuthorizationsCount => throw _privateConstructorUsedError;

  /// Serializes this DirectOlt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DirectOlt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DirectOltCopyWith<DirectOlt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DirectOltCopyWith<$Res> {
  factory $DirectOltCopyWith(DirectOlt value, $Res Function(DirectOlt) then) =
      _$DirectOltCopyWithImpl<$Res, DirectOlt>;
  @useResult
  $Res call({
    String id,
    String? name,
    String? vendor,
    String? model,
    @JsonKey(name: 'management_ip') String? managementIp,
    @JsonKey(name: 'connection_status') String? connectionStatus,
    @JsonKey(name: 'company_id') String? companyId,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'sub_branch_id') String? subBranchId,
    @JsonKey(name: 'authorization_preset')
    AuthorizationPreset? authorizationPreset,
    @JsonKey(name: 'running_authorizations_count')
    int? runningAuthorizationsCount,
  });

  $AuthorizationPresetCopyWith<$Res>? get authorizationPreset;
}

/// @nodoc
class _$DirectOltCopyWithImpl<$Res, $Val extends DirectOlt>
    implements $DirectOltCopyWith<$Res> {
  _$DirectOltCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DirectOlt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? vendor = freezed,
    Object? model = freezed,
    Object? managementIp = freezed,
    Object? connectionStatus = freezed,
    Object? companyId = freezed,
    Object? branchId = freezed,
    Object? subBranchId = freezed,
    Object? authorizationPreset = freezed,
    Object? runningAuthorizationsCount = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            vendor: freezed == vendor
                ? _value.vendor
                : vendor // ignore: cast_nullable_to_non_nullable
                      as String?,
            model: freezed == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String?,
            managementIp: freezed == managementIp
                ? _value.managementIp
                : managementIp // ignore: cast_nullable_to_non_nullable
                      as String?,
            connectionStatus: freezed == connectionStatus
                ? _value.connectionStatus
                : connectionStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            companyId: freezed == companyId
                ? _value.companyId
                : companyId // ignore: cast_nullable_to_non_nullable
                      as String?,
            branchId: freezed == branchId
                ? _value.branchId
                : branchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            subBranchId: freezed == subBranchId
                ? _value.subBranchId
                : subBranchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorizationPreset: freezed == authorizationPreset
                ? _value.authorizationPreset
                : authorizationPreset // ignore: cast_nullable_to_non_nullable
                      as AuthorizationPreset?,
            runningAuthorizationsCount: freezed == runningAuthorizationsCount
                ? _value.runningAuthorizationsCount
                : runningAuthorizationsCount // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of DirectOlt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthorizationPresetCopyWith<$Res>? get authorizationPreset {
    if (_value.authorizationPreset == null) {
      return null;
    }

    return $AuthorizationPresetCopyWith<$Res>(_value.authorizationPreset!, (
      value,
    ) {
      return _then(_value.copyWith(authorizationPreset: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DirectOltImplCopyWith<$Res>
    implements $DirectOltCopyWith<$Res> {
  factory _$$DirectOltImplCopyWith(
    _$DirectOltImpl value,
    $Res Function(_$DirectOltImpl) then,
  ) = __$$DirectOltImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? name,
    String? vendor,
    String? model,
    @JsonKey(name: 'management_ip') String? managementIp,
    @JsonKey(name: 'connection_status') String? connectionStatus,
    @JsonKey(name: 'company_id') String? companyId,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'sub_branch_id') String? subBranchId,
    @JsonKey(name: 'authorization_preset')
    AuthorizationPreset? authorizationPreset,
    @JsonKey(name: 'running_authorizations_count')
    int? runningAuthorizationsCount,
  });

  @override
  $AuthorizationPresetCopyWith<$Res>? get authorizationPreset;
}

/// @nodoc
class __$$DirectOltImplCopyWithImpl<$Res>
    extends _$DirectOltCopyWithImpl<$Res, _$DirectOltImpl>
    implements _$$DirectOltImplCopyWith<$Res> {
  __$$DirectOltImplCopyWithImpl(
    _$DirectOltImpl _value,
    $Res Function(_$DirectOltImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DirectOlt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? vendor = freezed,
    Object? model = freezed,
    Object? managementIp = freezed,
    Object? connectionStatus = freezed,
    Object? companyId = freezed,
    Object? branchId = freezed,
    Object? subBranchId = freezed,
    Object? authorizationPreset = freezed,
    Object? runningAuthorizationsCount = freezed,
  }) {
    return _then(
      _$DirectOltImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        vendor: freezed == vendor
            ? _value.vendor
            : vendor // ignore: cast_nullable_to_non_nullable
                  as String?,
        model: freezed == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String?,
        managementIp: freezed == managementIp
            ? _value.managementIp
            : managementIp // ignore: cast_nullable_to_non_nullable
                  as String?,
        connectionStatus: freezed == connectionStatus
            ? _value.connectionStatus
            : connectionStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        companyId: freezed == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String?,
        branchId: freezed == branchId
            ? _value.branchId
            : branchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        subBranchId: freezed == subBranchId
            ? _value.subBranchId
            : subBranchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorizationPreset: freezed == authorizationPreset
            ? _value.authorizationPreset
            : authorizationPreset // ignore: cast_nullable_to_non_nullable
                  as AuthorizationPreset?,
        runningAuthorizationsCount: freezed == runningAuthorizationsCount
            ? _value.runningAuthorizationsCount
            : runningAuthorizationsCount // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DirectOltImpl implements _DirectOlt {
  const _$DirectOltImpl({
    required this.id,
    this.name,
    this.vendor,
    this.model,
    @JsonKey(name: 'management_ip') this.managementIp,
    @JsonKey(name: 'connection_status') this.connectionStatus,
    @JsonKey(name: 'company_id') this.companyId,
    @JsonKey(name: 'branch_id') this.branchId,
    @JsonKey(name: 'sub_branch_id') this.subBranchId,
    @JsonKey(name: 'authorization_preset') this.authorizationPreset,
    @JsonKey(name: 'running_authorizations_count')
    this.runningAuthorizationsCount,
  });

  factory _$DirectOltImpl.fromJson(Map<String, dynamic> json) =>
      _$$DirectOltImplFromJson(json);

  @override
  final String id;
  @override
  final String? name;
  @override
  final String? vendor;
  @override
  final String? model;
  @override
  @JsonKey(name: 'management_ip')
  final String? managementIp;
  @override
  @JsonKey(name: 'connection_status')
  final String? connectionStatus;
  @override
  @JsonKey(name: 'company_id')
  final String? companyId;
  @override
  @JsonKey(name: 'branch_id')
  final String? branchId;
  @override
  @JsonKey(name: 'sub_branch_id')
  final String? subBranchId;
  @override
  @JsonKey(name: 'authorization_preset')
  final AuthorizationPreset? authorizationPreset;
  @override
  @JsonKey(name: 'running_authorizations_count')
  final int? runningAuthorizationsCount;

  @override
  String toString() {
    return 'DirectOlt(id: $id, name: $name, vendor: $vendor, model: $model, managementIp: $managementIp, connectionStatus: $connectionStatus, companyId: $companyId, branchId: $branchId, subBranchId: $subBranchId, authorizationPreset: $authorizationPreset, runningAuthorizationsCount: $runningAuthorizationsCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DirectOltImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.managementIp, managementIp) ||
                other.managementIp == managementIp) &&
            (identical(other.connectionStatus, connectionStatus) ||
                other.connectionStatus == connectionStatus) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.subBranchId, subBranchId) ||
                other.subBranchId == subBranchId) &&
            (identical(other.authorizationPreset, authorizationPreset) ||
                other.authorizationPreset == authorizationPreset) &&
            (identical(
                  other.runningAuthorizationsCount,
                  runningAuthorizationsCount,
                ) ||
                other.runningAuthorizationsCount ==
                    runningAuthorizationsCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    vendor,
    model,
    managementIp,
    connectionStatus,
    companyId,
    branchId,
    subBranchId,
    authorizationPreset,
    runningAuthorizationsCount,
  );

  /// Create a copy of DirectOlt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DirectOltImplCopyWith<_$DirectOltImpl> get copyWith =>
      __$$DirectOltImplCopyWithImpl<_$DirectOltImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DirectOltImplToJson(this);
  }
}

abstract class _DirectOlt implements DirectOlt {
  const factory _DirectOlt({
    required final String id,
    final String? name,
    final String? vendor,
    final String? model,
    @JsonKey(name: 'management_ip') final String? managementIp,
    @JsonKey(name: 'connection_status') final String? connectionStatus,
    @JsonKey(name: 'company_id') final String? companyId,
    @JsonKey(name: 'branch_id') final String? branchId,
    @JsonKey(name: 'sub_branch_id') final String? subBranchId,
    @JsonKey(name: 'authorization_preset')
    final AuthorizationPreset? authorizationPreset,
    @JsonKey(name: 'running_authorizations_count')
    final int? runningAuthorizationsCount,
  }) = _$DirectOltImpl;

  factory _DirectOlt.fromJson(Map<String, dynamic> json) =
      _$DirectOltImpl.fromJson;

  @override
  String get id;
  @override
  String? get name;
  @override
  String? get vendor;
  @override
  String? get model;
  @override
  @JsonKey(name: 'management_ip')
  String? get managementIp;
  @override
  @JsonKey(name: 'connection_status')
  String? get connectionStatus;
  @override
  @JsonKey(name: 'company_id')
  String? get companyId;
  @override
  @JsonKey(name: 'branch_id')
  String? get branchId;
  @override
  @JsonKey(name: 'sub_branch_id')
  String? get subBranchId;
  @override
  @JsonKey(name: 'authorization_preset')
  AuthorizationPreset? get authorizationPreset;
  @override
  @JsonKey(name: 'running_authorizations_count')
  int? get runningAuthorizationsCount;

  /// Create a copy of DirectOlt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DirectOltImplCopyWith<_$DirectOltImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DirectOltList _$DirectOltListFromJson(Map<String, dynamic> json) {
  return _DirectOltList.fromJson(json);
}

/// @nodoc
mixin _$DirectOltList {
  List<DirectOlt> get data => throw _privateConstructorUsedError;

  /// Serializes this DirectOltList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DirectOltList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DirectOltListCopyWith<DirectOltList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DirectOltListCopyWith<$Res> {
  factory $DirectOltListCopyWith(
    DirectOltList value,
    $Res Function(DirectOltList) then,
  ) = _$DirectOltListCopyWithImpl<$Res, DirectOltList>;
  @useResult
  $Res call({List<DirectOlt> data});
}

/// @nodoc
class _$DirectOltListCopyWithImpl<$Res, $Val extends DirectOltList>
    implements $DirectOltListCopyWith<$Res> {
  _$DirectOltListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DirectOltList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<DirectOlt>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DirectOltListImplCopyWith<$Res>
    implements $DirectOltListCopyWith<$Res> {
  factory _$$DirectOltListImplCopyWith(
    _$DirectOltListImpl value,
    $Res Function(_$DirectOltListImpl) then,
  ) = __$$DirectOltListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<DirectOlt> data});
}

/// @nodoc
class __$$DirectOltListImplCopyWithImpl<$Res>
    extends _$DirectOltListCopyWithImpl<$Res, _$DirectOltListImpl>
    implements _$$DirectOltListImplCopyWith<$Res> {
  __$$DirectOltListImplCopyWithImpl(
    _$DirectOltListImpl _value,
    $Res Function(_$DirectOltListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DirectOltList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$DirectOltListImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<DirectOlt>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DirectOltListImpl implements _DirectOltList {
  const _$DirectOltListImpl({required final List<DirectOlt> data})
    : _data = data;

  factory _$DirectOltListImpl.fromJson(Map<String, dynamic> json) =>
      _$$DirectOltListImplFromJson(json);

  final List<DirectOlt> _data;
  @override
  List<DirectOlt> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'DirectOltList(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DirectOltListImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  /// Create a copy of DirectOltList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DirectOltListImplCopyWith<_$DirectOltListImpl> get copyWith =>
      __$$DirectOltListImplCopyWithImpl<_$DirectOltListImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DirectOltListImplToJson(this);
  }
}

abstract class _DirectOltList implements DirectOltList {
  const factory _DirectOltList({required final List<DirectOlt> data}) =
      _$DirectOltListImpl;

  factory _DirectOltList.fromJson(Map<String, dynamic> json) =
      _$DirectOltListImpl.fromJson;

  @override
  List<DirectOlt> get data;

  /// Create a copy of DirectOltList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DirectOltListImplCopyWith<_$DirectOltListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
