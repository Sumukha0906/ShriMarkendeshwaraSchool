import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'leave_request.freezed.dart';
part 'leave_request.g.dart';

enum LeaveStatus { PENDING, APPROVED, REJECTED }

@freezed
class LeaveRequest with _$LeaveRequest {
  const factory LeaveRequest({
    required String requestId,
    required String schoolId,
    required String classId,
    required String studentId,
    required String parentUid,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
    @Default('') String attachmentUrl,
    @Default('') String studentName,
    @Default(false) bool isAbsentLetter,
    @Default(LeaveStatus.PENDING) LeaveStatus status,
    @Default('') String reviewedBy,
    DateTime? reviewedAt,
    @Default('') String reviewNote,
    DateTime? createdAt,
  }) = _LeaveRequest;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestFromJson(json);

  factory LeaveRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaveRequest.fromJson({
      ...data,
      'requestId': doc.id,
      'fromDate': (data['fromDate'] as Timestamp).toDate().toIso8601String(),
      'toDate':   (data['toDate']   as Timestamp).toDate().toIso8601String(),
      'reviewedAt':
          (data['reviewedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension LeaveRequestX on LeaveRequest {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('requestId');
    json['fromDate'] = Timestamp.fromDate(fromDate);
    json['toDate']   = Timestamp.fromDate(toDate);
    if (reviewedAt != null) json['reviewedAt'] = Timestamp.fromDate(reviewedAt!);
    if (createdAt != null)  json['createdAt']  = Timestamp.fromDate(createdAt!);
    return json;
  }

  int get durationDays => toDate.difference(fromDate).inDays + 1;
}