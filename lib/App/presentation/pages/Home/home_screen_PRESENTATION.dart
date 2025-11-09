import 'package:ezride/Core/widgets/AppBarWidget/CustomAppBarWidget.dart';
import 'package:ezride/Core/widgets/Cards/Card_Optap.dart';
import 'package:ezride/Core/widgets/CustomBottonBar/CustomBottonBar.dart';
import 'package:ezride/Core/widgets/inputs/home/search_field.dart';
import 'package:ezride/Feature/Home/HOME/Home_model/Home_Controller.dart';
import 'package:ezride/Feature/Home/HOME/widgets/Home_Promo_widget.dart';
import 'package:ezride/Core/widgets/Heads/section_header_HomeWidgets.dart';
import 'package:ezride/Feature/Home/HOME/widgets/Home_CardCars_widget.dart';
import 'package:ezride/Feature/Home/HOME/widgets/Home_Welcome_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final HomeModel _homeModel = HomeModel();
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Datos optimizados
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Luxury',
      'subtitle': 'From \$120/day',
      'icon': Icons.sports_motorsports,
    },
    {
      'title': 'SUV',
      'subtitle': 'From \$80/day',
      'icon': Icons.local_shipping,
    },
    {
      'title': 'Sports',
      'subtitle': 'From \$150/day',
      'icon': Icons.directions_car,
    },
    {
      'title': 'Economy',
      'subtitle': 'From \$40/day',
      'icon': Icons.electric_car,
    },
  ];

  final List<Map<String, dynamic>> _featuredVehicles = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1731988666788-6f0251886c1b',
      'title': 'BMW X5 2024',
      'subtitle': 'Luxury SUV • Automatic',
      'rating': 4.8,
      'reviewCount': 124,
      'price': '\$89/day',
    },
    {
      'imageUrl': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b',
      'title': 'Audi Q7 2023',
      'subtitle': 'Premium SUV • Quattro',
      'rating': 4.6,
      'reviewCount': 89,
      'price': '\$95/day',
    },
    {
      'imageUrl': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d',
      'title': 'Toyota Corolla 2024',
      'subtitle': 'Compact • Hybrid',
      'rating': 4.4,
      'reviewCount': 256,
      'price': '\$45/day',
    },
  ];

  final List<Map<String, dynamic>> _popularVehicles = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70',
      'title': 'Mercedes C-Class',
      'subtitle': 'Executive • Automatic',
      'rating': 4.7,
      'reviewCount': 167,
      'price': '\$75/day',
    },
    {
      'imageUrl': 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2',
      'title': 'Honda Civic',
      'subtitle': 'Compact • Fuel Efficient',
      'rating': 4.3,
      'reviewCount': 312,
      'price': '\$38/day',
    },
  ];

  // VehicleCard optimizado con loading builder
  Widget _buildVehicleCardWithPlaceholder(Map<String, dynamic> vehicle,
      {required VoidCallback onTap}) {
    return VehicleCard(
      key: ValueKey('vehicle_${vehicle['title']}'),
      imageUrl: vehicle['imageUrl'],
      title: vehicle['title'],
      subtitle: vehicle['subtitle'],
      rating: vehicle['rating'],
      reviewCount: vehicle['reviewCount'],
      price: vehicle['price'],
      onTap: onTap,
    );
  }

  // PromoBanner optimizado
  Widget _buildPromoBannerWithPlaceholder() {
    return PromoBanner(
      title: 'Premium Cars',
      subtitle: 'Luxury vehicles for special occasions',
      buttonText: 'Browse Now',
      imageUrl: 'https://images.unsplash.com/photo-1727547082307-84ec9e300f9a',
      onPressed: _onPromoBannerTap,
    );
  }

  @override
  void initState() {
    super.initState();
    // Precarga mínima - solo el banner principal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadCriticalImages();
    });
  }

  void _preloadCriticalImages() async {
    try {
      final bannerImage = NetworkImage(
          'https://images.unsplash.com/photo-1727547082307-84ec9e300f9a');
      await bannerImage.resolve(ImageConfiguration());
    } catch (e) {
      print('Error precargando imagen del banner: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == _categories.length - 1 ? 0 : 12,
            ),
            child: GenericCardGlobalwidgets(
              title: category['title'],
              subtitle: category['subtitle'],
              icon: category['icon'],
              onTap: () {
                print('Category tapped: ${category['title']}');
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedVehicles() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _featuredVehicles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = _featuredVehicles[index];
        return _buildVehicleCardWithPlaceholder(
          vehicle,
          onTap: () => _onVehicleTap(),
        );
      },
    );
  }

  Widget _buildPopularVehicles() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _popularVehicles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = _popularVehicles[index];
        return _buildVehicleCardWithPlaceholder(
          vehicle,
          onTap: () => _onVehicleTap(),
        );
      },
    );
  }

  // Función cuando se presiona "Ver detalles" en una tarjeta
  void _onVehicleTap() {
    GoRouter.of(context).push('/auto-details');
  }

  void _onPromoBannerTap() {
    print('Promo banner tapped');
  }

  void _onSearchChanged(String value) {
    print('Search text changed: $value');
  }

  void _onSearchSubmitted(String value) {
    print('Search submitted: $value');
  }

  void _onSearchTap() {
    print('Search field tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Contenido con scroll
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    WelcomeHeader(),
                    // Search Field
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SearchTextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        hintText: 'Search for cars, brands, locations...',
                        hintColor: const Color(0xFF94A3B8),
                        prefixIcon: Icons.search_rounded,
                        prefixIconColor: const Color(0xFF3B82F6),
                        prefixIconSize: 20,
                        padding: const EdgeInsets.all(4),
                        backgroundColor: Colors.white,
                        borderRadius: 12,
                        showBorder: true,
                        borderColor: const Color(0xFFE2E8F0),
                        focusedBorderColor: const Color(0xFF3B82F6),
                        onChanged: _onSearchChanged,
                        onSubmitted: _onSearchSubmitted,
                        onTap: _onSearchTap,
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    // Banner promocional con placeholder
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _buildPromoBannerWithPlaceholder(),
                    ),

                    // Sección de categorías
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeaderHomeWidgets(
                        title: 'Categories',
                        actionText: 'View all',
                        onActionPressed: null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategories(),

                    // Sección de vehículos destacados
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeaderHomeWidgets(
                        title: 'Featured Vehicles',
                        actionText: 'View all',
                        onActionPressed: null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeaturedVehicles(),

                    // Sección de vehículos populares
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeaderHomeWidgets(
                        title: 'Popular Near You',
                        actionText: 'View all',
                        onActionPressed: null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPopularVehicles(),

                    // Espacio final
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
