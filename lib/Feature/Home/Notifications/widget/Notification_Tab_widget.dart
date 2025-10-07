import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class NotificationTabs extends StatelessWidget {
  final NotificationTabType currentTab;
  final ValueChanged<NotificationTabType> onTabChanged;
  final VoidCallback? onPop; // Nueva propiedad para el pop

  const NotificationTabs({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    this.onPop, // Parámetro opcional
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Botón de retroceso
            if (onPop != null) _buildPopButton(context),
            if (onPop != null) const SizedBox(width: 12),
            
            // Tabs
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTab(
                    context: context,
                    type: NotificationTabType.chats,
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Chats',
                    isSelected: currentTab == NotificationTabType.chats,
                  ),
                  _buildTab(
                    context: context,
                    type: NotificationTabType.rentals,
                    icon: Icons.directions_car_rounded,
                    label: 'Rentas',
                    isSelected: currentTab == NotificationTabType.rentals,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPop,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE9ECEF),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF014ECF),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required NotificationTabType type,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onTabChanged(type),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF014ECF)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF014ECF)
                      : const Color(0xFFE9ECEF),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF014ECF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF014ECF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: GoogleFonts.figtree(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF014ECF),
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum NotificationTabType { chats, rentals }