import 'dart:ui';
import 'package:ezride/Feature/PROFILE_RENT/profile_model_model.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ContentSectionType {
  aboutUs,
  contactInfo,
  rentalPolicies,
  additionalServices
}

class ContentSection extends StatelessWidget {
  final ContentSectionType type;
  final String title;
  final String description;
  final List<RentalPolicy>? policies;
  final List<AdditionalService>? services;
  final ContactInfo? contactInfo;

  const ContentSection({
    super.key,
    required this.type,
    required this.title,
    this.description = '',
    this.policies,
    this.services,
    this.contactInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
          child: _buildContentByType(context),
        ),
      ),
    );
  }

  Widget _buildContentByType(BuildContext context) {
    switch (type) {
      case ContentSectionType.aboutUs:
        return _buildAboutUsContent(context);
      case ContentSectionType.contactInfo:
        return _buildContactInfoContent(context);
      case ContentSectionType.rentalPolicies:
        return _buildPoliciesContent(context);
      case ContentSectionType.additionalServices:
        return _buildServicesContent(context);
    }
  }

  Widget _buildAboutUsContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context, title),
        const SizedBox(height: 12),
        _buildDescription(context, description),
      ],
    );
  }

  Widget _buildContactInfoContent(BuildContext context) {
    if (contactInfo == null) return const SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context, title),
        const SizedBox(height: 16),
        _buildContactItem(
          context,
          Icons.location_on_rounded,
          contactInfo!.address,
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          context,
          Icons.phone_rounded,
          contactInfo!.phone,
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          context,
          Icons.email_rounded,
          contactInfo!.email,
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          context,
          Icons.access_time_rounded,
          contactInfo!.businessHours,
        ),
      ],
    );
  }

  Widget _buildPoliciesContent(BuildContext context) {
    if (policies == null || policies!.isEmpty) return const SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context, title),
        const SizedBox(height: 16),
        Column(
          children: policies!
              .map((policy) => _buildPolicyItem(context, policy))
              .toList()
              .divide(const SizedBox(height: 8)),
        ),
      ],
    );
  }

  Widget _buildServicesContent(BuildContext context) {
    if (services == null || services!.isEmpty) return const SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start, // Texto a la izquierda
      children: [
        _buildTitle(context, title),
        const SizedBox(height: 16),
        // Contenedor centrado
        Center(
          child: _buildServicesGrid(context, services!),
        ),
      ],
    );
  }

  // ========== COMPONENTES REUTILIZABLES ==========

  Widget _buildTitle(BuildContext context, String text) {
    return Text(
      text,
      style: FlutterFlowTheme.of(context).titleLarge.override(
            font: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
            ),
            letterSpacing: 0.0,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDescription(BuildContext context, String text) {
    return Text(
      text,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.lato(
              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
            color: FlutterFlowTheme.of(context).primaryText,
            letterSpacing: 0.0,
            lineHeight: 1.5,
          ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: FlutterFlowTheme.of(context).primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lato(
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  letterSpacing: 0.0,
                ),
          ),
        ),
      ],
    );
  }

//Politicas de la empresa en renta
  Widget _buildPolicyItem(BuildContext context, RentalPolicy policy) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: FlutterFlowTheme.of(context).success,
          size: 16,
        ),
        Expanded(
          child: Text(
            policy.description,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.lato(
                    fontWeight:
                        FlutterFlowTheme.of(context).bodySmall.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  ),
                  letterSpacing: 0.0,
                ),
          ),
        ),
      ].divide(const SizedBox(width: 8)),
    );
  }

  Widget _buildServicesGrid(
      BuildContext context, List<AdditionalService> services) {
    return Container(
      width: double.infinity, // ✅ Ocupa todo el ancho disponible
      child: Wrap(
        alignment:
            WrapAlignment.center, // ✅ CENTRA los elementos horizontalmente
        runAlignment: WrapAlignment.center, // ✅ CENTRA las filas verticalmente
        spacing: 12, // ✅ Espacio horizontal entre elementos
        runSpacing: 12, // ✅ Espacio vertical entre filas
        children: services
            .map((service) => _buildServiceItem(context, service))
            .toList(),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, AdditionalService service) {
    return Container(
      width: service.width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            service.icon,
            color: FlutterFlowTheme.of(context).primary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            service.name,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.lato(
                    fontWeight:
                        FlutterFlowTheme.of(context).bodySmall.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  ),
                  fontSize: 10,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }
}

// Modelo adicional para información de contacto
class ContactInfo {
  final String address;
  final String phone;
  final String email;
  final String businessHours;

  const ContactInfo({
    required this.address,
    required this.phone,
    required this.email,
    required this.businessHours,
  });
}
