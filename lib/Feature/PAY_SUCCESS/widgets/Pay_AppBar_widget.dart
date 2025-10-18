import 'package:flutter/material.dart';

class AppbarPaycWidgets extends StatelessWidget implements PreferredSizeWidget {
  const AppbarPaycWidgets({
    Key? key,
    required this.onClosePressed,
    this.title = 'Confirmación de pago',
    this.backgroundColor = const Color(0xFFF8FFFE),
    this.elevation = 0,
    this.leadingIcon = Icons.close_rounded,
    this.leadingIconColor = const Color(0xFF6B7280),
    this.leadingButtonColor = const Color(0xFFF9FAFB),
    this.leadingBorderColor = const Color(0xFFE5E7EB),
    this.titleColor = const Color(0xFF1F2937),
  }) : super(key: key);

  final VoidCallback onClosePressed;
  final String title;
  final Color backgroundColor;
  final double elevation;
  final IconData leadingIcon;
  final Color leadingIconColor;
  final Color leadingButtonColor;
  final Color leadingBorderColor;
  final Color titleColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      leading: const _LeadingButton(), // Widget separado para optimización
      title: _Title( // Widget separado con const
        title: title,
        titleColor: titleColor,
      ),
      centerTitle: true,
      elevation: elevation,
      toolbarHeight: kToolbarHeight,
    );
  }
}

// Widget separado para el botón - PUEDE SER CONST
class _LeadingButton extends StatelessWidget {
  const _LeadingButton();

  @override
  Widget build(BuildContext context) {
    final appBar = context.findAncestorWidgetOfExactType<AppbarPaycWidgets>();
    if (appBar == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 0, 15),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Material(
          borderRadius: BorderRadius.circular(12),
          color: appBar.leadingButtonColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: appBar.onClosePressed,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: appBar.leadingBorderColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                appBar.leadingIcon,
                color: appBar.leadingIconColor,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget separado para el título - PUEDE SER CONST
class _Title extends StatelessWidget {
  const _Title({
    required this.title,
    required this.titleColor,
  });

  final String title;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: titleColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
      ),
    );
  }
}