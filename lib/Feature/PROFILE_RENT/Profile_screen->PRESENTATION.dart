import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezride/Feature/PROFILE_RENT/profile_model.-%3Emodel.dart';
import 'package:ezride/Core/widgets/Buttons/Button_global.dart';
import 'package:ezride/Core/widgets/Reviews/Reviews_card.dart';
import 'package:ezride/Core/widgets/Reviews/Reviews_global.dart';
import 'package:ezride/Feature/PROFILE_RENT/widget/Profile_Content_widget.dart';
import 'package:ezride/Feature/PROFILE_RENT/widget/Profile_Header_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ProfileScreenBussines extends StatefulWidget {
  const ProfileScreenBussines({super.key});

  @override
  State<ProfileScreenBussines> createState() => _ProfileScreenBussinesState();
}

class _ProfileScreenBussinesState extends State<ProfileScreenBussines> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0.0);

  late final ProfileData _profileData = _getProfileData();
  late final List<Review> _reviews = _getReviews();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  void _onScroll() {
    final newOffset = _scrollController.offset;
    if ((newOffset - _scrollOffset.value).abs() > 5.0) {
      _scrollOffset.value = newOffset;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Stack(
        children: <Widget>[
          // ✅ REUTILIZACIÓN DEL WIDGET ParallaxProfileHeader
          ValueListenableBuilder<double>(
            valueListenable: _scrollOffset,
            builder: (context, offset, _) {
              final double parallaxOffset =
                  _scrollOffset.value.clamp(0.0, 150.0) * 0.4;
              return ParallaxProfileHeader(
                backgroundImageUrl: _profileData.backgroundImageUrl,
                profileImageUrl: _profileData.profileImageUrl,
                businessName: _profileData.businessName,
                businessType: 'Renta de Autos Premium',
                onBackPressed: () => Navigator.of(context).pop(),
                height: 278,
                parallaxOffset: parallaxOffset,
                avatarSize: 100,
              );
            },
          ),

          // ✅ El contenido ya no depende del scrollOffset → no se rebuilda
          _ScrollContent(
            controller: _scrollController,
            profileData: _profileData,
            reviews: _reviews,
            onContact: _contactBusiness,
            onViewCars: _viewCars,
            onOpenLocation: _openLocation,
          ),
        ],
      ),
    );
  }

  void _contactBusiness() {
    print('Contactar con la empresa');
  }

  void _viewCars() {
    print('Ver autos disponibles');
  }

  void _openLocation() {
    print('Abrir ubicación');
  }

  // ✅ DATOS DE EJEMPLO
  ProfileData _getProfileData() {
    return ProfileData(
      businessName: 'AutoRent Premium',
      backgroundImageUrl:
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      profileImageUrl:
          'https://images.unsplash.com/photo-1653479499749-a65f2d322f7f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTg0MjM4MTV8&ixlib=rb-4.1.0&q=80&w=1080',
      rating: 4.5,
      reviewCount: 128,
      aboutUs:
          'AutoRent Premium es una empresa líder en renta de vehículos con más de 15 años de experiencia. Ofrecemos una amplia flota de autos desde económicos hasta de lujo, todos en excelente estado y con mantenimiento regular.',
      address: 'Av. Principal 123, Ciudad, País',
      phone: '+1 234 567 8900',
      email: 'info@autorent.com',
      businessHours:
          'Lun - Vie: 8:00 AM - 8:00 PM, Sáb - Dom: 9:00 AM - 6:00 PM',
      rentalPolicies: [
        RentalPolicy('Edad mínima: 21 años con licencia vigente'),
        RentalPolicy('Seguro incluido en todas las rentas'),
        RentalPolicy('Combustible: entregar con el mismo nivel'),
        RentalPolicy('Cancelación gratuita hasta 24h antes'),
      ],
      additionalServices: [
        AdditionalService(
            name: 'Combustible completo',
            icon: Icons.local_gas_station_rounded,
            width: 80),
        AdditionalService(
            name: 'Sillas para niños',
            icon: Icons.child_friendly_rounded,
            width: 86),
        AdditionalService(
            name: 'GPS incluido', icon: Icons.gps_fixed_rounded, width: 60),
        AdditionalService(
            name: 'Entrega a domicilio',
            icon: Icons.local_shipping_rounded,
            width: 64),
      ],
    );
  }

  List<Review> _getReviews() {
    return [
      Review(
        userName: 'María González',
        userImageUrl: 'https://example.com/user1.jpg',
        rating: 5.0,
        comment:
            'Excelente servicio! El auto estaba impecable y el proceso de renta fue muy sencillo. Definitivamente volveré a rentar con ellos.',
        timeAgo: 'Hace 2 días',
      ),
      Review(
        userName: 'Carlos Rodríguez',
        userImageUrl: 'https://example.com/user2.jpg',
        rating: 4.0,
        comment:
            'Buen servicio en general. El auto estaba limpio y en buen estado. La entrega fue puntual.',
        timeAgo: 'Hace 1 semana',
      ),
      Review(
        userName: 'Ana Martínez',
        userImageUrl: 'https://example.com/user3.jpg',
        rating: 4.5,
        comment:
            'Muy profesionales. Me ayudaron a elegir el auto perfecto para mi viaje familiar. Lo recomiendo!',
        timeAgo: 'Hace 3 semanas',
      ),
    ];
  }
}

// ✅ WIDGET SEPARADO PARA CONTENIDO SCROLLABLE
class _ScrollContent extends StatelessWidget {
  final ScrollController controller;
  final ProfileData profileData;
  final List<Review> reviews;
  final VoidCallback onContact;
  final VoidCallback onViewCars;
  final VoidCallback onOpenLocation;

  const _ScrollContent({
    required this.controller,
    required this.profileData,
    required this.reviews,
    required this.onContact,
    required this.onViewCars,
    required this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
        // ✅ APP BAR TRANSPARENTE
        const SliverAppBar(
          expandedHeight: 250,
          flexibleSpace: SizedBox(),
          pinned: false,
          snap: false,
          floating: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          collapsedHeight: 0,
        ),

        // ✅ CONTENIDO PRINCIPAL
        SliverToBoxAdapter(
          child: _ContentBody(
            profileData: profileData,
            reviews: reviews,
            onContact: onContact,
            onViewCars: onViewCars,
            onOpenLocation: onOpenLocation,
          ),
        ),
      ],
    );
  }
}

// ✅ WIDGET SEPARADO PARA EL CUERPO DEL CONTENIDO
class _ContentBody extends StatelessWidget {
  final ProfileData profileData;
  final List<Review> reviews;
  final VoidCallback onContact;
  final VoidCallback onViewCars;
  final VoidCallback onOpenLocation;

  const _ContentBody({
    required this.profileData,
    required this.reviews,
    required this.onContact,
    required this.onViewCars,
    required this.onOpenLocation,
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
            // Rating centrado
            _buildRatingSection(context),

            // Botones de acción
            _buildActionButtons(context),

            // ✅ SECCIONES DE CONTENIDO
            _buildContentSection(
              ContentSection(
                type: ContentSectionType.contactInfo,
                title: 'Información de contacto',
                contactInfo: ContactInfo(
                  address: profileData.address,
                  phone: profileData.phone,
                  email: profileData.email,
                  businessHours: profileData.businessHours,
                ),
              ),
            ),

            _buildContentSection(
              ContentSection(
                type: ContentSectionType.aboutUs,
                title: 'Acerca de nosotros',
                description: profileData.aboutUs,
              ),
            ),

            _buildContentSection(
              ContentSection(
                type: ContentSectionType.rentalPolicies,
                title: 'Políticas de renta',
                policies: profileData.rentalPolicies,
              ),
            ),

            _buildContentSection(
              ContentSection(
                type: ContentSectionType.additionalServices,
                title: 'Servicios adicionales',
                services: profileData.additionalServices,
              ),
            ),

            // ✅ SECCIÓN DE RESEÑAS OPTIMIZADA
            _buildReviewsSection(context),
          ],
        ),
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
          // Botón CONTÁCTANOS
          Flexible(
            child: CustomButtonWithStates(
              onPressed: onContact,
              text: 'Contáctanos',
              icon: Icons.chat_rounded,
              backgroundColor: FlutterFlowTheme.of(context).primary,
              hoverColor: FlutterFlowTheme.of(context).primary.withOpacity(0.8),
              splashColor:
                  FlutterFlowTheme.of(context).primary.withOpacity(0.6),
              height: 48,
              borderRadius: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 12),

          // Botón VER AUTOS
          Flexible(
            child: CustomButtonWithStates(
              onPressed: onContact,
              text: 'Autos',
              icon: Icons.directions_car_rounded,
              backgroundColor: FlutterFlowTheme.of(context).primary,
              hoverColor: FlutterFlowTheme.of(context).primary.withOpacity(0.8),
              splashColor:
                  FlutterFlowTheme.of(context).primary.withOpacity(0.6),
              height: 48,
              borderRadius: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),

          // Botón VER AUTOS
          Flexible(
            child: CustomButtonWithStates(
              onPressed: onContact,
              text: 'Ubicacion',
              icon: Icons.location_on_rounded,
              backgroundColor: FlutterFlowTheme.of(context).primary,
              hoverColor: FlutterFlowTheme.of(context).primary.withOpacity(0.8),
              splashColor:
                  FlutterFlowTheme.of(context).primary.withOpacity(0.6),
              height: 48,
              borderRadius: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: RatingWidget(
        rating: profileData.rating,
        reviewCount: profileData.reviewCount,
        starSize: 24,
        starSpacing: 4,
        textSpacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        ratingTextStyle: FlutterFlowTheme.of(context).titleMedium.override(
              font: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
              ),
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
            ),
        reviewsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lato(
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Reseñas',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleLarge.fontStyle,
                  ),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // ✅ LISTVIEW.BUILDER PARA MEJOR RENDIMIENTO
          _ReviewsList(reviews: reviews),
        ],
      ),
    );
  }
}

// ✅ WIDGET SEPARADO PARA LISTA DE RESEÑAS
class _ReviewsList extends StatelessWidget {
  final List<Review> reviews;

  const _ReviewsList({required this.reviews});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ReviewCard(
          userName: review.userName,
          userImageUrl: review.userImageUrl,
          rating: review.rating,
          comment: review.comment,
          timeAgo: review.timeAgo,
          padding: const EdgeInsets.only(bottom: 12),
        );
      },
    );
  }
}

// ✅ CLASES DE DATOS (mantener igual)
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

class Review {
  final String userName;
  final String userImageUrl;
  final double rating;
  final String comment;
  final String timeAgo;

  const Review({
    required this.userName,
    required this.userImageUrl,
    required this.rating,
    required this.comment,
    required this.timeAgo,
  });
}
