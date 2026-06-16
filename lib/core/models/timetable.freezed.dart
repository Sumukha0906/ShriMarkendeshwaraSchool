// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timetable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Period _$PeriodFromJson(Map<String, dynamic> json) {
  return _Period.fromJson(json);
}

/// @nodoc
mixin _$Period {
  int get periodNumber => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get teacherUid => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  String get substituteTeacherUid => throw _privateConstructorUsedError;

  /// Serializes this Period to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Period
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PeriodCopyWith<Period> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeriodCopyWith<$Res> {
  factory $PeriodCopyWith(Period value, $Res Function(Period) then) =
      _$PeriodCopyWithImpl<$Res, Period>;
  @useResult
  $Res call({
    int periodNumber,
    String subject,
    String teacherUid,
    String startTime,
    String endTime,
    String substituteTeacherUid,
  });
}

/// @nodoc
class _$PeriodCopyWithImpl<$Res, $Val extends Period>
    implements $PeriodCopyWith<$Res> {
  _$PeriodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Period
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periodNumber = null,
    Object? subject = null,
    Object? teacherUid = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? substituteTeacherUid = null,
  }) {
    return _then(
      _value.copyWith(
            periodNumber: null == periodNumber
                ? _value.periodNumber
                : periodNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String,
            teacherUid: null == teacherUid
                ? _value.teacherUid
                : teacherUid // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String,
            substituteTeacherUid: null == substituteTeacherUid
                ? _value.substituteTeacherUid
                : substituteTeacherUid // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PeriodImplCopyWith<$Res> implements $PeriodCopyWith<$Res> {
  factory _$$PeriodImplCopyWith(
    _$PeriodImpl value,
    $Res Function(_$PeriodImpl) then,
  ) = __$$PeriodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int periodNumber,
    String subject,
    String teacherUid,
    String startTime,
    String endTime,
    String substituteTeacherUid,
  });
}

/// @nodoc
class __$$PeriodImplCopyWithImpl<$Res>
    extends _$PeriodCopyWithImpl<$Res, _$PeriodImpl>
    implements _$$PeriodImplCopyWith<$Res> {
  __$$PeriodImplCopyWithImpl(
    _$PeriodImpl _value,
    $Res Function(_$PeriodImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Period
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periodNumber = null,
    Object? subject = null,
    Object? teacherUid = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? substituteTeacherUid = null,
  }) {
    return _then(
      _$PeriodImpl(
        periodNumber: null == periodNumber
            ? _value.periodNumber
            : periodNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherUid: null == teacherUid
            ? _value.teacherUid
            : teacherUid // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String,
        substituteTeacherUid: null == substituteTeacherUid
            ? _value.substituteTeacherUid
            : substituteTeacherUid // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PeriodImpl implements _Period {
  const _$PeriodImpl({
    required this.periodNumber,
    required this.subject,
    required this.teacherUid,
    required this.startTime,
    required this.endTime,
    this.substituteTeacherUid = '',
  });

  factory _$PeriodImpl.fromJson(Map<String, dynamic> json) =>
      _$$PeriodImplFromJson(json);

  @override
  final int periodNumber;
  @override
  final String subject;
  @override
  final String teacherUid;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  @JsonKey()
  final String substituteTeacherUid;

  @override
  String toString() {
    return 'Period(periodNumber: $periodNumber, subject: $subject, teacherUid: $teacherUid, startTime: $startTime, endTime: $endTime, substituteTeacherUid: $substituteTeacherUid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeriodImpl &&
            (identical(other.periodNumber, periodNumber) ||
                other.periodNumber == periodNumber) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.teacherUid, teacherUid) ||
                other.teacherUid == teacherUid) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.substituteTeacherUid, substituteTeacherUid) ||
                other.substituteTeacherUid == substituteTeacherUid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    periodNumber,
    subject,
    teacherUid,
    startTime,
    endTime,
    substituteTeacherUid,
  );

  /// Create a copy of Period
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeriodImplCopyWith<_$PeriodImpl> get copyWith =>
      __$$PeriodImplCopyWithImpl<_$PeriodImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PeriodImplToJson(this);
  }
}

abstract class _Period implements Period {
  const factory _Period({
    required final int periodNumber,
    required final String subject,
    required final String teacherUid,
    required final String startTime,
    required final String endTime,
    final String substituteTeacherUid,
  }) = _$PeriodImpl;

  factory _Period.fromJson(Map<String, dynamic> json) = _$PeriodImpl.fromJson;

  @override
  int get periodNumber;
  @override
  String get subject;
  @override
  String get teacherUid;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  String get substituteTeacherUid;

  /// Create a copy of Period
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeriodImplCopyWith<_$PeriodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Timetable _$TimetableFromJson(Map<String, dynamic> json) {
  return _Timetable.fromJson(json);
}

/// @nodoc
mixin _$Timetable {
  String get classId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String get updatedBy => throw _privateConstructorUsedError;
  Map<String, List<Period>> get schedule => throw _privateConstructorUsedError;

  /// Serializes this Timetable to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Timetable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimetableCopyWith<Timetable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimetableCopyWith<$Res> {
  factory $TimetableCopyWith(Timetable value, $Res Function(Timetable) then) =
      _$TimetableCopyWithImpl<$Res, Timetable>;
  @useResult
  $Res call({
    String classId,
    String schoolId,
    DateTime? updatedAt,
    String updatedBy,
    Map<String, List<Period>> schedule,
  });
}

/// @nodoc
class _$TimetableCopyWithImpl<$Res, $Val extends Timetable>
    implements $TimetableCopyWith<$Res> {
  _$TimetableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Timetable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? schoolId = null,
    Object? updatedAt = freezed,
    Object? updatedBy = null,
    Object? schedule = null,
  }) {
    return _then(
      _value.copyWith(
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            schoolId: null == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedBy: null == updatedBy
                ? _value.updatedBy
                : updatedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            schedule: null == schedule
                ? _value.schedule
                : schedule // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<Period>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimetableImplCopyWith<$Res>
    implements $TimetableCopyWith<$Res> {
  factory _$$TimetableImplCopyWith(
    _$TimetableImpl value,
    $Res Function(_$TimetableImpl) then,
  ) = __$$TimetableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String classId,
    String schoolId,
    DateTime? updatedAt,
    String updatedBy,
    Map<String, List<Period>> schedule,
  });
}

/// @nodoc
class __$$TimetableImplCopyWithImpl<$Res>
    extends _$TimetableCopyWithImpl<$Res, _$TimetableImpl>
    implements _$$TimetableImplCopyWith<$Res> {
  __$$TimetableImplCopyWithImpl(
    _$TimetableImpl _value,
    $Res Function(_$TimetableImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Timetable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? schoolId = null,
    Object? updatedAt = freezed,
    Object? updatedBy = null,
    Object? schedule = null,
  }) {
    return _then(
      _$TimetableImpl(
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedBy: null == updatedBy
            ? _value.updatedBy
            : updatedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        schedule: null == schedule
            ? _value._schedule
            : schedule // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<Period>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimetableImpl implements _Timetable {
  const _$TimetableImpl({
    required this.classId,
    required this.schoolId,
    this.updatedAt,
    this.updatedBy = '',
    final Map<String, List<Period>> schedule = const {},
  }) : _schedule = schedule;

  factory _$TimetableImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimetableImplFromJson(json);

  @override
  final String classId;
  @override
  final String schoolId;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final String updatedBy;
  final Map<String, List<Period>> _schedule;
  @override
  @JsonKey()
  Map<String, List<Period>> get schedule {
    if (_schedule is EqualUnmodifiableMapView) return _schedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_schedule);
  }

  @override
  String toString() {
    return 'Timetable(classId: $classId, schoolId: $schoolId, updatedAt: $updatedAt, updatedBy: $updatedBy, schedule: $schedule)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimetableImpl &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            const DeepCollectionEquality().equals(other._schedule, _schedule));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    classId,
    schoolId,
    updatedAt,
    updatedBy,
    const DeepCollectionEquality().hash(_schedule),
  );

  /// Create a copy of Timetable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimetableImplCopyWith<_$TimetableImpl> get copyWith =>
      __$$TimetableImplCopyWithImpl<_$TimetableImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimetableImplToJson(this);
  }
}

abstract class _Timetable implements Timetable {
  const factory _Timetable({
    required final String classId,
    required final String schoolId,
    final DateTime? updatedAt,
    final String updatedBy,
    final Map<String, List<Period>> schedule,
  }) = _$TimetableImpl;

  factory _Timetable.fromJson(Map<String, dynamic> json) =
      _$TimetableImpl.fromJson;

  @override
  String get classId;
  @override
  String get schoolId;
  @override
  DateTime? get updatedAt;
  @override
  String get updatedBy;
  @override
  Map<String, List<Period>> get schedule;

  /// Create a copy of Timetable
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimetableImplCopyWith<_$TimetableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
