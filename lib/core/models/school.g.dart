// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SchoolImpl _$$SchoolImplFromJson(Map<String, dynamic> json) => _$SchoolImpl(
  schoolId: json['schoolId'] as String,
  name: json['name'] as String,
  address: json['address'] as String? ?? '',
  logoUrl: json['logoUrl'] as String? ?? '',
  primaryColor: json['primaryColor'] as String? ?? '#1A56DB',
  phone: json['phone'] as String? ?? '',
  email: json['email'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? true,
  academicYear: json['academicYear'] as String? ?? '2026-27',
  plan: json['plan'] as String? ?? 'PREMIUM',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$SchoolImplToJson(_$SchoolImpl instance) =>
    <String, dynamic>{
      'schoolId': instance.schoolId,
      'name': instance.name,
      'address': instance.address,
      'logoUrl': instance.logoUrl,
      'primaryColor': instance.primaryColor,
      'phone': instance.phone,
      'email': instance.email,
      'isActive': instance.isActive,
      'academicYear': instance.academicYear,
      'plan': instance.plan,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
