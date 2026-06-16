import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'lesson_plan.freezed.dart';
part 'lesson_plan.g.dart';

@freezed
class LessonPlan with _$LessonPlan {
  const factory LessonPlan({
    required String planId,
    required String schoolId,
    required String classId,
    required String teacherUid,
    required String subject,
    required DateTime date,
    required String topicsCovered,
    @Default('') String homework,
    @Default('') String notes,
    @Default(false) bool notificationSent,
    @Default([]) List<String> attachmentUrls,
    @Default([]) List<String> attachmentNames,
    DateTime? createdAt,
  }) = _LessonPlan;

  factory LessonPlan.fromJson(Map<String, dynamic> json) =>
      _$LessonPlanFromJson(json);

  factory LessonPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonPlan.fromJson({
      ...data,
      'planId': doc.id,
      'date': (data['date'] as Timestamp).toDate().toIso8601String(),
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension LessonPlanX on LessonPlan {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('planId');
    json['date'] = Timestamp.fromDate(date);
    if (createdAt != null) json['createdAt'] = Timestamp.fromDate(createdAt!);
    return json;
  }
}