// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exit_attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExitAttendanceImpl _$$ExitAttendanceImplFromJson(Map<String, dynamic> json) =>
    _$ExitAttendanceImpl(
      recordId: json['recordId'] as String,
      schoolId: json['schoolId'] as String,
      classId: json['classId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      exitTime: DateTime.parse(json['exitTime'] as String),
      mode: $enumDecode(_$ExitModeEnumMap, json['mode']),
      collectorName: json['collectorName'] as String? ?? '',
      collectorRelation: json['collectorRelation'] as String? ?? '',
      collectorPhone: json['collectorPhone'] as String? ?? '',
      pickupPhotoUrl: json['pickupPhotoUrl'] as String? ?? '',
      vehicleDetails: json['vehicleDetails'] as String? ?? '',
      linkedPickupRequestId: json['linkedPickupRequestId'] as String? ?? '',
      loggedBy: json['loggedBy'] as String,
      loggedByName: json['loggedByName'] as String? ?? '',
      parentNotified: json['parentNotified'] as bool? ?? false,
      remarks: json['remarks'] as String? ?? '',
    );

Map<String, dynamic> _$$ExitAttendanceImplToJson(
  _$ExitAttendanceImpl instance,
) => <String, dynamic>{
  'recordId': instance.recordId,
  'schoolId': instance.schoolId,
  'classId': instance.classId,
  'studentId': instance.studentId,
  'studentName': instance.studentName,
  'date': instance.date.toIso8601String(),
  'exitTime': instance.exitTime.toIso8601String(),
  'mode': _$ExitModeEnumMap[instance.mode]!,
  'collectorName': instance.collectorName,
  'collectorRelation': instance.collectorRelation,
  'collectorPhone': instance.collectorPhone,
  'pickupPhotoUrl': instance.pickupPhotoUrl,
  'vehicleDetails': instance.vehicleDetails,
  'linkedPickupRequestId': instance.linkedPickupRequestId,
  'loggedBy': instance.loggedBy,
  'loggedByName': instance.loggedByName,
  'parentNotified': instance.parentNotified,
  'remarks': instance.remarks,
};

const _$ExitModeEnumMap = {
  ExitMode.SELF: 'SELF',
  ExitMode.PARENT: 'PARENT',
  ExitMode.GUARDIAN: 'GUARDIAN',
  ExitMode.SCHOOL_BUS: 'SCHOOL_BUS',
  ExitMode.PRIVATE_TRANSPORT: 'PRIVATE_TRANSPORT',
  ExitMode.OTHERS: 'OTHERS',
  ExitMode.EARLY_PICKUP: 'EARLY_PICKUP',
};
