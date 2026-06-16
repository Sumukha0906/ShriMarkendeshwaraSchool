// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PeriodImpl _$$PeriodImplFromJson(Map<String, dynamic> json) => _$PeriodImpl(
  periodNumber: (json['periodNumber'] as num).toInt(),
  subject: json['subject'] as String,
  teacherUid: json['teacherUid'] as String,
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  substituteTeacherUid: json['substituteTeacherUid'] as String? ?? '',
);

Map<String, dynamic> _$$PeriodImplToJson(_$PeriodImpl instance) =>
    <String, dynamic>{
      'periodNumber': instance.periodNumber,
      'subject': instance.subject,
      'teacherUid': instance.teacherUid,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'substituteTeacherUid': instance.substituteTeacherUid,
    };

_$TimetableImpl _$$TimetableImplFromJson(Map<String, dynamic> json) =>
    _$TimetableImpl(
      classId: json['classId'] as String,
      schoolId: json['schoolId'] as String,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String? ?? '',
      schedule:
          (json['schedule'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>)
                  .map((e) => Period.fromJson(e as Map<String, dynamic>))
                  .toList(),
            ),
          ) ??
          const {},
    );

Map<String, dynamic> _$$TimetableImplToJson(_$TimetableImpl instance) =>
    <String, dynamic>{
      'classId': instance.classId,
      'schoolId': instance.schoolId,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedBy': instance.updatedBy,
      'schedule': instance.schedule,
    };
