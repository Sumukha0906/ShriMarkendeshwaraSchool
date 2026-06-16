import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'class_model.freezed.dart';
part 'class_model.g.dart';

@freezed
class SubjectTeacher with _$SubjectTeacher {
  const factory SubjectTeacher({
    required String teacherUid,
    required String subject,
  }) = _SubjectTeacher;

  factory SubjectTeacher.fromJson(Map<String, dynamic> json) =>
      _$SubjectTeacherFromJson(json);
}

@freezed
class ClassModel with _$ClassModel {
  const factory ClassModel({
    required String classId,
    required String schoolId,
    required String name,
    @Default('') String section,
    @Default('') String classTeacherUid,
    @Default('') String proctorTeacherUid,
    @Default([]) List<SubjectTeacher> subjectTeachers,
    @Default(0) int studentCount,
    DateTime? createdAt,
  }) = _ClassModel;

  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassModel.fromJson({
      ...data,
      'classId': doc.id,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension ClassModelX on ClassModel {
  String get displayName =>
      section.isEmpty ? name : '$name - $section';

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('classId');
    if (createdAt != null) json['createdAt'] = Timestamp.fromDate(createdAt!);
    // Explicitly serialize subjectTeachers — toJson() leaves them as Freezed objects
    json['subjectTeachers'] = subjectTeachers.map((st) => st.toJson()).toList();
    return json;
  }
}