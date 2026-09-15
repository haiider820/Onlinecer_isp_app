// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConnectionRequest _$ConnectionRequestFromJson(Map<String, dynamic> json) {
  return _ConnectionRequest.fromJson(json);
}

/// @nodoc
mixin _$ConnectionRequest {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'request_number')
  String get requestNumber => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String? get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_type')
  String? get customerType => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_phone')
  String? get customerPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_address')
  String? get customerAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_area')
  String? get customerArea => throw _privateConstructorUsedError;
  @JsonKey(name: 'requested_plan')
  Plan? get requestedPlan => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_team')
  Team? get currentTeam => throw _privateConstructorUsedError; // Detail-only blocks: the list endpoint omits them, the detail endpoint
  // populates them progressively across stages (null until the relevant
  // stage has run).
  @JsonKey(name: 'stage_data')
  StageData? get stageData => throw _privateConstructorUsedError;
  Locations? get locations => throw _privateConstructorUsedError;

  /// Serializes this ConnectionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionRequestCopyWith<ConnectionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionRequestCopyWith<$Res> {
  factory $ConnectionRequestCopyWith(
    ConnectionRequest value,
    $Res Function(ConnectionRequest) then,
  ) = _$ConnectionRequestCopyWithImpl<$Res, ConnectionRequest>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'request_number') String requestNumber,
    String status,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'customer_type') String? customerType,
    @JsonKey(name: 'customer_phone') String? customerPhone,
    @JsonKey(name: 'customer_address') String? customerAddress,
    @JsonKey(name: 'customer_area') String? customerArea,
    @JsonKey(name: 'requested_plan') Plan? requestedPlan,
    @JsonKey(name: 'current_team') Team? currentTeam,
    @JsonKey(name: 'stage_data') StageData? stageData,
    Locations? locations,
  });

  $PlanCopyWith<$Res>? get requestedPlan;
  $TeamCopyWith<$Res>? get currentTeam;
  $StageDataCopyWith<$Res>? get stageData;
  $LocationsCopyWith<$Res>? get locations;
}

/// @nodoc
class _$ConnectionRequestCopyWithImpl<$Res, $Val extends ConnectionRequest>
    implements $ConnectionRequestCopyWith<$Res> {
  _$ConnectionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requestNumber = null,
    Object? status = null,
    Object? customerName = freezed,
    Object? customerType = freezed,
    Object? customerPhone = freezed,
    Object? customerAddress = freezed,
    Object? customerArea = freezed,
    Object? requestedPlan = freezed,
    Object? currentTeam = freezed,
    Object? stageData = freezed,
    Object? locations = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            requestNumber: null == requestNumber
                ? _value.requestNumber
                : requestNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerType: freezed == customerType
                ? _value.customerType
                : customerType // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerPhone: freezed == customerPhone
                ? _value.customerPhone
                : customerPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerAddress: freezed == customerAddress
                ? _value.customerAddress
                : customerAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerArea: freezed == customerArea
                ? _value.customerArea
                : customerArea // ignore: cast_nullable_to_non_nullable
                      as String?,
            requestedPlan: freezed == requestedPlan
                ? _value.requestedPlan
                : requestedPlan // ignore: cast_nullable_to_non_nullable
                      as Plan?,
            currentTeam: freezed == currentTeam
                ? _value.currentTeam
                : currentTeam // ignore: cast_nullable_to_non_nullable
                      as Team?,
            stageData: freezed == stageData
                ? _value.stageData
                : stageData // ignore: cast_nullable_to_non_nullable
                      as StageData?,
            locations: freezed == locations
                ? _value.locations
                : locations // ignore: cast_nullable_to_non_nullable
                      as Locations?,
          )
          as $Val,
    );
  }

  /// Create a copy of ConnectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlanCopyWith<$Res>? get requestedPlan {
    if (_value.requestedPlan == null) {
      return null;
    }

    return $PlanCopyWith<$Res>(_value.requestedPlan!, (value) {
      return _then(_value.copyWith(requestedPlan: value) as $Val);
    });
  }

  /// Create a copy of ConnectionRequest
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

  /// Create a copy of ConnectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StageDataCopyWith<$Res>? get stageData {
    if (_value.stageData == null) {
      return null;
    }

    return $StageDataCopyWith<$Res>(_value.stageData!, (value) {
      return _then(_value.copyWith(stageData: value) as $Val);
    });
  }

  /// Create a copy of ConnectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationsCopyWith<$Res>? get locations {
    if (_value.locations == null) {
      return null;
    }

    return $LocationsCopyWith<$Res>(_value.locations!, (value) {
      return _then(_value.copyWith(locations: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConnectionRequestImplCopyWith<$Res>
    implements $ConnectionRequestCopyWith<$Res> {
  factory _$$ConnectionRequestImplCopyWith(
    _$ConnectionRequestImpl value,
    $Res Function(_$ConnectionRequestImpl) then,
  ) = __$$ConnectionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'request_number') String requestNumber,
    String status,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'customer_type') String? customerType,
    @JsonKey(name: 'customer_phone') String? customerPhone,
    @JsonKey(name: 'customer_address') String? customerAddress,
    @JsonKey(name: 'customer_area') String? customerArea,
    @JsonKey(name: 'requested_plan') Plan? requestedPlan,
    @JsonKey(name: 'current_team') Team? currentTeam,
    @JsonKey(name: 'stage_data') StageData? stageData,
    Locations? locations,
  });

  @override
  $PlanCopyWith<$Res>? get requestedPlan;
  @override
  $TeamCopyWith<$Res>? get currentTeam;
  @override
  $StageDataCopyWith<$Res>? get stageData;
  @override
  $LocationsCopyWith<$Res>? get locations;
}

/// @nodoc
class __$$ConnectionRequestImplCopyWithImpl<$Res>
    extends _$ConnectionRequestCopyWithImpl<$Res, _$ConnectionRequestImpl>
    implements _$$ConnectionRequestImplCopyWith<$Res> {
  __$$ConnectionRequestImplCopyWithImpl(
    _$ConnectionRequestImpl _value,
    $Res Function(_$ConnectionRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requestNumber = null,
    Object? status = null,
    Object? customerName = freezed,
    Object? customerType = freezed,
    Object? customerPhone = freezed,
    Object? customerAddress = freezed,
    Object? customerArea = freezed,
    Object? requestedPlan = freezed,
    Object? currentTeam = freezed,
    Object? stageData = freezed,
    Object? locations = freezed,
  }) {
    return _then(
      _$ConnectionRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        requestNumber: null == requestNumber
            ? _value.requestNumber
            : requestNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerType: freezed == customerType
            ? _value.customerType
            : customerType // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerPhone: freezed == customerPhone
            ? _value.customerPhone
            : customerPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerAddress: freezed == customerAddress
            ? _value.customerAddress
            : customerAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerArea: freezed == customerArea
            ? _value.customerArea
            : customerArea // ignore: cast_nullable_to_non_nullable
                  as String?,
        requestedPlan: freezed == requestedPlan
            ? _value.requestedPlan
            : requestedPlan // ignore: cast_nullable_to_non_nullable
                  as Plan?,
        currentTeam: freezed == currentTeam
            ? _value.currentTeam
            : currentTeam // ignore: cast_nullable_to_non_nullable
                  as Team?,
        stageData: freezed == stageData
            ? _value.stageData
            : stageData // ignore: cast_nullable_to_non_nullable
                  as StageData?,
        locations: freezed == locations
            ? _value.locations
            : locations // ignore: cast_nullable_to_non_nullable
                  as Locations?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionRequestImpl implements _ConnectionRequest {
  const _$ConnectionRequestImpl({
    required this.id,
    @JsonKey(name: 'request_number') required this.requestNumber,
    required this.status,
    @JsonKey(name: 'customer_name') this.customerName,
    @JsonKey(name: 'customer_type') this.customerType,
    @JsonKey(name: 'customer_phone') this.customerPhone,
    @JsonKey(name: 'customer_address') this.customerAddress,
    @JsonKey(name: 'customer_area') this.customerArea,
    @JsonKey(name: 'requested_plan') this.requestedPlan,
    @JsonKey(name: 'current_team') this.currentTeam,
    @JsonKey(name: 'stage_data') this.stageData,
    this.locations,
  });

  factory _$ConnectionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectionRequestImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'request_number')
  final String requestNumber;
  @override
  final String status;
  @override
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @override
  @JsonKey(name: 'customer_type')
  final String? customerType;
  @override
  @JsonKey(name: 'customer_phone')
  final String? customerPhone;
  @override
  @JsonKey(name: 'customer_address')
  final String? customerAddress;
  @override
  @JsonKey(name: 'customer_area')
  final String? customerArea;
  @override
  @JsonKey(name: 'requested_plan')
  final Plan? requestedPlan;
  @override
  @JsonKey(name: 'current_team')
  final Team? currentTeam;
  // Detail-only blocks: the list endpoint omits them, the detail endpoint
  // populates them progressively across stages (null until the relevant
  // stage has run).
  @override
  @JsonKey(name: 'stage_data')
  final StageData? stageData;
  @override
  final Locations? locations;

  @override
  String toString() {
    return 'ConnectionRequest(id: $id, requestNumber: $requestNumber, status: $status, customerName: $customerName, customerType: $customerType, customerPhone: $customerPhone, customerAddress: $customerAddress, customerArea: $customerArea, requestedPlan: $requestedPlan, currentTeam: $currentTeam, stageData: $stageData, locations: $locations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.requestNumber, requestNumber) ||
                other.requestNumber == requestNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerType, customerType) ||
                other.customerType == customerType) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.customerAddress, customerAddress) ||
                other.customerAddress == customerAddress) &&
            (identical(other.customerArea, customerArea) ||
                other.customerArea == customerArea) &&
            (identical(other.requestedPlan, requestedPlan) ||
                other.requestedPlan == requestedPlan) &&
            (identical(other.currentTeam, currentTeam) ||
                other.currentTeam == currentTeam) &&
            (identical(other.stageData, stageData) ||
                other.stageData == stageData) &&
            (identical(other.locations, locations) ||
                other.locations == locations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    requestNumber,
    status,
    customerName,
    customerType,
    customerPhone,
    customerAddress,
    customerArea,
    requestedPlan,
    currentTeam,
    stageData,
    locations,
  );

  /// Create a copy of ConnectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionRequestImplCopyWith<_$ConnectionRequestImpl> get copyWith =>
      __$$ConnectionRequestImplCopyWithImpl<_$ConnectionRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionRequestImplToJson(this);
  }
}

abstract class _ConnectionRequest implements ConnectionRequest {
  const factory _ConnectionRequest({
    required final String id,
    @JsonKey(name: 'request_number') required final String requestNumber,
    required final String status,
    @JsonKey(name: 'customer_name') final String? customerName,
    @JsonKey(name: 'customer_type') final String? customerType,
    @JsonKey(name: 'customer_phone') final String? customerPhone,
    @JsonKey(name: 'customer_address') final String? customerAddress,
    @JsonKey(name: 'customer_area') final String? customerArea,
    @JsonKey(name: 'requested_plan') final Plan? requestedPlan,
    @JsonKey(name: 'current_team') final Team? currentTeam,
    @JsonKey(name: 'stage_data') final StageData? stageData,
    final Locations? locations,
  }) = _$ConnectionRequestImpl;

  factory _ConnectionRequest.fromJson(Map<String, dynamic> json) =
      _$ConnectionRequestImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'request_number')
  String get requestNumber;
  @override
  String get status;
  @override
  @JsonKey(name: 'customer_name')
  String? get customerName;
  @override
  @JsonKey(name: 'customer_type')
  String? get customerType;
  @override
  @JsonKey(name: 'customer_phone')
  String? get customerPhone;
  @override
  @JsonKey(name: 'customer_address')
  String? get customerAddress;
  @override
  @JsonKey(name: 'customer_area')
  String? get customerArea;
  @override
  @JsonKey(name: 'requested_plan')
  Plan? get requestedPlan;
  @override
  @JsonKey(name: 'current_team')
  Team? get currentTeam; // Detail-only blocks: the list endpoint omits them, the detail endpoint
  // populates them progressively across stages (null until the relevant
  // stage has run).
  @override
  @JsonKey(name: 'stage_data')
  StageData? get stageData;
  @override
  Locations? get locations;

  /// Create a copy of ConnectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionRequestImplCopyWith<_$ConnectionRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConnectionRequestDetail _$ConnectionRequestDetailFromJson(
  Map<String, dynamic> json,
) {
  return _ConnectionRequestDetail.fromJson(json);
}

/// @nodoc
mixin _$ConnectionRequestDetail {
  @JsonKey(name: 'data')
  ConnectionRequest get request => throw _privateConstructorUsedError;
  @JsonKey(name: 'allowed_action')
  String? get allowedAction => throw _privateConstructorUsedError;

  /// Serializes this ConnectionRequestDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionRequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionRequestDetailCopyWith<ConnectionRequestDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionRequestDetailCopyWith<$Res> {
  factory $ConnectionRequestDetailCopyWith(
    ConnectionRequestDetail value,
    $Res Function(ConnectionRequestDetail) then,
  ) = _$ConnectionRequestDetailCopyWithImpl<$Res, ConnectionRequestDetail>;
  @useResult
  $Res call({
    @JsonKey(name: 'data') ConnectionRequest request,
    @JsonKey(name: 'allowed_action') String? allowedAction,
  });

  $ConnectionRequestCopyWith<$Res> get request;
}

/// @nodoc
class _$ConnectionRequestDetailCopyWithImpl<
  $Res,
  $Val extends ConnectionRequestDetail
>
    implements $ConnectionRequestDetailCopyWith<$Res> {
  _$ConnectionRequestDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionRequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? request = null, Object? allowedAction = freezed}) {
    return _then(
      _value.copyWith(
            request: null == request
                ? _value.request
                : request // ignore: cast_nullable_to_non_nullable
                      as ConnectionRequest,
            allowedAction: freezed == allowedAction
                ? _value.allowedAction
                : allowedAction // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ConnectionRequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConnectionRequestCopyWith<$Res> get request {
    return $ConnectionRequestCopyWith<$Res>(_value.request, (value) {
      return _then(_value.copyWith(request: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConnectionRequestDetailImplCopyWith<$Res>
    implements $ConnectionRequestDetailCopyWith<$Res> {
  factory _$$ConnectionRequestDetailImplCopyWith(
    _$ConnectionRequestDetailImpl value,
    $Res Function(_$ConnectionRequestDetailImpl) then,
  ) = __$$ConnectionRequestDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'data') ConnectionRequest request,
    @JsonKey(name: 'allowed_action') String? allowedAction,
  });

  @override
  $ConnectionRequestCopyWith<$Res> get request;
}

/// @nodoc
class __$$ConnectionRequestDetailImplCopyWithImpl<$Res>
    extends
        _$ConnectionRequestDetailCopyWithImpl<
          $Res,
          _$ConnectionRequestDetailImpl
        >
    implements _$$ConnectionRequestDetailImplCopyWith<$Res> {
  __$$ConnectionRequestDetailImplCopyWithImpl(
    _$ConnectionRequestDetailImpl _value,
    $Res Function(_$ConnectionRequestDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionRequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? request = null, Object? allowedAction = freezed}) {
    return _then(
      _$ConnectionRequestDetailImpl(
        request: null == request
            ? _value.request
            : request // ignore: cast_nullable_to_non_nullable
                  as ConnectionRequest,
        allowedAction: freezed == allowedAction
            ? _value.allowedAction
            : allowedAction // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionRequestDetailImpl extends _ConnectionRequestDetail {
  const _$ConnectionRequestDetailImpl({
    @JsonKey(name: 'data') required this.request,
    @JsonKey(name: 'allowed_action') this.allowedAction,
  }) : super._();

  factory _$ConnectionRequestDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectionRequestDetailImplFromJson(json);

  @override
  @JsonKey(name: 'data')
  final ConnectionRequest request;
  @override
  @JsonKey(name: 'allowed_action')
  final String? allowedAction;

  @override
  String toString() {
    return 'ConnectionRequestDetail(request: $request, allowedAction: $allowedAction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionRequestDetailImpl &&
            (identical(other.request, request) || other.request == request) &&
            (identical(other.allowedAction, allowedAction) ||
                other.allowedAction == allowedAction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, request, allowedAction);

  /// Create a copy of ConnectionRequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionRequestDetailImplCopyWith<_$ConnectionRequestDetailImpl>
  get copyWith =>
      __$$ConnectionRequestDetailImplCopyWithImpl<
        _$ConnectionRequestDetailImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionRequestDetailImplToJson(this);
  }
}

abstract class _ConnectionRequestDetail extends ConnectionRequestDetail {
  const factory _ConnectionRequestDetail({
    @JsonKey(name: 'data') required final ConnectionRequest request,
    @JsonKey(name: 'allowed_action') final String? allowedAction,
  }) = _$ConnectionRequestDetailImpl;
  const _ConnectionRequestDetail._() : super._();

  factory _ConnectionRequestDetail.fromJson(Map<String, dynamic> json) =
      _$ConnectionRequestDetailImpl.fromJson;

  @override
  @JsonKey(name: 'data')
  ConnectionRequest get request;
  @override
  @JsonKey(name: 'allowed_action')
  String? get allowedAction;

  /// Create a copy of ConnectionRequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionRequestDetailImplCopyWith<_$ConnectionRequestDetailImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ConnectionRequestPage _$ConnectionRequestPageFromJson(
  Map<String, dynamic> json,
) {
  return _ConnectionRequestPage.fromJson(json);
}

/// @nodoc
mixin _$ConnectionRequestPage {
  List<ConnectionRequest> get data => throw _privateConstructorUsedError;
  @JsonKey(name: 'meta')
  PaginationMeta get meta => throw _privateConstructorUsedError;

  /// Serializes this ConnectionRequestPage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionRequestPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionRequestPageCopyWith<ConnectionRequestPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionRequestPageCopyWith<$Res> {
  factory $ConnectionRequestPageCopyWith(
    ConnectionRequestPage value,
    $Res Function(ConnectionRequestPage) then,
  ) = _$ConnectionRequestPageCopyWithImpl<$Res, ConnectionRequestPage>;
  @useResult
  $Res call({
    List<ConnectionRequest> data,
    @JsonKey(name: 'meta') PaginationMeta meta,
  });

  $PaginationMetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$ConnectionRequestPageCopyWithImpl<
  $Res,
  $Val extends ConnectionRequestPage
>
    implements $ConnectionRequestPageCopyWith<$Res> {
  _$ConnectionRequestPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionRequestPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? meta = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<ConnectionRequest>,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as PaginationMeta,
          )
          as $Val,
    );
  }

  /// Create a copy of ConnectionRequestPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginationMetaCopyWith<$Res> get meta {
    return $PaginationMetaCopyWith<$Res>(_value.meta, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConnectionRequestPageImplCopyWith<$Res>
    implements $ConnectionRequestPageCopyWith<$Res> {
  factory _$$ConnectionRequestPageImplCopyWith(
    _$ConnectionRequestPageImpl value,
    $Res Function(_$ConnectionRequestPageImpl) then,
  ) = __$$ConnectionRequestPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ConnectionRequest> data,
    @JsonKey(name: 'meta') PaginationMeta meta,
  });

  @override
  $PaginationMetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$$ConnectionRequestPageImplCopyWithImpl<$Res>
    extends
        _$ConnectionRequestPageCopyWithImpl<$Res, _$ConnectionRequestPageImpl>
    implements _$$ConnectionRequestPageImplCopyWith<$Res> {
  __$$ConnectionRequestPageImplCopyWithImpl(
    _$ConnectionRequestPageImpl _value,
    $Res Function(_$ConnectionRequestPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionRequestPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? meta = null}) {
    return _then(
      _$ConnectionRequestPageImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<ConnectionRequest>,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as PaginationMeta,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionRequestPageImpl implements _ConnectionRequestPage {
  const _$ConnectionRequestPageImpl({
    required final List<ConnectionRequest> data,
    @JsonKey(name: 'meta') required this.meta,
  }) : _data = data;

  factory _$ConnectionRequestPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectionRequestPageImplFromJson(json);

  final List<ConnectionRequest> _data;
  @override
  List<ConnectionRequest> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  @JsonKey(name: 'meta')
  final PaginationMeta meta;

  @override
  String toString() {
    return 'ConnectionRequestPage(data: $data, meta: $meta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionRequestPageImpl &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.meta, meta) || other.meta == meta));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_data),
    meta,
  );

  /// Create a copy of ConnectionRequestPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionRequestPageImplCopyWith<_$ConnectionRequestPageImpl>
  get copyWith =>
      __$$ConnectionRequestPageImplCopyWithImpl<_$ConnectionRequestPageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionRequestPageImplToJson(this);
  }
}

abstract class _ConnectionRequestPage implements ConnectionRequestPage {
  const factory _ConnectionRequestPage({
    required final List<ConnectionRequest> data,
    @JsonKey(name: 'meta') required final PaginationMeta meta,
  }) = _$ConnectionRequestPageImpl;

  factory _ConnectionRequestPage.fromJson(Map<String, dynamic> json) =
      _$ConnectionRequestPageImpl.fromJson;

  @override
  List<ConnectionRequest> get data;
  @override
  @JsonKey(name: 'meta')
  PaginationMeta get meta;

  /// Create a copy of ConnectionRequestPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionRequestPageImplCopyWith<_$ConnectionRequestPageImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) {
  return _PaginationMeta.fromJson(json);
}

/// @nodoc
mixin _$PaginationMeta {
  @JsonKey(name: 'current_page')
  int? get currentPage => throw _privateConstructorUsedError;
  @JsonKey(name: 'per_page')
  int? get perPage => throw _privateConstructorUsedError;
  int? get total => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_page')
  int? get lastPage => throw _privateConstructorUsedError;

  /// Serializes this PaginationMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaginationMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginationMetaCopyWith<PaginationMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginationMetaCopyWith<$Res> {
  factory $PaginationMetaCopyWith(
    PaginationMeta value,
    $Res Function(PaginationMeta) then,
  ) = _$PaginationMetaCopyWithImpl<$Res, PaginationMeta>;
  @useResult
  $Res call({
    @JsonKey(name: 'current_page') int? currentPage,
    @JsonKey(name: 'per_page') int? perPage,
    int? total,
    @JsonKey(name: 'last_page') int? lastPage,
  });
}

/// @nodoc
class _$PaginationMetaCopyWithImpl<$Res, $Val extends PaginationMeta>
    implements $PaginationMetaCopyWith<$Res> {
  _$PaginationMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginationMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = freezed,
    Object? perPage = freezed,
    Object? total = freezed,
    Object? lastPage = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentPage: freezed == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int?,
            perPage: freezed == perPage
                ? _value.perPage
                : perPage // ignore: cast_nullable_to_non_nullable
                      as int?,
            total: freezed == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int?,
            lastPage: freezed == lastPage
                ? _value.lastPage
                : lastPage // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaginationMetaImplCopyWith<$Res>
    implements $PaginationMetaCopyWith<$Res> {
  factory _$$PaginationMetaImplCopyWith(
    _$PaginationMetaImpl value,
    $Res Function(_$PaginationMetaImpl) then,
  ) = __$$PaginationMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'current_page') int? currentPage,
    @JsonKey(name: 'per_page') int? perPage,
    int? total,
    @JsonKey(name: 'last_page') int? lastPage,
  });
}

/// @nodoc
class __$$PaginationMetaImplCopyWithImpl<$Res>
    extends _$PaginationMetaCopyWithImpl<$Res, _$PaginationMetaImpl>
    implements _$$PaginationMetaImplCopyWith<$Res> {
  __$$PaginationMetaImplCopyWithImpl(
    _$PaginationMetaImpl _value,
    $Res Function(_$PaginationMetaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaginationMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = freezed,
    Object? perPage = freezed,
    Object? total = freezed,
    Object? lastPage = freezed,
  }) {
    return _then(
      _$PaginationMetaImpl(
        currentPage: freezed == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int?,
        perPage: freezed == perPage
            ? _value.perPage
            : perPage // ignore: cast_nullable_to_non_nullable
                  as int?,
        total: freezed == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int?,
        lastPage: freezed == lastPage
            ? _value.lastPage
            : lastPage // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaginationMetaImpl implements _PaginationMeta {
  const _$PaginationMetaImpl({
    @JsonKey(name: 'current_page') this.currentPage,
    @JsonKey(name: 'per_page') this.perPage,
    this.total,
    @JsonKey(name: 'last_page') this.lastPage,
  });

  factory _$PaginationMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginationMetaImplFromJson(json);

  @override
  @JsonKey(name: 'current_page')
  final int? currentPage;
  @override
  @JsonKey(name: 'per_page')
  final int? perPage;
  @override
  final int? total;
  @override
  @JsonKey(name: 'last_page')
  final int? lastPage;

  @override
  String toString() {
    return 'PaginationMeta(currentPage: $currentPage, perPage: $perPage, total: $total, lastPage: $lastPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginationMetaImpl &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.perPage, perPage) || other.perPage == perPage) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.lastPage, lastPage) ||
                other.lastPage == lastPage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, currentPage, perPage, total, lastPage);

  /// Create a copy of PaginationMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginationMetaImplCopyWith<_$PaginationMetaImpl> get copyWith =>
      __$$PaginationMetaImplCopyWithImpl<_$PaginationMetaImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaginationMetaImplToJson(this);
  }
}

abstract class _PaginationMeta implements PaginationMeta {
  const factory _PaginationMeta({
    @JsonKey(name: 'current_page') final int? currentPage,
    @JsonKey(name: 'per_page') final int? perPage,
    final int? total,
    @JsonKey(name: 'last_page') final int? lastPage,
  }) = _$PaginationMetaImpl;

  factory _PaginationMeta.fromJson(Map<String, dynamic> json) =
      _$PaginationMetaImpl.fromJson;

  @override
  @JsonKey(name: 'current_page')
  int? get currentPage;
  @override
  @JsonKey(name: 'per_page')
  int? get perPage;
  @override
  int? get total;
  @override
  @JsonKey(name: 'last_page')
  int? get lastPage;

  /// Create a copy of PaginationMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginationMetaImplCopyWith<_$PaginationMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
