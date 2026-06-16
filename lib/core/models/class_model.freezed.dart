// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubjectTeacher _$SubjectTeacherFromJson(Map<String, dynamic> json) {
  return _SubjectTeacher.fromJson(json);
}

/// @nodoc
mixin _$SubjectTeacher {
  String get teacherUid => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;

  /// Serializes this SubjectTeacher to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubjectTeacher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubjectTeacherCopyWith<SubjectTeacher> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubjectTeacherCopyWith<$Res> {
  factory $SubjectTeacherCopyWith(
    SubjectTeacher value,
    $Res Function(SubjectTeacher) then,
  ) = _$SubjectTeacherCopyWithImpl<$Res, SubjectTeacher>;
  @useResult
  $Res call({String teacherUid, String subject});
}

/// @nodoc
class _$SubjectTeacherCopyWithImpl<$Res, $Val extends SubjectTeacher>
    implements $SubjectTeacherCopyWith<$Res> {
  _$SubjectTeacherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubjectTeacher
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? teacherUid = null, Object? subject = null}) {
    return _then(
      _value.copyWith(
            teacherUid: null == teacherUid
                ? _value.teacherUid
                : teacherUid // ignore: cast_nullable_to_non_nullable
                      as String,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubjectTeacherImplCopyWith<$Res>
    implements $SubjectTeacherCopyWith<$Res> {
  factory _$$SubjectTeacherImplCopyWith(
    _$SubjectTeacherImpl value,
    $Res Function(_$SubjectTeacherImpl) then,
  ) = __$$SubjectTeacherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String teacherUid, String subject});
}

/// @nodoc
class __$$SubjectTeacherImplCopyWithImpl<$Res>
    extends _$SubjectTeacherCopyWithImpl<$Res, _$SubjectTeacherImpl>
    implements _$$SubjectTeacherImplCopyWith<$Res> {
  __$$SubjectTeacherImplCopyWithImpl(
    _$SubjectTeacherImpl _value,
    $Res Function(_$SubjectTeacherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubjectTeacher
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? teacherUid = null, Object? subject = null}) {
    return _then(
      _$SubjectTeacherImpl(
        teacherUid: null == teacherUid
            ? _value.teacherUid
            : teacherUid // ignore: cast_nullable_to_non_nullable
                  as String,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubjectTeacherImpl implements _SubjectTeacher {
  const _$SubjectTeacherImpl({required this.teacherUid, required this.subject});

  factory _$SubjectTeacherImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubjectTeacherImplFromJson(json);

  @override
  final String teacherUid;
  @override
  final String subject;

  @override
  String toString() {
    return 'SubjectTeacher(teacherUid: $teacherUid, subject: $subject)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubjectTeacherImpl &&
            (identical(other.teacherUid, teacherUid) ||
                other.teacherUid == teacherUid) &&
            (identical(other.subject, subject) || other.subject == subject));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, teacherUid, subject);

  /// Create a copy of SubjectTeacher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubjectTeacherImplCopyWith<_$SubjectTeacherImpl> get copyWith =>
      __$$SubjectTeacherImplCopyWithImpl<_$SubjectTeacherImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubjectTeacherImplToJson(this);
  }
}

abstract class _SubjectTeacher implements SubjectTeacher {
  const factory _SubjectTeacher({
    required final String teacherUid,
    required final String subject,
  }) = _$SubjectTeacherImpl;

  factory _SubjectTeacher.fromJson(Map<String, dynamic> json) =
      _$SubjectTeacherImpl.fromJson;

  @override
  String get teacherUid;
  @override
  String get subject;

  /// Create a copy of SubjectTeacher
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubjectTeacherImplCopyWith<_$SubjectTeacherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClassModel _$ClassModelFromJson(Map<String, dynamic> json) {
  return _ClassModel.fromJson(json);
}

/// @nodoc
mixin _$ClassModel {
  String get classId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get section => throw _privateConstructorUsedError;
  String get classTeacherUid => throw _privateConstructorUsedError;
  String get proctorTeacherUid => throw _privateConstructorUsedError;
  List<SubjectTeacher> get subjectTeachers =>
      throw _privateConstructorUsedError;
  int get studentCount => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ClassModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassModelCopyWith<ClassModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassModelCopyWith<$Res> {
  factory $ClassModelCopyWith(
    ClassModel value,
    $Res Function(ClassModel) then,
  ) = _$ClassModelCopyWithImpl<$Res, ClassModel>;
  @useResult
  $Res call({
    String classId,
    String schoolId,
    String name,
    String section,
    String classTeacherUid,
    String proctorTeacherUid,
    List<SubjectTeacher> subjectTeachers,
    int studentCount,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$ClassModelCopyWithImpl<$Res, $Val extends ClassModel>
    implements $ClassModelCopyWith<$Res> {
  _$ClassModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? schoolId = null,
    Object? name = null,
    Object? section = null,
    Object? classTeacherUid = null,
    Object? proctorTeacherUid = null,
    Object? subjectTeachers = null,
    Object? studentCount = null,
    Object? createdAt = freezed,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            section: null == section
                ? _value.section
                : section // ignore: cast_nullable_to_non_nullable
                      as String,
            classTeacherUid: null == classTeacherUid
                ? _value.classTeacherUid
                : classTeacherUid // ignore: cast_nullable_to_non_nullable
                      as String,
            proctorTeacherUid: null == proctorTeacherUid
                ? _value.proctorTeacherUid
                : proctorTeacherUid // ignore: cast_nullable_to_non_nullable
                      as String,
            subjectTeachers: null == subjectTeachers
                ? _value.subjectTeachers
                : subjectTeachers // ignore: cast_nullable_to_non_nullable
                      as List<SubjectTeacher>,
            studentCount: null == studentCount
                ? _value.studentCount
                : studentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClassModelImplCopyWith<$Res>
    implements $ClassModelCopyWith<$Res> {
  factory _$$ClassModelImplCopyWith(
    _$ClassModelImpl value,
    $Res Function(_$ClassModelImpl) then,
  ) = __$$ClassModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String classId,
    String schoolId,
    String name,
    String section,
    String classTeacherUid,
    String proctorTeacherUid,
    List<SubjectTeacher> subjectTeachers,
    int studentCount,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$ClassModelImplCopyWithImpl<$Res>
    extends _$ClassModelCopyWithImpl<$Res, _$ClassModelImpl>
    implements _$$ClassModelImplCopyWith<$Res> {
  __$$ClassModelImplCopyWithImpl(
    _$ClassModelImpl _value,
    $Res Function(_$ClassModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClassModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? schoolId = null,
    Object? name = null,
    Object? section = null,
    Object? classTeacherUid = null,
    Object? proctorTeacherUid = null,
    Object? subjectTeachers = null,
    Object? studentCount = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ClassModelImpl(
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        section: null == section
            ? _value.section
            : section // ignore: cast_nullable_to_non_nullable
                  as String,
        classTeacherUid: null == classTeacherUid
            ? _value.classTeacherUid
            : classTeacherUid // ignore: cast_nullable_to_non_nullable
                  as String,
        proctorTeacherUid: null == proctorTeacherUid
            ? _value.proctorTeacherUid
            : proctorTeacherUid // ignore: cast_nullable_to_non_nullable
                  as String,
        subjectTeachers: null == subjectTeachers
            ? _value._subjectTeachers
            : subjectTeachers // ignore: cast_nullable_to_non_nullable
                  as List<SubjectTeacher>,
        studentCount: null == studentCount
            ? _value.studentCount
            : studentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassModelImpl implements _ClassModel {
  const _$ClassModelImpl({
    required this.classId,
    required this.schoolId,
    required this.name,
    this.section = '',
    this.classTeacherUid = '',
    this.proctorTeacherUid = '',
    final List<SubjectTeacher> subjectTeachers = const [],
    this.studentCount = 0,
    this.createdAt,
  }) : _subjectTeachers = subjectTeachers;

  factory _$ClassModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassModelImplFromJson(json);

  @override
  final String classId;
  @override
  final String schoolId;
  @override
  final String name;
  @override
  @JsonKey()
  final String section;
  @override
  @JsonKey()
  final String classTeacherUid;
  @override
  @JsonKey()
  final String proctorTeacherUid;
  final List<SubjectTeacher> _subjectTeachers;
  @override
  @JsonKey()
  List<SubjectTeacher> get subjectTeachers {
    if (_subjectTeachers is EqualUnmodifiableListView) return _subjectTeachers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjectTeachers);
  }

  @override
  @JsonKey()
  final int studentCount;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ClassModel(classId: $classId, schoolId: $schoolId, name: $name, section: $section, classTeacherUid: $classTeacherUid, proctorTeacherUid: $proctorTeacherUid, subjectTeachers: $subjectTeachers, studentCount: $studentCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassModelImpl &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.classTeacherUid, classTeacherUid) ||
                other.classTeacherUid == classTeacherUid) &&
            (identical(other.proctorTeacherUid, proctorTeacherUid) ||
                other.proctorTeacherUid == proctorTeacherUid) &&
            const DeepCollectionEquality().equals(
              other._subjectTeachers,
              _subjectTeachers,
            ) &&
            (identical(other.studentCount, studentCount) ||
                other.studentCount == studentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    classId,
    schoolId,
    name,
    section,
    classTeacherUid,
    proctorTeacherUid,
    const DeepCollectionEquality().hash(_subjectTeachers),
    studentCount,
    createdAt,
  );

  /// Create a copy of ClassModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassModelImplCopyWith<_$ClassModelImpl> get copyWith =>
      __$$ClassModelImplCopyWithImpl<_$ClassModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassModelImplToJson(this);
  }
}

abstract class _ClassModel implements ClassModel {
  const factory _ClassModel({
    required final String classId,
    required final String schoolId,
    required final String name,
    final String section,
    final String classTeacherUid,
    final String proctorTeacherUid,
    final List<SubjectTeacher> subjectTeachers,
    final int studentCount,
    final DateTime? createdAt,
  }) = _$ClassModelImpl;

  factory _ClassModel.fromJson(Map<String, dynamic> json) =
      _$ClassModelImpl.fromJson;

  @override
  String get classId;
  @override
  String get schoolId;
  @override
  String get name;
  @override
  String get section;
  @override
  String get classTeacherUid;
  @override
  String get proctorTeacherUid;
  @override
  List<SubjectTeacher> get subjectTeachers;
  @override
  int get studentCount;
  @override
  DateTime? get createdAt;

  /// Create a copy of ClassModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassModelImplCopyWith<_$ClassModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
