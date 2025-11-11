import 'package:ezride/App/DOMAIN/Entities/Chat/chat_message_entity.dart';
import 'package:ezride/Core/enums/enums.dart';

class ChatMessageModel extends ChatMessage {
  final String? senderName;
  final String? senderAvatar;

  ChatMessageModel({
    required String id,
    required String conversationId,
    required String senderId,
    required ChatUserRole senderRole,
    required String text,
    required DateTime timestamp,
    MessageStatus status = MessageStatus.sent,
    this.senderName,
    this.senderAvatar,
  }) : super(
          id: id,
          conversationId: conversationId,
          senderId: senderId,
          senderRole: senderRole,
          text: text,
          timestamp: timestamp,
          status: status,
        );

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as String? ?? '',
      conversationId: map['conversation_id'] as String? ?? '',
      senderId: map['sender_id'] as String? ?? '',
      senderRole: _parseChatUserRole(map['sender_role'] as String?),
      text: map['text'] as String? ?? '',
      timestamp: _parseDateTime(map['timestamp']),
      status: _parseMessageStatus(map['status'] as String?),
      senderName: map['sender_name'] as String?,
      senderAvatar: map['sender_avatar'] as String?,
    );
  }

  static ChatUserRole _parseChatUserRole(String? value) {
    if (value == null) return ChatUserRole.customer;
    try {
      return ChatUserRole.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return ChatUserRole.customer;
    }
  }

  static MessageStatus _parseMessageStatus(String? value) {
    if (value == null) return MessageStatus.sent;
    try {
      return MessageStatus.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return MessageStatus.sent;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_role': senderRole.name,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
    };
  }

  // Método para crear desde entity (sin campos adicionales)
  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      senderRole: entity.senderRole,
      text: entity.text,
      timestamp: entity.timestamp,
      status: entity.status,
    );
  }
}