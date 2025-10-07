import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    this.backgroundColor = Colors.white,
    this.automaticallyImplyLeading = false,
    this.title = 'RIDE & BUY',
    this.logoIcon = Icons.directions_car,
    this.logoColor = Colors.white,
    this.logoSize = 20,
    this.titleColor = const Color(0xFF1E293B),
    this.titleSize = 22,
    this.showNotifications = true,
    this.showMenu = true,
    this.onNotificationsPressed,
    this.onMenuPressed,
    this.elevation = 0,
    this.centerTitle = false,
  }) : super(key: key);

  final Color backgroundColor;
  final bool automaticallyImplyLeading;
  final String title;
  final IconData logoIcon;
  final Color logoColor;
  final double logoSize;
  final Color titleColor;
  final double titleSize;
  final bool showNotifications;
  final bool showMenu;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onMenuPressed;
  final double elevation;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Logo container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                stops: [0, 1],
                begin: AlignmentDirectional(1, -1),
                end: AlignmentDirectional(-1, 1),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Align(
              alignment: AlignmentDirectional.center,
              child: Icon(
                logoIcon,
                color: logoColor,
                size: logoSize,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: titleColor,
                  fontSize: titleSize,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      actions: _buildActions(),
      centerTitle: centerTitle,
      elevation: elevation,
      // ↓↓↓↓ ESTAS SON LAS PROPIEDADES CLAVE PARA BLOQUEAR EL COLOR ↓↓↓↓
      scrolledUnderElevation: 0, // Elimina la sombra al scrollear
      surfaceTintColor: Colors.transparent, // Elimina el tinte automático
      shadowColor: Colors.transparent, // Sin sombras
      foregroundColor: Colors.transparent, // Sin efectos de overlay
      // ↑↑↑↑ ESTAS SON LAS PROPIEDADES CLAVE PARA BLOQUEAR EL COLOR ↑↑↑↑
    );
  }

  List<Widget>? _buildActions() {
    final actions = <Widget>[];

    if (showNotifications || showMenu) {
      final actionButtons = <Widget>[];

      if (showNotifications) {
        actionButtons.add(
          _buildActionButton(
            icon: Icons.notifications_outlined,
            onPressed: onNotificationsPressed ?? () {
              print('Notifications button pressed ...');
            },
          ),
        );
      }

      actions.add(
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: actionButtons,
          ),
        ),
      );
    }

    return actions.isNotEmpty ? actions : null;
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: const Color(0xFF3B82F6),
          size: 20,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}