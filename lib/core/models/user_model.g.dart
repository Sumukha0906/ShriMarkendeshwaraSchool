// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['uid'] as String,
      schoolId: json['schoolId'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String? ?? '',
      fcmTokens:
          (json['fcmTokens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'schoolId': instance.schoolId,
      'role': _$UserRoleEnumMap[instance.role]!,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'fcmTokens': instance.fcmTokens,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.SUPER_ADMIN: 'SUPER_ADMIN',
  UserRole.PRINCIPAL: 'PRINCIPAL',
  UserRole.ADMIN: 'ADMIN',
  UserRole.ADMINISTRATOR: 'ADMINISTRATOR',
  UserRole.TEACHER: 'TEACHER',
  UserRole.PARENT: 'PARENT',
  UserRole.MANAGEMENT: 'MANAGEMENT',
};
