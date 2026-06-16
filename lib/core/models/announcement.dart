import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'announcement.freezed.dart';
part 'announcement.g.dart';

/// ALL      = everyone (staff + parents)
/// PARENTS  = parents only
/// TEACHERS = only users with role TEACHER
/// STAFF    = all non-parent staff (TEACHER, ADMIN, PRINCIPAL, ADMINISTRATOR, MANAGEMENT)
/// CLASS    = a specific class's parents/students
enum AnnouncementAudience { ALL, PARENTS, TEACHERS, STAFF, CLASS }

@freezed
class Announcement with _$Announcement {
  const factory Announcement({
    required String announcementId,
    required String schoolId,
    required String title,
    required String body,
    required String createdBy,
    @Default('') String createdByName,
    @Default(AnnouncementAudience.ALL) AnnouncementAudience audience,
    @Default('') String targetClassId,
    @Default('') String targetClassName,
    @Default(false) bool requiresAck,
    @Default([]) List<String> ackedBy,
    @Default('') String attachmentUrl,
    DateTime? publishedAt,
    DateTime? createdAt,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Announcement.fromJson({
      ...data,
      'announcementId': doc.id,
      'publishedAt':
          (data['publishedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'createdByName':  data['createdByName']  ?? '',
      'targetClassName': data['targetClassName'] ?? '',
      'audience': (data['audience'] as String?)?.toUpperCase(),
    });
  }
}

extension AnnouncementX on Announcement {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('announcementId');
    if (publishedAt != null) json['publishedAt'] = Timestamp.fromDate(publishedAt!);
    if (createdAt != null)   json['createdAt']   = Timestamp.fromDate(createdAt!);
    return json;
  }

  bool hasUserAcked(String uid) => ackedBy.contains(uid);
}