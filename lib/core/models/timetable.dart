import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'timetable.freezed.dart';
part 'timetable.g.dart';

@freezed
class Period with _$Period {
  const factory Period({
    required int periodNumber,
    required String subject,
    required String teacherUid,
    required String startTime,
    required String endTime,
    @Default('') String substituteTeacherUid,
  }) = _Period;

  factory Period.fromJson(Map<String, dynamic> json) =>
      _$PeriodFromJson(json);
}

@freezed
class Timetable with _$Timetable {
  const factory Timetable({
    required String classId,
    required String schoolId,
    DateTime? updatedAt,
    @Default('') String updatedBy,
    @Default({}) Map<String, List<Period>> schedule,
  }) = _Timetable;

  factory Timetable.fromJson(Map<String, dynamic> json) =>
      _$TimetableFromJson(json);

  factory Timetable.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Timetable.fromJson({
      ...data,
      'classId': doc.id,
      'updatedAt':
          (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension TimetableX on Timetable {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('classId');
    if (updatedAt != null) json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    // Explicitly serialize Period objects — toJson() leaves them as Freezed instances
    json['schedule'] = schedule.map(
      (day, periods) => MapEntry(day, periods.map((p) => p.toJson()).toList()),
    );
    return json;
  }

  List<Period> periodsForDay(String day) => schedule[day] ?? [];
}