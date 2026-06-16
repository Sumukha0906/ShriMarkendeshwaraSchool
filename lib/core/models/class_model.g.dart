// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubjectTeacherImpl _$$SubjectTeacherImplFromJson(Map<String, dynamic> json) =>
    _$SubjectTeacherImpl(
      teacherUid: json['teacherUid'] as String,
      subject: json['subject'] as String,
    );

Map<String, dynamic> _$$SubjectTeacherImplToJson(
  _$SubjectTeacherImpl instance,
) => <String, dynamic>{
  'teacherUid': instance.teacherUid,
  'subject': instance.subject,
};

_$ClassModelImpl _$$ClassModelImplFromJson(Map<String, dynamic> json) =>
    _$ClassModelImpl(
      classId: json['classId'] as String,
      schoolId: json['schoolId'] as String,
      name: json['name'] as String,
      section: json['section'] as String? ?? '',
      classTeacherUid: json['classTeacherUid'] as String? ?? '',
      proctorTeacherUid: json['proctorTeacherUid'] as String? ?? '',
      subjectTeachers:
          (json['subjectTeachers'] as List<dynamic>?)
              ?.map((e) => SubjectTeacher.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ClassModelImplToJson(_$ClassModelImpl instance) =>
    <String, dynamic>{
      'classId': instance.classId,
      'schoolId': instance.schoolId,
      'name': instance.name,
      'section': instance.section,
      'classTeacherUid': instance.classTeacherUid,
      'proctorTeacherUid': instance.proctorTeacherUid,
      'subjectTeachers': instance.subjectTeachers,
      'studentCount': instance.studentCount,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
