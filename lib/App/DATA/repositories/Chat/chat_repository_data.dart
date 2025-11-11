import 'package:ezride/App/DATA/datasources/Chat/chat_remote_datasource.dart';
import 'package:ezride/App/DATA/models/Chat/chat_message_model.dart';
import 'package:ezride/App/DOMAIN/Entities/Chat/chat_message_entity.dart';
import 'package:ezride/App/DOMAIN/Entities/Chat/chat_conversation_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/Chat/chat_repository_domain.dart';

class ChatRepositoryData implements ChatRepositoryDomain {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryData(this.remoteDataSource);

  @override
  Future<List<ChatConversation>> getConversations(String userId) async {
    try {
      final conversations = await remoteDataSource.getConversations(userId);
      return conversations;
    } catch (e) {
      print('Error en getConversations: $e');
      rethrow;
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final messages = await remoteDataSource.getMessages(conversationId);
      return messages;
    } catch (e) {
      print('Error en getMessages: $e');
      rethrow;
    }
  }

  @override
  Future<ChatMessage> sendMessage(ChatMessage message) async {
    try {
      final messageModel = ChatMessageModel.fromEntity(message);
      final sentMessage = await remoteDataSource.sendMessage(messageModel);
      return sentMessage;
    } catch (e) {
      print('Error en sendMessage: $e');
      rethrow;
    }
  }

  @override
  Future<bool> markAsRead(String conversationId, String userId) async {
    try {
      return await remoteDataSource.markMessagesAsRead(conversationId, userId);
    } catch (e) {
      print('Error en markAsRead: $e');
      return false;
    }
  }
}