// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marks.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubjectMark _$SubjectMarkFromJson(Map<String, dynamic> json) {
  return _SubjectMark.fromJson(json);
}

/// @nodoc
mixin _$SubjectMark {
  String get subject => throw _privateConstructorUsedError;
  double get marksObtained => throw _privateConstructorUsedError;
  double get maxMarks => throw _privateConstructorUsedError;
  String get grade => throw _privateConstructorUsedError;
  String get remarks => throw _privateConstructorUsedError;

  /// Serializes this SubjectMark to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubjectMark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubjectMarkCopyWith<SubjectMark> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubjectMarkCopyWith<$Res> {
  factory $SubjectMarkCopyWith(
    SubjectMark value,
    $Res Function(SubjectMark) then,
  ) = _$SubjectMarkCopyWithImpl<$Res, SubjectMark>;
  @useResult
  $Res call({
    String subject,
    double marksObtained,
    double maxMarks,
    String grade,
    String remarks,
  });
}

/// @nodoc
class _$SubjectMarkCopyWithImpl<$Res, $Val extends SubjectMark>
    implements $SubjectMarkCopyWith<$Res> {
  _$SubjectMarkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubjectMark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? marksObtained = null,
    Object? maxMarks = null,
    Object? grade = null,
    Object? remarks = null,
  }) {
    return _then(
      _value.copyWith(
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String,
            marksObtained: null == marksObtained
                ? _value.marksObtained
                : marksObtained // ignore: cast_nullable_to_non_nullable
                      as double,
            maxMarks: null == maxMarks
                ? _value.maxMarks
                : maxMarks // ignore: cast_nullable_to_non_nullable
                      as double,
            grade: null == grade
                ? _value.grade
                : grade // ignore: cast_nullable_to_non_nullable
                      as String,
            remarks: null == remarks
                ? _value.remarks
                : remarks // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubjectMarkImplCopyWith<$Res>
    implements $SubjectMarkCopyWith<$Res> {
  factory _$$SubjectMarkImplCopyWith(
    _$SubjectMarkImpl value,
    $Res Function(_$SubjectMarkImpl) then,
  ) = __$$SubjectMarkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String subject,
    double marksObtained,
    double maxMarks,
    String grade,
    String remarks,
  });
}

/// @nodoc
class __$$SubjectMarkImplCopyWithImpl<$Res>
    extends _$SubjectMarkCopyWithImpl<$Res, _$SubjectMarkImpl>
    implements _$$SubjectMarkImplCopyWith<$Res> {
  __$$SubjectMarkImplCopyWithImpl(
    _$SubjectMarkImpl _value,
    $Res Function(_$SubjectMarkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubjectMark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? marksObtained = null,
    Object? maxMarks = null,
    Object? grade = null,
    Object? remarks = null,
  }) {
    return _then(
      _$SubjectMarkImpl(
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String,
        marksObtained: null == marksObtained
            ? _value.marksObtained
            : marksObtained // ignore: cast_nullable_to_non_nullable
                  as double,
        maxMarks: null == maxMarks
            ? _value.maxMarks
            : maxMarks // ignore: cast_nullable_to_non_nullable
                  as double,
        grade: null == grade
            ? _value.grade
            : grade // ignore: cast_nullable_to_non_nullable
                  as String,
        remarks: null == remarks
            ? _value.remarks
            : remarks // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubjectMarkImpl implements _SubjectMark {
  const _$SubjectMarkImpl({
    required this.subject,
    required this.marksObtained,
    required this.maxMarks,
    this.grade = '',
    this.remarks = '',
  });

  factory _$SubjectMarkImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubjectMarkImplFromJson(json);

  @override
  final String subject;
  @override
  final double marksObtained;
  @override
  final double maxMarks;
  @override
  @JsonKey()
  final String grade;
  @override
  @JsonKey()
  final String remarks;

  @override
  String toString() {
    return 'SubjectMark(subject: $subject, marksObtained: $marksObtained, maxMarks: $maxMarks, grade: $grade, remarks: $remarks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubjectMarkImpl &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.marksObtained, marksObtained) ||
                other.marksObtained == marksObtained) &&
            (identical(other.maxMarks, maxMarks) ||
                other.maxMarks == maxMarks) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.remarks, remarks) || other.remarks == remarks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    subject,
    marksObtained,
    maxMarks,
    grade,
    remarks,
  );

  /// Create a copy of SubjectMark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubjectMarkImplCopyWith<_$SubjectMarkImpl> get copyWith =>
      __$$SubjectMarkImplCopyWithImpl<_$SubjectMarkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubjectMarkImplToJson(this);
  }
}

abstract class _SubjectMark implements SubjectMark {
  const factory _SubjectMark({
    required final String subject,
    required final double marksObtained,
    required final double maxMarks,
    final String grade,
    final String remarks,
  }) = _$SubjectMarkImpl;

  factory _SubjectMark.fromJson(Map<String, dynamic> json) =
      _$SubjectMarkImpl.fromJson;

  @override
  String get subject;
  @override
  double get marksObtained;
  @override
  double get maxMarks;
  @override
  String get grade;
  @override
  String get remarks;

  /// Create a copy of SubjectMark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubjectMarkImplCopyWith<_$SubjectMarkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentMarks _$StudentMarksFromJson(Map<String, dynamic> json) {
  return _StudentMarks.fromJson(json);
}

/// @nodoc
mixin _$StudentMarks {
  String get studentId => throw _privateConstructorUsedError;
  String get classId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get academicYear => throw _privateConstructorUsedError;
  String get term => throw _privateConstructorUsedError;
  List<SubjectMark> get subjects => throw _privateConstructorUsedError;
  String get updatedBy => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isPublished => throw _privateConstructorUsedError;

  /// Serializes this StudentMarks to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentMarks
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentMarksCopyWith<StudentMarks> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentMarksCopyWith<$Res> {
  factory $StudentMarksCopyWith(
    StudentMarks value,
    $Res Function(StudentMarks) then,
  ) = _$StudentMarksCopyWithImpl<$Res, StudentMarks>;
  @useResult
  $Res call({
    String studentId,
    String classId,
    String schoolId,
    String academicYear,
    String term,
    List<SubjectMark> subjects,
    String updatedBy,
    DateTime? updatedAt,
    bool isPublished,
  });
}

/// @nodoc
class _$StudentMarksCopyWithImpl<$Res, $Val extends StudentMarks>
    implements $StudentMarksCopyWith<$Res> {
  _$StudentMarksCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentMarks
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? classId = null,
    Object? schoolId = null,
    Object? academicYear = null,
    Object? term = null,
    Object? subjects = null,
    Object? updatedBy = null,
    Object? updatedAt = freezed,
    Object? isPublished = null,
  }) {
    return _then(
      _value.copyWith(
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            schoolId: null == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String,
            academicYear: null == academicYear
                ? _value.academicYear
                : academicYear // ignore: cast_nullable_to_non_nullable
                      as String,
            term: null == term
                ? _value.term
                : term // ignore: cast_nullable_to_non_nullable
                      as String,
            subjects: null == subjects
                ? _value.subjects
                : subjects // ignore: cast_nullable_to_non_nullable
                      as List<SubjectMark>,
            updatedBy: null == updatedBy
                ? _value.updatedBy
                : updatedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isPublished: null == isPublished
                ? _value.isPublished
                : isPublished // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentMarksImplCopyWith<$Res>
    implements $StudentMarksCopyWith<$Res> {
  factory _$$StudentMarksImplCopyWith(
    _$StudentMarksImpl value,
    $Res Function(_$StudentMarksImpl) then,
  ) = __$$StudentMarksImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String studentId,
    String classId,
    String schoolId,
    String academicYear,
    String term,
    List<SubjectMark> subjects,
    String updatedBy,
    DateTime? updatedAt,
    bool isPublished,
  });
}

/// @nodoc
class __$$StudentMarksImplCopyWithImpl<$Res>
    extends _$StudentMarksCopyWithImpl<$Res, _$StudentMarksImpl>
    implements _$$StudentMarksImplCopyWith<$Res> {
  __$$StudentMarksImplCopyWithImpl(
    _$StudentMarksImpl _value,
    $Res Function(_$StudentMarksImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentMarks
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? classId = null,
    Object? schoolId = null,
    Object? academicYear = null,
    Object? term = null,
    Object? subjects = null,
    Object? updatedBy = null,
    Object? updatedAt = freezed,
    Object? isPublished = null,
  }) {
    return _then(
      _$StudentMarksImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        academicYear: null == academicYear
            ? _value.academicYear
            : academicYear // ignore: cast_nullable_to_non_nullable
                  as String,
        term: null == term
            ? _value.term
            : term // ignore: cast_nullable_to_non_nullable
                  as String,
        subjects: null == subjects
            ? _value._subjects
            : subjects // ignore: cast_nullable_to_non_nullable
                  as List<SubjectMark>,
        updatedBy: null == updatedBy
            ? _value.updatedBy
            : updatedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isPublished: null == isPublished
            ? _value.isPublished
            : isPublished // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentMarksImpl implements _StudentMarks {
  const _$StudentMarksImpl({
    required this.studentId,
    required this.classId,
    required this.schoolId,
    required this.academicYear,
    required this.term,
    final List<SubjectMark> subjects = const [],
    this.updatedBy = '',
    this.updatedAt,
    this.isPublished = false,
  }) : _subjects = subjects;

  factory _$StudentMarksImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentMarksImplFromJson(json);

  @override
  final String studentId;
  @override
  final String classId;
  @override
  final String schoolId;
  @override
  final String academicYear;
  @override
  final String term;
  final List<SubjectMark> _subjects;
  @override
  @JsonKey()
  List<SubjectMark> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  @JsonKey()
  final String updatedBy;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isPublished;

  @override
  String toString() {
    return 'StudentMarks(studentId: $studentId, classId: $classId, schoolId: $schoolId, academicYear: $academicYear, term: $term, subjects: $subjects, updatedBy: $updatedBy, updatedAt: $updatedAt, isPublished: $isPublished)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentMarksImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.academicYear, academicYear) ||
                other.academicYear == academicYear) &&
            (identical(other.term, term) || other.term == term) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    studentId,
    classId,
    schoolId,
    academicYear,
    term,
    const DeepCollectionEquality().hash(_subjects),
    updatedBy,
    updatedAt,
    isPublished,
  );

  /// Create a copy of StudentMarks
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentMarksImplCopyWith<_$StudentMarksImpl> get copyWith =>
      __$$StudentMarksImplCopyWithImpl<_$StudentMarksImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentMarksImplToJson(this);
  }
}

abstract class _StudentMarks implements StudentMarks {
  const factory _StudentMarks({
    required final String studentId,
    required final String classId,
    required final String schoolId,
    required final String academicYear,
    required final String term,
    final List<SubjectMark> subjects,
    final String updatedBy,
    final DateTime? updatedAt,
    final bool isPublished,
  }) = _$StudentMarksImpl;

  factory _StudentMarks.fromJson(Map<String, dynamic> json) =
      _$StudentMarksImpl.fromJson;

  @override
  String get studentId;
  @override
  String get classId;
  @override
  String get schoolId;
  @override
  String get academicYear;
  @override
  String get term;
  @override
  List<SubjectMark> get subjects;
  @override
  String get updatedBy;
  @override
  DateTime? get updatedAt;
  @override
  bool get isPublished;

  /// Create a copy of StudentMarks
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentMarksImplCopyWith<_$StudentMarksImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
