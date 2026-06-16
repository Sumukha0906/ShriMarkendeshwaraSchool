import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'sms_whatsapp_log.freezed.dart';
part 'sms_whatsapp_log.g.dart';

enum SmsChannel     { SMS, WHATSAPP }
enum SmsStatus      { SENT, FAILED, PENDING }
enum SmsMessageType { FEE_REQUEST, INVITE, ANNOUNCEMENT, ATTENDANCE_ALERT, CUSTOM }

@freezed
class SmsSender with _$SmsSender {
  const SmsSender._();
  const factory SmsSender({
    required String uid,
    required String name,
    required String role,
  }) = _SmsSender;

  factory SmsSender.fromJson(Map<String, dynamic> json) =>
      _$SmsSenderFromJson(json);
}

@freezed
class SmsRecipient with _$SmsRecipient {
  const SmsRecipient._();
  const factory SmsRecipient({
    @Default('') String uid,
    required String name,
    required String phone,
  }) = _SmsRecipient;

  factory SmsRecipient.fromJson(Map<String, dynamic> json) =>
      _$SmsRecipientFromJson(json);
}

@freezed
class SmsWhatsappLog with _$SmsWhatsappLog {
  const SmsWhatsappLog._();
  const factory SmsWhatsappLog({
    required String logId,
    required String schoolId,
    required SmsSender sentBy,
    required SmsRecipient recipient,
    required SmsChannel channel,
    required SmsMessageType messageType,
    required String messagePreview,
    @Default(SmsStatus.PENDING) SmsStatus status,
    @Default('') String failureReason,
    @Default('') String linkedEntityId,
    @Default('') String linkedEntityType,
    DateTime? sentAt,
    DateTime? createdAt,
  }) = _SmsWhatsappLog;

  factory SmsWhatsappLog.fromJson(Map<String, dynamic> json) =>
      _$SmsWhatsappLogFromJson(json);

  factory SmsWhatsappLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SmsWhatsappLog.fromJson({
      ...data,
      'logId':     doc.id,
      'sentAt':    (data['sentAt']    as Timestamp?)?.toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('logId');
    if (sentAt != null)    json['sentAt']    = Timestamp.fromDate(sentAt!);
    if (createdAt != null) json['createdAt'] = Timestamp.fromDate(createdAt!);
    return json;
  }
}