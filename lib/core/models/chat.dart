import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String messageId,
    required String senderId,
    required String text,
    @Default('') String mediaUrl,
    String? mediaType,
    required DateTime sentAt,
    DateTime? readAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage.fromJson({
      ...data,
      'messageId': doc.id,
      'sentAt': (data['sentAt'] as Timestamp).toDate().toIso8601String(),
      'readAt': (data['readAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension ChatMessageX on ChatMessage {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('messageId');
    json['sentAt'] = Timestamp.fromDate(sentAt);
    if (readAt != null) json['readAt'] = Timestamp.fromDate(readAt!);
    return json;
  }

  bool get isRead => readAt != null;
}

@freezed
class Chat with _$Chat {
  const factory Chat({
    required String chatId,
    required String schoolId,
    required List<String> participantUids,
    required Map<String, String> participantRoles,
    @Default('') String lastMessage,
    DateTime? lastMessageAt,
    @Default({}) Map<String, int> unreadCount,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat.fromJson({
      ...data,
      'chatId': doc.id,
      'lastMessageAt':
          (data['lastMessageAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension ChatX on Chat {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('chatId');
    if (lastMessageAt != null) {
      json['lastMessageAt'] = Timestamp.fromDate(lastMessageAt!);
    }
    return json;
  }

  String otherParticipant(String myUid) =>
      participantUids.firstWhere((uid) => uid != myUid, orElse: () => '');

  int unreadFor(String uid) => unreadCount[uid] ?? 0;
}