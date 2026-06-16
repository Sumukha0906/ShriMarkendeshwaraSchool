import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'exit_attendance.freezed.dart';
part 'exit_attendance.g.dart';

enum ExitMode {
  SELF,
  PARENT,
  GUARDIAN,
  SCHOOL_BUS,
  PRIVATE_TRANSPORT,
  OTHERS,
  EARLY_PICKUP,
}

@freezed
class ExitAttendance with _$ExitAttendance {
  const factory ExitAttendance({
    required String recordId,
    required String schoolId,
    required String classId,
    required String studentId,
    @Default('') String studentName,
    required DateTime date,
    required DateTime exitTime,
    required ExitMode mode,
    @Default('') String collectorName,
    @Default('') String collectorRelation,
    @Default('') String collectorPhone,
    @Default('') String pickupPhotoUrl,
    @Default('') String vehicleDetails,
    @Default('') String linkedPickupRequestId,
    required String loggedBy,
    @Default('') String loggedByName,
    @Default(false) bool parentNotified,
    @Default('') String remarks,
  }) = _ExitAttendance;

  factory ExitAttendance.fromJson(Map<String, dynamic> json) =>
      _$ExitAttendanceFromJson(json);

  factory ExitAttendance.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExitAttendance.fromJson({
      ...data,
      'recordId': doc.id,
      'date':     (data['date']     as Timestamp).toDate().toIso8601String(),
      'exitTime': (data['exitTime'] as Timestamp).toDate().toIso8601String(),
    });
  }
}

extension ExitAttendanceX on ExitAttendance {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('recordId');
    json['date']     = Timestamp.fromDate(date);
    json['exitTime'] = Timestamp.fromDate(exitTime);
    return json;
  }

  String get modeLabel {
    switch (mode) {
      case ExitMode.SELF:              return 'Gone by Self';
      case ExitMode.PARENT:            return 'Picked by Parent';
      case ExitMode.GUARDIAN:          return 'Picked by Guardian';
      case ExitMode.SCHOOL_BUS:        return 'School Bus';
      case ExitMode.PRIVATE_TRANSPORT: return 'Private Transport';
      case ExitMode.OTHERS:            return 'Others';
      case ExitMode.EARLY_PICKUP:      return 'Early Pickup';
    }
  }
}
