// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LessonPlan _$LessonPlanFromJson(Map<String, dynamic> json) {
  return _LessonPlan.fromJson(json);
}

/// @nodoc
mixin _$LessonPlan {
  String get planId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get classId => throw _privateConstructorUsedError;
  String get teacherUid => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get topicsCovered => throw _privateConstructorUsedError;
  String get homework => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  bool get notificationSent => throw _privateConstructorUsedError;
  List<String> get attachmentUrls => throw _privateConstructorUsedError;
  List<String> get attachmentNames => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LessonPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LessonPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonPlanCopyWith<LessonPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonPlanCopyWith<$Res> {
  factory $LessonPlanCopyWith(
    LessonPlan value,
    $Res Function(LessonPlan) then,
  ) = _$LessonPlanCopyWithImpl<$Res, LessonPlan>;
  @useResult
  $Res call({
    String planId,
    String schoolId,
    String classId,
    String teacherUid,
    String subject,
    DateTime date,
    String topicsCovered,
    String homework,
    String notes,
    bool notificationSent,
    List<String> attachmentUrls,
    List<String> attachmentNames,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$LessonPlanCopyWithImpl<$Res, $Val extends LessonPlan>
    implements $LessonPlanCopyWith<$Res> {
  _$LessonPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LessonPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planId = null,
    Object? schoolId = null,
    Object? classId = null,
    Object? teacherUid = null,
    Object? subject = null,
    Object? date = null,
    Object? topicsCovered = null,
    Object? homework = null,
    Object? notes = null,
    Object? notificationSent = null,
    Object? attachmentUrls = null,
    Object? attachmentNames = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            planId: null == planId
                ? _value.planId
                : planId // ignore: cast_nullable_to_non_nullable
                      as String,
            schoolId: null == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String,
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            teacherUid: null == teacherUid
                ? _value.teacherUid
                : teacherUid // ignore: cast_nullable_to_non_nullable
                      as String,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            topicsCovered: null == topicsCovered
                ? _value.topicsCovered
                : topicsCovered // ignore: cast_nullable_to_non_nullable
                      as String,
            homework: null == homework
                ? _value.homework
                : homework // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            notificationSent: null == notificationSent
                ? _value.notificationSent
                : notificationSent // ignore: cast_nullable_to_non_nullable
                      as bool,
            attachmentUrls: null == attachmentUrls
                ? _value.attachmentUrls
                : attachmentUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            attachmentNames: null == attachmentNames
                ? _value.attachmentNames
                : attachmentNames // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
abstract class _$$LessonPlanImplCopyWith<$Res>
    implements $LessonPlanCopyWith<$Res> {
  factory _$$LessonPlanImplCopyWith(
    _$LessonPlanImpl value,
    $Res Function(_$LessonPlanImpl) then,
  ) = __$$LessonPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String planId,
    String schoolId,
    String classId,
    String teacherUid,
    String subject,
    DateTime date,
    String topicsCovered,
    String homework,
    String notes,
    bool notificationSent,
    List<String> attachmentUrls,
    List<String> attachmentNames,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$LessonPlanImplCopyWithImpl<$Res>
    extends _$LessonPlanCopyWithImpl<$Res, _$LessonPlanImpl>
    implements _$$LessonPlanImplCopyWith<$Res> {
  __$$LessonPlanImplCopyWithImpl(
    _$LessonPlanImpl _value,
    $Res Function(_$LessonPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LessonPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planId = null,
    Object? schoolId = null,
    Object? classId = null,
    Object? teacherUid = null,
    Object? subject = null,
    Object? date = null,
    Object? topicsCovered = null,
    Object? homework = null,
    Object? notes = null,
    Object? notificationSent = null,
    Object? attachmentUrls = null,
    Object? attachmentNames = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$LessonPlanImpl(
        planId: null == planId
            ? _value.planId
            : planId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherUid: null == teacherUid
            ? _value.teacherUid
            : teacherUid // ignore: cast_nullable_to_non_nullable
                  as String,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        topicsCovered: null == topicsCovered
            ? _value.topicsCovered
            : topicsCovered // ignore: cast_nullable_to_non_nullable
                  as String,
        homework: null == homework
            ? _value.homework
            : homework // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        notificationSent: null == notificationSent
            ? _value.notificationSent
            : notificationSent // ignore: cast_nullable_to_non_nullable
                  as bool,
        attachmentUrls: null == attachmentUrls
            ? _value._attachmentUrls
            : attachmentUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        attachmentNames: null == attachmentNames
            ? _value._attachmentNames
            : attachmentNames // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
class _$LessonPlanImpl implements _LessonPlan {
  const _$LessonPlanImpl({
    required this.planId,
    required this.schoolId,
    required this.classId,
    required this.teacherUid,
    required this.subject,
    required this.date,
    required this.topicsCovered,
    this.homework = '',
    this.notes = '',
    this.notificationSent = false,
    final List<String> attachmentUrls = const [],
    final List<String> attachmentNames = const [],
    this.createdAt,
  }) : _attachmentUrls = attachmentUrls,
       _attachmentNames = attachmentNames;

  factory _$LessonPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonPlanImplFromJson(json);

  @override
  final String planId;
  @override
  final String schoolId;
  @override
  final String classId;
  @override
  final String teacherUid;
  @override
  final String subject;
  @override
  final DateTime date;
  @override
  final String topicsCovered;
  @override
  @JsonKey()
  final String homework;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey()
  final bool notificationSent;
  final List<String> _attachmentUrls;
  @override
  @JsonKey()
  List<String> get attachmentUrls {
    if (_attachmentUrls is EqualUnmodifiableListView) return _attachmentUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachmentUrls);
  }

  final List<String> _attachmentNames;
  @override
  @JsonKey()
  List<String> get attachmentNames {
    if (_attachmentNames is EqualUnmodifiableListView) return _attachmentNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachmentNames);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'LessonPlan(planId: $planId, schoolId: $schoolId, classId: $classId, teacherUid: $teacherUid, subject: $subject, date: $date, topicsCovered: $topicsCovered, homework: $homework, notes: $notes, notificationSent: $notificationSent, attachmentUrls: $attachmentUrls, attachmentNames: $attachmentNames, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonPlanImpl &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.teacherUid, teacherUid) ||
                other.teacherUid == teacherUid) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.topicsCovered, topicsCovered) ||
                other.topicsCovered == topicsCovered) &&
            (identical(other.homework, homework) ||
                other.homework == homework) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.notificationSent, notificationSent) ||
                other.notificationSent == notificationSent) &&
            const DeepCollectionEquality().equals(
              other._attachmentUrls,
              _attachmentUrls,
            ) &&
            const DeepCollectionEquality().equals(
              other._attachmentNames,
              _attachmentNames,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    planId,
    schoolId,
    classId,
    teacherUid,
    subject,
    date,
    topicsCovered,
    homework,
    notes,
    notificationSent,
    const DeepCollectionEquality().hash(_attachmentUrls),
    const DeepCollectionEquality().hash(_attachmentNames),
    createdAt,
  );

  /// Create a copy of LessonPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonPlanImplCopyWith<_$LessonPlanImpl> get copyWith =>
      __$$LessonPlanImplCopyWithImpl<_$LessonPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonPlanImplToJson(this);
  }
}

abstract class _LessonPlan implements LessonPlan {
  const factory _LessonPlan({
    required final String planId,
    required final String schoolId,
    required final String classId,
    required final String teacherUid,
    required final String subject,
    required final DateTime date,
    required final String topicsCovered,
    final String homework,
    final String notes,
    final bool notificationSent,
    final List<String> attachmentUrls,
    final List<String> attachmentNames,
    final DateTime? createdAt,
  }) = _$LessonPlanImpl;

  factory _LessonPlan.fromJson(Map<String, dynamic> json) =
      _$LessonPlanImpl.fromJson;

  @override
  String get planId;
  @override
  String get schoolId;
  @override
  String get classId;
  @override
  String get teacherUid;
  @override
  String get subject;
  @override
  DateTime get date;
  @override
  String get topicsCovered;
  @override
  String get homework;
  @override
  String get notes;
  @override
  bool get notificationSent;
  @override
  List<String> get attachmentUrls;
  @override
  List<String> get attachmentNames;
  @override
  DateTime? get createdAt;

  /// Create a copy of LessonPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonPlanImplCopyWith<_$LessonPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
