import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum UserRole {
  SUPER_ADMIN,
  PRINCIPAL,
  ADMIN,
  ADMINISTRATOR, // View-only access to fees; all other admin features
  TEACHER,
  PARENT,
  MANAGEMENT,
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String schoolId,
    required UserRole role,
    required String name,
    required String email,
    required String phone,
    @Default('') String profilePhotoUrl,
    @Default([]) List<String> fcmTokens,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      ...data,
      'uid': doc.id,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension UserModelX on UserModel {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('uid');
    if (createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    return json;
  }

  bool get isSuperAdmin    => role == UserRole.SUPER_ADMIN;
  bool get isPrincipal     => role == UserRole.PRINCIPAL;
  bool get isAdmin         => role == UserRole.ADMIN;
  bool get isAdministrator => role == UserRole.ADMINISTRATOR;
  bool get isTeacher       => role == UserRole.TEACHER;
  bool get isParent        => role == UserRole.PARENT;
  bool get isManagement    => role == UserRole.MANAGEMENT;
  /// True for roles with school-level admin access (Principal, Admin, Administrator)
  bool get isSchoolAdmin =>
      role == UserRole.PRINCIPAL ||
      role == UserRole.ADMIN ||
      role == UserRole.ADMINISTRATOR;
  /// True if the user can modify fee structures / record payments
  bool get canManageFees =>
      role == UserRole.PRINCIPAL ||
      role == UserRole.ADMIN ||
      role == UserRole.MANAGEMENT;
}