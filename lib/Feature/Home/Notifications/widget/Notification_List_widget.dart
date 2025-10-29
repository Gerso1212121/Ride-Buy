import 'package:ezride/Feature/Home/Notifications/widget/Notification_Card_widget.dart';
import 'package:flutter/material.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationItem> notifications;
  final ValueChanged<String>? onNotificationTap;

  const NotificationList({
    super.key,
    required this.notifications,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(
            title: notification.title,
            message: notification.message,
            time: notification.time,
            icon: notification.icon,
            iconColor: notification.iconColor,
            isRead: notification.isRead,
            hasNewMessage: notification.hasNewMessage,
            onTap: () => onNotificationTap?.call(notification.id),
          );
        },
      ),
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isRead;
  final bool hasNewMessage;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
    this.hasNewMessage = false,
  });
}