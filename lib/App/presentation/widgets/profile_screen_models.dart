import 'package:flutter/material.dart';

class ProfileData {
  final String businessName;
  final String backgroundImageUrl;
  final String profileImageUrl;
  final double rating;
  final int reviewCount;
  final String aboutUs;
  final String address;
  final String phone;
  final String email;
  final String businessHours;
  final List<RentalPolicy> rentalPolicies;
  final List<AdditionalService> additionalServices;

  const ProfileData({
    required this.businessName,
    required this.backgroundImageUrl,
    required this.profileImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.aboutUs,
    required this.address,
    required this.phone,
    required this.email,
    required this.businessHours,
    required this.rentalPolicies,
    required this.additionalServices,
  });

  ContactInfo get contactInfo => ContactInfo(
    address: address,
    phone: phone,
    email: email,
    businessHours: businessHours,
  );
}

class RentalPolicy {
  final String description;

  const RentalPolicy(this.description);
}

class AdditionalService {
  final String name;
  final IconData icon;
  final double width;

  const AdditionalService({
    required this.name,
    required this.icon,
    required this.width,
  });
}

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

// ✅ CAMBIADO: ProfileContentSectionType en lugar de ContentSectionType
enum ProfileContentSectionType {
  contactInfo,
  aboutUs,
  rentalPolicies,
  additionalServices,
}

// ✅ CAMBIADO: ProfileContentSection en lugar de ContentSection
class ProfileContentSection extends StatelessWidget {
  final ProfileContentSectionType type;
  final String title;
  final String? description;
  final ContactInfo? contactInfo;
  final List<RentalPolicy>? policies;
  final List<AdditionalService>? services;

  const ProfileContentSection({
    super.key,
    required this.type,
    required this.title,
    this.description,
    this.contactInfo,
    this.policies,
    this.services,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ CORREGIDO: Usar el widget correcto
    return _buildContentSection();
  }

  Widget _buildContentSection() {
    // Aquí debes retornar el widget correspondiente según el tipo
    // Por ahora retornamos un placeholder
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (description != null) Text(description!),
          // Aquí puedes agregar más lógica según el tipo
        ],
      ),
    );
  }
}