import 'package:cloud_firestore/cloud_firestore.dart';

enum SpecialRequestStatus { PENDING, ACKNOWLEDGED, APPROVED, REJECTED }

enum SpecialRequestType {
  GENERAL,
  MEDICAL,
  BEHAVIORAL,
  ACADEMIC,
  TRANSPORT,
  OTHER,
}

class SpecialRequest {
  final String requestId;
  final String schoolId;
  final String classId;
  final String studentId;
  final String studentName;
  final String parentUid;
  final String parentName;
  final String targetTeacherUid;
  final String targetTeacherName;
  final SpecialRequestType type;
  final String subject;
  final String description;
  final SpecialRequestStatus status;
  final String responseNote;
  final String respondedBy;
  final DateTime? respondedAt;
  final DateTime? createdAt;

  const SpecialRequest({
    required this.requestId,
    required this.schoolId,
    required this.classId,
    required this.studentId,
    required this.studentName,
    required this.parentUid,
    required this.parentName,
    required this.targetTeacherUid,
    required this.targetTeacherName,
    required this.type,
    required this.subject,
    required this.description,
    this.status = SpecialRequestStatus.PENDING,
    this.responseNote = '',
    this.respondedBy = '',
    this.respondedAt,
    this.createdAt,
  });

  factory SpecialRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpecialRequest(
      requestId: doc.id,
      schoolId: data['schoolId'] ?? '',
      classId: data['classId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      parentUid: data['parentUid'] ?? '',
      parentName: data['parentName'] ?? '',
      targetTeacherUid: data['targetTeacherUid'] ?? '',
      targetTeacherName: data['targetTeacherName'] ?? '',
      type: SpecialRequestType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'GENERAL'),
        orElse: () => SpecialRequestType.GENERAL,
      ),
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      status: SpecialRequestStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'PENDING'),
        orElse: () => SpecialRequestStatus.PENDING,
      ),
      responseNote: data['responseNote'] ?? '',
      respondedBy: data['respondedBy'] ?? '',
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'classId': classId,
      'studentId': studentId,
      'studentName': studentName,
      'parentUid': parentUid,
      'parentName': parentName,
      'targetTeacherUid': targetTeacherUid,
      'targetTeacherName': targetTeacherName,
      'type': type.name,
      'subject': subject,
      'description': description,
      'status': status.name,
      'responseNote': responseNote,
      'respondedBy': respondedBy,
      if (respondedAt != null) 'respondedAt': Timestamp.fromDate(respondedAt!),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}
