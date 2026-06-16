import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

enum AttendanceStatus { PRESENT, ABSENT, LATE, LEAVE }

@freezed
class AttendanceRecord with _$AttendanceRecord {
  const factory AttendanceRecord({
    required String studentId,
    required AttendanceStatus status,
    @Default('') String note,
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);
}

@freezed
class AttendanceSession with _$AttendanceSession {
  const factory AttendanceSession({
    required String sessionId,
    required String classId,
    required String schoolId,
    required DateTime date,
    required String markedBy,
    DateTime? markedAt,
    @Default(false) bool isUpdated,
    @Default([]) List<AttendanceRecord> records,
  }) = _AttendanceSession;

  factory AttendanceSession.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSessionFromJson(json);

  factory AttendanceSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceSession.fromJson({
      ...data,
      'sessionId': doc.id,
      'date': (data['date'] as Timestamp).toDate().toIso8601String(),
      'markedAt':
          (data['markedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension AttendanceSessionX on AttendanceSession {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('sessionId');
    json['date'] = Timestamp.fromDate(date);
    if (markedAt != null) json['markedAt'] = Timestamp.fromDate(markedAt!);
    // Explicitly serialize records to avoid Firestore rejecting Dart objects
    json['records'] = records.map((r) => {
      'studentId': r.studentId,
      'status': r.status.name,
      'note': r.note,
    }).toList();
    return json;
  }

  int get presentCount =>
      records.where((r) => r.status == AttendanceStatus.PRESENT).length;
  int get absentCount =>
      records.where((r) => r.status == AttendanceStatus.ABSENT).length;
  int get leaveCount =>
      records.where((r) => r.status == AttendanceStatus.LEAVE).length;
  int get lateCount =>
      records.where((r) => r.status == AttendanceStatus.LATE).length;
}