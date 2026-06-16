import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'notification_log.freezed.dart';
part 'notification_log.g.dart';

enum NotificationType {
  ATTENDANCE_MARKED,
  ATTENDANCE_UPDATED,
  STUDENT_ABSENT,
  LEAVE_SUBMITTED,
  LEAVE_APPROVED,
  LEAVE_REJECTED,
  EARLY_PICKUP_REQUESTED,
  EARLY_PICKUP_APPROVED,
  LESSON_PLAN_POSTED,
  MARKS_PUBLISHED,
  FEE_PAYMENT_REQUEST,
  FEE_PAYMENT_RECEIVED,
  ANNOUNCEMENT,
  CHAT_MESSAGE,
  INVITE_SENT,
}

enum NotificationAudienceType { ALL, CLASS, INDIVIDUAL, TEACHERS, PARENTS }

@freezed
class NotificationActor with _$NotificationActor {
  const NotificationActor._();
  const factory NotificationActor({
    required String uid,
    required String name,
    required String role,
  }) = _NotificationActor;

  factory NotificationActor.fromJson(Map<String, dynamic> json) =>
      _$NotificationActorFromJson(json);
}

@freezed
class NotificationAudience with _$NotificationAudience {
  const NotificationAudience._();
  const factory NotificationAudience({
    required NotificationAudienceType type,
    @Default('') String classId,
    @Default([]) List<String> targetUids,
    @Default(0) int recipientCount,
  }) = _NotificationAudience;

  factory NotificationAudience.fromJson(Map<String, dynamic> json) =>
      _$NotificationAudienceFromJson(json);
}

@freezed
class DeliveryStats with _$DeliveryStats {
  const DeliveryStats._();
  const factory DeliveryStats({
    @Default(0) int sent,
    @Default(0) int failed,
    @Default(0) int opened,
  }) = _DeliveryStats;

  factory DeliveryStats.fromJson(Map<String, dynamic> json) =>
      _$DeliveryStatsFromJson(json);
}

@freezed
class NotificationLog with _$NotificationLog {
  const NotificationLog._();
  const factory NotificationLog({
    required String logId,
    required String schoolId,
    NotificationActor? triggeredBy,
    @Default(false) bool isSystemTriggered,
    required NotificationType notificationType,
    required String title,
    required String body,
    required NotificationAudience audience,
    @Default('') String linkedEntityId,
    @Default('') String linkedEntityType,
    @Default(DeliveryStats()) DeliveryStats deliveryStats,
    DateTime? sentAt,
    DateTime? createdAt,
  }) = _NotificationLog;

  factory NotificationLog.fromJson(Map<String, dynamic> json) =>
      _$NotificationLogFromJson(json);

  factory NotificationLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationLog.fromJson({
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