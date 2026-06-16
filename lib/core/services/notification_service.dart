import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants/firestore_constants.dart';
import '../utils/app_logger.dart';
import 'logger_service.dart';

// ─── Background handler — must be top-level (not a class method) ───────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by the system before this runs.
  // No-op needed — Android shows the notification automatically.
}

// ─── Shared local notifications plugin instance ────────────────────────────
final FlutterLocalNotificationsPlugin _localNotif =
    FlutterLocalNotificationsPlugin();

const _channelId   = 'shalalink_default';
const _channelName = 'SMS School Notifications';
const _channelDesc = 'School updates, attendance alerts and messages';

// ═══════════════════════════════════════════════════════════════════════════
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Tracks the session ID for this device login session.
  // Used to detect when another device has logged in and invalidate this session.
  static String? currentSessionId;
  static const _sessionPrefKey = 'edu_active_session_id';

  /// Loads the persisted session ID from SharedPreferences (call on app start).
  static Future<void> loadPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    currentSessionId = prefs.getString(_sessionPrefKey);
  }

  /// Clears the local session (call on logout).
  static Future<void> clearSession() async {
    currentSessionId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionPrefKey);
  }

  /// Removes this device's FCM token from the current user's Firestore record,
  /// clears the local session, then signs out of Firebase Auth.
  ///
  /// Always call this instead of FirebaseAuth.instance.signOut() directly,
  /// so stale tokens don't cause cross-user notification leaks.
  static Future<void> signOut() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await FirebaseFirestore.instance
              .collection(FSC.users)
              .doc(user.uid)
              .update({'fcmTokens': FieldValue.arrayRemove([token])});
        }
      }
    } catch (_) {
      // Best-effort — don't block sign-out on Firestore errors
    }
    // Audit log before signing out (user doc still readable at this point)
    try {
      final snap = await FirebaseFirestore.instance
          .collection(FSC.users)
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      final schoolId = (snap.data()?['schoolId'] as String?) ?? '';
      await AuditLogger.logLogout(schoolId: schoolId);
    } catch (_) {}

    await clearSession();
    await FirebaseAuth.instance.signOut();
  }

  /// Call once from main.dart after Firebase.initializeApp()
  Future<void> initialize() async {
    AppLogger.i('NotificationService', 'Initializing FCM + local notifications');
    // 1. Request permission — shows system dialog on iOS and Android 13+
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialise flutter_local_notifications (for foreground display)
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // already asked via FCM above
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // 3. Create Android high-importance notification channel
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );

    // 4. Show foreground notifications on iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Display local notification banner when app is in foreground (Android)
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // 6. Keep FCM token fresh — update Firestore whenever FCM rotates the token.
    //    Registered here (once) so multiple saveTokenForUser calls don't stack listeners.
    _messaging.onTokenRefresh.listen((newToken) async {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) return;
      // Claim the new token from other users to prevent cross-user notification leaks
      try {
        final staleSnap = await FirebaseFirestore.instance
            .collection(FSC.users)
            .where('fcmTokens', arrayContains: newToken)
            .get();
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in staleSnap.docs) {
          if (doc.id != currentUid) {
            batch.update(doc.reference,
                {'fcmTokens': FieldValue.arrayRemove([newToken])});
          }
        }
        if (staleSnap.docs.any((d) => d.id != currentUid)) {
          await batch.commit();
        }
      } catch (_) {}
      await FirebaseFirestore.instance
          .collection(FSC.users)
          .doc(currentUid)
          .update({'fcmTokens': FieldValue.arrayUnion([newToken])});
    });
  }

  /// Writes in-app notification documents to Firestore for each receiver UID.
  ///
  /// The Cloud Function listening to `notifications/{uid}/items/{id}` picks
  /// up every new document and delivers an FCM push notification automatically.
  ///
  /// [extra] lets callers attach UI-specific fields (type, entityId, …) beyond
  /// the standard payload required by the Cloud Function (title/body/createdAt/isRead).
  static Future<void> sendNotification({
    required List<String> receiverUids,
    required String title,
    required String body,
    Map<String, dynamic> extra = const {},
  }) async {
    if (receiverUids.isEmpty) return;
    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();
      final payload = <String, dynamic>{
        'title': title,
        'body': body,
        'createdAt': Timestamp.now(),
        'isRead': false,
        ...extra,
      };
      for (final uid in receiverUids) {
        final ref = db
            .collection('notifications')
            .doc(uid)
            .collection('items')
            .doc();
        batch.set(ref, payload);
      }
      await batch.commit();
    } catch (e) {
      AppLogger.e('NotificationService', 'sendNotification failed', error: e);
    }
  }

  /// Call after user is confirmed logged in (from role_router / dashboard).
  ///
  /// On first login (no persisted session), generates a new sessionId.
  /// On subsequent app starts (existing session), reuses the stored sessionId.
  /// FCM tokens are REPLACED (not merged) so the old device stops receiving notifications.
  Future<void> saveTokenForUser(String uid) async {
    AppLogger.i('NotificationService', 'saveTokenForUser uid=$uid');
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      final prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString(_sessionPrefKey);

      // No stored session → this is a fresh login on this device
      if (sessionId == null) {
        sessionId = const Uuid().v4();
        await prefs.setString(_sessionPrefKey, sessionId);
        AppLogger.i('NotificationService', 'New session created: $sessionId');
      }

      currentSessionId = sessionId;

      // Step 1 — Token claiming: remove this device's token from ANY other user
      // who still has it. This prevents cross-user notification leaks when the
      // same device was previously logged in as a different account.
      try {
        final staleSnap = await FirebaseFirestore.instance
            .collection(FSC.users)
            .where('fcmTokens', arrayContains: token)
            .get();
        if (staleSnap.docs.isNotEmpty) {
          final batch = FirebaseFirestore.instance.batch();
          for (final doc in staleSnap.docs) {
            if (doc.id != uid) {
              AppLogger.i('NotificationService',
                  'Removing stale token from user ${doc.id}');
              batch.update(doc.reference,
                  {'fcmTokens': FieldValue.arrayRemove([token])});
            }
          }
          await batch.commit();
        }
      } catch (e) {
        AppLogger.w('NotificationService', 'Stale token cleanup failed', error: e);
      }

      // Step 2 — REPLACE fcmTokens so only this device receives notifications.
      // Also write activeSessionId so other devices can detect session takeover.
      await FirebaseFirestore.instance
          .collection(FSC.users)
          .doc(uid)
          .update({
            'fcmTokens': [token],
            'activeSessionId': sessionId,
          });
    } catch (e) {
      AppLogger.w('NotificationService', 'saveTokenForUser failed', error: e);
    }
  }

  // ── Internal: show banner for foreground messages on Android ─────────────
  void _showLocalNotification(RemoteMessage message) {
    AppLogger.d('NotificationService', 'FCM foreground message: ${message.notification?.title}');
    final n = message.notification;
    if (n == null) return;

    _localNotif.show(
      n.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
