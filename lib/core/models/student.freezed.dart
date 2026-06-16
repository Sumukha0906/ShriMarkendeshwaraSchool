// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) {
  return _EmergencyContact.fromJson(json);
}

/// @nodoc
mixin _$EmergencyContact {
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get relation => throw _privateConstructorUsedError;

  /// Serializes this EmergencyContact to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmergencyContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmergencyContactCopyWith<EmergencyContact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmergencyContactCopyWith<$Res> {
  factory $EmergencyContactCopyWith(
    EmergencyContact value,
    $Res Function(EmergencyContact) then,
  ) = _$EmergencyContactCopyWithImpl<$Res, EmergencyContact>;
  @useResult
  $Res call({String name, String phone, String relation});
}

/// @nodoc
class _$EmergencyContactCopyWithImpl<$Res, $Val extends EmergencyContact>
    implements $EmergencyContactCopyWith<$Res> {
  _$EmergencyContactCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmergencyContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? phone = null,
    Object? relation = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            relation: null == relation
                ? _value.relation
                : relation // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmergencyContactImplCopyWith<$Res>
    implements $EmergencyContactCopyWith<$Res> {
  factory _$$EmergencyContactImplCopyWith(
    _$EmergencyContactImpl value,
    $Res Function(_$EmergencyContactImpl) then,
  ) = __$$EmergencyContactImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String phone, String relation});
}

/// @nodoc
class __$$EmergencyContactImplCopyWithImpl<$Res>
    extends _$EmergencyContactCopyWithImpl<$Res, _$EmergencyContactImpl>
    implements _$$EmergencyContactImplCopyWith<$Res> {
  __$$EmergencyContactImplCopyWithImpl(
    _$EmergencyContactImpl _value,
    $Res Function(_$EmergencyContactImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmergencyContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? phone = null,
    Object? relation = null,
  }) {
    return _then(
      _$EmergencyContactImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        relation: null == relation
            ? _value.relation
            : relation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EmergencyContactImpl implements _EmergencyContact {
  const _$EmergencyContactImpl({
    required this.name,
    required this.phone,
    this.relation = '',
  });

  factory _$EmergencyContactImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmergencyContactImplFromJson(json);

  @override
  final String name;
  @override
  final String phone;
  @override
  @JsonKey()
  final String relation;

  @override
  String toString() {
    return 'EmergencyContact(name: $name, phone: $phone, relation: $relation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmergencyContactImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.relation, relation) ||
                other.relation == relation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, phone, relation);

  /// Create a copy of EmergencyContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmergencyContactImplCopyWith<_$EmergencyContactImpl> get copyWith =>
      __$$EmergencyContactImplCopyWithImpl<_$EmergencyContactImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EmergencyContactImplToJson(this);
  }
}

abstract class _EmergencyContact implements EmergencyContact {
  const factory _EmergencyContact({
    required final String name,
    required final String phone,
    final String relation,
  }) = _$EmergencyContactImpl;

  factory _EmergencyContact.fromJson(Map<String, dynamic> json) =
      _$EmergencyContactImpl.fromJson;

  @override
  String get name;
  @override
  String get phone;
  @override
  String get relation;

  /// Create a copy of EmergencyContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmergencyContactImplCopyWith<_$EmergencyContactImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MedicalHistory _$MedicalHistoryFromJson(Map<String, dynamic> json) {
  return _MedicalHistory.fromJson(json);
}

/// @nodoc
mixin _$MedicalHistory {
  String get bloodGroup => throw _privateConstructorUsedError;
  List<String> get allergies => throw _privateConstructorUsedError;
  List<String> get conditions => throw _privateConstructorUsedError;
  String get vaccinationNotes => throw _privateConstructorUsedError;
  EmergencyContact? get emergencyContact => throw _privateConstructorUsedError;

  /// Serializes this MedicalHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicalHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicalHistoryCopyWith<MedicalHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicalHistoryCopyWith<$Res> {
  factory $MedicalHistoryCopyWith(
    MedicalHistory value,
    $Res Function(MedicalHistory) then,
  ) = _$MedicalHistoryCopyWithImpl<$Res, MedicalHistory>;
  @useResult
  $Res call({
    String bloodGroup,
    List<String> allergies,
    List<String> conditions,
    String vaccinationNotes,
    EmergencyContact? emergencyContact,
  });

  $EmergencyContactCopyWith<$Res>? get emergencyContact;
}

/// @nodoc
class _$MedicalHistoryCopyWithImpl<$Res, $Val extends MedicalHistory>
    implements $MedicalHistoryCopyWith<$Res> {
  _$MedicalHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicalHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bloodGroup = null,
    Object? allergies = null,
    Object? conditions = null,
    Object? vaccinationNotes = null,
    Object? emergencyContact = freezed,
  }) {
    return _then(
      _value.copyWith(
            bloodGroup: null == bloodGroup
                ? _value.bloodGroup
                : bloodGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            allergies: null == allergies
                ? _value.allergies
                : allergies // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            conditions: null == conditions
                ? _value.conditions
                : conditions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            vaccinationNotes: null == vaccinationNotes
                ? _value.vaccinationNotes
                : vaccinationNotes // ignore: cast_nullable_to_non_nullable
                      as String,
            emergencyContact: freezed == emergencyContact
                ? _value.emergencyContact
                : emergencyContact // ignore: cast_nullable_to_non_nullable
                      as EmergencyContact?,
          )
          as $Val,
    );
  }

  /// Create a copy of MedicalHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EmergencyContactCopyWith<$Res>? get emergencyContact {
    if (_value.emergencyContact == null) {
      return null;
    }

    return $EmergencyContactCopyWith<$Res>(_value.emergencyContact!, (value) {
      return _then(_value.copyWith(emergencyContact: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MedicalHistoryImplCopyWith<$Res>
    implements $MedicalHistoryCopyWith<$Res> {
  factory _$$MedicalHistoryImplCopyWith(
    _$MedicalHistoryImpl value,
    $Res Function(_$MedicalHistoryImpl) then,
  ) = __$$MedicalHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String bloodGroup,
    List<String> allergies,
    List<String> conditions,
    String vaccinationNotes,
    EmergencyContact? emergencyContact,
  });

  @override
  $EmergencyContactCopyWith<$Res>? get emergencyContact;
}

/// @nodoc
class __$$MedicalHistoryImplCopyWithImpl<$Res>
    extends _$MedicalHistoryCopyWithImpl<$Res, _$MedicalHistoryImpl>
    implements _$$MedicalHistoryImplCopyWith<$Res> {
  __$$MedicalHistoryImplCopyWithImpl(
    _$MedicalHistoryImpl _value,
    $Res Function(_$MedicalHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicalHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bloodGroup = null,
    Object? allergies = null,
    Object? conditions = null,
    Object? vaccinationNotes = null,
    Object? emergencyContact = freezed,
  }) {
    return _then(
      _$MedicalHistoryImpl(
        bloodGroup: null == bloodGroup
            ? _value.bloodGroup
            : bloodGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        allergies: null == allergies
            ? _value._allergies
            : allergies // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        conditions: null == conditions
            ? _value._conditions
            : conditions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        vaccinationNotes: null == vaccinationNotes
            ? _value.vaccinationNotes
            : vaccinationNotes // ignore: cast_nullable_to_non_nullable
                  as String,
        emergencyContact: freezed == emergencyContact
            ? _value.emergencyContact
            : emergencyContact // ignore: cast_nullable_to_non_nullable
                  as EmergencyContact?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicalHistoryImpl implements _MedicalHistory {
  const _$MedicalHistoryImpl({
    this.bloodGroup = '',
    final List<String> allergies = const [],
    final List<String> conditions = const [],
    this.vaccinationNotes = '',
    this.emergencyContact,
  }) : _allergies = allergies,
       _conditions = conditions;

  factory _$MedicalHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicalHistoryImplFromJson(json);

  @override
  @JsonKey()
  final String bloodGroup;
  final List<String> _allergies;
  @override
  @JsonKey()
  List<String> get allergies {
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergies);
  }

  final List<String> _conditions;
  @override
  @JsonKey()
  List<String> get conditions {
    if (_conditions is EqualUnmodifiableListView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conditions);
  }

  @override
  @JsonKey()
  final String vaccinationNotes;
  @override
  final EmergencyContact? emergencyContact;

  @override
  String toString() {
    return 'MedicalHistory(bloodGroup: $bloodGroup, allergies: $allergies, conditions: $conditions, vaccinationNotes: $vaccinationNotes, emergencyContact: $emergencyContact)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicalHistoryImpl &&
            (identical(other.bloodGroup, bloodGroup) ||
                other.bloodGroup == bloodGroup) &&
            const DeepCollectionEquality().equals(
              other._allergies,
              _allergies,
            ) &&
            const DeepCollectionEquality().equals(
              other._conditions,
              _conditions,
            ) &&
            (identical(other.vaccinationNotes, vaccinationNotes) ||
                other.vaccinationNotes == vaccinationNotes) &&
            (identical(other.emergencyContact, emergencyContact) ||
                other.emergencyContact == emergencyContact));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    bloodGroup,
    const DeepCollectionEquality().hash(_allergies),
    const DeepCollectionEquality().hash(_conditions),
    vaccinationNotes,
    emergencyContact,
  );

  /// Create a copy of MedicalHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicalHistoryImplCopyWith<_$MedicalHistoryImpl> get copyWith =>
      __$$MedicalHistoryImplCopyWithImpl<_$MedicalHistoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicalHistoryImplToJson(this);
  }
}

abstract class _MedicalHistory implements MedicalHistory {
  const factory _MedicalHistory({
    final String bloodGroup,
    final List<String> allergies,
    final List<String> conditions,
    final String vaccinationNotes,
    final EmergencyContact? emergencyContact,
  }) = _$MedicalHistoryImpl;

  factory _MedicalHistory.fromJson(Map<String, dynamic> json) =
      _$MedicalHistoryImpl.fromJson;

  @override
  String get bloodGroup;
  @override
  List<String> get allergies;
  @override
  List<String> get conditions;
  @override
  String get vaccinationNotes;
  @override
  EmergencyContact? get emergencyContact;

  /// Create a copy of MedicalHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicalHistoryImplCopyWith<_$MedicalHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Student _$StudentFromJson(Map<String, dynamic> json) {
  return _Student.fromJson(json);
}

/// @nodoc
mixin _$Student {
  String get studentId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get classId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get rollNo => throw _privateConstructorUsedError;
  String get admissionNo => throw _privateConstructorUsedError;
  String get dob => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get photoUrl => throw _privateConstructorUsedError;
  String get parentUid => throw _privateConstructorUsedError;
  MedicalHistory get medicalHistory => throw _privateConstructorUsedError;
  String get academicYear => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Free-text class label entered at registration (e.g. "Class 5A").
  String get admissionClass => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Student to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentCopyWith<Student> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentCopyWith<$Res> {
  factory $StudentCopyWith(Student value, $Res Function(Student) then) =
      _$StudentCopyWithImpl<$Res, Student>;
  @useResult
  $Res call({
    String studentId,
    String schoolId,
    String classId,
    String name,
    String rollNo,
    String admissionNo,
    String dob,
    String gender,
    String address,
    String photoUrl,
    String parentUid,
    MedicalHistory medicalHistory,
    String academicYear,
    bool isActive,
    String admissionClass,
    DateTime? createdAt,
  });

  $MedicalHistoryCopyWith<$Res> get medicalHistory;
}

/// @nodoc
class _$StudentCopyWithImpl<$Res, $Val extends Student>
    implements $StudentCopyWith<$Res> {
  _$StudentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? schoolId = null,
    Object? classId = null,
    Object? name = null,
    Object? rollNo = null,
    Object? admissionNo = null,
    Object? dob = null,
    Object? gender = null,
    Object? address = null,
    Object? photoUrl = null,
    Object? parentUid = null,
    Object? medicalHistory = null,
    Object? academicYear = null,
    Object? isActive = null,
    Object? admissionClass = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            schoolId: null == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String,
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            rollNo: null == rollNo
                ? _value.rollNo
                : rollNo // ignore: cast_nullable_to_non_nullable
                      as String,
            admissionNo: null == admissionNo
                ? _value.admissionNo
                : admissionNo // ignore: cast_nullable_to_non_nullable
                      as String,
            dob: null == dob
                ? _value.dob
                : dob // ignore: cast_nullable_to_non_nullable
                      as String,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: null == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            parentUid: null == parentUid
                ? _value.parentUid
                : parentUid // ignore: cast_nullable_to_non_nullable
                      as String,
            medicalHistory: null == medicalHistory
                ? _value.medicalHistory
                : medicalHistory // ignore: cast_nullable_to_non_nullable
                      as MedicalHistory,
            academicYear: null == academicYear
                ? _value.academicYear
                : academicYear // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            admissionClass: null == admissionClass
                ? _value.admissionClass
                : admissionClass // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MedicalHistoryCopyWith<$Res> get medicalHistory {
    return $MedicalHistoryCopyWith<$Res>(_value.medicalHistory, (value) {
      return _then(_value.copyWith(medicalHistory: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StudentImplCopyWith<$Res> implements $StudentCopyWith<$Res> {
  factory _$$StudentImplCopyWith(
    _$StudentImpl value,
    $Res Function(_$StudentImpl) then,
  ) = __$$StudentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String studentId,
    String schoolId,
    String classId,
    String name,
    String rollNo,
    String admissionNo,
    String dob,
    String gender,
    String address,
    String photoUrl,
    String parentUid,
    MedicalHistory medicalHistory,
    String academicYear,
    bool isActive,
    String admissionClass,
    DateTime? createdAt,
  });

  @override
  $MedicalHistoryCopyWith<$Res> get medicalHistory;
}

/// @nodoc
class __$$StudentImplCopyWithImpl<$Res>
    extends _$StudentCopyWithImpl<$Res, _$StudentImpl>
    implements _$$StudentImplCopyWith<$Res> {
  __$$StudentImplCopyWithImpl(
    _$StudentImpl _value,
    $Res Function(_$StudentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? schoolId = null,
    Object? classId = null,
    Object? name = null,
    Object? rollNo = null,
    Object? admissionNo = null,
    Object? dob = null,
    Object? gender = null,
    Object? address = null,
    Object? photoUrl = null,
    Object? parentUid = null,
    Object? medicalHistory = null,
    Object? academicYear = null,
    Object? isActive = null,
    Object? admissionClass = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$StudentImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        rollNo: null == rollNo
            ? _value.rollNo
            : rollNo // ignore: cast_nullable_to_non_nullable
                  as String,
        admissionNo: null == admissionNo
            ? _value.admissionNo
            : admissionNo // ignore: cast_nullable_to_non_nullable
                  as String,
        dob: null == dob
            ? _value.dob
            : dob // ignore: cast_nullable_to_non_nullable
                  as String,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: null == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        parentUid: null == parentUid
            ? _value.parentUid
            : parentUid // ignore: cast_nullable_to_non_nullable
                  as String,
        medicalHistory: null == medicalHistory
            ? _value.medicalHistory
            : medicalHistory // ignore: cast_nullable_to_non_nullable
                  as MedicalHistory,
        academicYear: null == academicYear
            ? _value.academicYear
            : academicYear // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        admissionClass: null == admissionClass
            ? _value.admissionClass
            : admissionClass // ignore: cast_nullable_to_non_nullable
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
class _$StudentImpl implements _Student {
  const _$StudentImpl({
    required this.studentId,
    required this.schoolId,
    required this.classId,
    required this.name,
    this.rollNo = '',
    this.admissionNo = '',
    this.dob = '',
    this.gender = '',
    this.address = '',
    this.photoUrl = '',
    required this.parentUid,
    this.medicalHistory = const MedicalHistory(),
    this.academicYear = '2026-27',
    this.isActive = true,
    this.admissionClass = '',
    this.createdAt,
  });

  factory _$StudentImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentImplFromJson(json);

  @override
  final String studentId;
  @override
  final String schoolId;
  @override
  final String classId;
  @override
  final String name;
  @override
  @JsonKey()
  final String rollNo;
  @override
  @JsonKey()
  final String admissionNo;
  @override
  @JsonKey()
  final String dob;
  @override
  @JsonKey()
  final String gender;
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String photoUrl;
  @override
  final String parentUid;
  @override
  @JsonKey()
  final MedicalHistory medicalHistory;
  @override
  @JsonKey()
  final String academicYear;
  @override
  @JsonKey()
  final bool isActive;

  /// Free-text class label entered at registration (e.g. "Class 5A").
  @override
  @JsonKey()
  final String admissionClass;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Student(studentId: $studentId, schoolId: $schoolId, classId: $classId, name: $name, rollNo: $rollNo, admissionNo: $admissionNo, dob: $dob, gender: $gender, address: $address, photoUrl: $photoUrl, parentUid: $parentUid, medicalHistory: $medicalHistory, academicYear: $academicYear, isActive: $isActive, admissionClass: $admissionClass, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.rollNo, rollNo) || other.rollNo == rollNo) &&
            (identical(other.admissionNo, admissionNo) ||
                other.admissionNo == admissionNo) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.parentUid, parentUid) ||
                other.parentUid == parentUid) &&
            (identical(other.medicalHistory, medicalHistory) ||
                other.medicalHistory == medicalHistory) &&
            (identical(other.academicYear, academicYear) ||
                other.academicYear == academicYear) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.admissionClass, admissionClass) ||
                other.admissionClass == admissionClass) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    studentId,
    schoolId,
    classId,
    name,
    rollNo,
    admissionNo,
    dob,
    gender,
    address,
    photoUrl,
    parentUid,
    medicalHistory,
    academicYear,
    isActive,
    admissionClass,
    createdAt,
  );

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentImplCopyWith<_$StudentImpl> get copyWith =>
      __$$StudentImplCopyWithImpl<_$StudentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentImplToJson(this);
  }
}

abstract class _Student implements Student {
  const factory _Student({
    required final String studentId,
    required final String schoolId,
    required final String classId,
    required final String name,
    final String rollNo,
    final String admissionNo,
    final String dob,
    final String gender,
    final String address,
    final String photoUrl,
    required final String parentUid,
    final MedicalHistory medicalHistory,
    final String academicYear,
    final bool isActive,
    final String admissionClass,
    final DateTime? createdAt,
  }) = _$StudentImpl;

  factory _Student.fromJson(Map<String, dynamic> json) = _$StudentImpl.fromJson;

  @override
  String get studentId;
  @override
  String get schoolId;
  @override
  String get classId;
  @override
  String get name;
  @override
  String get rollNo;
  @override
  String get admissionNo;
  @override
  String get dob;
  @override
  String get gender;
  @override
  String get address;
  @override
  String get photoUrl;
  @override
  String get parentUid;
  @override
  MedicalHistory get medicalHistory;
  @override
  String get academicYear;
  @override
  bool get isActive;

  /// Free-text class label entered at registration (e.g. "Class 5A").
  @override
  String get admissionClass;
  @override
  DateTime? get createdAt;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentImplCopyWith<_$StudentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
