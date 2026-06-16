// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_whatsapp_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SmsSenderImpl _$$SmsSenderImplFromJson(Map<String, dynamic> json) =>
    _$SmsSenderImpl(
      uid: json['uid'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$$SmsSenderImplToJson(_$SmsSenderImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'role': instance.role,
    };

_$SmsRecipientImpl _$$SmsRecipientImplFromJson(Map<String, dynamic> json) =>
    _$SmsRecipientImpl(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$$SmsRecipientImplToJson(_$SmsRecipientImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'phone': instance.phone,
    };

_$SmsWhatsappLogImpl _$$SmsWhatsappLogImplFromJson(Map<String, dynamic> json) =>
    _$SmsWhatsappLogImpl(
      logId: json['logId'] as String,
      schoolId: json['schoolId'] as String,
      sentBy: SmsSender.fromJson(json['sentBy'] as Map<String, dynamic>),
      recipient: SmsRecipient.fromJson(
        json['recipient'] as Map<String, dynamic>,
      ),
      channel: $enumDecode(_$SmsChannelEnumMap, json['channel']),
      messageType: $enumDecode(_$SmsMessageTypeEnumMap, json['messageType']),
      messagePreview: json['messagePreview'] as String,
      status:
          $enumDecodeNullable(_$SmsStatusEnumMap, json['status']) ??
          SmsStatus.PENDING,
      failureReason: json['failureReason'] as String? ?? '',
      linkedEntityId: json['linkedEntityId'] as String? ?? '',
      linkedEntityType: json['linkedEntityType'] as String? ?? '',
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SmsWhatsappLogImplToJson(
  _$SmsWhatsappLogImpl instance,
) => <String, dynamic>{
  'logId': instance.logId,
  'schoolId': instance.schoolId,
  'sentBy': instance.sentBy,
  'recipient': instance.recipient,
  'channel': _$SmsChannelEnumMap[instance.channel]!,
  'messageType': _$SmsMessageTypeEnumMap[instance.messageType]!,
  'messagePreview': instance.messagePreview,
  'status': _$SmsStatusEnumMap[instance.status]!,
  'failureReason': instance.failureReason,
  'linkedEntityId': instance.linkedEntityId,
  'linkedEntityType': instance.linkedEntityType,
  'sentAt': instance.sentAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$SmsChannelEnumMap = {
  SmsChannel.SMS: 'SMS',
  SmsChannel.WHATSAPP: 'WHATSAPP',
};

const _$SmsMessageTypeEnumMap = {
  SmsMessageType.FEE_REQUEST: 'FEE_REQUEST',
  SmsMessageType.INVITE: 'INVITE',
  SmsMessageType.ANNOUNCEMENT: 'ANNOUNCEMENT',
  SmsMessageType.ATTENDANCE_ALERT: 'ATTENDANCE_ALERT',
  SmsMessageType.CUSTOM: 'CUSTOM',
};

const _$SmsStatusEnumMap = {
  SmsStatus.SENT: 'SENT',
  SmsStatus.FAILED: 'FAILED',
  SmsStatus.PENDING: 'PENDING',
};
