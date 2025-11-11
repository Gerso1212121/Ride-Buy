import 'package:ezride/App/DOMAIN/Entities/Chat/chat_conversation_entity.dart';

class ChatConversationModel extends ChatConversation {
  ChatConversationModel({
    required String id,
    String? title,
    String? imageUrl,
    required List<String> participantIds,
    required DateTime lastMessageAt,
    int unreadCount = 0,
    bool isActive = true,
  }) : super(
          id: id,
          title: title,
          imageUrl: imageUrl,
          participantIds: participantIds,
          lastMessageAt: lastMessageAt,
          unreadCount: unreadCount,
          isActive: isActive,
        );

  factory ChatConversationModel.fromMap(Map<String, dynamic> map) {
    return ChatConversationModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String?,
      imageUrl: map['image_url'] as String?,
      participantIds: map['participant_ids'] != null 
          ? List<String>.from(map['participant_ids'] as List)
          : [],
      lastMessageAt: _parseDateTime(map['last_message_at']),
      unreadCount: (map['unread_count'] as int?) ?? 0,
      isActive: map['is_active'] as bool? ?? true,
    );
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
      'title': title,
      'image_url': imageUrl,
      'participant_ids': participantIds,
      'last_message_at': lastMessageAt.toIso8601String(),
      'unread_count': unreadCount,
      'is_active': isActive,
    };
  }

  // Método para crear desde entity (sin campos adicionales)
  factory ChatConversationModel.fromEntity(ChatConversation entity) {
    return ChatConversationModel(
      id: entity.id,
      title: entity.title,
      imageUrl: entity.imageUrl,
      participantIds: entity.participantIds,
      lastMessageAt: entity.lastMessageAt,
      unreadCount: entity.unreadCount,
      isActive: entity.isActive,
    );
  }
}