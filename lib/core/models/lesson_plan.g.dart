// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonPlanImpl _$$LessonPlanImplFromJson(Map<String, dynamic> json) =>
    _$LessonPlanImpl(
      planId: json['planId'] as String,
      schoolId: json['schoolId'] as String,
      classId: json['classId'] as String,
      teacherUid: json['teacherUid'] as String,
      subject: json['subject'] as String,
      date: DateTime.parse(json['date'] as String),
      topicsCovered: json['topicsCovered'] as String,
      homework: json['homework'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      notificationSent: json['notificationSent'] as bool? ?? false,
      attachmentUrls:
          (json['attachmentUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      attachmentNames:
          (json['attachmentNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LessonPlanImplToJson(_$LessonPlanImpl instance) =>
    <String, dynamic>{
      'planId': instance.planId,
      'schoolId': instance.schoolId,
      'classId': instance.classId,
      'teacherUid': instance.teacherUid,
      'subject': instance.subject,
      'date': instance.date.toIso8601String(),
      'topicsCovered': instance.topicsCovered,
      'homework': instance.homework,
      'notes': instance.notes,
      'notificationSent': instance.notificationSent,
      'attachmentUrls': instance.attachmentUrls,
      'attachmentNames': instance.attachmentNames,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
