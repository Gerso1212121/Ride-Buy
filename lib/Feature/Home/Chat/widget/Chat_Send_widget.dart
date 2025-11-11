// lib/Feature/Home/Chat/widget/Chat_Send_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final Function(String) onSubmitted;
  final VoidCallback onAttachPressed;
  final VoidCallback? onTypingStarted;
  final VoidCallback? onTypingStopped;

  const MessageInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onSubmitted,
    required this.onAttachPressed,
    this.onTypingStarted,
    this.onTypingStopped,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  Timer? _typingTimer;

  void _onTextChanged(String text) {
    // Notificar que se está escribiendo
    widget.onTypingStarted?.call();

    // Reiniciar timer de typing
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      widget.onTypingStopped?.call();
    });
  }

  void _onSubmitted(String text) {
    _typingTimer?.cancel();
    widget.onTypingStopped?.call();
    widget.onSubmitted(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Botón adjuntar
          IconButton(
            onPressed: widget.onAttachPressed,
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.grey.shade600,
              size: 28,
            ),
          ),
          
          // Campo de texto
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                onChanged: _onTextChanged,
                onSubmitted: _onSubmitted,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          
          // Botón enviar
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                _onSubmitted(widget.controller.text);
              },
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}