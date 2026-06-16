// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaveRequestImpl _$$LeaveRequestImplFromJson(Map<String, dynamic> json) =>
    _$LeaveRequestImpl(
      requestId: json['requestId'] as String,
      schoolId: json['schoolId'] as String,
      classId: json['classId'] as String,
      studentId: json['studentId'] as String,
      parentUid: json['parentUid'] as String,
      fromDate: DateTime.parse(json['fromDate'] as String),
      toDate: DateTime.parse(json['toDate'] as String),
      reason: json['reason'] as String,
      attachmentUrl: json['attachmentUrl'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      isAbsentLetter: json['isAbsentLetter'] as bool? ?? false,
      status:
          $enumDecodeNullable(_$LeaveStatusEnumMap, json['status']) ??
          LeaveStatus.PENDING,
      reviewedBy: json['reviewedBy'] as String? ?? '',
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      reviewNote: json['reviewNote'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LeaveRequestImplToJson(_$LeaveRequestImpl instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'schoolId': instance.schoolId,
      'classId': instance.classId,
      'studentId': instance.studentId,
      'parentUid': instance.parentUid,
      'fromDate': instance.fromDate.toIso8601String(),
      'toDate': instance.toDate.toIso8601String(),
      'reason': instance.reason,
      'attachmentUrl': instance.attachmentUrl,
      'studentName': instance.studentName,
      'isAbsentLetter': instance.isAbsentLetter,
      'status': _$LeaveStatusEnumMap[instance.status]!,
      'reviewedBy': instance.reviewedBy,
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'reviewNote': instance.reviewNote,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$LeaveStatusEnumMap = {
  LeaveStatus.PENDING: 'PENDING',
  LeaveStatus.APPROVED: 'APPROVED',
  LeaveStatus.REJECTED: 'REJECTED',
};
