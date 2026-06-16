import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'marks.freezed.dart';
part 'marks.g.dart';

@freezed
class SubjectMark with _$SubjectMark {
  const factory SubjectMark({
    required String subject,
    required double marksObtained,
    required double maxMarks,
    @Default('') String grade,
    @Default('') String remarks,
  }) = _SubjectMark;

  factory SubjectMark.fromJson(Map<String, dynamic> json) =>
      _$SubjectMarkFromJson(json);
}

@freezed
class StudentMarks with _$StudentMarks {
  const factory StudentMarks({
    required String studentId,
    required String classId,
    required String schoolId,
    required String academicYear,
    required String term,
    @Default([]) List<SubjectMark> subjects,
    @Default('') String updatedBy,
    DateTime? updatedAt,
    @Default(false) bool isPublished,
  }) = _StudentMarks;

  factory StudentMarks.fromJson(Map<String, dynamic> json) =>
      _$StudentMarksFromJson(json);

  factory StudentMarks.fromFirestore(DocumentSnapshot doc, String studentId) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentMarks.fromJson({
      ...data,
      'studentId': studentId,
      'updatedAt':
          (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension StudentMarksX on StudentMarks {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('studentId');
    json['subjects'] = subjects.map((s) => s.toJson()).toList();
    if (updatedAt != null) json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    return json;
  }

  double get totalObtained =>
      subjects.fold(0, (acc, s) => acc + s.marksObtained);
  double get totalMax =>
      subjects.fold(0, (acc, s) => acc + s.maxMarks);
  double get percentage =>
      totalMax > 0 ? (totalObtained / totalMax) * 100 : 0;
}