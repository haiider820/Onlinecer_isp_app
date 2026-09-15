// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DashboardSummary _$DashboardSummaryFromJson(Map<String, dynamic> json) {
  return _DashboardSummary.fromJson(json);
}

/// @nodoc
mixin _$DashboardSummary {
  Employee? get employee => throw _privateConstructorUsedError;
  DashboardStats? get stats => throw _privateConstructorUsedError;
  @JsonKey(name: 'recent_connection_requests')
  List<ConnectionRequest>? get recentConnectionRequests =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'recent_tickets')
  List<Object?>? get recentTickets => throw _privateConstructorUsedError;

  /// Serializes this DashboardSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardSummaryCopyWith<DashboardSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardSummaryCopyWith<$Res> {
  factory $DashboardSummaryCopyWith(
    DashboardSummary value,
    $Res Function(DashboardSummary) then,
  ) = _$DashboardSummaryCopyWithImpl<$Res, DashboardSummary>;
  @useResult
  $Res call({
    Employee? employee,
    DashboardStats? stats,
    @JsonKey(name: 'recent_connection_requests')
    List<ConnectionRequest>? recentConnectionRequests,
    @JsonKey(name: 'recent_tickets') List<Object?>? recentTickets,
  });

  $EmployeeCopyWith<$Res>? get employee;
  $DashboardStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res, $Val extends DashboardSummary>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? employee = freezed,
    Object? stats = freezed,
    Object? recentConnectionRequests = freezed,
    Object? recentTickets = freezed,
  }) {
    return _then(
      _value.copyWith(
            employee: freezed == employee
                ? _value.employee
                : employee // ignore: cast_nullable_to_non_nullable
                      as Employee?,
            stats: freezed == stats
                ? _value.stats
                : stats // ignore: cast_nullable_to_non_nullable
                      as DashboardStats?,
            recentConnectionRequests: freezed == recentConnectionRequests
                ? _value.recentConnectionRequests
                : recentConnectionRequests // ignore: cast_nullable_to_non_nullable
                      as List<ConnectionRequest>?,
            recentTickets: freezed == recentTickets
                ? _value.recentTickets
                : recentTickets // ignore: cast_nullable_to_non_nullable
                      as List<Object?>?,
          )
          as $Val,
    );
  }

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EmployeeCopyWith<$Res>? get employee {
    if (_value.employee == null) {
      return null;
    }

    return $EmployeeCopyWith<$Res>(_value.employee!, (value) {
      return _then(_value.copyWith(employee: value) as $Val);
    });
  }

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardStatsCopyWith<$Res>? get stats {
    if (_value.stats == null) {
      return null;
    }

    return $DashboardStatsCopyWith<$Res>(_value.stats!, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardSummaryImplCopyWith<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  factory _$$DashboardSummaryImplCopyWith(
    _$DashboardSummaryImpl value,
    $Res Function(_$DashboardSummaryImpl) then,
  ) = __$$DashboardSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Employee? employee,
    DashboardStats? stats,
    @JsonKey(name: 'recent_connection_requests')
    List<ConnectionRequest>? recentConnectionRequests,
    @JsonKey(name: 'recent_tickets') List<Object?>? recentTickets,
  });

  @override
  $EmployeeCopyWith<$Res>? get employee;
  @override
  $DashboardStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class __$$DashboardSummaryImplCopyWithImpl<$Res>
    extends _$DashboardSummaryCopyWithImpl<$Res, _$DashboardSummaryImpl>
    implements _$$DashboardSummaryImplCopyWith<$Res> {
  __$$DashboardSummaryImplCopyWithImpl(
    _$DashboardSummaryImpl _value,
    $Res Function(_$DashboardSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? employee = freezed,
    Object? stats = freezed,
    Object? recentConnectionRequests = freezed,
    Object? recentTickets = freezed,
  }) {
    return _then(
      _$DashboardSummaryImpl(
        employee: freezed == employee
            ? _value.employee
            : employee // ignore: cast_nullable_to_non_nullable
                  as Employee?,
        stats: freezed == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as DashboardStats?,
        recentConnectionRequests: freezed == recentConnectionRequests
            ? _value._recentConnectionRequests
            : recentConnectionRequests // ignore: cast_nullable_to_non_nullable
                  as List<ConnectionRequest>?,
        recentTickets: freezed == recentTickets
            ? _value._recentTickets
            : recentTickets // ignore: cast_nullable_to_non_nullable
                  as List<Object?>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardSummaryImpl implements _DashboardSummary {
  const _$DashboardSummaryImpl({
    this.employee,
    this.stats,
    @JsonKey(name: 'recent_connection_requests')
    final List<ConnectionRequest>? recentConnectionRequests,
    @JsonKey(name: 'recent_tickets') final List<Object?>? recentTickets,
  }) : _recentConnectionRequests = recentConnectionRequests,
       _recentTickets = recentTickets;

  factory _$DashboardSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardSummaryImplFromJson(json);

  @override
  final Employee? employee;
  @override
  final DashboardStats? stats;
  final List<ConnectionRequest>? _recentConnectionRequests;
  @override
  @JsonKey(name: 'recent_connection_requests')
  List<ConnectionRequest>? get recentConnectionRequests {
    final value = _recentConnectionRequests;
    if (value == null) return null;
    if (_recentConnectionRequests is EqualUnmodifiableListView)
      return _recentConnectionRequests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Object?>? _recentTickets;
  @override
  @JsonKey(name: 'recent_tickets')
  List<Object?>? get recentTickets {
    final value = _recentTickets;
    if (value == null) return null;
    if (_recentTickets is EqualUnmodifiableListView) return _recentTickets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'DashboardSummary(employee: $employee, stats: $stats, recentConnectionRequests: $recentConnectionRequests, recentTickets: $recentTickets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardSummaryImpl &&
            (identical(other.employee, employee) ||
                other.employee == employee) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            const DeepCollectionEquality().equals(
              other._recentConnectionRequests,
              _recentConnectionRequests,
            ) &&
            const DeepCollectionEquality().equals(
              other._recentTickets,
              _recentTickets,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    employee,
    stats,
    const DeepCollectionEquality().hash(_recentConnectionRequests),
    const DeepCollectionEquality().hash(_recentTickets),
  );

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardSummaryImplCopyWith<_$DashboardSummaryImpl> get copyWith =>
      __$$DashboardSummaryImplCopyWithImpl<_$DashboardSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardSummaryImplToJson(this);
  }
}

abstract class _DashboardSummary implements DashboardSummary {
  const factory _DashboardSummary({
    final Employee? employee,
    final DashboardStats? stats,
    @JsonKey(name: 'recent_connection_requests')
    final List<ConnectionRequest>? recentConnectionRequests,
    @JsonKey(name: 'recent_tickets') final List<Object?>? recentTickets,
  }) = _$DashboardSummaryImpl;

  factory _DashboardSummary.fromJson(Map<String, dynamic> json) =
      _$DashboardSummaryImpl.fromJson;

  @override
  Employee? get employee;
  @override
  DashboardStats? get stats;
  @override
  @JsonKey(name: 'recent_connection_requests')
  List<ConnectionRequest>? get recentConnectionRequests;
  @override
  @JsonKey(name: 'recent_tickets')
  List<Object?>? get recentTickets;

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardSummaryImplCopyWith<_$DashboardSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DashboardCounts _$DashboardCountsFromJson(Map<String, dynamic> json) {
  return _DashboardCounts.fromJson(json);
}

/// @nodoc
mixin _$DashboardCounts {
  int? get total => throw _privateConstructorUsedError;
  int? get pending => throw _privateConstructorUsedError;
  int? get completed => throw _privateConstructorUsedError;

  /// Serializes this DashboardCounts to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardCountsCopyWith<DashboardCounts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardCountsCopyWith<$Res> {
  factory $DashboardCountsCopyWith(
    DashboardCounts value,
    $Res Function(DashboardCounts) then,
  ) = _$DashboardCountsCopyWithImpl<$Res, DashboardCounts>;
  @useResult
  $Res call({int? total, int? pending, int? completed});
}

/// @nodoc
class _$DashboardCountsCopyWithImpl<$Res, $Val extends DashboardCounts>
    implements $DashboardCountsCopyWith<$Res> {
  _$DashboardCountsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = freezed,
    Object? pending = freezed,
    Object? completed = freezed,
  }) {
    return _then(
      _value.copyWith(
            total: freezed == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int?,
            pending: freezed == pending
                ? _value.pending
                : pending // ignore: cast_nullable_to_non_nullable
                      as int?,
            completed: freezed == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardCountsImplCopyWith<$Res>
    implements $DashboardCountsCopyWith<$Res> {
  factory _$$DashboardCountsImplCopyWith(
    _$DashboardCountsImpl value,
    $Res Function(_$DashboardCountsImpl) then,
  ) = __$$DashboardCountsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? total, int? pending, int? completed});
}

/// @nodoc
class __$$DashboardCountsImplCopyWithImpl<$Res>
    extends _$DashboardCountsCopyWithImpl<$Res, _$DashboardCountsImpl>
    implements _$$DashboardCountsImplCopyWith<$Res> {
  __$$DashboardCountsImplCopyWithImpl(
    _$DashboardCountsImpl _value,
    $Res Function(_$DashboardCountsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = freezed,
    Object? pending = freezed,
    Object? completed = freezed,
  }) {
    return _then(
      _$DashboardCountsImpl(
        total: freezed == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int?,
        pending: freezed == pending
            ? _value.pending
            : pending // ignore: cast_nullable_to_non_nullable
                  as int?,
        completed: freezed == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardCountsImpl implements _DashboardCounts {
  const _$DashboardCountsImpl({this.total, this.pending, this.completed});

  factory _$DashboardCountsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardCountsImplFromJson(json);

  @override
  final int? total;
  @override
  final int? pending;
  @override
  final int? completed;

  @override
  String toString() {
    return 'DashboardCounts(total: $total, pending: $pending, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardCountsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, total, pending, completed);

  /// Create a copy of DashboardCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardCountsImplCopyWith<_$DashboardCountsImpl> get copyWith =>
      __$$DashboardCountsImplCopyWithImpl<_$DashboardCountsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardCountsImplToJson(this);
  }
}

abstract class _DashboardCounts implements DashboardCounts {
  const factory _DashboardCounts({
    final int? total,
    final int? pending,
    final int? completed,
  }) = _$DashboardCountsImpl;

  factory _DashboardCounts.fromJson(Map<String, dynamic> json) =
      _$DashboardCountsImpl.fromJson;

  @override
  int? get total;
  @override
  int? get pending;
  @override
  int? get completed;

  /// Create a copy of DashboardCounts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardCountsImplCopyWith<_$DashboardCountsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) {
  return _DashboardStats.fromJson(json);
}

/// @nodoc
mixin _$DashboardStats {
  @JsonKey(name: 'connection_requests')
  DashboardCounts? get connectionRequests => throw _privateConstructorUsedError;
  DashboardCounts? get tickets => throw _privateConstructorUsedError;

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStatsCopyWith<DashboardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsCopyWith<$Res> {
  factory $DashboardStatsCopyWith(
    DashboardStats value,
    $Res Function(DashboardStats) then,
  ) = _$DashboardStatsCopyWithImpl<$Res, DashboardStats>;
  @useResult
  $Res call({
    @JsonKey(name: 'connection_requests') DashboardCounts? connectionRequests,
    DashboardCounts? tickets,
  });

  $DashboardCountsCopyWith<$Res>? get connectionRequests;
  $DashboardCountsCopyWith<$Res>? get tickets;
}

/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res, $Val extends DashboardStats>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? connectionRequests = freezed, Object? tickets = freezed}) {
    return _then(
      _value.copyWith(
            connectionRequests: freezed == connectionRequests
                ? _value.connectionRequests
                : connectionRequests // ignore: cast_nullable_to_non_nullable
                      as DashboardCounts?,
            tickets: freezed == tickets
                ? _value.tickets
                : tickets // ignore: cast_nullable_to_non_nullable
                      as DashboardCounts?,
          )
          as $Val,
    );
  }

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardCountsCopyWith<$Res>? get connectionRequests {
    if (_value.connectionRequests == null) {
      return null;
    }

    return $DashboardCountsCopyWith<$Res>(_value.connectionRequests!, (value) {
      return _then(_value.copyWith(connectionRequests: value) as $Val);
    });
  }

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardCountsCopyWith<$Res>? get tickets {
    if (_value.tickets == null) {
      return null;
    }

    return $DashboardCountsCopyWith<$Res>(_value.tickets!, (value) {
      return _then(_value.copyWith(tickets: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardStatsImplCopyWith<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  factory _$$DashboardStatsImplCopyWith(
    _$DashboardStatsImpl value,
    $Res Function(_$DashboardStatsImpl) then,
  ) = __$$DashboardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'connection_requests') DashboardCounts? connectionRequests,
    DashboardCounts? tickets,
  });

  @override
  $DashboardCountsCopyWith<$Res>? get connectionRequests;
  @override
  $DashboardCountsCopyWith<$Res>? get tickets;
}

/// @nodoc
class __$$DashboardStatsImplCopyWithImpl<$Res>
    extends _$DashboardStatsCopyWithImpl<$Res, _$DashboardStatsImpl>
    implements _$$DashboardStatsImplCopyWith<$Res> {
  __$$DashboardStatsImplCopyWithImpl(
    _$DashboardStatsImpl _value,
    $Res Function(_$DashboardStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? connectionRequests = freezed, Object? tickets = freezed}) {
    return _then(
      _$DashboardStatsImpl(
        connectionRequests: freezed == connectionRequests
            ? _value.connectionRequests
            : connectionRequests // ignore: cast_nullable_to_non_nullable
                  as DashboardCounts?,
        tickets: freezed == tickets
            ? _value.tickets
            : tickets // ignore: cast_nullable_to_non_nullable
                  as DashboardCounts?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsImpl implements _DashboardStats {
  const _$DashboardStatsImpl({
    @JsonKey(name: 'connection_requests') this.connectionRequests,
    this.tickets,
  });

  factory _$DashboardStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsImplFromJson(json);

  @override
  @JsonKey(name: 'connection_requests')
  final DashboardCounts? connectionRequests;
  @override
  final DashboardCounts? tickets;

  @override
  String toString() {
    return 'DashboardStats(connectionRequests: $connectionRequests, tickets: $tickets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsImpl &&
            (identical(other.connectionRequests, connectionRequests) ||
                other.connectionRequests == connectionRequests) &&
            (identical(other.tickets, tickets) || other.tickets == tickets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, connectionRequests, tickets);

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      __$$DashboardStatsImplCopyWithImpl<_$DashboardStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsImplToJson(this);
  }
}

abstract class _DashboardStats implements DashboardStats {
  const factory _DashboardStats({
    @JsonKey(name: 'connection_requests')
    final DashboardCounts? connectionRequests,
    final DashboardCounts? tickets,
  }) = _$DashboardStatsImpl;

  factory _DashboardStats.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsImpl.fromJson;

  @override
  @JsonKey(name: 'connection_requests')
  DashboardCounts? get connectionRequests;
  @override
  DashboardCounts? get tickets;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
