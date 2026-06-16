// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeaveRequest _$LeaveRequestFromJson(Map<String, dynamic> json) {
  return _LeaveRequest.fromJson(json);
}

/// @nodoc
mixin _$LeaveRequest {
  String get requestId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get classId => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get parentUid => throw _privateConstructorUsedError;
  DateTime get fromDate => throw _privateConstructorUsedError;
  DateTime get toDate => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get attachmentUrl => throw _privateConstructorUsedError;
  String get studentName => throw _privateConstructorUsedError;
  bool get isAbsentLetter => throw _privateConstructorUsedError;
  LeaveStatus get status => throw _privateConstructorUsedError;
  String get reviewedBy => throw _privateConstructorUsedError;
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  String get reviewNote => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LeaveRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveRequestCopyWith<LeaveRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveRequestCopyWith<$Res> {
  factory $LeaveRequestCopyWith(
    LeaveRequest value,
    $Res Function(LeaveRequest) then,
  ) = _$LeaveRequestCopyWithImpl<$Res, LeaveRequest>;
  @useResult
  $Res call({
    String requestId,
    String schoolId,
    String classId,
    String studentId,
    String parentUid,
    DateTime fromDate,
    DateTime toDate,
    String reason,
    String attachmentUrl,
    String studentName,
    bool isAbsentLetter,
    LeaveStatus status,
    String reviewedBy,
    DateTime? reviewedAt,
    String reviewNote,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$LeaveRequestCopyWithImpl<$Res, $Val extends LeaveRequest>
    implements $LeaveRequestCopyWith<$Res> {
  _$LeaveRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? schoolId = null,
    Object? classId = null,
    Object? studentId = null,
    Object? parentUid = null,
    Object? fromDate = null,
    Object? toDate = null,
    Object? reason = null,
    Object? attachmentUrl = null,
    Object? studentName = null,
    Object? isAbsentLetter = null,
    Object? status = null,
    Object? reviewedBy = null,
    Object? reviewedAt = freezed,
    Object? reviewNote = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            requestId: null == requestId
                ? _value.requestId
                : requestId // ignore: cast_nullable_to_non_nullable
                      as String,
            schoolId: null == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String,
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            parentUid: null == parentUid
                ? _value.parentUid
                : parentUid // ignore: cast_nullable_to_non_nullable
                      as String,
            fromDate: null == fromDate
                ? _value.fromDate
                : fromDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            toDate: null == toDate
                ? _value.toDate
                : toDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            attachmentUrl: null == attachmentUrl
                ? _value.attachmentUrl
                : attachmentUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            studentName: null == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String,
            isAbsentLetter: null == isAbsentLetter
                ? _value.isAbsentLetter
                : isAbsentLetter // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as LeaveStatus,
            reviewedBy: null == reviewedBy
                ? _value.reviewedBy
                : reviewedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            reviewedAt: freezed == reviewedAt
                ? _value.reviewedAt
                : reviewedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            reviewNote: null == reviewNote
                ? _value.reviewNote
                : reviewNote // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$LeaveRequestImplCopyWith<$Res>
    implements $LeaveRequestCopyWith<$Res> {
  factory _$$LeaveRequestImplCopyWith(
    _$LeaveRequestImpl value,
    $Res Function(_$LeaveRequestImpl) then,
  ) = __$$LeaveRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String requestId,
    String schoolId,
    String classId,
    String studentId,
    String parentUid,
    DateTime fromDate,
    DateTime toDate,
    String reason,
    String attachmentUrl,
    String studentName,
    bool isAbsentLetter,
    LeaveStatus status,
    String reviewedBy,
    DateTime? reviewedAt,
    String reviewNote,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$LeaveRequestImplCopyWithImpl<$Res>
    extends _$LeaveRequestCopyWithImpl<$Res, _$LeaveRequestImpl>
    implements _$$LeaveRequestImplCopyWith<$Res> {
  __$$LeaveRequestImplCopyWithImpl(
    _$LeaveRequestImpl _value,
    $Res Function(_$LeaveRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? schoolId = null,
    Object? classId = null,
    Object? studentId = null,
    Object? parentUid = null,
    Object? fromDate = null,
    Object? toDate = null,
    Object? reason = null,
    Object? attachmentUrl = null,
    Object? studentName = null,
    Object? isAbsentLetter = null,
    Object? status = null,
    Object? reviewedBy = null,
    Object? reviewedAt = freezed,
    Object? reviewNote = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$LeaveRequestImpl(
        requestId: null == requestId
            ? _value.requestId
            : requestId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        parentUid: null == parentUid
            ? _value.parentUid
            : parentUid // ignore: cast_nullable_to_non_nullable
                  as String,
        fromDate: null == fromDate
            ? _value.fromDate
            : fromDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        toDate: null == toDate
            ? _value.toDate
            : toDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        attachmentUrl: null == attachmentUrl
            ? _value.attachmentUrl
            : attachmentUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        studentName: null == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String,
        isAbsentLetter: null == isAbsentLetter
            ? _value.isAbsentLetter
            : isAbsentLetter // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as LeaveStatus,
        reviewedBy: null == reviewedBy
            ? _value.reviewedBy
            : reviewedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        reviewedAt: freezed == reviewedAt
            ? _value.reviewedAt
            : reviewedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        reviewNote: null == reviewNote
            ? _value.reviewNote
            : reviewNote // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$LeaveRequestImpl implements _LeaveRequest {
  const _$LeaveRequestImpl({
    required this.requestId,
    required this.schoolId,
    required this.classId,
    required this.studentId,
    required this.parentUid,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    this.attachmentUrl = '',
    this.studentName = '',
    this.isAbsentLetter = false,
    this.status = LeaveStatus.PENDING,
    this.reviewedBy = '',
    this.reviewedAt,
    this.reviewNote = '',
    this.createdAt,
  });

  factory _$LeaveRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveRequestImplFromJson(json);

  @override
  final String requestId;
  @override
  final String schoolId;
  @override
  final String classId;
  @override
  final String studentId;
  @override
  final String parentUid;
  @override
  final DateTime fromDate;
  @override
  final DateTime toDate;
  @override
  final String reason;
  @override
  @JsonKey()
  final String attachmentUrl;
  @override
  @JsonKey()
  final String studentName;
  @override
  @JsonKey()
  final bool isAbsentLetter;
  @override
  @JsonKey()
  final LeaveStatus status;
  @override
  @JsonKey()
  final String reviewedBy;
  @override
  final DateTime? reviewedAt;
  @override
  @JsonKey()
  final String reviewNote;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'LeaveRequest(requestId: $requestId, schoolId: $schoolId, classId: $classId, studentId: $studentId, parentUid: $parentUid, fromDate: $fromDate, toDate: $toDate, reason: $reason, attachmentUrl: $attachmentUrl, studentName: $studentName, isAbsentLetter: $isAbsentLetter, status: $status, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, reviewNote: $reviewNote, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveRequestImpl &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.parentUid, parentUid) ||
                other.parentUid == parentUid) &&
            (identical(other.fromDate, fromDate) ||
                other.fromDate == fromDate) &&
            (identical(other.toDate, toDate) || other.toDate == toDate) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.attachmentUrl, attachmentUrl) ||
                other.attachmentUrl == attachmentUrl) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.isAbsentLetter, isAbsentLetter) ||
                other.isAbsentLetter == isAbsentLetter) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.reviewNote, reviewNote) ||
                other.reviewNote == reviewNote) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    requestId,
    schoolId,
    classId,
    studentId,
    parentUid,
    fromDate,
    toDate,
    reason,
    attachmentUrl,
    studentName,
    isAbsentLetter,
    status,
    reviewedBy,
    reviewedAt,
    reviewNote,
    createdAt,
  );

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveRequestImplCopyWith<_$LeaveRequestImpl> get copyWith =>
      __$$LeaveRequestImplCopyWithImpl<_$LeaveRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveRequestImplToJson(this);
  }
}

abstract class _LeaveRequest implements LeaveRequest {
  const factory _LeaveRequest({
    required final String requestId,
    required final String schoolId,
    required final String classId,
    required final String studentId,
    required final String parentUid,
    required final DateTime fromDate,
    required final DateTime toDate,
    required final String reason,
    final String attachmentUrl,
    final String studentName,
    final bool isAbsentLetter,
    final LeaveStatus status,
    final String reviewedBy,
    final DateTime? reviewedAt,
    final String reviewNote,
    final DateTime? createdAt,
  }) = _$LeaveRequestImpl;

  factory _LeaveRequest.fromJson(Map<String, dynamic> json) =
      _$LeaveRequestImpl.fromJson;

  @override
  String get requestId;
  @override
  String get schoolId;
  @override
  String get classId;
  @override
  String get studentId;
  @override
  String get parentUid;
  @override
  DateTime get fromDate;
  @override
  DateTime get toDate;
  @override
  String get reason;
  @override
  String get attachmentUrl;
  @override
  String get studentName;
  @override
  bool get isAbsentLetter;
  @override
  LeaveStatus get status;
  @override
  String get reviewedBy;
  @override
  DateTime? get reviewedAt;
  @override
  String get reviewNote;
  @override
  DateTime? get createdAt;

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveRequestImplCopyWith<_$LeaveRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
