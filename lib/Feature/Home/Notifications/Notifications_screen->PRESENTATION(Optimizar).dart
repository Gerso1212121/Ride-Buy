import 'package:ezride/Feature/Home/Notifications/widget/Notification_List_widget.dart';
import 'package:ezride/Feature/Home/Notifications/widget/Notification_Tab_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificacionesWidget extends StatefulWidget {
  const NotificacionesWidget({super.key});

  static String routeName = 'NOTIFICACIONES';
  static String routePath = '/notificaciones';

  @override
  State<NotificacionesWidget> createState() => _NotificacionesWidgetState();
}

class _NotificacionesWidgetState extends State<NotificacionesWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  NotificationTabType _currentTab = NotificationTabType.chats;
  
  final List<NotificationItem> _chatNotifications = [
    NotificationItem(
      id: '1',
      title: 'Soporte EzRide',
      message: 'Hola! ¿En qué podemos ayudarte con tu reserva?',
      time: '10:30 AM',
      icon: Icons.support_agent,
      iconColor: Colors.blue,
      hasNewMessage: true,
    ),
    NotificationItem(
      id: '2',
      title: 'Carlos Mendoza',
      message: 'Perfecto, nos vemos en el punto de encuentro',
      time: '9:15 AM',
      icon: Icons.message,
      iconColor: Colors.green,
    ),
    NotificationItem(
      id: '3',
      title: 'Ana García',
      message: 'Gracias por la excelente atención durante la renta',
      time: 'Ayer',
      icon: Icons.chat,
      iconColor: Colors.orange,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Centro de Ayuda',
      message: 'Nuevas preguntas frecuentes disponibles',
      time: '2 días',
      icon: Icons.help_center,
      iconColor: Colors.purple,
      hasNewMessage: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Comunidad EzRide',
      message: 'Nuevos consejos de conducción compartidos',
      time: '3 días',
      icon: Icons.forum,
      iconColor: Color(0xFF607D8B),
      isRead: true,
    ),
  ];

  final List<NotificationItem> _rentalNotifications = [
    // Aquí puedes agregar las notificaciones de rentas
    NotificationItem(
      id: 'r1',
      title: 'Confirmación de Renta',
      message: 'Tu renta del BMW Serie 3 ha sido confirmada',
      time: 'Hoy',
      icon: Icons.check_circle,
      iconColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _unfocus(context),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            NotificationTabs(
              currentTab: _currentTab,
              onTabChanged: _handleTabChanged,
            ),
            Expanded(
              child: _buildCurrentTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    final notifications = _currentTab == NotificationTabType.chats
        ? _chatNotifications
        : _rentalNotifications;

    return NotificationList(
      notifications: notifications,
      onNotificationTap: _handleNotificationTap,
    );
  }

  void _handleTabChanged(NotificationTabType tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  void _handleNotificationTap(String notificationId) {
    GoRouter.of(context).push('/chat');
    // Navegar a detalle de notificación o chat
  }

  void _handleMorePressed() {
    print('IconButton pressed ...');
  }

  void _unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }
}