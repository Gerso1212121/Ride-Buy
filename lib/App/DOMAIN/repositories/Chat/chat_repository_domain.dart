import 'package:ezride/App/DOMAIN/Entities/Chat/chat_message_entity.dart';
import 'package:ezride/App/DOMAIN/Entities/Chat/chat_conversation_entity.dart';

abstract class ChatRepositoryDomain {
  // Solo métodos esenciales
  Future<List<ChatConversation>> getConversations(String userId);
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<ChatMessage> sendMessage(ChatMessage message);
  Future<bool> markAsRead(String conversationId, String userId);
}