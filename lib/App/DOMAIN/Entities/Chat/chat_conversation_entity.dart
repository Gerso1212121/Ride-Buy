class ChatConversation {
  final String id;
  final String? title;
  final String? imageUrl;
  final List<String> participantIds;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isActive;

  ChatConversation({
    required this.id,
    this.title,
    this.imageUrl,
    required this.participantIds,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isActive = true,
  });

  bool get hasUnread => unreadCount > 0;
  String get tituloDisplay => title ?? 'Chat';
}