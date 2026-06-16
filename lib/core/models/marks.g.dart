// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubjectMarkImpl _$$SubjectMarkImplFromJson(Map<String, dynamic> json) =>
    _$SubjectMarkImpl(
      subject: json['subject'] as String,
      marksObtained: (json['marksObtained'] as num).toDouble(),
      maxMarks: (json['maxMarks'] as num).toDouble(),
      grade: json['grade'] as String? ?? '',
      remarks: json['remarks'] as String? ?? '',
    );

Map<String, dynamic> _$$SubjectMarkImplToJson(_$SubjectMarkImpl instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'marksObtained': instance.marksObtained,
      'maxMarks': instance.maxMarks,
      'grade': instance.grade,
      'remarks': instance.remarks,
    };

_$StudentMarksImpl _$$StudentMarksImplFromJson(Map<String, dynamic> json) =>
    _$StudentMarksImpl(
      studentId: json['studentId'] as String,
      classId: json['classId'] as String,
      schoolId: json['schoolId'] as String,
      academicYear: json['academicYear'] as String,
      term: json['term'] as String,
      subjects:
          (json['subjects'] as List<dynamic>?)
              ?.map((e) => SubjectMark.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      updatedBy: json['updatedBy'] as String? ?? '',
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isPublished: json['isPublished'] as bool? ?? false,
    );

Map<String, dynamic> _$$StudentMarksImplToJson(_$StudentMarksImpl instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'classId': instance.classId,
      'schoolId': instance.schoolId,
      'academicYear': instance.academicYear,
      'term': instance.term,
      'subjects': instance.subjects,
      'updatedBy': instance.updatedBy,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isPublished': instance.isPublished,
    };
