import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessage {
  final String text;
  final String time;
  final bool isMe;
  final String? dateLabel;

  ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
    this.dateLabel,
  });
}

class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final Color myMessageColor;
  final Color otherMessageColor;
  final Color myTextColor;
  final Color otherTextColor;
  final Color myTimeColor;
  final Color otherTimeColor;
  final double maxMessageWidth;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry messagePadding;

  const ChatMessageList({
    Key? key,
    required this.messages,
    this.myMessageColor = const Color.fromARGB(255, 70, 107, 229),
    this.otherMessageColor = Colors.white,
    this.myTextColor = Colors.white,
    this.otherTextColor = Colors.black,
    this.myTimeColor = const Color(0xFFE0E7FF),
    this.otherTimeColor = const Color(0xFF64748B),
    this.maxMessageWidth = 280,
    this.borderRadius = 16,
    this.padding = const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
    this.messagePadding = const EdgeInsets.all(12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: padding,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: _buildMessageList(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMessageList(BuildContext context) {
    List<Widget> messageWidgets = [];

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];

      // Add date label if exists
      if (message.dateLabel != null) {
        messageWidgets.add(
          _buildDateLabel(context, message.dateLabel!),
        );
      }

      // Add message bubble
      messageWidgets.add(
        _buildMessageBubble(context, message),
      );

      // Add spacing between messages
      if (i < messages.length - 1) {
        messageWidgets.add(const SizedBox(height: 16));
      }
    }

    // Add top and bottom padding
    return messageWidgets
        .addToStart(const SizedBox(height: 16))
        .addToEnd(const SizedBox(height: 16));
  }

  Widget _buildDateLabel(BuildContext context, String label) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: FlutterFlowTheme.of(context).bodySmall.override(
            font: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
            ),
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: 12,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w500,
          ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: maxMessageWidth,
          ),
          decoration: BoxDecoration(
            color: message.isMe ? myMessageColor : otherMessageColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: message.isMe
                ? null
                : Border.all(
                    color: FlutterFlowTheme.of(context).alternate,
                    width: 1,
                  ),
          ),
          child: Padding(
            padding: messagePadding,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: message.isMe ? myTextColor : otherTextColor,
                        fontSize: 14,
                        letterSpacing: 0.0,
                      ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                  child: Text(
                    message.time,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                            fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                          ),
                          color: message.isMe ? myTimeColor : otherTimeColor,
                          fontSize: 11,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}