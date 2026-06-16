import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firestore_constants.dart';

/// Persistent audit logger — every user action is written to Firestore
/// `activityLogs` so schools have proof of every activity.
///
/// This is separate from [AppLogger] (debug console / Sentry).
/// Usage:
///   AuditLogger.log(event: 'attendance_marked', details: {'studentId': '...'});
class AuditLogger {
  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Write an audit event to Firestore `activityLogs`.
  ///
  /// [event]    — snake_case event name, e.g. 'login', 'fee_recorded'
  /// [details]  — arbitrary key-value context (student IDs, amounts, etc.)
  /// [schoolId] — pass explicitly when not readable from auth (super-admin ops)
  static Future<void> log({
    required String event,
    Map<String, dynamic> details = const {},
    String? schoolId,
  }) async {
    try {
      final uid = _auth.currentUser?.uid ?? 'anonymous';
      final now = DateTime.now();

      await _db.collection(FSC.activityLogs).add({
        'event':     event,
        'uid':       uid,
        'schoolId':  schoolId ?? '',
        'details':   details,
        'platform':  'mobile',
        'timestamp': Timestamp.fromDate(now),
        'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      });
    } catch (_) {
      // Never let logging crash the app — fail silently.
    }
  }

  /// Log a successful login.
  static Future<void> logLogin({required String uid, required String role, required String schoolId}) =>
      log(event: 'login', schoolId: schoolId, details: {'role': role, 'uid': uid});

  /// Log sign-out.
  static Future<void> logLogout({required String schoolId}) =>
      log(event: 'logout', schoolId: schoolId);

  /// Log screen/section views.
  static Future<void> logScreenView({required String screen, String? schoolId}) =>
      log(event: 'screen_view', schoolId: schoolId, details: {'screen': screen});

  /// Log a button tap or named action.
  static Future<void> logTap({
    required String action,
    String? schoolId,
    Map<String, dynamic> extra = const {},
  }) =>
      log(event: 'tap', schoolId: schoolId, details: {'action': action, ...extra});
}

