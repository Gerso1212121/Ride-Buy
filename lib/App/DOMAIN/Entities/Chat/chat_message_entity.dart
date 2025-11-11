import 'package:ezride/Core/enums/enums.dart';

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final ChatUserRole senderRole;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  // Métodos básicos
  bool get isFromCustomer => senderRole == ChatUserRole.customer;
  bool get isFromAgent => senderRole == ChatUserRole.agent;

  String get horaFormateada {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get fechaFormateada {
    final ahora = DateTime.now();
    if (timestamp.day == ahora.day && 
        timestamp.month == ahora.month && 
        timestamp.year == ahora.year) {
      return 'Hoy';
    }
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}