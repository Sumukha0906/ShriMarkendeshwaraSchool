// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceRecordImpl _$$AttendanceRecordImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceRecordImpl(
  studentId: json['studentId'] as String,
  status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
  note: json['note'] as String? ?? '',
);

Map<String, dynamic> _$$AttendanceRecordImplToJson(
  _$AttendanceRecordImpl instance,
) => <String, dynamic>{
  'studentId': instance.studentId,
  'status': _$AttendanceStatusEnumMap[instance.status]!,
  'note': instance.note,
};

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.PRESENT: 'PRESENT',
  AttendanceStatus.ABSENT: 'ABSENT',
  AttendanceStatus.LATE: 'LATE',
  AttendanceStatus.LEAVE: 'LEAVE',
};

_$AttendanceSessionImpl _$$AttendanceSessionImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceSessionImpl(
  sessionId: json['sessionId'] as String,
  classId: json['classId'] as String,
  schoolId: json['schoolId'] as String,
  date: DateTime.parse(json['date'] as String),
  markedBy: json['markedBy'] as String,
  markedAt: json['markedAt'] == null
      ? null
      : DateTime.parse(json['markedAt'] as String),
  isUpdated: json['isUpdated'] as bool? ?? false,
  records:
      (json['records'] as List<dynamic>?)
          ?.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$AttendanceSessionImplToJson(
  _$AttendanceSessionImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'classId': instance.classId,
  'schoolId': instance.schoolId,
  'date': instance.date.toIso8601String(),
  'markedBy': instance.markedBy,
  'markedAt': instance.markedAt?.toIso8601String(),
  'isUpdated': instance.isUpdated,
  'records': instance.records,
};
