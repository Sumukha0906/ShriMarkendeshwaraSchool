// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      mediaUrl: json['mediaUrl'] as String? ?? '',
      mediaType: json['mediaType'] as String?,
      sentAt: DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'senderId': instance.senderId,
      'text': instance.text,
      'mediaUrl': instance.mediaUrl,
      'mediaType': instance.mediaType,
      'sentAt': instance.sentAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
    };

_$ChatImpl _$$ChatImplFromJson(Map<String, dynamic> json) => _$ChatImpl(
  chatId: json['chatId'] as String,
  schoolId: json['schoolId'] as String,
  participantUids: (json['participantUids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  participantRoles: Map<String, String>.from(json['participantRoles'] as Map),
  lastMessage: json['lastMessage'] as String? ?? '',
  lastMessageAt: json['lastMessageAt'] == null
      ? null
      : DateTime.parse(json['lastMessageAt'] as String),
  unreadCount:
      (json['unreadCount'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$$ChatImplToJson(_$ChatImpl instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'schoolId': instance.schoolId,
      'participantUids': instance.participantUids,
      'participantRoles': instance.participantRoles,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'unreadCount': instance.unreadCount,
    };
