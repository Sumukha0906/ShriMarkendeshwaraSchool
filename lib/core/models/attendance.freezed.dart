// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) {
  return _AttendanceRecord.fromJson(json);
}

/// @nodoc
mixin _$AttendanceRecord {
  String get studentId => throw _privateConstructorUsedError;
  AttendanceStatus get status => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;

  /// Serializes this AttendanceRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceRecordCopyWith<AttendanceRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceRecordCopyWith<$Res> {
  factory $AttendanceRecordCopyWith(
    AttendanceRecord value,
    $Res Function(AttendanceRecord) then,
  ) = _$AttendanceRecordCopyWithImpl<$Res, AttendanceRecord>;
  @useResult
  $Res call({String studentId, AttendanceStatus status, String note});
}

/// @nodoc
class _$AttendanceRecordCopyWithImpl<$Res, $Val extends AttendanceRecord>
    implements $AttendanceRecordCopyWith<$Res> {
  _$AttendanceRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? status = null,
    Object? note = null,
  }) {
    return _then(
      _value.copyWith(
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AttendanceStatus,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceRecordImplCopyWith<$Res>
    implements $AttendanceRecordCopyWith<$Res> {
  factory _$$AttendanceRecordImplCopyWith(
    _$AttendanceRecordImpl value,
    $Res Function(_$AttendanceRecordImpl) then,
  ) = __$$AttendanceRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String studentId, AttendanceStatus status, String note});
}

/// @nodoc
class __$$AttendanceRecordImplCopyWithImpl<$Res>
    extends _$AttendanceRecordCopyWithImpl<$Res, _$AttendanceRecordImpl>
    implements _$$AttendanceRecordImplCopyWith<$Res> {
  __$$AttendanceRecordImplCopyWithImpl(
    _$AttendanceRecordImpl _value,
    $Res Function(_$AttendanceRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? status = null,
    Object? note = null,
  }) {
    return _then(
      _$AttendanceRecordImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AttendanceStatus,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceRecordImpl implements _AttendanceRecord {
  const _$AttendanceRecordImpl({
    required this.studentId,
    required this.status,
    this.note = '',
  });

  factory _$AttendanceRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceRecordImplFromJson(json);

  @override
  final String studentId;
  @override
  final AttendanceStatus status;
  @override
  @JsonKey()
  final String note;

  @override
  String toString() {
    return 'AttendanceRecord(studentId: $studentId, status: $status, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceRecordImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, studentId, status, note);

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceRecordImplCopyWith<_$AttendanceRecordImpl> get copyWith =>
      __$$AttendanceRecordImplCopyWithImpl<_$AttendanceRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceRecordImplToJson(this);
  }
}

abstract class _AttendanceRecord implements AttendanceRecord {
  const factory _AttendanceRecord({
    required final String studentId,
    required final AttendanceStatus status,
    final String note,
  }) = _$AttendanceRecordImpl;

  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) =
      _$AttendanceRecordImpl.fromJson;

  @override
  String get studentId;
  @override
  AttendanceStatus get status;
  @override
  String get note;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceRecordImplCopyWith<_$AttendanceRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AttendanceSession _$AttendanceSessionFromJson(Map<String, dynamic> json) {
  return _AttendanceSession.fromJson(json);
}

/// @nodoc
mixin _$AttendanceSession {
  String get sessionId => throw _privateConstructorUsedError;
  String get classId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get markedBy => throw _privateConstructorUsedError;
  DateTime? get markedAt => throw _privateConstructorUsedError;
  bool get isUpdated => throw _privateConstructorUsedError;
  List<AttendanceRecord> get records => throw _privateConstructorUsedError;

  /// Serializes this AttendanceSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceSessionCopyWith<AttendanceSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceSessionCopyWith<$Res> {
  factory $AttendanceSessionCopyWith(
    AttendanceSession value,
    $Res Function(AttendanceSession) then,
  ) = _$AttendanceSessionCopyWithImpl<$Res, AttendanceSession>;
  @useResult
  $Res call({
    String sessionId,
    String classId,
    String schoolId,
    DateTime date,
    String markedBy,
    DateTime? markedAt,
    bool isUpdated,
    List<AttendanceRecord> records,
  });
}

/// @nodoc
class _$AttendanceSessionCopyWithImpl<$Res, $Val extends AttendanceSession>
    implements $AttendanceSessionCopyWith<$Res> {
  _$AttendanceSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? classId = null,
    Object? schoolId = null,
    Object? date = null,
    Object? markedBy = null,
    Object? markedAt = freezed,
    Object? isUpdated = null,
    Object? records = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            schoolId: null == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            markedBy: null == markedBy
                ? _value.markedBy
                : markedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            markedAt: freezed == markedAt
                ? _value.markedAt
                : markedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isUpdated: null == isUpdated
                ? _value.isUpdated
                : isUpdated // ignore: cast_nullable_to_non_nullable
                      as bool,
            records: null == records
                ? _value.records
                : records // ignore: cast_nullable_to_non_nullable
                      as List<AttendanceRecord>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceSessionImplCopyWith<$Res>
    implements $AttendanceSessionCopyWith<$Res> {
  factory _$$AttendanceSessionImplCopyWith(
    _$AttendanceSessionImpl value,
    $Res Function(_$AttendanceSessionImpl) then,
  ) = __$$AttendanceSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    String classId,
    String schoolId,
    DateTime date,
    String markedBy,
    DateTime? markedAt,
    bool isUpdated,
    List<AttendanceRecord> records,
  });
}

/// @nodoc
class __$$AttendanceSessionImplCopyWithImpl<$Res>
    extends _$AttendanceSessionCopyWithImpl<$Res, _$AttendanceSessionImpl>
    implements _$$AttendanceSessionImplCopyWith<$Res> {
  __$$AttendanceSessionImplCopyWithImpl(
    _$AttendanceSessionImpl _value,
    $Res Function(_$AttendanceSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? classId = null,
    Object? schoolId = null,
    Object? date = null,
    Object? markedBy = null,
    Object? markedAt = freezed,
    Object? isUpdated = null,
    Object? records = null,
  }) {
    return _then(
      _$AttendanceSessionImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        markedBy: null == markedBy
            ? _value.markedBy
            : markedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        markedAt: freezed == markedAt
            ? _value.markedAt
            : markedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isUpdated: null == isUpdated
            ? _value.isUpdated
            : isUpdated // ignore: cast_nullable_to_non_nullable
                  as bool,
        records: null == records
            ? _value._records
            : records // ignore: cast_nullable_to_non_nullable
                  as List<AttendanceRecord>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceSessionImpl implements _AttendanceSession {
  const _$AttendanceSessionImpl({
    required this.sessionId,
    required this.classId,
    required this.schoolId,
    required this.date,
    required this.markedBy,
    this.markedAt,
    this.isUpdated = false,
    final List<AttendanceRecord> records = const [],
  }) : _records = records;

  factory _$AttendanceSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceSessionImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String classId;
  @override
  final String schoolId;
  @override
  final DateTime date;
  @override
  final String markedBy;
  @override
  final DateTime? markedAt;
  @override
  @JsonKey()
  final bool isUpdated;
  final List<AttendanceRecord> _records;
  @override
  @JsonKey()
  List<AttendanceRecord> get records {
    if (_records is EqualUnmodifiableListView) return _records;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_records);
  }

  @override
  String toString() {
    return 'AttendanceSession(sessionId: $sessionId, classId: $classId, schoolId: $schoolId, date: $date, markedBy: $markedBy, markedAt: $markedAt, isUpdated: $isUpdated, records: $records)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceSessionImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.markedBy, markedBy) ||
                other.markedBy == markedBy) &&
            (identical(other.markedAt, markedAt) ||
                other.markedAt == markedAt) &&
            (identical(other.isUpdated, isUpdated) ||
                other.isUpdated == isUpdated) &&
            const DeepCollectionEquality().equals(other._records, _records));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    classId,
    schoolId,
    date,
    markedBy,
    markedAt,
    isUpdated,
    const DeepCollectionEquality().hash(_records),
  );

  /// Create a copy of AttendanceSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceSessionImplCopyWith<_$AttendanceSessionImpl> get copyWith =>
      __$$AttendanceSessionImplCopyWithImpl<_$AttendanceSessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceSessionImplToJson(this);
  }
}

abstract class _AttendanceSession implements AttendanceSession {
  const factory _AttendanceSession({
    required final String sessionId,
    required final String classId,
    required final String schoolId,
    required final DateTime date,
    required final String markedBy,
    final DateTime? markedAt,
    final bool isUpdated,
    final List<AttendanceRecord> records,
  }) = _$AttendanceSessionImpl;

  factory _AttendanceSession.fromJson(Map<String, dynamic> json) =
      _$AttendanceSessionImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get classId;
  @override
  String get schoolId;
  @override
  DateTime get date;
  @override
  String get markedBy;
  @override
  DateTime? get markedAt;
  @override
  bool get isUpdated;
  @override
  List<AttendanceRecord> get records;

  /// Create a copy of AttendanceSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceSessionImplCopyWith<_$AttendanceSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
