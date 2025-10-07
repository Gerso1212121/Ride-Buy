import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isRead;
  final bool hasNewMessage;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
    this.hasNewMessage = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return Opacity(
      opacity: isRead ? 0.7 : 1.0,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.transparent,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildIcon(theme),
                  const SizedBox(width: 16),
                  _buildContent(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(FlutterFlowTheme theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        icon,
        color: theme.info,
        size: 24,
      ),
    );
  }

  Widget _buildContent(FlutterFlowTheme theme) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.titleMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.w600,
                    fontStyle: theme.titleMedium.fontStyle,
                  ),
                  letterSpacing: 0.0,
                ),
              ),
              Text(
                time,
                style: theme.bodySmall.override(
                  font: GoogleFonts.inter(
                    fontWeight: theme.bodySmall.fontWeight,
                    fontStyle: theme.bodySmall.fontStyle,
                  ),
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            maxLines: 2,
            style: theme.bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight: theme.bodyMedium.fontWeight,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
              color: theme.secondaryText,
              letterSpacing: 0.0,
            ),
          ),
          if (hasNewMessage) ...[
            const SizedBox(height: 4),
            _buildNewMessageIndicator(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildNewMessageIndicator(FlutterFlowTheme theme) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: theme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Nuevo mensaje',
          style: theme.bodySmall.override(
            font: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontStyle: theme.bodySmall.fontStyle,
            ),
            color: theme.primary,
            letterSpacing: 0.0,
          ),
        ),
      ],
    );
  }
}