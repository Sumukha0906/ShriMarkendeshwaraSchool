import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../constants/firestore_constants.dart';
import '../utils/app_logger.dart';
import '../models/user_model.dart';
import '../models/school.dart';
import '../models/student.dart';
import '../models/class_model.dart';
import '../models/attendance.dart';
import '../models/leave_request.dart';
import '../models/early_pickup.dart';
import '../models/exit_attendance.dart';
import '../models/lesson_plan.dart';
import '../models/announcement.dart';
import '../models/chat.dart';
import '../models/timetable.dart';
import '../models/fee.dart';
import '../models/marks.dart';
import '../models/invitation.dart';
import '../models/sms_whatsapp_log.dart';
import 'notification_service.dart';
import '../models/special_request.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // ════════════════════════════════════════════════════
  //  AUDIT LOG  (private — written from server side,
  //  never returned to clients via Firestore rules)
  // ════════════════════════════════════════════════════

  /// Writes a single record to [FSC.activityLogs] capturing every deletion
  /// or update so disputes from schools can be resolved.
  Future<void> logActivity({
    required String action, // 'DELETE' | 'UPDATE' | 'CREATE'
    required String entityType, // 'staff' | 'expense' | 'fee' | etc.
    required String entityId,
    required String schoolId,
    required String performedByUid,
    required String performedByName,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    String? note,
  }) async {
    try {
      final logId = _uuid.v4();
      await _db.collection(FSC.activityLogs).doc(logId).set({
        'logId': logId,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'schoolId': schoolId,
        'performedByUid': performedByUid,
        'performedByName': performedByName,
        if (oldData != null) 'oldData': oldData,
        if (newData != null) 'newData': newData,
        if (note != null) 'note': note,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Never let audit-log failures break the main operation.
    }
  }

  // ════════════════════════════════════════════════════
  //  SCHOOLS
  // ════════════════════════════════════════════════════

  Future<void> createSchool(School school) async {
    await _db
        .collection(FSC.schools)
        .doc(school.schoolId)
        .set(school.toFirestore());
  }

  Future<School?> getSchool(String schoolId) async {
    final doc = await _db.collection(FSC.schools).doc(schoolId).get();
    if (!doc.exists) return null;
    return School.fromFirestore(doc);
  }

  Stream<List<School>> streamAllSchools() {
    return _db.collection(FSC.schools).snapshots().map((s) {
      final schools = <School>[];
      for (final doc in s.docs) {
        try {
          schools.add(School.fromFirestore(doc));
        } catch (_) {
          // Skip malformed documents (e.g. missing required fields)
        }
      }
      return schools;
    });
  }

  // ════════════════════════════════════════════════════
  //  USERS
  // ════════════════════════════════════════════════════

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(FSC.users).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> streamUser(String uid) {
    return _db
        .collection(FSC.users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Stream<List<UserModel>> streamSchoolTeachers(String schoolId) {
    return _db
        .collection(FSC.users)
        .where('schoolId', isEqualTo: schoolId)
        .where('role', whereIn: ['TEACHER', 'PRINCIPAL'])
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(UserModel.fromFirestore).toList());
  }

  // ════════════════════════════════════════════════════
  //  CLASSES
  // ════════════════════════════════════════════════════

  Future<String> createClass(ClassModel cls) async {
    final id = _uuid.v4();
    final withId = cls.copyWith(classId: id);
    await _db.collection(FSC.classes).doc(id).set(withId.toFirestore());
    return id;
  }

  Future<void> updateClass(ClassModel cls) async {
    await _db
        .collection(FSC.classes)
        .doc(cls.classId)
        .update(cls.toFirestore());
  }

  Stream<List<ClassModel>> streamSchoolClasses(String schoolId) {
    return _db
        .collection(FSC.classes)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((s) => s.docs.map(ClassModel.fromFirestore).toList());
  }

  Stream<List<ClassModel>> streamTeacherClasses(
    String schoolId,
    String teacherUid,
  ) {
    return _db
        .collection(FSC.classes)
        .where('schoolId', isEqualTo: schoolId)
        .where('classTeacherUid', isEqualTo: teacherUid)
        .snapshots()
        .map((s) => s.docs.map(ClassModel.fromFirestore).toList());
  }

  Future<ClassModel?> getClass(String classId) async {
    if (classId.isEmpty) return null;
    final doc = await _db.collection(FSC.classes).doc(classId).get();
    if (!doc.exists) return null;
    return ClassModel.fromFirestore(doc);
  }

  // ════════════════════════════════════════════════════
  //  STUDENTS
  // ════════════════════════════════════════════════════

  Future<String> createStudent(
    Student student, {
    required String createdBy,
    required String createdByName,
  }) async {
    AppLogger.i(
      'Firestore',
      'createStudent name=${student.name} class=${student.classId}',
    );
    final id = _uuid.v4();
    final withId = student.copyWith(studentId: id);
    final data = withId.toFirestore();
    data['createdBy'] = createdBy;
    data['createdByName'] = createdByName;
    data['createdTimestamp'] = FieldValue.serverTimestamp();
    data['modifiedBy'] = createdBy;
    data['modifiedByName'] = createdByName;
    data['modifiedTimestamp'] = FieldValue.serverTimestamp();
    await _db.collection(FSC.students).doc(id).set(data);

    // Increment class student count
    await _db.collection(FSC.classes).doc(student.classId).update({
      'studentCount': FieldValue.increment(1),
    });

    return id;
  }

  Future<void> updateStudent(
    Student student, {
    required String modifiedBy,
    required String modifiedByName,
  }) async {
    final data = student.toFirestore();
    data['modifiedBy'] = modifiedBy;
    data['modifiedByName'] = modifiedByName;
    data['modifiedTimestamp'] = FieldValue.serverTimestamp();
    await _db.collection(FSC.students).doc(student.studentId).update(data);
  }

  Stream<List<Student>> streamStudentsByClass(String classId) {
    return _db
        .collection(FSC.students)
        .where('classId', isEqualTo: classId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(Student.fromFirestore).toList());
  }

  // Force a server-read for students — bypasses stale local cache.
  Future<List<Student>> fetchStudentsByClass(String classId) async {
    final snap = await _db
        .collection(FSC.students)
        .where('classId', isEqualTo: classId)
        .where('isActive', isEqualTo: true)
        .get(const GetOptions(source: Source.server));
    return snap.docs.map(Student.fromFirestore).toList();
  }

  Stream<List<Student>> streamAllStudentsByClass(String classId) {
    return _db
        .collection(FSC.students)
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((s) => s.docs.map(Student.fromFirestore).toList());
  }

  Stream<Map<String, String>> streamStudentNameMapForSchool(String schoolId) {
    return _db
        .collection(FSC.students)
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) {
      return {
        for (final doc in s.docs)
          doc.id: (doc.data()['name'] as String? ?? ''),
      };
    });
  }

  Future<Student?> getStudentById(String studentId) async {
    final doc = await _db.collection(FSC.students).doc(studentId).get();
    if (!doc.exists) return null;
    return Student.fromFirestore(doc);
  }

  Future<Student?> getStudentByParent(String parentUid) async {
    final snap = await _db
        .collection(FSC.students)
        .where('parentUid', isEqualTo: parentUid)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Student.fromFirestore(snap.docs.first);
  }

  Future<Student?> getStudent(String studentId) async {
    final doc = await _db.collection(FSC.students).doc(studentId).get();
    if (!doc.exists) return null;
    return Student.fromFirestore(doc);
  }

  /// Returns the raw Firestore data for a student (includes motherPhone, fatherPhone, etc.)
  Future<Map<String, dynamic>?> getStudentRawDoc(String studentId) async {
    final doc = await _db.collection(FSC.students).doc(studentId).get();
    if (!doc.exists) return null;
    final data = Map<String, dynamic>.from(doc.data() as Map);
    data['studentId'] = doc.id;
    return data;
  }

  // Creates a parent invitation linked to the given student
  Future<String> createParentInvitation({
    required String schoolId,
    required String phone,
    required String studentId,
    required String createdBy,
    String inviteeName = '',
  }) async {
    final id = _uuid.v4();
    final token = _uuid.v4();
    final invitation = Invitation(
      inviteId: id,
      schoolId: schoolId,
      role: InvitationRole.PARENT,
      email: '',
      phone: phone,
      token: token,
      createdBy: createdBy,
      linkedEntityId: studentId,
      inviteeName: inviteeName,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
    );
    await _db.collection(FSC.invitations).doc(id).set(invitation.toFirestore());
    return id;
  }

  Future<void> updateMedicalHistory(
    String studentId,
    MedicalHistory medical,
  ) async {
    await _db.collection(FSC.students).doc(studentId).update({
      'medicalHistory': medical.toJson(),
    });
  }

  // Creates a staff invitation (PRINCIPAL, ADMIN, or TEACHER role)
  Future<String> createStaffInvitation({
    required String schoolId,
    required String phone,
    required InvitationRole role,
    required String createdBy,
    String inviteeName = '',
  }) async {
    final id = _uuid.v4();
    final token = _uuid.v4();
    final invitation = Invitation(
      inviteId: id,
      schoolId: schoolId,
      role: role,
      email: '',
      phone: phone,
      token: token,
      createdBy: createdBy,
      inviteeName: inviteeName,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
    );
    await _db.collection(FSC.invitations).doc(id).set(invitation.toFirestore());
    return id;
  }

  // Stream all invitations for a school
  Stream<List<Invitation>> streamSchoolInvitations(String schoolId) {
    return _db
        .collection(FSC.invitations)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((s) {
          final list = s.docs.map(Invitation.fromFirestore).toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  // Stream ALL classes where a teacher is involved (class teacher, subject teacher, or proctor)
  Stream<List<ClassModel>> streamAllClassesForTeacher(
    String schoolId,
    String teacherUid,
  ) {
    return _db
        .collection(FSC.classes)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((s) {
          return s.docs.map(ClassModel.fromFirestore).where((cls) {
            if (cls.classTeacherUid == teacherUid) return true;
            if (cls.proctorTeacherUid == teacherUid) return true;
            return cls.subjectTeachers.any((st) => st.teacherUid == teacherUid);
          }).toList();
        });
  }

  // Stream ADMIN + TEACHER users for a school
  Stream<List<UserModel>> streamSchoolStaff(String schoolId) {
    return _db
        .collection(FSC.users)
        .where('schoolId', isEqualTo: schoolId)
        .where(
          'role',
          whereIn: ['ADMIN', 'TEACHER', 'ADMINISTRATOR', 'MANAGEMENT'],
        )
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(UserModel.fromFirestore).toList());
  }

  // Stream the principal of a school
  Stream<UserModel?> streamSchoolPrincipal(String schoolId) {
    return _db
        .collection(FSC.users)
        .where('schoolId', isEqualTo: schoolId)
        .where('role', isEqualTo: 'PRINCIPAL')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map(
          (s) => s.docs.isEmpty ? null : UserModel.fromFirestore(s.docs.first),
        );
  }

  Future<void> updateSchool(School school) async {
    await _db
        .collection(FSC.schools)
        .doc(school.schoolId)
        .update(school.toFirestore());
  }

  Future<void> updateSchoolPlan(String schoolId, String plan) async {
    await _db.collection(FSC.schools).doc(schoolId).update({'plan': plan});
  }

  // ════════════════════════════════════════════════════
  //  ATTENDANCE
  // ════════════════════════════════════════════════════

  String _attendanceSessionId(String classId, DateTime date) {
    final d =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${classId}_$d';
  }

  Future<void> saveAttendanceSession(AttendanceSession session) async {
    AppLogger.i(
      'Firestore',
      'saveAttendanceSession class=${session.classId} students=${session.records.length}',
    );
    final id = _attendanceSessionId(session.classId, session.date);
    final withId = session.copyWith(sessionId: id);
    await _db
        .collection(FSC.attendance)
        .doc(session.classId)
        .collection(FSC.sessions)
        .doc(id)
        .set(withId.toFirestore());
  }

  Future<void> updateAttendanceSession(AttendanceSession session) async {
    final id = _attendanceSessionId(session.classId, session.date);
    await _db
        .collection(FSC.attendance)
        .doc(session.classId)
        .collection(FSC.sessions)
        .doc(id)
        .update({...session.toFirestore(), 'isUpdated': true});
  }

  Future<AttendanceSession?> getAttendanceSession(
    String classId,
    DateTime date,
  ) async {
    final id = _attendanceSessionId(classId, date);
    final doc = await _db
        .collection(FSC.attendance)
        .doc(classId)
        .collection(FSC.sessions)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return AttendanceSession.fromFirestore(doc);
  }

  Stream<AttendanceSession?> streamAttendanceSession(
    String classId,
    DateTime date,
  ) {
    if (classId.isEmpty) return Stream.value(null);
    final id = _attendanceSessionId(classId, date);
    return _db
        .collection(FSC.attendance)
        .doc(classId)
        .collection(FSC.sessions)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? AttendanceSession.fromFirestore(doc) : null);
  }

  Stream<List<AttendanceSession>> streamMonthAttendance(
    String classId,
    DateTime month,
  ) {
    if (classId.isEmpty) return Stream.value([]);
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return _db
        .collection(FSC.attendance)
        .doc(classId)
        .collection(FSC.sessions)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          isLessThan: Timestamp.fromDate(end),
        )
        .snapshots()
        .map((s) => s.docs.map(AttendanceSession.fromFirestore).toList());
  }

  // ════════════════════════════════════════════════════
  //  LEAVE REQUESTS
  // ════════════════════════════════════════════════════

  Future<String> submitLeaveRequest(LeaveRequest request) async {
    final id = _uuid.v4();
    final withId = request.copyWith(requestId: id, createdAt: DateTime.now());
    await _db.collection(FSC.leaveRequests).doc(id).set(withId.toFirestore());
    return id;
  }

  Stream<List<LeaveRequest>> streamPendingLeaves(String classId) {
    return _db
        .collection(FSC.leaveRequests)
        .where('classId', isEqualTo: classId)
        .where('status', isEqualTo: 'PENDING')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(LeaveRequest.fromFirestore).toList());
  }

  Stream<List<LeaveRequest>> streamParentLeaves(String parentUid) {
    return _db
        .collection(FSC.leaveRequests)
        .where('parentUid', isEqualTo: parentUid)
        .snapshots()
        .map((s) {
          final list = s.docs.map(LeaveRequest.fromFirestore).toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  Future<void> reviewLeave(
    String requestId,
    LeaveStatus status,
    String reviewerUid, {
    String note = '',
  }) async {
    await _db.collection(FSC.leaveRequests).doc(requestId).update({
      'status': status.name,
      'reviewedBy': reviewerUid,
      'reviewedAt': Timestamp.fromDate(DateTime.now()),
      'reviewNote': note,
    });
  }

  // ════════════════════════════════════════════════════
  //  EARLY PICKUP
  // ════════════════════════════════════════════════════

  Future<String> createPickupRequest(EarlyPickup pickup) async {
    final id = _uuid.v4();
    final withId = pickup.copyWith(requestId: id, createdAt: DateTime.now());
    await _db.collection(FSC.earlyPickup).doc(id).set(withId.toFirestore());
    return id;
  }

  Stream<List<EarlyPickup>> streamPendingPickups(String schoolId) {
    return _db
        .collection(FSC.earlyPickup)
        .where('schoolId', isEqualTo: schoolId)
        .where('status', isEqualTo: 'PENDING')
        .snapshots()
        .map((s) => s.docs.map(EarlyPickup.fromFirestore).toList());
  }

  Stream<List<EarlyPickup>> streamParentPickups(String parentUid) {
    return _db
        .collection(FSC.earlyPickup)
        .where('parentUid', isEqualTo: parentUid)
        .snapshots()
        .map((s) {
          final list = s.docs.map(EarlyPickup.fromFirestore).toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  Future<void> approvePickup(String requestId, String approverUid) async {
    await _db.collection(FSC.earlyPickup).doc(requestId).update({
      'status': 'APPROVED',
      'approvedBy': approverUid,
      'approvedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> rejectPickup(String requestId, String rejectedBy) async {
    await _db.collection(FSC.earlyPickup).doc(requestId).update({
      'status': 'REJECTED',
      'approvedBy': rejectedBy,
      'approvedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<EarlyPickup>> streamSchoolPickups(
    String schoolId, {
    String? status,
  }) {
    var query = _db
        .collection(FSC.earlyPickup)
        .where('schoolId', isEqualTo: schoolId);
    if (status != null) query = query.where('status', isEqualTo: status);
    return query.snapshots().map((s) {
      final list = s.docs.map(EarlyPickup.fromFirestore).toList();
      list.sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
      return list;
    });
  }

  Future<void> completePickup(String requestId) async {
    await _db.collection(FSC.earlyPickup).doc(requestId).update({
      'status': 'COMPLETED',
      'exitLoggedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ════════════════════════════════════════════════════
  //  EXIT ATTENDANCE
  // ════════════════════════════════════════════════════

  Future<void> logExit(ExitAttendance record) async {
    final id = _uuid.v4();
    final withId = record.copyWith(recordId: id);
    await _db.collection(FSC.exitAttendance).doc(id).set(withId.toFirestore());
  }

  Stream<List<ExitAttendance>> streamTodayExits(String schoolId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _db
        .collection(FSC.exitAttendance)
        .where('schoolId', isEqualTo: schoolId)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          isLessThan: Timestamp.fromDate(end),
        )
        .snapshots()
        .map((s) => s.docs.map(ExitAttendance.fromFirestore).toList());
  }

  Stream<List<ExitAttendance>> streamStudentExits(String studentId) {
    return _db
        .collection(FSC.exitAttendance)
        .where('studentId', isEqualTo: studentId)
        .limit(30)
        .snapshots()
        .map((s) {
          final list = s.docs.map(ExitAttendance.fromFirestore).toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  // ════════════════════════════════════════════════════
  //  LESSON PLANS
  // ════════════════════════════════════════════════════

  Future<String> saveLessonPlan(LessonPlan plan) async {
    final id = _uuid.v4();
    final withId = plan.copyWith(planId: id, createdAt: DateTime.now());
    await _db.collection(FSC.lessonPlans).doc(id).set(withId.toFirestore());
    return id;
  }

  Stream<List<LessonPlan>> streamClassLessonPlans(
    String classId, {
    String? subject,
  }) {
    return _db
        .collection(FSC.lessonPlans)
        .where('classId', isEqualTo: classId)
        .limit(60)
        .snapshots()
        .map((s) {
          var list = s.docs.map(LessonPlan.fromFirestore).toList();
          if (subject != null && subject.isNotEmpty) {
            list = list.where((p) => p.subject == subject).toList();
          }
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  Stream<List<LessonPlan>> streamTeacherLessonPlans(String teacherUid) {
    return _db
        .collection(FSC.lessonPlans)
        .where('teacherUid', isEqualTo: teacherUid)
        .limit(50)
        .snapshots()
        .map((s) {
          final list = s.docs.map(LessonPlan.fromFirestore).toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  // Stream pending leave requests for a school
  Stream<List<LeaveRequest>> streamPendingLeavesForSchool(String schoolId) {
    return _db
        .collection(FSC.leaveRequests)
        .where('schoolId', isEqualTo: schoolId)
        .where('status', isEqualTo: 'PENDING')
        .snapshots()
        .map((s) {
          final list = s.docs.map(LeaveRequest.fromFirestore).toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  // Stream ALL leave requests for a school (pending + history)
  Stream<List<LeaveRequest>> streamLeavesForSchool(String schoolId) {
    return _db
        .collection(FSC.leaveRequests)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((s) {
          final list = s.docs.map(LeaveRequest.fromFirestore).toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  // Stream ALL early-pickup requests for a school (all statuses)
  Stream<List<EarlyPickup>> streamAllSchoolPickups(String schoolId) {
    return _db
        .collection(FSC.earlyPickup)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((s) {
          final list = s.docs.map(EarlyPickup.fromFirestore).toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  // Stream ALL leave requests for a student (for multi-parent visibility)
  Stream<List<LeaveRequest>> streamStudentLeaves(String studentId) {
    return _db
        .collection(FSC.leaveRequests)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((s) {
          final list = s.docs.map(LeaveRequest.fromFirestore).toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  // Stream ALL early-pickup requests for a student (for multi-parent visibility)
  Stream<List<EarlyPickup>> streamStudentPickups(String studentId) {
    return _db
        .collection(FSC.earlyPickup)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((s) {
          final list = s.docs.map(EarlyPickup.fromFirestore).toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  // Stream ALL special requests for a student (for multi-parent visibility)
  Stream<List<SpecialRequest>> streamStudentSpecialRequests(String studentId) {
    return _db
        .collection('specialRequests')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((s) {
          final list = s.docs.map(SpecialRequest.fromFirestore).toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  // Get today's absent/leave student IDs for a class
  Future<Set<String>> getTodayAbsentStudentIds(String classId) async {
    final session = await getAttendanceSession(classId, DateTime.now());
    if (session == null) return {};
    return session.records
        .where(
          (r) =>
              r.status == AttendanceStatus.ABSENT ||
              r.status == AttendanceStatus.LEAVE,
        )
        .map((r) => r.studentId)
        .toSet();
  }

  // Get student IDs with an APPROVED leave that covers the given date
  Future<Set<String>> getApprovedLeaveStudentIdsForDate(
      String classId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final snapshot = await _db
        .collection(FSC.leaveRequests)
        .where('classId', isEqualTo: classId)
        .where('status', isEqualTo: 'APPROVED')
        .get();
    return snapshot.docs
        .map(LeaveRequest.fromFirestore)
        .where((req) {
          final from =
              DateTime(req.fromDate.year, req.fromDate.month, req.fromDate.day);
          final to =
              DateTime(req.toDate.year, req.toDate.month, req.toDate.day);
          return !dateOnly.isBefore(from) && !dateOnly.isAfter(to);
        })
        .map((req) => req.studentId)
        .toSet();
  }

  // Stream all students for a school (for search)
  Stream<List<Student>> streamSchoolStudents(String schoolId) {
    return _db
        .collection(FSC.students)
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(Student.fromFirestore).toList());
  }

  Stream<List<Student>> streamAllSchoolStudents(String schoolId) {
    return _db
        .collection(FSC.students)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((s) => s.docs.map(Student.fromFirestore).toList());
  }

  // ════════════════════════════════════════════════════
  //  STUDY MATERIALS
  // ════════════════════════════════════════════════════

  Future<String> saveStudyMaterial(Map<String, dynamic> data) async {
    AppLogger.i(
      'Firestore',
      'saveStudyMaterial title=${data['title']} class=${data['classId']} files=${(data['fileUrls'] as List?)?.length ?? 0}',
    );
    final id = _uuid.v4();
    data['materialId'] = id;
    data['createdAt'] = Timestamp.now();
    await _db.collection('studyMaterials').doc(id).set(data);
    return id;
  }

  Stream<List<Map<String, dynamic>>> streamClassStudyMaterials(String classId) {
    return _db
        .collection('studyMaterials')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((s) {
          final list = s.docs.map((doc) {
            final d = Map<String, dynamic>.from(doc.data());
            d['materialId'] = doc.id;
            return d;
          }).toList();
          list.sort((a, b) {
            final at = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bt = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bt.compareTo(at);
          });
          return list;
        });
  }

  Stream<List<Map<String, dynamic>>> streamTeacherStudyMaterials(
    String teacherUid,
  ) {
    return _db
        .collection('studyMaterials')
        .where('teacherUid', isEqualTo: teacherUid)
        .snapshots()
        .map((s) {
          final list = s.docs.map((doc) {
            final d = Map<String, dynamic>.from(doc.data());
            d['materialId'] = doc.id;
            return d;
          }).toList();
          list.sort((a, b) {
            final at = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bt = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bt.compareTo(at);
          });
          return list;
        });
  }

  // ════════════════════════════════════════════════════
  //  TEACHER PRIVATE NOTES
  // ════════════════════════════════════════════════════

  Future<void> saveTeacherNote(Map<String, dynamic> data) async {
    final id = _uuid.v4();
    data['noteId'] = id;
    data['createdAt'] = Timestamp.now();
    data['updatedAt'] = Timestamp.now();
    await _db.collection('teacherNotes').doc(id).set(data);
  }

  Future<void> updateTeacherNote(String noteId, String noteText) async {
    await _db.collection('teacherNotes').doc(noteId).update({
      'note': noteText,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteTeacherNote(String noteId) async {
    await _db.collection('teacherNotes').doc(noteId).delete();
  }

  Stream<List<Map<String, dynamic>>> streamTeacherStudentNotes(
    String teacherUid,
    String studentId,
  ) {
    return _db
        .collection('teacherNotes')
        .where('teacherUid', isEqualTo: teacherUid)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((doc) {
            final d = Map<String, dynamic>.from(doc.data());
            d['noteId'] = doc.id;
            return d;
          }).toList(),
        );
  }

  // ════════════════════════════════════════════════════
  //  GALLERY
  // ════════════════════════════════════════════════════

  Future<String> saveGalleryItem(Map<String, dynamic> data) async {
    final id = _uuid.v4();
    data['galleryId'] = id;
    data['createdAt'] = Timestamp.now();
    await _db.collection('gallery').doc(id).set(data);
    return id;
  }

  Stream<List<Map<String, dynamic>>> streamSchoolGallery(String schoolId) {
    return _db
        .collection('gallery')
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (s) => s.docs.map((doc) {
            final d = Map<String, dynamic>.from(doc.data());
            d['galleryId'] = doc.id;
            return d;
          }).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> streamClassGallery(String classId) {
    return _db
        .collection('gallery')
        .where('classId', isEqualTo: classId)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (s) => s.docs.map((doc) {
            final d = Map<String, dynamic>.from(doc.data());
            d['galleryId'] = doc.id;
            return d;
          }).toList(),
        );
  }

  // ════════════════════════════════════════════════════
  //  MARKS (class-level stream)
  // ════════════════════════════════════════════════════

  Stream<List<StudentMarks>> streamClassMarks(
    String classId,
    String academicYear,
    String term,
  ) {
    return _db
        .collection(FSC.marks)
        .where('classId', isEqualTo: classId)
        .where('academicYear', isEqualTo: academicYear)
        .where('term', isEqualTo: term)
        .snapshots()
        .map(
          (s) => s.docs
              .map((doc) => StudentMarks.fromFirestore(doc, doc.id))
              .toList(),
        );
  }

  // ════════════════════════════════════════════════════
  //  TIMETABLE — SUBSTITUTE COMMENTS
  // ════════════════════════════════════════════════════

  Future<void> addSubstituteComment({
    required String classId,
    required String day,
    required int periodNumber,
    required String substituteUid,
    required String substituteName,
    required String originalTeacherUid,
    required String comment,
    required DateTime date,
  }) async {
    final id = _uuid.v4();
    await _db.collection('substituteLog').doc(id).set({
      'logId': id,
      'classId': classId,
      'day': day,
      'periodNumber': periodNumber,
      'substituteUid': substituteUid,
      'substituteName': substituteName,
      'originalTeacherUid': originalTeacherUid,
      'comment': comment,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamSubstituteLogs(String classId) {
    return _db
        .collection('substituteLog')
        .where('classId', isEqualTo: classId)
        .orderBy('date', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (s) => s.docs.map((doc) {
            final d = Map<String, dynamic>.from(doc.data());
            d['logId'] = doc.id;
            return d;
          }).toList(),
        );
  }

  // ════════════════════════════════════════════════════
  //  ATTENDANCE — update with changed records tracking
  // ════════════════════════════════════════════════════

  /// Normalise a phone to both bare (10-digit) and E.164 (+91XXXXXXXXXX) forms.
  static List<String> _phoneVariants(String phone) {
    final p = phone.trim();
    if (p.isEmpty) return [];
    if (p.startsWith('+91') && p.length == 13) {
      return [p, p.substring(3)]; // +91XXXXXXXXXX and XXXXXXXXXX
    }
    if (p.startsWith('+') && p.length > 3) {
      return [p]; // some other country code — return as-is
    }
    if (p.length == 10) {
      return [p, '+91$p']; // bare 10-digit and E.164
    }
    return [p];
  }

  /// Given a set of phone numbers, returns a map of {variant → uid}
  /// (both bare and +91 forms) by querying the users collection.
  /// Tries both E.164 (+91XXXXXXXXXX) and bare (XXXXXXXXXX) formats so that
  /// student docs stored with one format still match users registered with the other.
  Future<Map<String, String>> _getParentUidsByPhones(
    List<String> phones,
  ) async {
    if (phones.isEmpty) return {};
    final result = <String, String>{};
    // Expand each phone to both variants then deduplicate
    final expanded = phones.expand(_phoneVariants).toSet().toList();
    AppLogger.d(
      'Firestore',
      '_getParentUidsByPhones: original=${phones.length} expanded=${expanded.length} variants=$expanded',
    );
    // Firestore whereIn limit is 30
    for (var i = 0; i < expanded.length; i += 30) {
      final chunk = expanded.sublist(i, (i + 30).clamp(0, expanded.length));
      try {
        final snap = await _db
            .collection(FSC.users)
            .where('phone', whereIn: chunk)
            .get();
        AppLogger.d(
          'Firestore',
          '_getParentUidsByPhones: chunk=$chunk → ${snap.docs.length} hits',
        );
        for (final doc in snap.docs) {
          final storedPhone = (doc.data()['phone'] as String?) ?? '';
          if (storedPhone.isNotEmpty) {
            // Map ALL variants of this phone to the uid
            for (final v in _phoneVariants(storedPhone)) {
              result[v] = doc.id;
            }
          }
        }
      } catch (e) {
        AppLogger.e(
          'Firestore',
          '_getParentUidsByPhones chunk query failed',
          error: e,
        );
      }
    }
    AppLogger.d(
      'Firestore',
      '_getParentUidsByPhones result: ${result.length} mappings',
    );
    return result;
  }

  /// Writes in-app notification docs for parents when attendance is saved.
  /// Each parent (matched via student.parentUid, motherPhone, fatherPhone)
  /// gets a doc in `notifications/{uid}/items/{id}` they can stream.
  Future<void> notifyParentsAttendance({
    required AttendanceSession session,
    required String className,
    required String teacherName,
  }) async {
    AppLogger.i(
      'Firestore',
      'notifyParentsAttendance class=$className students=${session.records.length}',
    );
    try {
      // Fetch only the students that have records in this session
      final studentIds = session.records.map((r) => r.studentId).toList();
      if (studentIds.isEmpty) return;

      // Firestore whereIn has a 30-item limit; chunk if needed
      final allDocs = <QueryDocumentSnapshot>[];
      for (var i = 0; i < studentIds.length; i += 30) {
        final chunk = studentIds.sublist(
          i,
          i + 30 > studentIds.length ? studentIds.length : i + 30,
        );
        final snap = await _db
            .collection(FSC.students)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        allDocs.addAll(snap.docs);
      }

      final dateStr =
          '${session.date.day}/${session.date.month}/${session.date.year}';
      final seenUids = <String>{};
      final phoneNotifMap = <String, Map<String, dynamic>>{};
      final sendFutures = <Future<void>>[];

      for (final doc in allDocs) {
        final data = doc.data() as Map<String, dynamic>;
        final studentName = (data['name'] as String?) ?? 'Your child';
        final parentUid = (data['parentUid'] as String?) ?? '';
        final record = session.records
            .where((r) => r.studentId == doc.id)
            .firstOrNull;
        if (record == null) continue;

        final statusLabel =
            {
              'PRESENT': 'Present ✅',
              'ABSENT': 'Absent ❌',
              'LEAVE': 'On Leave 📋',
            }[record.status.name] ??
            record.status.name;

        final title = 'Attendance Marked — $dateStr';
        final body = '$studentName is $statusLabel in $className';
        final extra = {
          'type': 'ATTENDANCE_MARKED',
          'studentId': doc.id,
          'classId': session.classId,
          'status': record.status.name,
        };

        if (parentUid.isNotEmpty && !seenUids.contains(parentUid)) {
          seenUids.add(parentUid);
          sendFutures.add(
            NotificationService.sendNotification(
              receiverUids: [parentUid],
              title: title,
              body: body,
              extra: extra,
            ),
          );
        }

        // Also collect phone numbers for fallback lookup
        final motherPhone = (data['motherPhone'] as String?) ?? '';
        final fatherPhone = (data['fatherPhone'] as String?) ?? '';
        if (parentUid.isEmpty) {
          if (motherPhone.isNotEmpty)
            phoneNotifMap[motherPhone] = {
              'title': title,
              'body': body,
              'extra': extra,
            };
          if (fatherPhone.isNotEmpty)
            phoneNotifMap[fatherPhone] = {
              'title': title,
              'body': body,
              'extra': extra,
            };
        }
      }

      // Look up parent UIDs by phone and notify any not already notified
      if (phoneNotifMap.isNotEmpty) {
        final phoneUidMap = await _getParentUidsByPhones(
          phoneNotifMap.keys.toList(),
        );
        for (final entry in phoneUidMap.entries) {
          final uid = entry.value;
          if (!seenUids.contains(uid)) {
            seenUids.add(uid);
            final nd = phoneNotifMap[entry.key]!;
            sendFutures.add(
              NotificationService.sendNotification(
                receiverUids: [uid],
                title: nd['title'] as String,
                body: nd['body'] as String,
                extra: nd['extra'] as Map<String, dynamic>,
              ),
            );
          }
        }
      }

      await Future.wait(sendFutures);
      AppLogger.i(
        'Firestore',
        'notifyParentsAttendance done — ${seenUids.length} parents notified',
      );
    } catch (e, st) {
      AppLogger.e(
        'Firestore',
        'notifyParentsAttendance failed',
        error: e,
        stack: st,
      );
    }
  }

  Future<void> updateAttendanceWithChanges({
    required AttendanceSession session,
    required List<String> changedStudentIds,
    required String teacherName,
  }) async {
    final id = _attendanceSessionId(session.classId, session.date);
    await _db
        .collection(FSC.attendance)
        .doc(session.classId)
        .collection(FSC.sessions)
        .doc(id)
        .update({
          ...session.toFirestore(),
          'isUpdated': true,
          'lastUpdatedBy': session.markedBy,
          'lastUpdatedByName': teacherName,
          'lastUpdatedAt': Timestamp.now(),
          'changedStudentIds': changedStudentIds,
        });
  }

  // all lesson plans for a school, optionally for a specific date
  Stream<List<LessonPlan>> streamSchoolLessonPlans(
    String schoolId, {
    DateTime? date,
  }) {
    return _db
        .collection(FSC.lessonPlans)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((s) {
          var list = s.docs.map(LessonPlan.fromFirestore).toList();
          if (date != null) {
            final start = DateTime(date.year, date.month, date.day);
            final end = start.add(const Duration(days: 1));
            list = list
                .where((p) => !p.date.isBefore(start) && p.date.isBefore(end))
                .toList();
          }
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  // ════════════════════════════════════════════════════
  //  ACHIEVEMENTS
  // ════════════════════════════════════════════════════

  Future<String> createAchievement(Map<String, dynamic> data) async {
    final id = _uuid.v4();
    data['createdAt'] = Timestamp.now();
    await _db.collection(FSC.achievements).doc(id).set(data);
    return id;
  }

  Stream<List<Map<String, dynamic>>> streamSchoolAchievements(String schoolId) {
    return _db
        .collection(FSC.achievements)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((s) {
          final list = s.docs.map((doc) {
            final d = doc.data();
            d['achievementId'] = doc.id;
            return d;
          }).toList();
          list.sort((a, b) {
            final at = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bt = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bt.compareTo(at);
          });
          return list;
        });
  }

  // ════════════════════════════════════════════════════
  //  ANNOUNCEMENTS
  // ════════════════════════════════════════════════════

  Future<String> createAnnouncement(Announcement announcement) async {
    AppLogger.i(
      'Firestore',
      'createAnnouncement title="${announcement.title}" audience=${announcement.audience.name} by=${announcement.createdByName}',
    );
    final id = _uuid.v4();
    final withId = announcement.copyWith(
      announcementId: id,
      publishedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await _db.collection(FSC.announcements).doc(id).set(withId.toFirestore());

    // Notify parents in-app
    unawaited(_notifyParentsAnnouncement(withId));
    unawaited(_notifyTeachersAnnouncement(withId));
    return id;
  }

  /// Writes in-app notification to each parent's notification feed
  /// when an announcement is created.
  Future<void> _notifyParentsAnnouncement(Announcement a) async {
    AppLogger.i(
      'Firestore',
      '_notifyParentsAnnouncement START title="${a.title}" audience=${a.audience.name} schoolId=${a.schoolId} targetClass=${a.targetClassId}',
    );
    try {
      // TEACHERS / STAFF audience — don't notify parents
      if (a.audience == AnnouncementAudience.TEACHERS ||
          a.audience == AnnouncementAudience.STAFF) {
        AppLogger.i(
          'Firestore',
          '_notifyParentsAnnouncement SKIP — staff-only audience',
        );
        return;
      }

      Query query = _db
          .collection(FSC.students)
          .where('schoolId', isEqualTo: a.schoolId)
          .where('isActive', isEqualTo: true);

      // CLASS audience — only notify parents in that class
      if (a.audience == AnnouncementAudience.CLASS &&
          a.targetClassId.isNotEmpty) {
        query = query.where('classId', isEqualTo: a.targetClassId);
      }

      final snap = await query.get();
      AppLogger.i(
        'Firestore',
        '_notifyParentsAnnouncement: found ${snap.docs.length} students',
      );

      final seen = <String>{};
      final phoneSet = <String>{};

      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final studentName = (data['name'] as String?) ?? doc.id;
        final parentUid = (data['parentUid'] as String?) ?? '';
        final motherPhone = (data['motherPhone'] as String?) ?? '';
        final fatherPhone = (data['fatherPhone'] as String?) ?? '';

        AppLogger.d(
          'Firestore',
          '_notifyParentsAnnouncement student=$studentName parentUid=${parentUid.isEmpty ? "EMPTY" : parentUid} motherPhone=$motherPhone fatherPhone=$fatherPhone',
        );

        if (parentUid.isNotEmpty) seen.add(parentUid);
        if (motherPhone.isNotEmpty) phoneSet.add(motherPhone);
        if (fatherPhone.isNotEmpty) phoneSet.add(fatherPhone);
      }

      // Add UIDs discovered via phone lookup
      AppLogger.i(
        'Firestore',
        '_notifyParentsAnnouncement: phone lookup for ${phoneSet.length} phones',
      );
      if (phoneSet.isNotEmpty) {
        final phoneUidMap = await _getParentUidsByPhones(phoneSet.toList());
        AppLogger.i(
          'Firestore',
          '_notifyParentsAnnouncement: phone→uid map has ${phoneUidMap.length} entries',
        );
        for (final uid in phoneUidMap.values) {
          seen.add(uid);
        }
      }

      await NotificationService.sendNotification(
        receiverUids: seen.toList(),
        title: 'New Announcement: ${a.title}',
        body: a.body.length > 100 ? '${a.body.substring(0, 100)}…' : a.body,
        extra: {
          'type': 'ANNOUNCEMENT',
          'announcementId': a.announcementId,
          'requiresAck': a.requiresAck,
        },
      );
      AppLogger.i(
        'Firestore',
        '_notifyParentsAnnouncement DONE — ${seen.length} unique parents notified',
      );
    } catch (e, st) {
      AppLogger.e(
        'Firestore',
        '_notifyParentsAnnouncement FAILED',
        error: e,
        stack: st,
      );
    }
  }

  /// Notifies staff when an announcement targets TEACHERS, STAFF, or ALL.
  ///
  /// TEACHERS → only role == 'TEACHER'
  /// STAFF    → all roles except PARENT and SUPER_ADMIN
  /// ALL      → same as STAFF (parents handled separately via _notifyParentsAnnouncement)
  Future<void> _notifyTeachersAnnouncement(Announcement a) async {
    try {
      if (a.audience != AnnouncementAudience.TEACHERS &&
          a.audience != AnnouncementAudience.STAFF &&
          a.audience != AnnouncementAudience.ALL) {
        return;
      }

      final snap = await _db
          .collection(FSC.users)
          .where('schoolId', isEqualTo: a.schoolId)
          .where('isActive', isEqualTo: true)
          .get();

      const staffRoles = {
        'TEACHER',
        'ADMIN',
        'PRINCIPAL',
        'ADMINISTRATOR',
        'MANAGEMENT',
      };

      final targetUids = <String>[];
      for (final doc in snap.docs) {
        final role =
            (doc.data() as Map<String, dynamic>)['role'] as String? ?? '';
        final shouldInclude = a.audience == AnnouncementAudience.TEACHERS
            ? role == 'TEACHER'
            : staffRoles.contains(role);
        if (shouldInclude) targetUids.add(doc.id);
      }

      if (targetUids.isEmpty) return;

      await NotificationService.sendNotification(
        receiverUids: targetUids,
        title: 'New Announcement: ${a.title}',
        body: a.body.length > 100 ? '${a.body.substring(0, 100)}…' : a.body,
        extra: {
          'type': 'ANNOUNCEMENT',
          'announcementId': a.announcementId,
          'requiresAck': a.requiresAck,
        },
      );
    } catch (e) {
      AppLogger.e('Firestore', '_notifyTeachersAnnouncement FAILED', error: e);
    }
  }

  // Stream ALL announcements for a school (principal / admin view)
  Stream<List<Announcement>> streamSchoolAllAnnouncements(String schoolId) {
    return _db
        .collection(FSC.announcements)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((s) {
          final list = <Announcement>[];
          for (final doc in s.docs) {
            try {
              list.add(Announcement.fromFirestore(doc));
            } catch (_) {}
          }
          list.sort(
            (a, b) => (b.publishedAt ?? DateTime(0)).compareTo(
              a.publishedAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  Stream<List<Announcement>> streamAnnouncementsForParent(
    String schoolId,
    String classId,
  ) {
    return _db
        .collection(FSC.announcements)
        .where('schoolId', isEqualTo: schoolId)
        .limit(50)
        .snapshots()
        .map((s) {
          final list = s.docs
              .map(Announcement.fromFirestore)
              .where(
                (a) =>
                    a.audience == AnnouncementAudience.ALL ||
                    a.audience == AnnouncementAudience.PARENTS ||
                    (a.audience == AnnouncementAudience.CLASS &&
                        a.targetClassId == classId),
              )
              .toList();
          list.sort(
            (a, b) => (b.publishedAt ?? DateTime(0)).compareTo(
              a.publishedAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  Stream<List<Announcement>> streamAnnouncementsForTeacher(String schoolId) {
    return _db
        .collection(FSC.announcements)
        .where('schoolId', isEqualTo: schoolId)
        .limit(50)
        .snapshots()
        .map((s) {
          final list = s.docs
              .map(Announcement.fromFirestore)
              .where(
                (a) =>
                    a.audience == AnnouncementAudience.ALL ||
                    a.audience == AnnouncementAudience.TEACHERS,
              )
              .toList();
          list.sort(
            (a, b) => (b.publishedAt ?? DateTime(0)).compareTo(
              a.publishedAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  Future<void> acknowledgeAnnouncement(
    String announcementId,
    String uid,
  ) async {
    await _db.collection(FSC.announcements).doc(announcementId).update({
      'ackedBy': FieldValue.arrayUnion([uid]),
    });
  }

  /// Returns per-student (and per-teacher) ack detail for an announcement.
  ///
  /// For PARENTS / ALL / CLASS audience: fetches students, checks if any of
  /// their parent UIDs (parentUid or phone-based lookup) appear in ackedBy.
  ///
  /// For TEACHERS audience: fetches school teachers, checks if their UIDs
  /// appear in ackedBy.
  ///
  /// Returns a list of maps with keys:
  ///   type: 'student' | 'teacher'
  ///   id, name, subLabel (class name / role), isAcked: bool
  Future<List<Map<String, dynamic>>> getAnnouncementAckDetail({
    required String announcementId,
    required String schoolId,
    required String audience, // 'ALL', 'PARENTS', 'TEACHERS', 'CLASS'
    String? classId,
  }) async {
    // Fetch ackedBy list from announcement
    final announcementDoc = await _db
        .collection(FSC.announcements)
        .doc(announcementId)
        .get();
    final ackedBy = List<String>.from(announcementDoc.data()?['ackedBy'] ?? []);

    final result = <Map<String, dynamic>>[];

    if (audience == 'TEACHERS') {
      // Fetch all active teachers in the school
      final teachersSnap = await _db
          .collection(FSC.users)
          .where('schoolId', isEqualTo: schoolId)
          .where('role', isEqualTo: 'TEACHER')
          .where('isActive', isEqualTo: true)
          .get();
      for (final doc in teachersSnap.docs) {
        final data = doc.data();
        result.add({
          'type': 'teacher',
          'id': doc.id,
          'name': (data['name'] as String?) ?? 'Teacher',
          'subLabel': 'Teacher',
          'isAcked': ackedBy.contains(doc.id),
        });
      }
      result.sort(
        (a, b) =>
            (a['isAcked'] as bool ? 1 : 0) - (b['isAcked'] as bool ? 1 : 0),
      );
      return result;
    }

    // For PARENTS / ALL / CLASS — fetch students
    Query<Map<String, dynamic>> query = _db
        .collection(FSC.students)
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true);
    if (audience == 'CLASS' && classId != null && classId.isNotEmpty) {
      query = query.where('classId', isEqualTo: classId);
    }
    final studentsSnap = await query.get();

    // Collect phones for bulk UID lookup
    final phones = <String>{};
    for (final doc in studentsSnap.docs) {
      final data = doc.data();
      final mp = (data['motherPhone'] as String?) ?? '';
      final fp = (data['fatherPhone'] as String?) ?? '';
      if (mp.isNotEmpty) phones.add(mp);
      if (fp.isNotEmpty) phones.add(fp);
    }
    final phoneToUid = await _getParentUidsByPhones(phones.toList());

    for (final doc in studentsSnap.docs) {
      final data = doc.data();
      final studentName = (data['name'] as String?) ?? 'Student';
      final className = (data['className'] as String?) ?? '';
      final section = (data['section'] as String?) ?? '';
      final displayClass = section.isNotEmpty
          ? '$className $section'
          : className;
      final parentUid = (data['parentUid'] as String?) ?? '';
      final motherPhone = (data['motherPhone'] as String?) ?? '';
      final fatherPhone = (data['fatherPhone'] as String?) ?? '';
      final motherName = (data['motherName'] as String?) ?? 'Mother';
      final fatherName = (data['fatherName'] as String?) ?? 'Father';

      // Collect all possible parent UIDs for this student
      final parentEntries = <Map<String, String>>[];
      if (parentUid.isNotEmpty) {
        parentEntries.add({'uid': parentUid, 'label': 'Parent'});
      }
      if (motherPhone.isNotEmpty && phoneToUid.containsKey(motherPhone)) {
        final uid = phoneToUid[motherPhone]!;
        if (!parentEntries.any((e) => e['uid'] == uid)) {
          parentEntries.add({'uid': uid, 'label': motherName});
        }
      }
      if (fatherPhone.isNotEmpty && phoneToUid.containsKey(fatherPhone)) {
        final uid = phoneToUid[fatherPhone]!;
        if (!parentEntries.any((e) => e['uid'] == uid)) {
          parentEntries.add({'uid': uid, 'label': fatherName});
        }
      }

      // Check ack
      final ackedEntry = parentEntries
          .where((e) => ackedBy.contains(e['uid']!))
          .toList();
      final isAcked = ackedEntry.isNotEmpty;
      final ackedByLabel = ackedEntry.isNotEmpty
          ? ackedEntry.first['label'] ?? ''
          : '';

      result.add({
        'type': 'student',
        'id': doc.id,
        'name': studentName,
        'subLabel': displayClass,
        'isAcked': isAcked,
        'ackedByLabel': ackedByLabel, // "Mother" / "Father" / "Parent"
      });
    }

    // Sort: pending first, then acked
    result.sort(
      (a, b) => (a['isAcked'] as bool ? 1 : 0) - (b['isAcked'] as bool ? 1 : 0),
    );
    return result;
  }

  // ════════════════════════════════════════════════════
  //  CHAT
  // ════════════════════════════════════════════════════

  String _chatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<Chat> getOrCreateChat(
    String schoolId,
    String uid1,
    String role1,
    String uid2,
    String role2,
  ) async {
    final chatId = _chatId(uid1, uid2);
    final doc = await _db.collection(FSC.chats).doc(chatId).get();

    if (doc.exists) return Chat.fromFirestore(doc);

    final chat = Chat(
      chatId: chatId,
      schoolId: schoolId,
      participantUids: [uid1, uid2],
      participantRoles: {uid1: role1, uid2: role2},
      lastMessageAt: DateTime.now(),
    );

    await _db.collection(FSC.chats).doc(chatId).set(chat.toFirestore());
    return chat;
  }

  Stream<List<Chat>> streamMyChats(String uid) {
    return _db
        .collection(FSC.chats)
        .where('participantUids', arrayContains: uid)
        .snapshots()
        .map((s) {
          final chats = s.docs.map(Chat.fromFirestore).toList();
          chats.sort(
            (a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(
              a.lastMessageAt ?? DateTime(0),
            ),
          );
          return chats;
        });
  }

  Stream<List<ChatMessage>> streamMessages(String chatId) {
    return _db
        .collection(FSC.chats)
        .doc(chatId)
        .collection(FSC.messages)
        .orderBy('sentAt')
        .snapshots()
        .map((s) => s.docs.map(ChatMessage.fromFirestore).toList());
  }

  Future<void> sendMessage(String chatId, ChatMessage message) async {
    AppLogger.d(
      'Chat',
      'sendMessage chatId=$chatId sender=${message.senderId}',
    );
    final id = _uuid.v4();
    final withId = message.copyWith(messageId: id);

    // Get chat to find recipient
    final chatDoc = await _db.collection(FSC.chats).doc(chatId).get();
    final chatData = chatDoc.data() as Map<String, dynamic>?;
    final participantUids = List<String>.from(
      chatData?['participantUids'] ?? [],
    );
    final recipientUid = participantUids.firstWhere(
      (uid) => uid != message.senderId,
      orElse: () => '',
    );

    final batch = _db.batch();

    // Save message
    batch.set(
      _db.collection(FSC.chats).doc(chatId).collection(FSC.messages).doc(id),
      withId.toFirestore(),
    );

    // Update chat metadata + increment recipient unread count
    final unreadKey = 'unreadCount.$recipientUid';
    batch.update(_db.collection(FSC.chats).doc(chatId), {
      'lastMessage': message.text,
      'lastMessageAt': Timestamp.fromDate(message.sentAt),
      unreadKey: FieldValue.increment(1),
    });

    await batch.commit();

    // Write in-app notification for recipient
    if (recipientUid.isNotEmpty) {
      final roles = Map<String, String>.from(
        chatData?['participantRoles'] ?? {},
      );
      final senderRole = roles[message.senderId] ?? '';
      final preview = message.text.length > 60
          ? '${message.text.substring(0, 60)}…'
          : message.text;
      unawaited(
        NotificationService.sendNotification(
          receiverUids: [recipientUid],
          title: 'New message from ${_roleName(senderRole)}',
          body: preview,
          extra: {
            'type': 'NEW_MESSAGE',
            'chatId': chatId,
            'senderId': message.senderId,
          },
        ),
      );
    }
  }

  String _roleName(String role) {
    switch (role.toUpperCase()) {
      case 'PARENT':
        return 'Parent';
      case 'TEACHER':
        return 'Teacher';
      case 'ADMIN':
        return 'Admin';
      default:
        return 'User';
    }
  }

  /// Mark all messages in a chat NOT sent by [myUid] as read, and reset unread count.
  Future<void> markMessagesRead(String chatId, String myUid) async {
    final unreadSnap = await _db
        .collection(FSC.chats)
        .doc(chatId)
        .collection(FSC.messages)
        .where('senderId', isNotEqualTo: myUid)
        .get();

    final batch = _db.batch();
    final now = Timestamp.now();
    for (final doc in unreadSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['readAt'] == null) {
        batch.update(doc.reference, {'readAt': now});
      }
    }
    // Reset unread count for me
    batch.update(_db.collection(FSC.chats).doc(chatId), {
      'unreadCount.$myUid': 0,
    });
    await batch.commit();
  }

  /// Returns active parents/guardians for a student who have logged into the app.
  /// Each entry contains the UserModel and their relationship label.
  /// Only returns entries where the parent has an active app account.
  Future<List<Map<String, dynamic>>> getActiveParentsForStudent(
    String studentId,
  ) async {
    final studentDoc = await _db.collection(FSC.students).doc(studentId).get();
    if (!studentDoc.exists) return [];
    final data = studentDoc.data() as Map<String, dynamic>;

    final motherPhone = (data['motherPhone'] as String?) ?? '';
    final fatherPhone = (data['fatherPhone'] as String?) ?? '';
    final guardianPhone = (data['guardianPhone'] as String?) ?? '';
    final guardianName = (data['guardianName'] as String?) ?? '';

    final results = <Map<String, dynamic>>[];

    Future<UserModel?> findActiveUser(String phone) async {
      if (phone.isEmpty) return null;
      final snap = await _db
          .collection(FSC.users)
          .where('phone', isEqualTo: phone)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return UserModel.fromFirestore(snap.docs.first);
    }

    final mother = await findActiveUser(motherPhone);
    if (mother != null) {
      results.add({'user': mother, 'relationship': 'Mother'});
    }

    if (fatherPhone.isNotEmpty && fatherPhone != motherPhone) {
      final father = await findActiveUser(fatherPhone);
      if (father != null) {
        results.add({'user': father, 'relationship': 'Father'});
      }
    }

    if (guardianPhone.isNotEmpty &&
        guardianPhone != motherPhone &&
        guardianPhone != fatherPhone) {
      final guardian = await findActiveUser(guardianPhone);
      if (guardian != null) {
        final label = guardianName.isNotEmpty
            ? 'Guardian ($guardianName)'
            : 'Guardian';
        results.add({'user': guardian, 'relationship': label});
      }
    }

    return results;
  }

  // ════════════════════════════════════════════════════
  //  IN-APP NOTIFICATIONS (parent stream)
  // ════════════════════════════════════════════════════

  Stream<List<Map<String, dynamic>>> streamParentNotifications(String uid) {
    AppLogger.d('Firestore', 'streamParentNotifications uid=$uid');
    return _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .snapshots()
        .map((s) {
          final list = s.docs.map((doc) {
            final d = Map<String, dynamic>.from(doc.data());
            d['notifId'] = doc.id;
            return d;
          }).toList();
          list.sort((a, b) {
            final at = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bt = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bt.compareTo(at);
          });
          return list;
        });
  }

  Future<void> markParentNotificationRead(String uid, String notifId) async {
    await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .doc(notifId)
        .update({'isRead': true});
  }

  /// Streams count of unread NEW_MESSAGE notifications for a teacher/user.
  Stream<int> streamUnreadChatNotificationsCount(String uid) {
    return _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('type', isEqualTo: 'NEW_MESSAGE')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// Marks all NEW_MESSAGE notifications as read for a user.
  Future<void> markChatNotificationsRead(String uid) async {
    final snap = await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('type', isEqualTo: 'NEW_MESSAGE')
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    if (snap.docs.isNotEmpty) await batch.commit();
  }

  /// Returns absent/leave students across all teacher's classes for a given date,
  /// including student name and class name.
  Future<List<Map<String, dynamic>>> getAbsentStudentsForTeacher(
    String schoolId,
    String teacherUid,
    DateTime date,
  ) async {
    final classes = await streamAllClassesForTeacher(
      schoolId,
      teacherUid,
    ).first;
    final result = <Map<String, dynamic>>[];

    for (final cls in classes) {
      final session = await getAttendanceSession(cls.classId, date);
      if (session == null) continue;
      final absentRecords = session.records
          .where(
            (r) =>
                r.status == AttendanceStatus.ABSENT ||
                r.status == AttendanceStatus.LEAVE,
          )
          .toList();
      if (absentRecords.isEmpty) continue;

      // Fetch students for name lookup
      final students = await streamStudentsByClass(cls.classId).first;
      final nameMap = {for (final s in students) s.studentId: s.name};

      for (final rec in absentRecords) {
        result.add({
          'studentId': rec.studentId,
          'name': nameMap[rec.studentId] ?? rec.studentId,
          'classId': cls.classId,
          'className': cls.name,
          'status': rec.status.name,
        });
      }
    }
    return result;
  }

  // ════════════════════════════════════════════════════
  //  TIMETABLE
  // ════════════════════════════════════════════════════

  Future<void> saveTimetable(Timetable timetable) async {
    await _db
        .collection(FSC.timetable)
        .doc(timetable.classId)
        .set(timetable.toFirestore());
  }

  Stream<Timetable?> streamTimetable(String classId) {
    if (classId.isEmpty) return Stream.value(null);
    return _db
        .collection(FSC.timetable)
        .doc(classId)
        .snapshots()
        .map((doc) => doc.exists ? Timetable.fromFirestore(doc) : null);
  }

  // ════════════════════════════════════════════════════
  //  SUBJECT ENROLLMENTS (Elective subjects)
  // ════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> getSubjectEnrollment(String docId) async {
    final doc = await _db.collection('subjectEnrollments').doc(docId).get();
    if (!doc.exists) return null;
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> saveSubjectEnrollment({
    required String docId,
    required String classId,
    required String schoolId,
    required String subjectName,
    required List<String> excludedStudentIds,
  }) async {
    await _db.collection('subjectEnrollments').doc(docId).set({
      'classId': classId,
      'schoolId': schoolId,
      'subjectName': subjectName,
      'excludedStudentIds': excludedStudentIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Returns excluded student IDs for a specific subject in a class.
  /// Students NOT in the excluded list are enrolled in the subject.
  Future<Set<String>> getExcludedStudentsForSubject(
    String classId,
    String subjectName,
  ) async {
    final safeSub = subjectName.toLowerCase().replaceAll(' ', '_');
    final docId = '${classId}_$safeSub';
    final doc = await _db.collection('subjectEnrollments').doc(docId).get();
    if (!doc.exists) return {};
    final data = doc.data() as Map<String, dynamic>;
    final excluded =
        (data['excludedStudentIds'] as List<dynamic>?)?.cast<String>() ?? [];
    return Set<String>.from(excluded);
  }

  // ════════════════════════════════════════════════════
  //  FEES
  // ════════════════════════════════════════════════════

  Future<String> createFeeRecord(Fee fee) async {
    final id = _uuid.v4();
    final withId = fee.copyWith(feeId: id, updatedAt: DateTime.now());
    await _db.collection(FSC.fees).doc(id).set(withId.toFirestore());
    return id;
  }

  /// Records a payment atomically using a Firestore transaction to prevent
  /// race conditions (double-charging) when multiple admins record simultaneously.
  Future<void> recordPayment(String feeId, Payment payment) async {
    await _db.runTransaction((txn) async {
      final feeRef = _db.collection(FSC.fees).doc(feeId);
      final snap = await txn.get(feeRef);
      if (!snap.exists) throw Exception('Fee record not found: $feeId');

      final current = Fee.fromFirestore(snap);

      // Guard: prevent overpayment
      if (payment.amount > current.totalPending + 0.01) {
        throw Exception(
          'Payment amount ₹${payment.amount} exceeds pending balance ₹${current.totalPending}',
        );
      }

      final newPaid = current.totalPaid + payment.amount;
      final newPending = (current.totalAmount - newPaid).clamp(
        0.0,
        double.infinity,
      );

      txn.update(feeRef, {
        'payments': FieldValue.arrayUnion([payment.toJson()]),
        'totalPaid': newPaid,
        'totalPending': newPending,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  Stream<Fee?> streamStudentFee(
    String studentId,
    String academicYear, {
    String? schoolId,
  }) {
    AppLogger.d(
      'FEE',
      'streamStudentFee: studentId="$studentId" academicYear="$academicYear" schoolId="$schoolId"',
    );

    // ── DIAGNOSTIC: fetch ALL fee docs for this studentId (no filters) ──────
    _db
        .collection(FSC.fees)
        .where('studentId', isEqualTo: studentId)
        .get()
        .then((all) {
          AppLogger.d(
            'FEE',
            'DIAG all fees for studentId: ${all.docs.length} docs',
          );
          for (final d in all.docs) {
            final r = d.data();
            AppLogger.d(
              'FEE',
              '  DIAG doc="${d.id}" studentId="${r['studentId']}" schoolId="${r['schoolId']}" academicYear="${r['academicYear']}" totalAmount=${r['totalAmount']}',
            );
          }
        })
        .catchError((Object e) {
          AppLogger.e('FEE', 'DIAG query error', error: e);
          return null;
        });

    // ── DIAGNOSTIC: fetch ALL fee docs for this schoolId ────────────────────
    if (schoolId != null && schoolId.isNotEmpty) {
      _db
          .collection(FSC.fees)
          .where('schoolId', isEqualTo: schoolId)
          .limit(10)
          .get()
          .then((all) {
            AppLogger.d(
              'FEE',
              'DIAG all fees for schoolId: ${all.docs.length} docs (max 10)',
            );
            for (final d in all.docs) {
              final r = d.data();
              AppLogger.d(
                'FEE',
                '  DIAG doc="${d.id}" studentId="${r['studentId']}" academicYear="${r['academicYear']}"',
              );
            }
          })
          .catchError((Object e) {
            AppLogger.e('FEE', 'DIAG schoolId query error', error: e);
            return null;
          });
    }
    // ── END DIAGNOSTIC ───────────────────────────────────────────────────────

    var q = _db
        .collection(FSC.fees)
        .where('studentId', isEqualTo: studentId)
        .where('academicYear', isEqualTo: academicYear);
    // Always filter by schoolId when available to enforce multi-school isolation
    if (schoolId != null && schoolId.isNotEmpty) {
      q = q.where('schoolId', isEqualTo: schoolId);
    }
    return q
        .limit(1)
        .snapshots()
        .handleError((Object err, StackTrace st) {
          AppLogger.e('FEE', 'Firestore query error', error: err, stack: st);
        })
        .map((s) {
          AppLogger.d('FEE', 'snapshot: docs.length=${s.docs.length}');
          if (s.docs.isNotEmpty) {
            final raw = s.docs.first.data();
            AppLogger.d('FEE', 'doc.id="${s.docs.first.id}"');
            AppLogger.d(
              'FEE',
              'raw.studentId="${raw['studentId']}" raw.academicYear="${raw['academicYear']}" raw.schoolId="${raw['schoolId']}"',
            );
            AppLogger.d(
              'FEE',
              'raw.feeComponents=${raw['feeComponents']}  raw.components=${raw['components']}  raw.totalAmount=${raw['totalAmount']}',
            );
          }
          if (s.docs.isEmpty) return null;
          try {
            final fee = Fee.fromFirestore(s.docs.first);
            AppLogger.d(
              'FEE',
              'Fee parsed OK: totalAmount=${fee.totalAmount} feeComponents=${fee.feeComponents}',
            );
            return fee;
          } catch (err, st) {
            AppLogger.e(
              'FEE',
              'Fee.fromFirestore parse error',
              error: err,
              stack: st,
            );
            return null;
          }
        });
  }

  /// Returns the most recently set fee for a student regardless of academic year.
  /// Useful for the parent view — shows whatever year the school has set.
  Stream<Fee?> streamLatestStudentFee(String studentId, String schoolId) {
    AppLogger.d(
      'FEE',
      'streamLatestStudentFee: studentId="$studentId" schoolId="$schoolId"',
    );
    return _db
        .collection(FSC.fees)
        .where('studentId', isEqualTo: studentId)
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('academicYear', descending: true)
        .limit(1)
        .snapshots()
        .handleError((Object err, StackTrace st) {
          AppLogger.e(
            'FEE',
            'streamLatestStudentFee error',
            error: err,
            stack: st,
          );
        })
        .map((s) {
          AppLogger.d('FEE', 'streamLatestStudentFee: docs=${s.docs.length}');
          if (s.docs.isEmpty) return null;
          try {
            return Fee.fromFirestore(s.docs.first);
          } catch (err, st) {
            AppLogger.e(
              'FEE',
              'streamLatestStudentFee parse error',
              error: err,
              stack: st,
            );
            return null;
          }
        });
  }

  Stream<List<Fee>> streamOutstandingFees(String schoolId) {
    return _db
        .collection(FSC.fees)
        .where('schoolId', isEqualTo: schoolId)
        .where('totalPending', isGreaterThan: 0)
        .snapshots()
        .map((s) => s.docs.map(Fee.fromFirestore).toList());
  }

  // No academicYear filter — returns all fee docs for the school, matching
  // the website's FeesSection behaviour. The caller deduplicates per student.
  Stream<List<Fee>> streamSchoolFees(String schoolId, [String? academicYear]) {
    return _db
        .collection(FSC.fees)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .handleError((Object err, StackTrace st) {
          AppLogger.e('FEE', 'streamSchoolFees error', error: err, stack: st);
        })
        .map((s) {
          final fees = <Fee>[];
          for (final doc in s.docs) {
            try {
              fees.add(Fee.fromFirestore(doc));
            } catch (e, st) {
              AppLogger.e(
                'FEE',
                'Fee parse error doc=${doc.id}',
                error: e,
                stack: st,
              );
            }
          }
          return fees;
        });
  }

  Future<Fee> upsertStudentFee({
    required String schoolId,
    required String studentId,
    required String studentName,
    required String classId,
    required String className,
    required String academicYear,
    required double totalAmount,
    String updatedByUid = '',
    String updatedByName = '',
  }) async {
    // Check if fee record already exists
    final existing = await _db
        .collection(FSC.fees)
        .where('studentId', isEqualTo: studentId)
        .where('academicYear', isEqualTo: academicYear)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final existingFee = Fee.fromFirestore(existing.docs.first);
      final oldData = existing.docs.first.data();
      final newPending = totalAmount - existingFee.totalPaid;
      await _db.collection(FSC.fees).doc(existingFee.feeId).update({
        'totalAmount': totalAmount,
        'totalPending': newPending.clamp(0, double.infinity),
        'studentName': studentName,
        'className': className,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'modifiedBy': updatedByUid,
        'modifiedByName': updatedByName,
      });
      if (updatedByUid.isNotEmpty) {
        await logActivity(
          action: 'UPDATE',
          entityType: 'fee',
          entityId: existingFee.feeId,
          schoolId: schoolId,
          performedByUid: updatedByUid,
          performedByName: updatedByName,
          oldData: oldData,
          newData: {
            'totalAmount': totalAmount,
            'totalPending': newPending.clamp(0, double.infinity),
          },
        );
      }
      return existingFee.copyWith(
        totalAmount: totalAmount,
        totalPending: newPending.clamp(0, double.infinity),
      );
    } else {
      // Use a deterministic composite ID (matching the pattern used by _applyFees
      // in fee_management_screen.dart and the website ApplyFeeModal) to guarantee
      // that all code paths produce exactly one fee document per student per year.
      final compositeId =
          '${schoolId}_${studentId}_${academicYear.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';
      final newDoc = {
        'feeId': compositeId,
        'schoolId': schoolId,
        'studentId': studentId,
        'studentName': studentName,
        'classId': classId,
        'className': className,
        'academicYear': academicYear,
        'totalAmount': totalAmount,
        'totalPaid': 0.0,
        'totalPending': totalAmount,
        'payments': <dynamic>[],
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'createdBy': updatedByUid,
        'createdByName': updatedByName,
      };
      await _db.collection(FSC.fees).doc(compositeId).set(newDoc);
      if (updatedByUid.isNotEmpty) {
        await logActivity(
          action: 'CREATE',
          entityType: 'fee',
          entityId: compositeId,
          schoolId: schoolId,
          performedByUid: updatedByUid,
          performedByName: updatedByName,
          newData: {
            'totalAmount': totalAmount,
            'studentId': studentId,
            'studentName': studentName,
          },
        );
      }
      return Fee(
        feeId: compositeId,
        schoolId: schoolId,
        studentId: studentId,
        academicYear: academicYear,
        totalAmount: totalAmount,
        totalPaid: 0,
        totalPending: totalAmount,
      );
    }
  }

  /// Update only the fee components (and recalculate total/pending) on an existing fee doc.
  Future<void> updateFeeComponents({
    required String feeId,
    required Map<String, double> components,
    required double totalAmount,
    required double totalPending,
    String updatedByUid = '',
    String updatedByName = '',
    String schoolId = '',
  }) async {
    // Capture old data for audit.
    Map<String, dynamic> oldData = {};
    try {
      final snap = await _db.collection(FSC.fees).doc(feeId).get();
      if (snap.exists) oldData = snap.data() ?? {};
    } catch (_) {}

    await _db.collection(FSC.fees).doc(feeId).update({
      'feeComponents': components,
      'totalAmount': totalAmount,
      'totalPending': totalPending,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'modifiedBy': updatedByUid,
      'modifiedByName': updatedByName,
    });

    if (updatedByUid.isNotEmpty) {
      await logActivity(
        action: 'UPDATE',
        entityType: 'fee',
        entityId: feeId,
        schoolId: schoolId.isNotEmpty
            ? schoolId
            : (oldData['schoolId'] as String? ?? ''),
        performedByUid: updatedByUid,
        performedByName: updatedByName,
        oldData: oldData,
        newData: {
          'feeComponents': components,
          'totalAmount': totalAmount,
          'totalPending': totalPending,
        },
      );
    }
  }

  /// Create or update a student fee record with explicit fee components.
  Future<void> upsertStudentFeeWithComponents({
    required String schoolId,
    required String studentId,
    required String studentName,
    required String classId,
    required String className,
    required String academicYear,
    required Map<String, double> components,
    required double totalAmount,
    String updatedByUid = '',
    String updatedByName = '',
  }) async {
    final existing = await _db
        .collection(FSC.fees)
        .where('studentId', isEqualTo: studentId)
        .where('academicYear', isEqualTo: academicYear)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final feeDoc = existing.docs.first;
      final oldData = feeDoc.data();
      final paid = ((oldData['totalPaid'] as num?) ?? 0).toDouble();
      final newPending = (totalAmount - paid).clamp(0.0, double.infinity);
      await feeDoc.reference.update({
        'feeComponents': components,
        'totalAmount': totalAmount,
        'totalPending': newPending,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'modifiedBy': updatedByUid,
        'modifiedByName': updatedByName,
      });
      if (updatedByUid.isNotEmpty) {
        await logActivity(
          action: 'UPDATE',
          entityType: 'fee',
          entityId: feeDoc.id,
          schoolId: schoolId,
          performedByUid: updatedByUid,
          performedByName: updatedByName,
          oldData: oldData,
          newData: {
            'feeComponents': components,
            'totalAmount': totalAmount,
            'totalPending': newPending,
          },
        );
      }
    } else {
      // Deterministic composite ID — same pattern used everywhere else.
      final compositeId =
          '${schoolId}_${studentId}_${academicYear.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';
      final ref = _db.collection(FSC.fees).doc(compositeId);
      final newDoc = {
        'feeId': compositeId,
        'schoolId': schoolId,
        'studentId': studentId,
        'studentName': studentName,
        'classId': classId,
        'className': className,
        'academicYear': academicYear,
        'feeComponents': components,
        'totalAmount': totalAmount,
        'totalPaid': 0.0,
        'totalPending': totalAmount,
        'payments': [],
        'feeHeads': [],
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'createdBy': updatedByUid,
        'createdByName': updatedByName,
      };
      await ref.set(newDoc);
      if (updatedByUid.isNotEmpty) {
        await logActivity(
          action: 'CREATE',
          entityType: 'fee',
          entityId: ref.id,
          schoolId: schoolId,
          performedByUid: updatedByUid,
          performedByName: updatedByName,
          newData: {'feeComponents': components, 'totalAmount': totalAmount},
        );
      }
    }
  }

  Future<void> recordFeePaymentWithNotification({
    required String feeId,
    required String studentId,
    required Payment payment,
    required String recordedByName,
  }) async {
    await recordPayment(feeId, payment);

    // Notify parent
    final studentDoc = await _db.collection(FSC.students).doc(studentId).get();
    if (!studentDoc.exists) return;
    final data = studentDoc.data() as Map<String, dynamic>;
    final parentUid = (data['parentUid'] as String?) ?? '';
    final studentName = (data['name'] as String?) ?? 'Your child';

    final notifData = {
      'title': 'Fee Payment Recorded — $studentName',
      'body':
          '₹${payment.amount.toStringAsFixed(0)} received via ${payment.mode.name}. Thank you!',
      'type': 'FEE_PAYMENT',
      'studentId': studentId,
      'paymentId': payment.paymentId,
      'isRead': false,
      'createdAt': Timestamp.now(),
    };

    final uidsToNotify = <String>{};
    if (parentUid.isNotEmpty) uidsToNotify.add(parentUid);

    // Also look up by phone
    final motherPhone = (data['motherPhone'] as String?) ?? '';
    final fatherPhone = (data['fatherPhone'] as String?) ?? '';
    final phoneMap = await _getParentUidsByPhones([
      if (motherPhone.isNotEmpty) motherPhone,
      if (fatherPhone.isNotEmpty) fatherPhone,
    ]);
    uidsToNotify.addAll(phoneMap.values);

    try {
      final batch = _db.batch();
      for (final uid in uidsToNotify) {
        final ref = _db
            .collection('notifications')
            .doc(uid)
            .collection('items')
            .doc();
        batch.set(ref, notifData);
      }
      if (uidsToNotify.isNotEmpty) await batch.commit();
    } catch (_) {
      // Notification write is best-effort; fee payment already succeeded.
    }
  }

  // ════════════════════════════════════════════════════
  //  SOFT DELETE (never hard-delete any data)
  // ════════════════════════════════════════════════════

  /// Soft-deletes a student by setting isActive=false.
  /// Also checks if the parent has no other active students at this school
  /// and if so, soft-deletes the parent too.
  Future<void> softDeleteStudent({
    required String studentId,
    required String deletedByUid,
  }) async {
    // Read classId before soft-deleting so the class studentCount can be decremented
    final studentSnap = await _db.collection(FSC.students).doc(studentId).get();
    final classId = studentSnap.exists
        ? ((studentSnap.data() as Map<String, dynamic>)['classId'] as String? ??
              '')
        : '';

    // 1. Soft-delete the student
    await _db.collection(FSC.students).doc(studentId).update({
      'isActive': false,
      'deletedAt': FieldValue.serverTimestamp(),
      'deletedBy': deletedByUid,
    });

    // 2. Decrement the class studentCount so the cached counter stays accurate
    if (classId.isNotEmpty) {
      try {
        await _db.collection(FSC.classes).doc(classId).update({
          'studentCount': FieldValue.increment(-1),
        });
      } catch (_) {}
    }

    // 3. Maybe deactivate linked parent(s)
    await _maybeDeactivateParent(
      studentId: studentId,
      deletedByUid: deletedByUid,
    );
  }

  /// Checks if a parent has any remaining active students at the same school.
  /// If not, soft-deletes the parent user.
  Future<void> _maybeDeactivateParent({
    required String studentId,
    required String deletedByUid,
  }) async {
    try {
      final studentDoc = await _db
          .collection(FSC.students)
          .doc(studentId)
          .get();
      if (!studentDoc.exists) return;
      final data = studentDoc.data() as Map<String, dynamic>;
      final schoolId = (data['schoolId'] as String?) ?? '';
      final parentUid = (data['parentUid'] as String?) ?? '';
      final motherPhone = (data['motherPhone'] as String?) ?? '';
      final fatherPhone = (data['fatherPhone'] as String?) ?? '';

      // Collect all parent UIDs linked to this student
      final parentUids = <String>{};
      if (parentUid.isNotEmpty) parentUids.add(parentUid);

      // Phone-based lookup for parents not yet linked via parentUid
      for (final phone in [motherPhone, fatherPhone]) {
        if (phone.isEmpty) continue;
        final snap = await _db
            .collection(FSC.users)
            .where('phone', isEqualTo: phone)
            .where('role', isEqualTo: 'PARENT')
            .limit(1)
            .get();
        for (final d in snap.docs) {
          parentUids.add(d.id);
        }
      }

      for (final uid in parentUids) {
        // Count remaining active students for this parent at this school
        final remaining = await _db
            .collection(FSC.students)
            .where('schoolId', isEqualTo: schoolId)
            .where('isActive', isEqualTo: true)
            .where('parentUid', isEqualTo: uid)
            .count()
            .get();
        if ((remaining.count ?? 0) == 0) {
          // No active children left — deactivate parent
          await _db.collection(FSC.users).doc(uid).update({
            'isActive': false,
            'deletedAt': FieldValue.serverTimestamp(),
            'deletedBy': deletedByUid,
            'deactivationReason': 'All linked students removed from school',
          });
        }
      }
    } catch (e) {
      AppLogger.e('Firestore', '_maybeDeactivateParent failed', error: e);
    }
  }

  /// Transfers a student from one class to another atomically.
  /// Updates the student's classId, appends to classHistory, and adjusts studentCount on both classes.
  Future<void> transferStudentClass({
    required String studentId,
    required String oldClassId,
    required String newClassId,
    required String transferredByUid,
    String oldClassName = '',
    String newClassName = '',
    String transferredByName = '',
  }) async {
    final batch = _db.batch();

    final historyEntry = {
      'fromClassId': oldClassId,
      'fromClassName': oldClassName,
      'toClassId': newClassId,
      'toClassName': newClassName,
      'transferredAt': FieldValue.serverTimestamp(),
      'transferredByName': transferredByName,
    };

    batch.update(_db.collection(FSC.students).doc(studentId), {
      'classId': newClassId,
      'classHistory': FieldValue.arrayUnion([historyEntry]),
      'modifiedTimestamp': FieldValue.serverTimestamp(),
      'modifiedBy': transferredByUid,
      'modifiedByName': transferredByName,
    });

    if (oldClassId.isNotEmpty) {
      batch.update(_db.collection(FSC.classes).doc(oldClassId), {
        'studentCount': FieldValue.increment(-1),
      });
    }

    batch.update(_db.collection(FSC.classes).doc(newClassId), {
      'studentCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // ════════════════════════════════════════════════════
  //  MARKS
  // ════════════════════════════════════════════════════

  Future<void> saveMarks(StudentMarks marks) async {
    final termId = '${marks.academicYear}_${marks.term}';
    await _db
        .collection(FSC.marks)
        .doc(marks.studentId)
        .collection(FSC.terms)
        .doc(termId)
        .set(marks.toFirestore());
  }

  Future<StudentMarks?> getStudentMarks(
    String studentId,
    String academicYear,
    String term,
  ) async {
    final doc = await _db
        .collection(FSC.marks)
        .doc(studentId)
        .collection(FSC.terms)
        .doc('${academicYear}_$term')
        .get();
    if (!doc.exists) return null;
    return StudentMarks.fromFirestore(doc, studentId);
  }

  // ════════════════════════════════════════════════════
  //  SMS / WHATSAPP LOGS
  // ════════════════════════════════════════════════════

  Future<void> logSms(SmsWhatsappLog log) async {
    final id = _uuid.v4();
    await _db
        .collection(FSC.smsWhatsappLogs)
        .doc(id)
        .set(log.copyWith(logId: id).toFirestore());
  }

  Future<void> updateSmsStatus(
    String logId,
    SmsStatus status, {
    String failureReason = '',
  }) async {
    await _db.collection(FSC.smsWhatsappLogs).doc(logId).update({
      'status': status.name,
      'failureReason': failureReason,
      'sentAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<SmsWhatsappLog>> streamSmsLogs(String schoolId) {
    return _db
        .collection(FSC.smsWhatsappLogs)
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map(SmsWhatsappLog.fromFirestore).toList());
  }

  // ════════════════════════════════════════════════════
  //  PARENT — MULTI-CHILD LOOKUP
  // ════════════════════════════════════════════════════

  /// Returns all students linked to a parent uid (parentUid field).
  /// Also accepts the parent's phone to find students via motherPhone/fatherPhone.
  Future<List<Student>> getStudentsForParent(
    String parentUid,
    String phone,
  ) async {
    final results = <Student>[];
    final seen = <String>{};

    // Primary: parentUid match
    final snap1 = await _db
        .collection(FSC.students)
        .where('parentUid', isEqualTo: parentUid)
        .where('isActive', isEqualTo: true)
        .get();
    for (final doc in snap1.docs) {
      if (!seen.contains(doc.id)) {
        seen.add(doc.id);
        results.add(Student.fromFirestore(doc));
      }
    }

    // Also look up by parentUids array (multi-parent support)
    final snap2 = await _db
        .collection(FSC.students)
        .where('parentUids', arrayContains: parentUid)
        .where('isActive', isEqualTo: true)
        .get();
    for (final doc in snap2.docs) {
      if (!seen.contains(doc.id)) {
        seen.add(doc.id);
        results.add(Student.fromFirestore(doc));
      }
    }

    // Secondary: phone-based match (motherPhone / fatherPhone / guardianPhone).
    // Uses single-field equality queries (no composite index required).
    // isActive is checked in Dart so we don't need a composite index on
    // (motherPhone, isActive) etc., which would silently return empty when
    // the index does not exist in Firestore.
    if (phone.isNotEmpty) {
      final normalised = phone.startsWith('+91') ? phone : '+91$phone';
      final plain = phone.startsWith('+91') ? phone.substring(3) : phone;

      for (final phoneVal in [normalised, plain]) {
        for (final field in ['motherPhone', 'fatherPhone', 'guardianPhone']) {
          try {
            final snap = await _db
                .collection(FSC.students)
                .where(field, isEqualTo: phoneVal)
                .get();
            for (final doc in snap.docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['isActive'] == false) continue;
              if (!seen.contains(doc.id)) {
                seen.add(doc.id);
                results.add(Student.fromFirestore(doc));
              }
            }
          } catch (_) {
            // Skip this variant on Firestore error (e.g. missing index).
          }
        }
      }
    }

    // Only require schoolId — classId may be empty for newly-registered students
    // that haven't been assigned to a class yet. Filtering by classId here was
    // silently causing "No Children Linked" for those students. The parent tabs
    // that need classId (attendance, timetable) handle the empty case individually.
    return results.where((s) => s.schoolId.isNotEmpty).toList();
  }

  Stream<List<Student>> streamStudentsForParent(String parentUid) {
    return _db
        .collection(FSC.students)
        .where('parentUid', isEqualTo: parentUid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(Student.fromFirestore).toList());
  }

  /// Live stream of all students for a parent, including phone-matched ones.
  ///
  /// Does one initial multi-query fetch (parentUid + phone fallback) to
  /// discover every linked student ID, then streams those specific documents
  /// so changes like classId updates are reflected immediately in the app.
  Stream<List<Student>> streamStudentsForParentFull(
    String parentUid,
    String phone,
  ) async* {
    final initial = await getStudentsForParent(parentUid, phone);
    if (initial.isEmpty) {
      yield [];
      return;
    }

    final ids = initial.map((s) => s.studentId).toList();

    // Chunk into groups of 30 (Firestore whereIn limit).
    // Most parents have 1-3 children so this is almost always one chunk.
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 30) {
      chunks.add(ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30));
    }

    if (chunks.length == 1) {
      yield* _db
          .collection(FSC.students)
          .where(FieldPath.documentId, whereIn: chunks.first)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((s) => s.docs.map(Student.fromFirestore).toList());
    } else {
      // Multiple chunks: merge snapshot streams into one combined stream.
      // Rare — only parents with 30+ children hit this path.
      final controller = StreamController<List<Student>>();
      final latest = List<List<Student>>.filled(chunks.length, []);
      final subs = <StreamSubscription<List<Student>>>[];

      void emit() {
        if (!controller.isClosed) {
          controller.add(latest.expand((l) => l).toList());
        }
      }

      for (var i = 0; i < chunks.length; i++) {
        final index = i;
        final sub = _db
            .collection(FSC.students)
            .where(FieldPath.documentId, whereIn: chunks[index])
            .where('isActive', isEqualTo: true)
            .snapshots()
            .map((s) => s.docs.map(Student.fromFirestore).toList())
            .listen(
              (list) {
                latest[index] = list;
                emit();
              },
              onError: controller.addError,
            );
        subs.add(sub);
      }

      controller.onCancel = () {
        for (final s in subs) {
          s.cancel();
        }
      };

      yield* controller.stream;
    }
  }

  // ════════════════════════════════════════════════════
  //  PARENT — STUDENT ATTENDANCE HISTORY
  // ════════════════════════════════════════════════════

  Stream<List<AttendanceSession>> streamStudentMonthAttendance(
    String classId,
    DateTime month,
  ) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return _db
        .collection(FSC.attendance)
        .doc(classId)
        .collection(FSC.sessions)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          isLessThan: Timestamp.fromDate(end),
        )
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AttendanceSession.fromFirestore).toList());
  }

  // ════════════════════════════════════════════════════
  //  PARENT — MARKS / REPORT CARD
  // ════════════════════════════════════════════════════

  Stream<List<StudentMarks>> streamAllStudentMarks(String studentId) {
    return _db
        .collection(FSC.marks)
        .doc(studentId)
        .collection(FSC.terms)
        .snapshots()
        .map(
          (s) => s.docs
              .map((doc) => StudentMarks.fromFirestore(doc, studentId))
              .toList(),
        );
  }

  // ════════════════════════════════════════════════════
  //  PARENT — LESSON PLANS FOR CLASS
  // ════════════════════════════════════════════════════

  Stream<List<LessonPlan>> streamLessonPlansForClass(
    String classId, {
    DateTime? date,
  }) {
    var query = _db
        .collection(FSC.lessonPlans)
        .where('classId', isEqualTo: classId);

    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThan: Timestamp.fromDate(end));
    }

    return query.limit(50).snapshots().map((s) {
      final list = s.docs.map(LessonPlan.fromFirestore).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  // ════════════════════════════════════════════════════
  //  SPECIAL REQUESTS
  // ════════════════════════════════════════════════════

  Future<String> createSpecialRequest(SpecialRequest request) async {
    final id = _uuid.v4();
    final data = request.toFirestore();
    data['requestId'] = id;
    data['createdAt'] = Timestamp.now();
    await _db.collection('specialRequests').doc(id).set(data);
    return id;
  }

  Stream<List<SpecialRequest>> streamParentSpecialRequests(
    String parentUid,
    String studentId,
  ) {
    return _db
        .collection('specialRequests')
        .where('parentUid', isEqualTo: parentUid)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(SpecialRequest.fromFirestore).toList());
  }

  Stream<List<SpecialRequest>> streamTeacherSpecialRequests(String teacherUid) {
    return _db
        .collection('specialRequests')
        .where('targetTeacherUid', isEqualTo: teacherUid)
        .snapshots()
        .map((s) {
          final list = s.docs.map(SpecialRequest.fromFirestore).toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  Future<void> respondToSpecialRequest({
    required String requestId,
    required SpecialRequestStatus status,
    required String respondedBy,
    String responseNote = '',
  }) async {
    await _db.collection('specialRequests').doc(requestId).update({
      'status': status.name,
      'respondedBy': respondedBy,
      'responseNote': responseNote,
      'respondedAt': Timestamp.now(),
    });
  }

  // ════════════════════════════════════════════════════
  //  PARENT — EXIT ATTENDANCE FOR STUDENT
  // ════════════════════════════════════════════════════

  Stream<List<ExitAttendance>> streamParentStudentExits(String studentId) {
    return _db
        .collection(FSC.exitAttendance)
        .where('studentId', isEqualTo: studentId)
        .limit(30)
        .snapshots()
        .map((s) {
          final list = s.docs.map(ExitAttendance.fromFirestore).toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  // ════════════════════════════════════════════════════
  //  PARENT — PAYMENT REQUESTS (school-initiated)
  // ════════════════════════════════════════════════════

  /// Parent submits payment intent (online reference / awaiting confirmation).
  /// Uses existing Fee structure: adds a Payment record with mode ONLINE
  /// and marks the feeHead status as PARTIAL / PAID.
  Future<void> submitPaymentIntent({
    required String feeId,
    required double amount,
    required String paidByUid,
    String transactionRef = '',
  }) async {
    final payment = Payment(
      paymentId: _uuid.v4(),
      amount: amount,
      mode: PaymentMode.ONLINE,
      paidAt: DateTime.now(),
      recordedBy: paidByUid,
      transactionRef: transactionRef,
    );
    await recordPayment(feeId, payment);
  }

  // ════════════════════════════════════════════════════
  //  PARENT — UPDATE PROFILE (email + address only)
  // ════════════════════════════════════════════════════

  Future<void> updateParentProfile(
    String uid, {
    required String email,
    required String address,
  }) async {
    await _db.collection(FSC.users).doc(uid).update({
      'email': email,
      'address': address,
    });
  }

  // ════════════════════════════════════════════════════
  //  USER PROFILE UPDATE (staff: name, email, address, DOB)
  // ════════════════════════════════════════════════════

  Future<void> updateUserProfile(
    String uid, {
    String? name,
    String? email,
    String? address,
    String? dateOfBirth,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (address != null) updates['address'] = address;
    if (dateOfBirth != null) updates['dateOfBirth'] = dateOfBirth;
    if (updates.isNotEmpty) {
      await _db.collection(FSC.users).doc(uid).update(updates);
    }
  }

  // ════════════════════════════════════════════════════
  //  STAFF LEAVES
  // ════════════════════════════════════════════════════

  Future<void> createStaffLeave(Map<String, dynamic> data) async {
    final id = _uuid.v4();
    await _db.collection(FSC.staffLeaves).doc(id).set({
      ...data,
      'leaveId': id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamStaffLeavesForSchool(
    String schoolId,
  ) {
    return _db
        .collection(FSC.staffLeaves)
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => {'leaveId': d.id, ...d.data()}).toList(),
        );
  }

  Future<void> reviewStaffLeave(
    String leaveId,
    String status,
    String reviewedBy,
  ) async {
    await _db.collection(FSC.staffLeaves).doc(leaveId).update({
      'status': status,
      'reviewedBy': reviewedBy,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  // ════════════════════════════════════════════════════
  //  TEACHER-PARENT DUAL ROLE CHECK
  // ════════════════════════════════════════════════════

  /// Quick check: does this user have any children linked as a parent?
  /// Mirrors the same three-step lookup used by [getStudentsForParent]:
  ///   1. parentUid field
  ///   2. parentUids array
  ///   3. motherPhone / fatherPhone (both bare and E.164 forms)
  /// Stops at the first positive match for efficiency.
  Future<bool> hasLinkedStudents(String uid, {String phone = ''}) async {
    // 1. parentUid exact match
    final snap1 = await _db
        .collection(FSC.students)
        .where('parentUid', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snap1.docs.isNotEmpty) return true;

    // 2. parentUids array contains uid
    final snap2 = await _db
        .collection(FSC.students)
        .where('parentUids', arrayContains: uid)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snap2.docs.isNotEmpty) return true;

    // 3. Phone-based match — single-field query so no composite index is needed.
    //    isActive checked in Dart so the query never silently returns empty
    //    due to a missing Firestore composite index.
    if (phone.isNotEmpty) {
      final normalised = phone.startsWith('+91') ? phone : '+91$phone';
      final plain = phone.startsWith('+91') ? phone.substring(3) : phone;
      for (final phoneVal in [normalised, plain]) {
        for (final field in ['motherPhone', 'fatherPhone', 'guardianPhone']) {
          try {
            final snap = await _db
                .collection(FSC.students)
                .where(field, isEqualTo: phoneVal)
                .limit(5)
                .get();
            for (final doc in snap.docs) {
              if (doc.data()['isActive'] == false) continue;
              return true;
            }
          } catch (_) {
            // Skip on error — try next variant.
          }
        }
      }
    }

    return false;
  }

  // ════════════════════════════════════════════════════
  //  EXPENSES (Admin / Management)
  // ════════════════════════════════════════════════════

  Future<void> addExpense(Map<String, dynamic> data) async {
    final id = _uuid.v4();
    await _db.collection(FSC.expenses).doc(id).set({
      ...data,
      'expenseId': id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamRecentExpensesByUser(
    String schoolId,
    String uid,
  ) {
    return _db
        .collection(FSC.expenses)
        .where('schoolId', isEqualTo: schoolId)
        .where('addedByUid', isEqualTo: uid)
        .limit(50)
        .snapshots()
        .map((s) {
          final list = s.docs
              .map((d) => {'expenseId': d.id, ...d.data()})
              .toList();
          list.sort((a, b) {
            final at = a['createdAt'] as Timestamp?;
            final bt = b['createdAt'] as Timestamp?;
            if (at == null && bt == null) return 0;
            if (at == null) return 1;
            if (bt == null) return -1;
            return bt.compareTo(at);
          });
          return list;
        });
  }

  /// Stream ALL expenses for a school (used by Admin role to see school-wide spend).
  Stream<List<Map<String, dynamic>>> streamAllExpensesBySchool(
    String schoolId,
  ) {
    return _db
        .collection(FSC.expenses)
        .where('schoolId', isEqualTo: schoolId)
        // No limit — salary expenses use deterministic IDs (salary_uid_month)
        // that can be excluded by a document-ID-ordered Firestore limit cut-off.
        .snapshots()
        .map((s) {
          final list = s.docs
              .map((d) => {'expenseId': d.id, ...d.data()})
              .toList();
          list.sort((a, b) {
            final at = a['createdAt'] as Timestamp?;
            final bt = b['createdAt'] as Timestamp?;
            if (at == null && bt == null) return 0;
            if (at == null) return 1;
            if (bt == null) return -1;
            return bt.compareTo(at);
          });
          return list;
        });
  }

  // ════════════════════════════════════════════════════
  //  STUDENT DOCUMENTS
  // ════════════════════════════════════════════════════

  Future<void> saveStudentDocument(
    String studentId,
    Map<String, dynamic> data,
  ) async {
    final id = _uuid.v4();
    await _db
        .collection(FSC.students)
        .doc(studentId)
        .collection(FSC.studentDocuments)
        .doc(id)
        .set({
          ...data,
          'docId': id,
          'uploadedAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<List<Map<String, dynamic>>> streamStudentDocuments(String studentId) {
    return _db
        .collection(FSC.students)
        .doc(studentId)
        .collection(FSC.studentDocuments)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'docId': d.id, ...d.data()}).toList());
  }

  Future<void> deleteStudentDocument(String studentId, String docId) async {
    await _db
        .collection(FSC.students)
        .doc(studentId)
        .collection(FSC.studentDocuments)
        .doc(docId)
        .delete();
  }

  // ════════════════════════════════════════════════════
  //  FEE PENDING (Admin finance view)
  // ════════════════════════════════════════════════════

  Stream<List<Map<String, dynamic>>> streamStudentsWithPendingFees(
    String schoolId,
    String academicYear,
  ) {
    return _db
        .collection(FSC.fees)
        .where('schoolId', isEqualTo: schoolId)
        .where('academicYear', isEqualTo: academicYear)
        .snapshots()
        .map((s) {
          final list = s.docs
              .map((d) => {'feeId': d.id, ...d.data()})
              .where((m) => ((m['totalPending'] as num?) ?? 0) > 0)
              .toList();
          list.sort((a, b) {
            final ap = ((a['totalPending'] as num?) ?? 0).toDouble();
            final bp = ((b['totalPending'] as num?) ?? 0).toDouble();
            return bp.compareTo(ap);
          });
          return list;
        });
  }

  // ════════════════════════════════════════════════════
  //  VISITORS
  // ════════════════════════════════════════════════════

  Future<void> logVisitor(Map<String, dynamic> data) async {
    final id = _uuid.v4();
    await _db.collection(FSC.visitors).doc(id).set({
      ...data,
      'visitorId': id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> checkOutVisitor(String visitorId) async {
    await _db.collection(FSC.visitors).doc(visitorId).update({
      'checkOut': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamTodayVisitors(String schoolId) {
    final now = DateTime.now();
    final since = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6)); // last 7 days
    return _db
        .collection(FSC.visitors)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((s) {
          final docs = s.docs
              .map((d) => {'visitorId': d.id, ...d.data()})
              .where((v) {
                final ts = v['checkIn'] as Timestamp?;
                return ts != null && ts.toDate().isAfter(since);
              })
              .toList();
          docs.sort((a, b) {
            final ta = (a['checkIn'] as Timestamp?)?.seconds ?? 0;
            final tb = (b['checkIn'] as Timestamp?)?.seconds ?? 0;
            return tb.compareTo(ta);
          });
          return docs;
        });
  }

}
