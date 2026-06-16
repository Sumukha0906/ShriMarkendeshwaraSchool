import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

// ── Firebase instances ────────────────────────────────────────
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// ── Services ──────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(),
);

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

// ── Auth state stream ─────────────────────────────────────────
// Emits Firebase User whenever login/logout happens
final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

// ── Current logged-in UserModel ───────────────────────────────
// Fetches full user profile from Firestore once auth state is known.
// Falls back to a phone-number lookup for phone-auth users whose doc
// may be stored under a different UID (e.g. after doc migration).
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);

  // Resolve which Firebase Auth user to look up.
  // When the stream is still initialising (loading state), fall back to the
  // synchronous FirebaseAuth.currentUser so we never return null for a user
  // who already authenticated (race condition: OTP screen navigates to /home
  // before the authStateChanges stream fires its first event).
  final fbUser = authState.when(
    data: (u) => u,
    loading: () => FirebaseAuth.instance.currentUser,
    error: (_, __) => null,
  );

  if (fbUser == null) return null;

  final firestoreService = ref.read(firestoreServiceProvider);

  // Fast path: doc exists at the current Firebase Auth UID
  final byUid = await firestoreService.getUser(fbUser.uid);
  if (byUid != null) return byUid;

  // Phone fallback: the Firestore doc may live under a different UID (e.g.
  // after a web→mobile migration), or may have been stored with the 10-digit
  // bare format while Firebase Auth exposes E.164 (+91XXXXXXXXXX).
  // Try both formats so neither mismatch causes a silent "user not found".
  final rawPhone = fbUser.phoneNumber;
  if (rawPhone == null || rawPhone.isEmpty) return null;

  // Build both variants: "+91XXXXXXXXXX" and bare "XXXXXXXXXX"
  final e164  = rawPhone.startsWith('+91') ? rawPhone : '+91$rawPhone';
  final bare  = rawPhone.startsWith('+91') ? rawPhone.substring(3) : rawPhone;

  QueryDocumentSnapshot<Map<String, dynamic>>? foundDoc;
  for (final phoneVal in [bare, e164]) {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phoneVal)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      foundDoc = snap.docs.first;
      break;
    }
  }

  if (foundDoc == null) return null;

  // If the stored UID differs from the current Firebase Auth UID, migrate
  // the doc so future logins hit the fast path.
  if (foundDoc.id != fbUser.uid) {
    final data = foundDoc.data();
    final batch = FirebaseFirestore.instance.batch();
    batch.set(
      FirebaseFirestore.instance.collection('users').doc(fbUser.uid),
      {...data, 'uid': fbUser.uid},
    );
    batch.delete(
      FirebaseFirestore.instance.collection('users').doc(foundDoc.id),
    );
    await batch.commit();
  }

  // Return with the CURRENT Firebase Auth UID so downstream code
  // (role_router, profile screens) always sees the correct uid.
  return UserModel.fromFirestore(foundDoc).copyWith(uid: fbUser.uid);
});

// ── Convenience: current user role ───────────────────────────
final currentUserRoleProvider = Provider<UserRole?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.value?.role;
});

// ── Convenience: current school ID ───────────────────────────
final currentSchoolIdProvider = Provider<String>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.value?.schoolId ?? '';
});

// ── Parent mode toggle (for dual-role users: teacher/admin/etc. + parent) ─────
final parentModeProvider = StateProvider<bool>((ref) => false);

// ── Does the current privileged user also have linked children? ───────────────
// Used to show the "Switch to Parent" option in profile sections.
final hasLinkedStudentsProvider = FutureProvider<bool>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return false;
  if (user.role == UserRole.PARENT || user.role == UserRole.SUPER_ADMIN) {
    return false;
  }
  final fs = ref.read(firestoreServiceProvider);
  final phone = user.phone.isNotEmpty
      ? user.phone
      : (FirebaseAuth.instance.currentUser?.phoneNumber ?? '');
  return fs.hasLinkedStudents(user.uid, phone: phone);
});

// ── Selected child index for multi-child parents ─────────────
final selectedChildIndexProvider = StateProvider<int>((ref) => 0);

// ── Raw Firestore user doc stream (for session monitoring) ────
// Emits the raw user document data whenever it changes in Firestore.
final userDocStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.data());
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});