// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationActorImpl _$$NotificationActorImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationActorImpl(
  uid: json['uid'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$$NotificationActorImplToJson(
  _$NotificationActorImpl instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'role': instance.role,
};

_$NotificationAudienceImpl _$$NotificationAudienceImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationAudienceImpl(
  type: $enumDecode(_$NotificationAudienceTypeEnumMap, json['type']),
  classId: json['classId'] as String? ?? '',
  targetUids:
      (json['targetUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  recipientCount: (json['recipientCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$NotificationAudienceImplToJson(
  _$NotificationAudienceImpl instance,
) => <String, dynamic>{
  'type': _$NotificationAudienceTypeEnumMap[instance.type]!,
  'classId': instance.classId,
  'targetUids': instance.targetUids,
  'recipientCount': instance.recipientCount,
};

const _$NotificationAudienceTypeEnumMap = {
  NotificationAudienceType.ALL: 'ALL',
  NotificationAudienceType.CLASS: 'CLASS',
  NotificationAudienceType.INDIVIDUAL: 'INDIVIDUAL',
  NotificationAudienceType.TEACHERS: 'TEACHERS',
  NotificationAudienceType.PARENTS: 'PARENTS',
};

_$DeliveryStatsImpl _$$DeliveryStatsImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryStatsImpl(
      sent: (json['sent'] as num?)?.toInt() ?? 0,
      failed: (json['failed'] as num?)?.toInt() ?? 0,
      opened: (json['opened'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$DeliveryStatsImplToJson(_$DeliveryStatsImpl instance) =>
    <String, dynamic>{
      'sent': instance.sent,
      'failed': instance.failed,
      'opened': instance.opened,
    };

_$NotificationLogImpl _$$NotificationLogImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationLogImpl(
  logId: json['logId'] as String,
  schoolId: json['schoolId'] as String,
  triggeredBy: json['triggeredBy'] == null
      ? null
      : NotificationActor.fromJson(json['triggeredBy'] as Map<String, dynamic>),
  isSystemTriggered: json['isSystemTriggered'] as bool? ?? false,
  notificationType: $enumDecode(
    _$NotificationTypeEnumMap,
    json['notificationType'],
  ),
  title: json['title'] as String,
  body: json['body'] as String,
  audience: NotificationAudience.fromJson(
    json['audience'] as Map<String, dynamic>,
  ),
  linkedEntityId: json['linkedEntityId'] as String? ?? '',
  linkedEntityType: json['linkedEntityType'] as String? ?? '',
  deliveryStats: json['deliveryStats'] == null
      ? const DeliveryStats()
      : DeliveryStats.fromJson(json['deliveryStats'] as Map<String, dynamic>),
  sentAt: json['sentAt'] == null
      ? null
      : DateTime.parse(json['sentAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$NotificationLogImplToJson(
  _$NotificationLogImpl instance,
) => <String, dynamic>{
  'logId': instance.logId,
  'schoolId': instance.schoolId,
  'triggeredBy': instance.triggeredBy,
  'isSystemTriggered': instance.isSystemTriggered,
  'notificationType': _$NotificationTypeEnumMap[instance.notificationType]!,
  'title': instance.title,
  'body': instance.body,
  'audience': instance.audience,
  'linkedEntityId': instance.linkedEntityId,
  'linkedEntityType': instance.linkedEntityType,
  'deliveryStats': instance.deliveryStats,
  'sentAt': instance.sentAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$NotificationTypeEnumMap = {
  NotificationType.ATTENDANCE_MARKED: 'ATTENDANCE_MARKED',
  NotificationType.ATTENDANCE_UPDATED: 'ATTENDANCE_UPDATED',
  NotificationType.STUDENT_ABSENT: 'STUDENT_ABSENT',
  NotificationType.LEAVE_SUBMITTED: 'LEAVE_SUBMITTED',
  NotificationType.LEAVE_APPROVED: 'LEAVE_APPROVED',
  NotificationType.LEAVE_REJECTED: 'LEAVE_REJECTED',
  NotificationType.EARLY_PICKUP_REQUESTED: 'EARLY_PICKUP_REQUESTED',
  NotificationType.EARLY_PICKUP_APPROVED: 'EARLY_PICKUP_APPROVED',
  NotificationType.LESSON_PLAN_POSTED: 'LESSON_PLAN_POSTED',
  NotificationType.MARKS_PUBLISHED: 'MARKS_PUBLISHED',
  NotificationType.FEE_PAYMENT_REQUEST: 'FEE_PAYMENT_REQUEST',
  NotificationType.FEE_PAYMENT_RECEIVED: 'FEE_PAYMENT_RECEIVED',
  NotificationType.ANNOUNCEMENT: 'ANNOUNCEMENT',
  NotificationType.CHAT_MESSAGE: 'CHAT_MESSAGE',
  NotificationType.INVITE_SENT: 'INVITE_SENT',
};
