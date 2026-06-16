// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnnouncementImpl _$$AnnouncementImplFromJson(
  Map<String, dynamic> json,
) => _$AnnouncementImpl(
  announcementId: json['announcementId'] as String,
  schoolId: json['schoolId'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  createdBy: json['createdBy'] as String,
  createdByName: json['createdByName'] as String? ?? '',
  audience:
      $enumDecodeNullable(_$AnnouncementAudienceEnumMap, json['audience']) ??
      AnnouncementAudience.ALL,
  targetClassId: json['targetClassId'] as String? ?? '',
  targetClassName: json['targetClassName'] as String? ?? '',
  requiresAck: json['requiresAck'] as bool? ?? false,
  ackedBy:
      (json['ackedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  attachmentUrl: json['attachmentUrl'] as String? ?? '',
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AnnouncementImplToJson(_$AnnouncementImpl instance) =>
    <String, dynamic>{
      'announcementId': instance.announcementId,
      'schoolId': instance.schoolId,
      'title': instance.title,
      'body': instance.body,
      'createdBy': instance.createdBy,
      'createdByName': instance.createdByName,
      'audience': _$AnnouncementAudienceEnumMap[instance.audience]!,
      'targetClassId': instance.targetClassId,
      'targetClassName': instance.targetClassName,
      'requiresAck': instance.requiresAck,
      'ackedBy': instance.ackedBy,
      'attachmentUrl': instance.attachmentUrl,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$AnnouncementAudienceEnumMap = {
  AnnouncementAudience.ALL: 'ALL',
  AnnouncementAudience.PARENTS: 'PARENTS',
  AnnouncementAudience.TEACHERS: 'TEACHERS',
  AnnouncementAudience.STAFF: 'STAFF',
  AnnouncementAudience.CLASS: 'CLASS',
};
