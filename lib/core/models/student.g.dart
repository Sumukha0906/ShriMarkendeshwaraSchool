// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmergencyContactImpl _$$EmergencyContactImplFromJson(
  Map<String, dynamic> json,
) => _$EmergencyContactImpl(
  name: json['name'] as String,
  phone: json['phone'] as String,
  relation: json['relation'] as String? ?? '',
);

Map<String, dynamic> _$$EmergencyContactImplToJson(
  _$EmergencyContactImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'phone': instance.phone,
  'relation': instance.relation,
};

_$MedicalHistoryImpl _$$MedicalHistoryImplFromJson(Map<String, dynamic> json) =>
    _$MedicalHistoryImpl(
      bloodGroup: json['bloodGroup'] as String? ?? '',
      allergies:
          (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      conditions:
          (json['conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      vaccinationNotes: json['vaccinationNotes'] as String? ?? '',
      emergencyContact: json['emergencyContact'] == null
          ? null
          : EmergencyContact.fromJson(
              json['emergencyContact'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$MedicalHistoryImplToJson(
  _$MedicalHistoryImpl instance,
) => <String, dynamic>{
  'bloodGroup': instance.bloodGroup,
  'allergies': instance.allergies,
  'conditions': instance.conditions,
  'vaccinationNotes': instance.vaccinationNotes,
  'emergencyContact': instance.emergencyContact,
};

_$StudentImpl _$$StudentImplFromJson(Map<String, dynamic> json) =>
    _$StudentImpl(
      studentId: json['studentId'] as String,
      schoolId: json['schoolId'] as String,
      classId: json['classId'] as String,
      name: json['name'] as String,
      rollNo: json['rollNo'] as String? ?? '',
      admissionNo: json['admissionNo'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      address: json['address'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      parentUid: json['parentUid'] as String,
      medicalHistory: json['medicalHistory'] == null
          ? const MedicalHistory()
          : MedicalHistory.fromJson(
              json['medicalHistory'] as Map<String, dynamic>,
            ),
      academicYear: json['academicYear'] as String? ?? '2026-27',
      isActive: json['isActive'] as bool? ?? true,
      admissionClass: json['admissionClass'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StudentImplToJson(_$StudentImpl instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'schoolId': instance.schoolId,
      'classId': instance.classId,
      'name': instance.name,
      'rollNo': instance.rollNo,
      'admissionNo': instance.admissionNo,
      'dob': instance.dob,
      'gender': instance.gender,
      'address': instance.address,
      'photoUrl': instance.photoUrl,
      'parentUid': instance.parentUid,
      'medicalHistory': instance.medicalHistory,
      'academicYear': instance.academicYear,
      'isActive': instance.isActive,
      'admissionClass': instance.admissionClass,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
