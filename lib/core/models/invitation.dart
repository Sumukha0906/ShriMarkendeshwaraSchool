import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'invitation.freezed.dart';
part 'invitation.g.dart';

enum InvitationRole   { PRINCIPAL, ADMIN, ADMINISTRATOR, TEACHER, PARENT, MANAGEMENT }
enum InvitationStatus { PENDING, ACCEPTED, EXPIRED }

@freezed
class Invitation with _$Invitation {
  const factory Invitation({
    required String inviteId,
    required String schoolId,
    required InvitationRole role,
    required String email,
    @Default('') String phone,
    @Default(InvitationStatus.PENDING) InvitationStatus status,
    required String token,
    required String createdBy,
    DateTime? expiresAt,
    @Default('') String linkedEntityId,
    DateTime? createdAt,
    @Default('') String inviteeName,
  }) = _Invitation;

  factory Invitation.fromJson(Map<String, dynamic> json) =>
      _$InvitationFromJson(json);

  factory Invitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Invitation.fromJson({
      ...data,
      'inviteId': doc.id,
      'expiresAt':
          (data['expiresAt'] as Timestamp?)?.toDate().toIso8601String(),
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension InvitationX on Invitation {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('inviteId');
    if (expiresAt != null) json['expiresAt'] = Timestamp.fromDate(expiresAt!);
    if (createdAt != null) json['createdAt'] = Timestamp.fromDate(createdAt!);
    return json;
  }

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
}