import 'package:flutter/material.dart';
import 'package:ezride/Core/widgets/Buttons/Button_global.dart';
import 'package:ezride/Feature/PROFILE_RENT/widget/Profile_Content_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'profile_screen_models.dart';

class ProfileContentBody extends StatelessWidget {
  final ProfileData profileData;
  final VoidCallback onContact;
  final VoidCallback onViewCars;
  final VoidCallback onOpenLocation;
  final bool hasInitialData;

  const ProfileContentBody({
    super.key,
    required this.profileData,
    required this.onContact,
    required this.onViewCars,
    required this.onOpenLocation,
    this.hasInitialData = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: <Widget>[
            if (hasInitialData) _buildQuickLoadIndicator(),
            _buildActionButtons(context),
            _buildContentSection(
              // ✅ CAMBIADO: Usar ProfileContentSection
              ProfileContentSection(
                type: ProfileContentSectionType.contactInfo,
                title: 'Información de contacto',
                contactInfo: profileData.contactInfo,
              ),
            ),
            _buildContentSection(
              ProfileContentSection(
                type: ProfileContentSectionType.aboutUs,
                title: 'Acerca de nosotros',
                description: profileData.aboutUs,
              ),
            ),
            _buildContentSection(
              ProfileContentSection(
                type: ProfileContentSectionType.rentalPolicies,
                title: 'Políticas de renta',
                policies: profileData.rentalPolicies,
              ),
            ),
            _buildContentSection(
              ProfileContentSection(
                type: ProfileContentSectionType.additionalServices,
                title: 'Servicios adicionales',
                services: profileData.additionalServices,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLoadIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          SizedBox(width: 4),
          Text(
            'Datos cargados instantáneamente',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: child,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          _buildActionButton(
            context: context,
            onPressed: onContact,
            text: 'Contáctanos',
            icon: Icons.chat_rounded,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            context: context,
            onPressed: onViewCars,
            text: 'Autos',
            icon: Icons.directions_car_rounded,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            context: context,
            onPressed: onOpenLocation,
            text: 'Ubicación',
            icon: Icons.location_on_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
  }) {
    return Flexible(
      child: CustomButtonWithStates(
        onPressed: onPressed,
        text: text,
        icon: icon,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        hoverColor: FlutterFlowTheme.of(context).primary.withOpacity(0.8),
        splashColor: FlutterFlowTheme.of(context).primary.withOpacity(0.6),
        height: 48,
        borderRadius: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}