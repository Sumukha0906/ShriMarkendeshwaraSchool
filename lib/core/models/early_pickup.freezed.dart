// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'early_pickup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CollectorDetails _$CollectorDetailsFromJson(Map<String, dynamic> json) {
  return _CollectorDetails.fromJson(json);
}

/// @nodoc
mixin _$CollectorDetails {
  String get name => throw _privateConstructorUsedError;
  String get relation => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get photoUrl => throw _privateConstructorUsedError;

  /// Serializes this CollectorDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollectorDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectorDetailsCopyWith<CollectorDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectorDetailsCopyWith<$Res> {
  factory $CollectorDetailsCopyWith(
    CollectorDetails value,
    $Res Function(CollectorDetails) then,
  ) = _$CollectorDetailsCopyWithImpl<$Res, CollectorDetails>;
  @useResult
  $Res call({String name, String relation, String phone, String photoUrl});
}

/// @nodoc
class _$CollectorDetailsCopyWithImpl<$Res, $Val extends CollectorDetails>
    implements $CollectorDetailsCopyWith<$Res> {
  _$CollectorDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectorDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? relation = null,
    Object? phone = null,
    Object? photoUrl = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            relation: null == relation
                ? _value.relation
                : relation // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: null == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CollectorDetailsImplCopyWith<$Res>
    implements $CollectorDetailsCopyWith<$Res> {
  factory _$$CollectorDetailsImplCopyWith(
    _$CollectorDetailsImpl value,
    $Res Function(_$CollectorDetailsImpl) then,
  ) = __$$CollectorDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String relation, String phone, String photoUrl});
}

/// @nodoc
class __$$CollectorDetailsImplCopyWithImpl<$Res>
    extends _$CollectorDetailsCopyWithImpl<$Res, _$CollectorDetailsImpl>
    implements _$$CollectorDetailsImplCopyWith<$Res> {
  __$$CollectorDetailsImplCopyWithImpl(
    _$CollectorDetailsImpl _value,
    $Res Function(_$CollectorDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CollectorDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? relation = null,
    Object? phone = null,
    Object? photoUrl = null,
  }) {
    return _then(
      _$CollectorDetailsImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        relation: null == relation
            ? _value.relation
            : relation // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: null == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollectorDetailsImpl extends _CollectorDetails {
  const _$CollectorDetailsImpl({
    required this.name,
    required this.relation,
    required this.phone,
    this.photoUrl = '',
  }) : super._();

  factory _$CollectorDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectorDetailsImplFromJson(json);

  @override
  final String name;
  @override
  final String relation;
  @override
  final String phone;
  @override
  @JsonKey()
  final String photoUrl;

  @override
  String toString() {
    return 'CollectorDetails(name: $name, relation: $relation, phone: $phone, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectorDetailsImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.relation, relation) ||
                other.relation == relation) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, relation, phone, photoUrl);

  /// Create a copy of CollectorDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectorDetailsImplCopyWith<_$CollectorDetailsImpl> get copyWith =>
      __$$CollectorDetailsImplCopyWithImpl<_$CollectorDetailsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectorDetailsImplToJson(this);
  }
}

abstract class _CollectorDetails extends CollectorDetails {
  const factory _CollectorDetails({
    required final String name,
    required final String relation,
    required final String phone,
    final String photoUrl,
  }) = _$CollectorDetailsImpl;
  const _CollectorDetails._() : super._();

  factory _CollectorDetails.fromJson(Map<String, dynamic> json) =
      _$CollectorDetailsImpl.fromJson;

  @override
  String get name;
  @override
  String get relation;
  @override
  String get phone;
  @override
  String get photoUrl;

  /// Create a copy of CollectorDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectorDetailsImplCopyWith<_$CollectorDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EarlyPickup _$EarlyPickupFromJson(Map<String, dynamic> json) {
  return _EarlyPickup.fromJson(json);
}

/// @nodoc
mixin _$EarlyPickup {
  String get requestId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get classId => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get parentUid => throw _privateConstructorUsedError;
  String get studentName => throw _privateConstructorUsedError;
  DateTime get pickupTime => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  CollectorDetails get collectorDetails => throw _privateConstructorUsedError;
  PickupStatus get status => throw _privateConstructorUsedError;
  String get approvedBy => throw _privateConstructorUsedError;
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  DateTime? get exitLoggedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this EarlyPickup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EarlyPickup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EarlyPickupCopyWith<EarlyPickup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EarlyPickupCopyWith<$Res> {
  factory $EarlyPickupCopyWith(
    EarlyPickup value,
    $Res Function(EarlyPickup) then,
  ) = _$EarlyPickupCopyWithImpl<$Res, EarlyPickup>;
  @useResult
  $Res call({
    String requestId,
    String schoolId,
    String classId,
    String studentId,
    String parentUid,
    String studentName,
    DateTime pickupTime,
    String reason,
    CollectorDetails collectorDetails,
    PickupStatus status,
    String approvedBy,
    DateTime? approvedAt,
    DateTime? exitLoggedAt,
    DateTime? createdAt,
  });

  $CollectorDetailsCopyWith<$Res> get collectorDetails;
}

/// @nodoc
class _$EarlyPickupCopyWithImpl<$Res, $Val extends EarlyPickup>
    implements $EarlyPickupCopyWith<$Res> {
  _$EarlyPickupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EarlyPickup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? schoolId = null,
    Object? classId = null,
    Object? studentId = null,
    Object? parentUid = null,
    Object? studentName = null,
    Object? pickupTime = null,
    Object? reason = null,
    Object? collectorDetails = null,
    Object? status = null,
    Object? approvedBy = null,
    Object? approvedAt = freezed,
    Object? exitLoggedAt = freezed,
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
            studentName: null == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String,
            pickupTime: null == pickupTime
                ? _value.pickupTime
                : pickupTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            collectorDetails: null == collectorDetails
                ? _value.collectorDetails
                : collectorDetails // ignore: cast_nullable_to_non_nullable
                      as CollectorDetails,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PickupStatus,
            approvedBy: null == approvedBy
                ? _value.approvedBy
                : approvedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            approvedAt: freezed == approvedAt
                ? _value.approvedAt
                : approvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            exitLoggedAt: freezed == exitLoggedAt
                ? _value.exitLoggedAt
                : exitLoggedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of EarlyPickup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CollectorDetailsCopyWith<$Res> get collectorDetails {
    return $CollectorDetailsCopyWith<$Res>(_value.collectorDetails, (value) {
      return _then(_value.copyWith(collectorDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EarlyPickupImplCopyWith<$Res>
    implements $EarlyPickupCopyWith<$Res> {
  factory _$$EarlyPickupImplCopyWith(
    _$EarlyPickupImpl value,
    $Res Function(_$EarlyPickupImpl) then,
  ) = __$$EarlyPickupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String requestId,
    String schoolId,
    String classId,
    String studentId,
    String parentUid,
    String studentName,
    DateTime pickupTime,
    String reason,
    CollectorDetails collectorDetails,
    PickupStatus status,
    String approvedBy,
    DateTime? approvedAt,
    DateTime? exitLoggedAt,
    DateTime? createdAt,
  });

  @override
  $CollectorDetailsCopyWith<$Res> get collectorDetails;
}

/// @nodoc
class __$$EarlyPickupImplCopyWithImpl<$Res>
    extends _$EarlyPickupCopyWithImpl<$Res, _$EarlyPickupImpl>
    implements _$$EarlyPickupImplCopyWith<$Res> {
  __$$EarlyPickupImplCopyWithImpl(
    _$EarlyPickupImpl _value,
    $Res Function(_$EarlyPickupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EarlyPickup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? schoolId = null,
    Object? classId = null,
    Object? studentId = null,
    Object? parentUid = null,
    Object? studentName = null,
    Object? pickupTime = null,
    Object? reason = null,
    Object? collectorDetails = null,
    Object? status = null,
    Object? approvedBy = null,
    Object? approvedAt = freezed,
    Object? exitLoggedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$EarlyPickupImpl(
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
        studentName: null == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String,
        pickupTime: null == pickupTime
            ? _value.pickupTime
            : pickupTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        collectorDetails: null == collectorDetails
            ? _value.collectorDetails
            : collectorDetails // ignore: cast_nullable_to_non_nullable
                  as CollectorDetails,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PickupStatus,
        approvedBy: null == approvedBy
            ? _value.approvedBy
            : approvedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        approvedAt: freezed == approvedAt
            ? _value.approvedAt
            : approvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        exitLoggedAt: freezed == exitLoggedAt
            ? _value.exitLoggedAt
            : exitLoggedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$EarlyPickupImpl extends _EarlyPickup {
  const _$EarlyPickupImpl({
    required this.requestId,
    required this.schoolId,
    required this.classId,
    required this.studentId,
    required this.parentUid,
    this.studentName = '',
    required this.pickupTime,
    required this.reason,
    required this.collectorDetails,
    this.status = PickupStatus.PENDING,
    this.approvedBy = '',
    this.approvedAt,
    this.exitLoggedAt,
    this.createdAt,
  }) : super._();

  factory _$EarlyPickupImpl.fromJson(Map<String, dynamic> json) =>
      _$$EarlyPickupImplFromJson(json);

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
  @JsonKey()
  final String studentName;
  @override
  final DateTime pickupTime;
  @override
  final String reason;
  @override
  final CollectorDetails collectorDetails;
  @override
  @JsonKey()
  final PickupStatus status;
  @override
  @JsonKey()
  final String approvedBy;
  @override
  final DateTime? approvedAt;
  @override
  final DateTime? exitLoggedAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'EarlyPickup(requestId: $requestId, schoolId: $schoolId, classId: $classId, studentId: $studentId, parentUid: $parentUid, studentName: $studentName, pickupTime: $pickupTime, reason: $reason, collectorDetails: $collectorDetails, status: $status, approvedBy: $approvedBy, approvedAt: $approvedAt, exitLoggedAt: $exitLoggedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EarlyPickupImpl &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.parentUid, parentUid) ||
                other.parentUid == parentUid) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.pickupTime, pickupTime) ||
                other.pickupTime == pickupTime) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.collectorDetails, collectorDetails) ||
                other.collectorDetails == collectorDetails) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.exitLoggedAt, exitLoggedAt) ||
                other.exitLoggedAt == exitLoggedAt) &&
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
    studentName,
    pickupTime,
    reason,
    collectorDetails,
    status,
    approvedBy,
    approvedAt,
    exitLoggedAt,
    createdAt,
  );

  /// Create a copy of EarlyPickup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EarlyPickupImplCopyWith<_$EarlyPickupImpl> get copyWith =>
      __$$EarlyPickupImplCopyWithImpl<_$EarlyPickupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EarlyPickupImplToJson(this);
  }
}

abstract class _EarlyPickup extends EarlyPickup {
  const factory _EarlyPickup({
    required final String requestId,
    required final String schoolId,
    required final String classId,
    required final String studentId,
    required final String parentUid,
    final String studentName,
    required final DateTime pickupTime,
    required final String reason,
    required final CollectorDetails collectorDetails,
    final PickupStatus status,
    final String approvedBy,
    final DateTime? approvedAt,
    final DateTime? exitLoggedAt,
    final DateTime? createdAt,
  }) = _$EarlyPickupImpl;
  const _EarlyPickup._() : super._();

  factory _EarlyPickup.fromJson(Map<String, dynamic> json) =
      _$EarlyPickupImpl.fromJson;

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
  String get studentName;
  @override
  DateTime get pickupTime;
  @override
  String get reason;
  @override
  CollectorDetails get collectorDetails;
  @override
  PickupStatus get status;
  @override
  String get approvedBy;
  @override
  DateTime? get approvedAt;
  @override
  DateTime? get exitLoggedAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of EarlyPickup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EarlyPickupImplCopyWith<_$EarlyPickupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
