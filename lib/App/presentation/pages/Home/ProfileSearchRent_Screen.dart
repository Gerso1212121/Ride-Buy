import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezride/Feature/PROFILE_RENT/profile_model_model.dart';
import 'package:ezride/Core/widgets/Buttons/Button_global.dart';
import 'package:ezride/Core/widgets/Reviews/Reviews_card.dart';
import 'package:ezride/Core/widgets/Reviews/Reviews_global.dart';
import 'package:ezride/Feature/PROFILE_RENT/widget/Profile_Content_widget.dart';
import 'package:ezride/Feature/PROFILE_RENT/widget/Profile_Header_widget.dart';
import 'package:ezride/Services/utils/EmpresasService.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ezride/App/DATA/models/Empresas_model.dart';

class ProfileScreenBussines extends StatefulWidget {
  final String empresaId;
  final Map<String, dynamic>? empresaData;

  const ProfileScreenBussines({
    super.key,
    required this.empresaId,
    this.empresaData,
  });

  @override
  State<ProfileScreenBussines> createState() => _ProfileScreenBussinesState();
}

class _ProfileScreenBussinesState extends State<ProfileScreenBussines> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0.0);

  late Future<Map<String, dynamic>> _profileDataFuture;
  EmpresasModel? _empresa;
  double _rating = 0.0;
  int _reviewCount = 0;
  int _totalVehiculos = 0;
  int _vehiculosDisponibles = 0;
  List<Map<String, dynamic>> _serviciosAdicionales = [];
  List<String> _politicasRenta = [];
  List<Map<String, dynamic>> _resenas = [];
  bool _hasInitialData = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    if (widget.empresaData != null) {
      _hasInitialData = true;
      _initializeWithExistingData(widget.empresaData!);
      _profileDataFuture = _loadAdditionalData();
    } else {
      _profileDataFuture = _loadFullProfileData();
    }
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

  // ✅ INICIALIZAR CON DATOS EXISTENTES
  void _initializeWithExistingData(Map<String, dynamic> empresaData) {
    try {
      print(
          '✅ Inicializando con datos existentes de: ${empresaData['nombre']}');

      setState(() {
        _empresa = EmpresasModel.fromJson(empresaData);
        _rating = 4.5;
        _reviewCount = 0;
        _totalVehiculos = 0;
        _vehiculosDisponibles = 0;
      });
    } catch (e) {
      print('❌ Error inicializando con datos existentes: $e');
      _hasInitialData = false;
    }
  }

  // ✅ CARGAR SOLO DATOS ADICIONALES
  Future<Map<String, dynamic>> _loadAdditionalData() async {
    try {
      print('📊 Cargando datos adicionales para empresa: ${widget.empresaId}');

      final resultados = await Future.wait([
        EmpresasService.getEstadisticasEmpresa(widget.empresaId),
        EmpresasService.getServiciosAdicionales(widget.empresaId),
        EmpresasService.getPoliticasRenta(widget.empresaId),
        EmpresasService.getResenasRecientes(widget.empresaId),
      ], eagerError: false);

      final estadisticas = resultados[0] as Map<String, dynamic>;
      final servicios = resultados[1] as List<Map<String, dynamic>>;
      final politicas = resultados[2] as List<String>;
      final resenas = resultados[3] as List<Map<String, dynamic>>;

      if (mounted) {
        setState(() {
          _rating = estadisticas['rating_promedio'] as double;
          _reviewCount = estadisticas['total_resenas'] as int;
          _totalVehiculos = estadisticas['total_vehiculos'] as int;
          _vehiculosDisponibles = estadisticas['vehiculos_disponibles'] as int;
          _serviciosAdicionales = servicios;
          _politicasRenta = politicas;
          _resenas = resenas;
        });
      }

      return {
        'empresa': _empresa,
        ...estadisticas,
        'servicios_adicionales': servicios,
        'politicas_renta': politicas,
        'reseñas_recientes': resenas,
      };
    } catch (e) {
      print('❌ Error cargando datos adicionales: $e');
      return {};
    }
  }

  // ✅ CARGAR TODOS LOS DATOS - CORREGIDO
  Future<Map<String, dynamic>> _loadFullProfileData() async {
    try {
      print('🏢 Cargando perfil completo de empresa: ${widget.empresaId}');

      final data =
          await EmpresasService.getEmpresaProfileData(widget.empresaId);

      if (mounted) {
        setState(() {
          // ✅ CORREGIDO: Convertir Map a EmpresasModel
          final empresaMap = data['empresa'] as Map<String, dynamic>;
          _empresa = EmpresasModel.fromJson(empresaMap);

          _rating = data['rating_promedio'] as double;
          _reviewCount = data['total_resenas'] as int;
          _totalVehiculos = data['total_vehiculos'] as int;
          _vehiculosDisponibles = data['vehiculos_disponibles'] as int;
          _serviciosAdicionales =
              data['servicios_adicionales'] as List<Map<String, dynamic>>;
          _politicasRenta = data['politicas_renta'] as List<String>;
          _resenas = data['reseñas_recientes'] as List<Map<String, dynamic>>;
        });
      }

      return data;
    } catch (e) {
      print('❌ Error cargando datos del perfil: $e');
      return {};
    }
  }

  ProfileData _getProfileData() {
    if (_empresa == null) {
      print('❌ _empresa es null, usando datos por defecto');
      return _getDefaultProfileData();
    }

    // ✅ DEBUG EXTENSIVO: Verificar TODOS los datos de la empresa
    print('🖼️ === DEBUG COMPLETO DE EMPRESA ===');
    print('   - Nombre: ${_empresa!.nombre}');
    print('   - ID: ${_empresa!.id}');
    print('   - imagenPerfil: ${_empresa!.imagenPerfil}');
    print('   - imagenBanner: ${_empresa!.imagenBanner}');
    print('   - imagenPerfil es null?: ${_empresa!.imagenPerfil == null}');
    print('   - imagenBanner es null?: ${_empresa!.imagenBanner == null}');
    print(
        '   - imagenPerfil está vacío?: ${_empresa!.imagenPerfil?.isEmpty ?? true}');
    print(
        '   - imagenBanner está vacío?: ${_empresa!.imagenBanner?.isEmpty ?? true}');

    // Verificar si las URLs son válidas
    if (_empresa!.imagenPerfil != null) {
      print(
          '   - imagenPerfil empieza con http?: ${_empresa!.imagenPerfil!.startsWith('http')}');
    }
    if (_empresa!.imagenBanner != null) {
      print(
          '   - imagenBanner empieza con http?: ${_empresa!.imagenBanner!.startsWith('http')}');
    }
    print('====================================');

    final profileData = ProfileData(
      businessName: _empresa!.nombre,
      backgroundImageUrl: _empresa!.imagenBanner ?? _getDefaultBackgroundImage(),
      profileImageUrl: _empresa!.imagenPerfil ?? _getDefaultProfileImage(),
      rating: _rating,
      reviewCount: _reviewCount,
      aboutUs: _generateAboutUsText(),
      address: _empresa!.direccion,
      phone: _empresa!.telefono,
      email: _empresa!.email,
      businessHours:
          'Lun - Vie: 8:00 AM - 8:00 PM, Sáb - Dom: 9:00 AM - 6:00 PM',
      rentalPolicies:
          _politicasRenta.map((politica) => RentalPolicy(politica)).toList(),
      additionalServices: _serviciosAdicionales.map((servicio) {
        return AdditionalService(
          name: servicio['nombre'],
          icon: _getIconFromString(servicio['icono']),
          width: _calculateWidth(servicio['nombre']),
        );
      }).toList(),
    );

    print('🎯 URLs que se enviarán al UI:');
    print('   - backgroundImageUrl: ${profileData.backgroundImageUrl}');
    print('   - profileImageUrl: ${profileData.profileImageUrl}');

    return profileData;

  }
  String _getDefaultBackgroundImage() {
    return 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80';
  }
  String _getDefaultProfileImage() {
    return 'https://images.unsplash.com/photo-1653479499749-a65f2d322f7f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTg0MjM4MTV8&ixlib=rb-4.1.0&q=80&w=1080';
  }



  String _generateAboutUsText() {
    if (_empresa == null) return '';

    final vehiculosText = _totalVehiculos > 0
        ? 'Contamos con una flota de $_totalVehiculos vehículos, ${_vehiculosDisponibles} disponibles actualmente.'
        : 'Ofrecemos una amplia variedad de vehículos para todas sus necesidades.';

    return '${_empresa!.nombre} es una empresa dedicada a la renta de vehículos con los más altos estándares de calidad. $vehiculosText Nuestra prioridad es brindar un servicio confiable y seguro para todos nuestros clientes.';
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'local_shipping':
        return Icons.local_shipping_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'support_agent':
        return Icons.support_agent_rounded;
      case 'clean_hands':
        return Icons.clean_hands_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  double _calculateWidth(String text) {
    final length = text.length;
    if (length <= 10) return 60;
    if (length <= 15) return 80;
    return 100;
  }

  List<Review> _getReviews() {
    return _resenas
        .map((resena) => Review(
              userName: resena['userName'] ?? 'Usuario',
              userImageUrl: resena['userImageUrl'] ??
                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
              rating: (resena['rating'] ?? 4.0).toDouble(),
              comment: resena['comment'] ?? 'Sin comentario',
              timeAgo: resena['timeAgo'] ?? 'Reciente',
            ))
        .toList();
  }

  ProfileData _getDefaultProfileData() {
    return ProfileData(
      businessName: 'Cargando...',
      backgroundImageUrl:
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
      profileImageUrl:
          'https://images.unsplash.com/photo-1653479499749-a65f2d322f7f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTg0MjM4MTV8&ixlib=rb-4.1.0&q=80&w=1080',
      rating: 0.0,
      reviewCount: 0,
      aboutUs: 'Cargando información de la empresa...',
      address: 'Cargando...',
      phone: 'Cargando...',
      email: 'Cargando...',
      businessHours: 'Cargando...',
      rentalPolicies: [RentalPolicy('Cargando políticas...')],
      additionalServices: [
        AdditionalService(
            name: 'Cargando...', icon: Icons.hourglass_empty, width: 80),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          final profileData = _getProfileData();
          final reviews = _getReviews();

          final isLoading =
              snapshot.connectionState == ConnectionState.waiting &&
                  !_hasInitialData;

          return Stack(
            children: <Widget>[
              ValueListenableBuilder<double>(
                valueListenable: _scrollOffset,
                builder: (context, offset, _) {
                  final double parallaxOffset =
                      _scrollOffset.value.clamp(0.0, 150.0) * 0.4;
                  return ParallaxProfileHeader(
                    backgroundImageUrl: profileData.backgroundImageUrl,
                    profileImageUrl: profileData.profileImageUrl,
                    businessName: profileData.businessName,
                    businessType: 'Renta de Vehículos',
                    onBackPressed: () => Navigator.of(context).pop(),
                    height: 278,
                    parallaxOffset: parallaxOffset,
                    avatarSize: 100,
                  );
                },
              ),
              _ScrollContent(
                controller: _scrollController,
                profileData: profileData,
                reviews: reviews,
                onContact: _contactBusiness,
                onViewCars: _viewCars,
                onOpenLocation: _openLocation,
                isLoading: isLoading,
                hasInitialData: _hasInitialData,
              ),
            ],
          );
        },
      ),
    );
  }

  void _contactBusiness() {
    if (_empresa != null) {
      print('📞 Contactando a: ${_empresa!.nombre}');
    }
  }

  void _viewCars() {
    if (_empresa != null) {
      print('🚗 Viendo vehículos de: ${_empresa!.nombre}');
    }
  }

  void _openLocation() {
    if (_empresa != null &&
        _empresa!.latitud != null &&
        _empresa!.longitud != null) {
      print('📍 Abriendo ubicación de: ${_empresa!.nombre}');
    }
  }
}

// ... (el resto del código de _ScrollContent, _ContentBody, etc. permanece igual)

// ✅ MEJORADO: _ScrollContent con manejo de datos iniciales
class _ScrollContent extends StatelessWidget {
  final ScrollController controller;
  final ProfileData profileData;
  final List<Review> reviews;
  final VoidCallback onContact;
  final VoidCallback onViewCars;
  final VoidCallback onOpenLocation;
  final bool isLoading;
  final bool hasInitialData;

  const _ScrollContent({
    required this.controller,
    required this.profileData,
    required this.reviews,
    required this.onContact,
    required this.onViewCars,
    required this.onOpenLocation,
    this.isLoading = false,
    this.hasInitialData = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
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
        SliverToBoxAdapter(
          child: isLoading
              ? _buildLoadingState()
              : _ContentBody(
                  profileData: profileData,
                  reviews: reviews,
                  onContact: onContact,
                  onViewCars: onViewCars,
                  onOpenLocation: onOpenLocation,
                  hasInitialData: hasInitialData,
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando perfil de la empresa...'),
          ],
        ),
      ),
    );
  }
}

// ✅ MEJORADO: _ContentBody con indicador de datos iniciales
class _ContentBody extends StatelessWidget {
  final ProfileData profileData;
  final List<Review> reviews;
  final VoidCallback onContact;
  final VoidCallback onViewCars;
  final VoidCallback onOpenLocation;
  final bool hasInitialData;

  const _ContentBody({
    required this.profileData,
    required this.reviews,
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
            // ✅ Indicador de carga rápida (opcional)
            if (hasInitialData)
              Padding(
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
              ),

            // Botones de acción
            _buildActionButtons(context),

            // Secciones de contenido
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

            // Sección de reseñas
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
              onPressed: onViewCars,
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

          // Botón UBICACIÓN
          Flexible(
            child: CustomButtonWithStates(
              onPressed: onOpenLocation,
              text: 'Ubicación',
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

  Widget _buildReviewsSection(BuildContext context) {
    if (reviews.isEmpty) {
      return SizedBox.shrink(); // Ocultar sección si no hay reseñas
    }

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
          _ReviewsList(reviews: reviews),
        ],
      ),
    );
  }
}

// Widget para lista de reseñas
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

// Clases de datos
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
