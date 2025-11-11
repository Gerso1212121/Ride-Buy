import 'package:ezride/App/DATA/models/Chat/chat_message_model.dart';
import 'package:ezride/App/DATA/models/Chat/chat_conversation_model.dart';
import 'package:ezride/Services/render/render_db_client.dart';

class ChatRemoteDataSource {
  
  Future<List<ChatConversationModel>> getConversations(String userId) async {
    const sql = '''
      SELECT c.*, COUNT(m.id) as total_messages
      FROM chat_conversations c
      LEFT JOIN chat_messages m ON m.conversation_id = c.id
      WHERE c.is_active = true AND @user_id = ANY(c.participant_ids)
      GROUP BY c.id
      ORDER BY c.last_message_at DESC;
    ''';

    try {
      final result = await RenderDbClient.query(sql, parameters: {'user_id': userId});
      return result.map((map) => ChatConversationModel.fromMap(map)).toList();
    } catch (e) {
      print('Error en getConversations: $e');
      rethrow;
    }
  }

  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    const sql = '''
      SELECT m.*, p.display_name as sender_name, p.avatar_url as sender_avatar
      FROM chat_messages m
      LEFT JOIN profiles p ON m.sender_id = p.id
      WHERE m.conversation_id = @conversation_id
      ORDER BY m.timestamp DESC
      LIMIT 100;
    ''';

    try {
      final result = await RenderDbClient.query(sql, parameters: {'conversation_id': conversationId});
      return result.map((map) => ChatMessageModel.fromMap(map)).toList();
    } catch (e) {
      print('Error en getMessages: $e');
      rethrow;
    }
  }

  Future<ChatMessageModel> sendMessage(ChatMessageModel message) async {
    const sql = '''
      INSERT INTO chat_messages (id, conversation_id, sender_id, sender_role, text, timestamp, status)
      VALUES (@id, @conversation_id, @sender_id, @sender_role, @text, @timestamp, @status)
      RETURNING *;
    ''';

    try {
      final result = await RenderDbClient.query(sql, parameters: message.toMap());
      if (result.isEmpty) throw Exception('No se pudo enviar el mensaje');
      return ChatMessageModel.fromMap(result.first);
    } catch (e) {
      print('Error en sendMessage: $e');
      rethrow;
    }
  }

  Future<bool> markMessagesAsRead(String conversationId, String userId) async {
    // Implementación básica - puedes expandir después
    print('Mensajes marcados como leídos: $conversationId por $userId');
    return true;
  }
}