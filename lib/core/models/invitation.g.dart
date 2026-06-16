// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvitationImpl _$$InvitationImplFromJson(Map<String, dynamic> json) =>
    _$InvitationImpl(
      inviteId: json['inviteId'] as String,
      schoolId: json['schoolId'] as String,
      role: $enumDecode(_$InvitationRoleEnumMap, json['role']),
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      status:
          $enumDecodeNullable(_$InvitationStatusEnumMap, json['status']) ??
          InvitationStatus.PENDING,
      token: json['token'] as String,
      createdBy: json['createdBy'] as String,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      linkedEntityId: json['linkedEntityId'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      inviteeName: json['inviteeName'] as String? ?? '',
    );

Map<String, dynamic> _$$InvitationImplToJson(_$InvitationImpl instance) =>
    <String, dynamic>{
      'inviteId': instance.inviteId,
      'schoolId': instance.schoolId,
      'role': _$InvitationRoleEnumMap[instance.role]!,
      'email': instance.email,
      'phone': instance.phone,
      'status': _$InvitationStatusEnumMap[instance.status]!,
      'token': instance.token,
      'createdBy': instance.createdBy,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'linkedEntityId': instance.linkedEntityId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'inviteeName': instance.inviteeName,
    };

const _$InvitationRoleEnumMap = {
  InvitationRole.PRINCIPAL: 'PRINCIPAL',
  InvitationRole.ADMIN: 'ADMIN',
  InvitationRole.ADMINISTRATOR: 'ADMINISTRATOR',
  InvitationRole.TEACHER: 'TEACHER',
  InvitationRole.PARENT: 'PARENT',
  InvitationRole.MANAGEMENT: 'MANAGEMENT',
};

const _$InvitationStatusEnumMap = {
  InvitationStatus.PENDING: 'PENDING',
  InvitationStatus.ACCEPTED: 'ACCEPTED',
  InvitationStatus.EXPIRED: 'EXPIRED',
};
