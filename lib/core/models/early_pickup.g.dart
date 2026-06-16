// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'early_pickup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CollectorDetailsImpl _$$CollectorDetailsImplFromJson(
  Map<String, dynamic> json,
) => _$CollectorDetailsImpl(
  name: json['name'] as String,
  relation: json['relation'] as String,
  phone: json['phone'] as String,
  photoUrl: json['photoUrl'] as String? ?? '',
);

Map<String, dynamic> _$$CollectorDetailsImplToJson(
  _$CollectorDetailsImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'relation': instance.relation,
  'phone': instance.phone,
  'photoUrl': instance.photoUrl,
};

_$EarlyPickupImpl _$$EarlyPickupImplFromJson(Map<String, dynamic> json) =>
    _$EarlyPickupImpl(
      requestId: json['requestId'] as String,
      schoolId: json['schoolId'] as String,
      classId: json['classId'] as String,
      studentId: json['studentId'] as String,
      parentUid: json['parentUid'] as String,
      studentName: json['studentName'] as String? ?? '',
      pickupTime: DateTime.parse(json['pickupTime'] as String),
      reason: json['reason'] as String,
      collectorDetails: CollectorDetails.fromJson(
        json['collectorDetails'] as Map<String, dynamic>,
      ),
      status:
          $enumDecodeNullable(_$PickupStatusEnumMap, json['status']) ??
          PickupStatus.PENDING,
      approvedBy: json['approvedBy'] as String? ?? '',
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      exitLoggedAt: json['exitLoggedAt'] == null
          ? null
          : DateTime.parse(json['exitLoggedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$EarlyPickupImplToJson(_$EarlyPickupImpl instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'schoolId': instance.schoolId,
      'classId': instance.classId,
      'studentId': instance.studentId,
      'parentUid': instance.parentUid,
      'studentName': instance.studentName,
      'pickupTime': instance.pickupTime.toIso8601String(),
      'reason': instance.reason,
      'collectorDetails': instance.collectorDetails,
      'status': _$PickupStatusEnumMap[instance.status]!,
      'approvedBy': instance.approvedBy,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'exitLoggedAt': instance.exitLoggedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$PickupStatusEnumMap = {
  PickupStatus.PENDING: 'PENDING',
  PickupStatus.APPROVED: 'APPROVED',
  PickupStatus.REJECTED: 'REJECTED',
  PickupStatus.COMPLETED: 'COMPLETED',
};
