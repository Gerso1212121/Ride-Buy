import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    Key? key,
    required this.imageUrl,
    required this.userName,
    required this.verificationStatus,
    this.width = double.infinity,
    this.height = 340,
    this.gradientColors = const [Color(0xFF014ECF), Color(0xFFF5F5F5)],
    this.gradientStops = const [0.1, 1],
    this.gradientBegin = const AlignmentDirectional(0, 1),
    this.gradientEnd = const AlignmentDirectional(0, -1),
    this.padding = const EdgeInsetsDirectional.fromSTEB(24, 40, 24, 24),
    this.imageSize = 120,
    this.borderColor,
    this.borderWidth = 4,
    this.statusIcon = Icons.schedule_rounded,
    this.statusIconSize = 18,
    this.statusBadgeSize = 36,
    this.statusBadgeColor = const Color(0xFFF39C12),
    this.statusTextColor,
    this.userNameStyle,
    this.statusTextStyle,
    this.spacing = 16,
  }) : super(key: key);

  final String imageUrl;
  final String userName;
  final String verificationStatus;
  final double width;
  final double height;
  final List<Color> gradientColors;
  final List<double> gradientStops;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final EdgeInsetsGeometry padding;
  final double imageSize;
  final Color? borderColor;
  final double borderWidth;
  final IconData statusIcon;
  final double statusIconSize;
  final double statusBadgeSize;
  final Color statusBadgeColor;
  final Color? statusTextColor;
  final TextStyle? userNameStyle;
  final TextStyle? statusTextStyle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          stops: gradientStops,
          begin: gradientBegin,
          end: gradientEnd,
        ),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen de perfil con badge de estado
            Container(
              width: imageSize,
              height: imageSize,
              child: Stack(
                children: [
                  // Imagen circular
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(imageUrl),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: borderColor ?? theme.secondaryBackground,
                        width: borderWidth,
                      ),
                    ),
                  ),
                  // Badge de estado
                  Align(
                    alignment: AlignmentDirectional(1, -1),
                    child: Container(
                      width: statusBadgeSize,
                      height: statusBadgeSize,
                      decoration: BoxDecoration(
                        color: statusBadgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: borderColor ?? theme.secondaryBackground,
                          width: borderWidth - 1,
                        ),
                      ),
                      child: Icon(
                        statusIcon,
                        color: statusTextColor ?? theme.info,
                        size: statusIconSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Nombre del usuario
            Text(
              userName,
              textAlign: TextAlign.center,
              style: userNameStyle ??
                  theme.headlineMedium?.copyWith(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 0.0,
                  ),
            ),

            // Badge de estado de verificación
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: statusBadgeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    verificationStatus,
                    style: statusTextStyle ??
                        theme.labelMedium?.copyWith(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w500,
                          color: statusTextColor ?? theme.info,
                          fontSize: 12,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
            ),
          ].divide(SizedBox(height: spacing)),
        ),
      ),
    );
  }
}
