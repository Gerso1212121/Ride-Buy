import 'package:flutter/material.dart';

class AppBarCarDetailwidgets extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCarDetailwidgets({
    Key? key,
    required this.onBackPressed,
    required this.onFavoritePressed,
    this.isFavorite = false,
    this.backgroundColor = Colors.transparent,
    this.elevation = 0,
    this.backIconColor = Colors.white,
    this.favoriteIconColor = Colors.white,
    this.backButtonColor = Colors.black54,
    this.showShadow = false,
  }) : super(key: key);

  final VoidCallback onBackPressed;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;
  final Color backgroundColor;
  final double elevation;
  final Color backIconColor;
  final Color favoriteIconColor;
  final Color backButtonColor;
  final bool showShadow;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency, // 👈 elimina el fondo gris por completo
      child: AppBar(
        backgroundColor: backgroundColor,
        elevation: elevation,
        leadingWidth: 56,
        toolbarHeight: kToolbarHeight,
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
        centerTitle: true,
        surfaceTintColor: Colors.transparent, // 👈 evita tintado en Material 3
        shadowColor: Colors.transparent,
        flexibleSpace: SafeArea(
          child: _buildAppBarContent(),
        ),
      ),
    );
  }

  Widget _buildAppBarContent() {
    return Container(
      decoration: showShadow
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔙 Botón de retroceso
            _buildIconButton(
              onPressed: onBackPressed,
              icon: Icons.arrow_back_rounded,
              iconColor: backIconColor,
              backgroundColor: backButtonColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }
}
