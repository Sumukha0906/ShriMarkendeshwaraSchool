import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/invitation.dart';
import '../constants/firestore_constants.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Login ─────────────────────────────────────────────────
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Sign Out ──────────────────────────────────────────────
  Future<void> signOut() async {
    await NotificationService.clearSession();
    await _auth.signOut();
  }

  // ── Validate invite token ─────────────────────────────────
  Future<Invitation?> validateInviteToken(String token) async {
    final snap = await _db
        .collection(FSC.invitations)
        .where('token', isEqualTo: token)
        .where('status', isEqualTo: 'PENDING')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final invite = Invitation.fromFirestore(snap.docs.first);

    if (invite.isExpired) return null;

    return invite;
  }

  // ── Accept invitation & create account ───────────────────
  Future<void> acceptInvitation({
    required String token,
    required String password,
    required String name,
    required String phone,
  }) async {
    // 1. Validate token
    final invite = await validateInviteToken(token);
    if (invite == null) throw Exception('Invalid or expired invitation link.');

    // 2. Create Firebase Auth account
    final credential = await _auth.createUserWithEmailAndPassword(
      email: invite.email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    // 3. Map invitation role to user role
    final userRole = _mapInviteRoleToUserRole(invite.role);

    // 4. Create user profile in Firestore
    final userModel = UserModel(
      uid: uid,
      schoolId: invite.schoolId,
      role: userRole,
      name: name.trim(),
      email: invite.email.trim(),
      phone: phone.trim(),
      isActive: true,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();

    // Write user doc
    batch.set(_db.collection(FSC.users).doc(uid), userModel.toFirestore());

    // Mark invite as accepted
    batch.update(_db.collection(FSC.invitations).doc(invite.inviteId), {
      'status': 'ACCEPTED',
    });

    await batch.commit();
  }

  // ── Create invitation ─────────────────────────────────────
  Future<String> createInvitation({
    required String schoolId,
    required InvitationRole role,
    required String email,
    String phone = '',
    required String createdBy,
    String linkedEntityId = '',
  }) async {
    final token = _uuid.v4();
    final inviteId = _uuid.v4();

    final invite = Invitation(
      inviteId: inviteId,
      schoolId: schoolId,
      role: role,
      email: email.trim(),
      phone: phone.trim(),
      token: token,
      createdBy: createdBy,
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
      linkedEntityId: linkedEntityId,
      createdAt: DateTime.now(),
    );

    await _db
        .collection(FSC.invitations)
        .doc(inviteId)
        .set(invite.toFirestore());

    return token;
  }

  // ── Update FCM token ──────────────────────────────────────
  Future<void> updateFcmToken(String uid, String fcmToken) async {
    await _db.collection(FSC.users).doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([fcmToken]),
    });
  }

  // ── Remove FCM token on logout ────────────────────────────
  Future<void> removeFcmToken(String uid, String fcmToken) async {
    await _db.collection(FSC.users).doc(uid).update({
      'fcmTokens': FieldValue.arrayRemove([fcmToken]),
    });
  }

  // ── Password reset ────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Helper: map invitation role to user role ──────────────
  UserRole _mapInviteRoleToUserRole(InvitationRole role) {
    switch (role) {
      case InvitationRole.PRINCIPAL:
        return UserRole.PRINCIPAL;
      case InvitationRole.ADMIN:
        return UserRole.ADMIN;
      case InvitationRole.ADMINISTRATOR:
        return UserRole.ADMINISTRATOR;
      case InvitationRole.TEACHER:
        return UserRole.TEACHER;
      case InvitationRole.PARENT:
        return UserRole.PARENT;
      case InvitationRole.MANAGEMENT:
        return UserRole.MANAGEMENT;
    }
  }
}
