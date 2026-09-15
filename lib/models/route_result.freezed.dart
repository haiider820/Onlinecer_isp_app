// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RouteResult _$RouteResultFromJson(Map<String, dynamic> json) {
  return _RouteResult.fromJson(json);
}

/// @nodoc
mixin _$RouteResult {
  @JsonKey(name: 'distance_meters')
  double? get distanceMeters => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_seconds')
  double? get durationSeconds => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'points',
    fromJson: decodeRoutePointsArray,
    toJson: encodeRoutePointsArray,
  )
  List<LatLng>? get points => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;

  /// Serializes this RouteResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RouteResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteResultCopyWith<RouteResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteResultCopyWith<$Res> {
  factory $RouteResultCopyWith(
    RouteResult value,
    $Res Function(RouteResult) then,
  ) = _$RouteResultCopyWithImpl<$Res, RouteResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'distance_meters') double? distanceMeters,
    @JsonKey(name: 'duration_seconds') double? durationSeconds,
    @JsonKey(
      name: 'points',
      fromJson: decodeRoutePointsArray,
      toJson: encodeRoutePointsArray,
    )
    List<LatLng>? points,
    String? source,
    String? summary,
  });
}

/// @nodoc
class _$RouteResultCopyWithImpl<$Res, $Val extends RouteResult>
    implements $RouteResultCopyWith<$Res> {
  _$RouteResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? distanceMeters = freezed,
    Object? durationSeconds = freezed,
    Object? points = freezed,
    Object? source = freezed,
    Object? summary = freezed,
  }) {
    return _then(
      _value.copyWith(
            distanceMeters: freezed == distanceMeters
                ? _value.distanceMeters
                : distanceMeters // ignore: cast_nullable_to_non_nullable
                      as double?,
            durationSeconds: freezed == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as double?,
            points: freezed == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as List<LatLng>?,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            summary: freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RouteResultImplCopyWith<$Res>
    implements $RouteResultCopyWith<$Res> {
  factory _$$RouteResultImplCopyWith(
    _$RouteResultImpl value,
    $Res Function(_$RouteResultImpl) then,
  ) = __$$RouteResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'distance_meters') double? distanceMeters,
    @JsonKey(name: 'duration_seconds') double? durationSeconds,
    @JsonKey(
      name: 'points',
      fromJson: decodeRoutePointsArray,
      toJson: encodeRoutePointsArray,
    )
    List<LatLng>? points,
    String? source,
    String? summary,
  });
}

/// @nodoc
class __$$RouteResultImplCopyWithImpl<$Res>
    extends _$RouteResultCopyWithImpl<$Res, _$RouteResultImpl>
    implements _$$RouteResultImplCopyWith<$Res> {
  __$$RouteResultImplCopyWithImpl(
    _$RouteResultImpl _value,
    $Res Function(_$RouteResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RouteResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? distanceMeters = freezed,
    Object? durationSeconds = freezed,
    Object? points = freezed,
    Object? source = freezed,
    Object? summary = freezed,
  }) {
    return _then(
      _$RouteResultImpl(
        distanceMeters: freezed == distanceMeters
            ? _value.distanceMeters
            : distanceMeters // ignore: cast_nullable_to_non_nullable
                  as double?,
        durationSeconds: freezed == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as double?,
        points: freezed == points
            ? _value._points
            : points // ignore: cast_nullable_to_non_nullable
                  as List<LatLng>?,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        summary: freezed == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RouteResultImpl implements _RouteResult {
  const _$RouteResultImpl({
    @JsonKey(name: 'distance_meters') this.distanceMeters,
    @JsonKey(name: 'duration_seconds') this.durationSeconds,
    @JsonKey(
      name: 'points',
      fromJson: decodeRoutePointsArray,
      toJson: encodeRoutePointsArray,
    )
    final List<LatLng>? points,
    this.source,
    this.summary,
  }) : _points = points;

  factory _$RouteResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteResultImplFromJson(json);

  @override
  @JsonKey(name: 'distance_meters')
  final double? distanceMeters;
  @override
  @JsonKey(name: 'duration_seconds')
  final double? durationSeconds;
  final List<LatLng>? _points;
  @override
  @JsonKey(
    name: 'points',
    fromJson: decodeRoutePointsArray,
    toJson: encodeRoutePointsArray,
  )
  List<LatLng>? get points {
    final value = _points;
    if (value == null) return null;
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? source;
  @override
  final String? summary;

  @override
  String toString() {
    return 'RouteResult(distanceMeters: $distanceMeters, durationSeconds: $durationSeconds, points: $points, source: $source, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteResultImpl &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            const DeepCollectionEquality().equals(other._points, _points) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    distanceMeters,
    durationSeconds,
    const DeepCollectionEquality().hash(_points),
    source,
    summary,
  );

  /// Create a copy of RouteResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteResultImplCopyWith<_$RouteResultImpl> get copyWith =>
      __$$RouteResultImplCopyWithImpl<_$RouteResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteResultImplToJson(this);
  }
}

abstract class _RouteResult implements RouteResult {
  const factory _RouteResult({
    @JsonKey(name: 'distance_meters') final double? distanceMeters,
    @JsonKey(name: 'duration_seconds') final double? durationSeconds,
    @JsonKey(
      name: 'points',
      fromJson: decodeRoutePointsArray,
      toJson: encodeRoutePointsArray,
    )
    final List<LatLng>? points,
    final String? source,
    final String? summary,
  }) = _$RouteResultImpl;

  factory _RouteResult.fromJson(Map<String, dynamic> json) =
      _$RouteResultImpl.fromJson;

  @override
  @JsonKey(name: 'distance_meters')
  double? get distanceMeters;
  @override
  @JsonKey(name: 'duration_seconds')
  double? get durationSeconds;
  @override
  @JsonKey(
    name: 'points',
    fromJson: decodeRoutePointsArray,
    toJson: encodeRoutePointsArray,
  )
  List<LatLng>? get points;
  @override
  String? get source;
  @override
  String? get summary;

  /// Create a copy of RouteResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteResultImplCopyWith<_$RouteResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
