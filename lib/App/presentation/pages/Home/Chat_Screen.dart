import 'package:ezride/App/DOMAIN/Entities/Chat/chat_message_entity.dart';
import 'package:ezride/Feature/Home/Chat/widget/Chat_Header_widget.dart';
import 'package:ezride/Feature/Home/Chat/widget/Chat_Message_widget.dart';
import 'package:ezride/Feature/Home/Chat/widget/Chat_Send_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class ChatsUser extends StatefulWidget {
  const ChatsUser({super.key});

  @override
  State<ChatsUser> createState() => _ChatsUserState();
}

class _ChatsUserState extends State<ChatsUser> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: '¡Hola! ¿Cómo estás? Me alegra verte por aquí.',
      time: '10:30',
      isMe: false,
    ),
    ChatMessage(
      text: '¡Hola Cerebelo! Estoy muy bien, gracias. ¿Tienes alguna recomendación de vehículos para hoy?',
      time: '10:32',
      isMe: true,
    ),
    ChatMessage(
      text: 'Por supuesto. Tenemos disponibles varios vehículos según tus preferencias. ¿Buscas algo específico?',
      time: '10:35',
      isMe: false,
    ),
    ChatMessage(
      text: 'Estoy buscando un SUV familiar, automático, preferiblemente híbrido. ¿Qué opciones tienes?',
      time: '10:38',
      isMe: true,
    ),
    ChatMessage(
      text: 'Excelente elección. Tenemos un Toyota RAV4 Hybrid 2024 disponible por \$1,200/día y un Honda CR-V Hybrid por \$1,100/día. Ambos son automáticos y tienen capacidad para 5 pasajeros.',
      time: '10:40',
      isMe: false,
    ),
    ChatMessage(
      text: '¿Podrías enviarme más detalles sobre el Toyota RAV4?',
      time: '18:45',
      isMe: true,
    ),
    ChatMessage(
      text: 'Claro que sí. El Toyota RAV4 Hybrid 2024 incluye: • Asistente de mantenimiento de carril • Control de crucero adaptativo • Cámara de 360° • Sistema de sonido premium JBL • Tapicería de cuero. ¿Te interesa agendar una prueba de manejo?',
      time: '18:47',
      isMe: false,
    ),
  ];

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  void _handleSendMessage(String message) {
    if (message.trim().isEmpty) return;

    // Agregar mensaje del usuario
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          time: _getCurrentTime(),
          isMe: true,
        ),
      );
    });

    // Simular respuesta del asistente después de 1 segundo
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: _generateResponse(message),
              time: _getCurrentTime(),
              isMe: false,
            ),
          );
        });
      }
    });

    _messageController.clear();
  }

  void _handleAttachPressed() {
    _showAttachmentOptions();
  }

  void _handleMoreOptionsPressed() {
    _showChatOptions();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _generateResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('hola') || message.contains('buenos días') || message.contains('buenas tardes')) {
      return '¡Hola! ¿En qué puedo ayudarte hoy?';
    } else if (message.contains('precio') || message.contains('cost') || message.contains('valor')) {
      return 'Tenemos vehículos desde \$800 hasta \$2,000 por día. ¿Qué tipo de vehículo te interesa?';
    } else if (message.contains('suv') || message.contains('familiar')) {
      return 'Para SUV familiares te recomiendo el Toyota RAV4 Hybrid o el Honda CR-V. Ambos son excelentes opciones para familia.';
    } else if (message.contains('deportivo') || message.contains('rápido')) {
      return 'Tenemos BMW Serie 3 y Audi A4 disponibles. Son perfectos para quienes buscan rendimiento y estilo.';
    } else if (message.contains('gracias') || message.contains('thank')) {
      return '¡De nada! Estoy aquí para ayudarte. ¿Necesitas más información sobre algún vehículo en particular?';
    } else if (message.contains('disponibilidad') || message.contains('fecha')) {
      return 'Puedo revisar la disponibilidad para las fechas que necesites. ¿Para cuándo planeas tu viaje?';
    } else {
      return 'Entendido. ¿Te gustaría que te ayude a encontrar el vehículo perfecto para tus necesidades?';
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería de fotos'),
                onTap: () {
                  Navigator.pop(context);
                  print('Abrir galería de fotos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  print('Abrir cámara');
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('Documentos'),
                onTap: () {
                  Navigator.pop(context);
                  print('Abrir documentos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Ubicación'),
                onTap: () {
                  Navigator.pop(context);
                  print('Compartir ubicación');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Ver perfil de Cerebelo'),
                onTap: () {
                  Navigator.pop(context);
                  print('Ver perfil');
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Silenciar notificaciones'),
                onTap: () {
                  Navigator.pop(context);
                  print('Silenciar notificaciones');
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Bloquear usuario'),
                onTap: () {
                  Navigator.pop(context);
                  print('Bloquear usuario');
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Reportar problema'),
                onTap: () {
                  Navigator.pop(context);
                  print('Reportar problema');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar chat'),
                titleTextStyle: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
                onTap: () {
                  Navigator.pop(context);
                  print('Eliminar chat');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          // Header del chat
          ChatHeaderCard(
            imageUrl: 'https://images.unsplash.com/photo-1705397523929-84d7c31c99d5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTkwMjM0NjN8&ixlib=rb-4.1.0&q=80&w=1080',
            title: 'Chat',
            subtitle: 'Cerebelo - Asistente Ride & Buy',
            onMorePressed: _handleMoreOptionsPressed,
          ),

          // Lista de mensajes
          ChatMessageList(
            messages: _messages,
            otherMessageColor: Colors.white,
            myTextColor: Colors.white,
            otherTextColor: const Color(0xFF1E293B),
            myTimeColor: const Color(0xFFE0E7FF),
            otherTimeColor: const Color(0xFF64748B),
          ),

          // Input de mensaje
          MessageInput(
            controller: _messageController,
            focusNode: _messageFocusNode,
            hintText: 'Escribe un mensaje...',
            onSubmitted: _handleSendMessage,
            onAttachPressed: _handleAttachPressed,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }
}