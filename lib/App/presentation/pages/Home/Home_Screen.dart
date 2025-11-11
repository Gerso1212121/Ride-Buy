import 'package:ezride/Core/widgets/AppBarWidget/CustomAppBarWidget.dart';
import 'package:ezride/Core/widgets/Cards/Card_Optap.dart';
import 'package:ezride/Core/widgets/CustomBottonBar/CustomBottonBar.dart';
import 'package:ezride/Core/widgets/inputs/home/search_field.dart';
import 'package:ezride/Feature/Home/HOME/Home_model/Home_Controller.dart';
import 'package:ezride/Feature/Home/HOME/widgets/Home_Promo_widget.dart';
import 'package:ezride/Core/widgets/Heads/section_header_HomeWidgets.dart';
import 'package:ezride/Feature/Home/HOME/widgets/Home_CardCars_widget.dart';
import 'package:ezride/Feature/Home/HOME/widgets/Home_Welcome_widget.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ✅ IMPORTAR EL MODELO
import 'package:ezride/App/DATA/models/Vehiculo_model.dart';

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
  bool _isLoadingVehicle = false;
  bool _isLoadingVehicles = true;

  // ✅ USAR VehicleModel EN LUGAR DE Map<String, dynamic>
  List<VehicleModel> _featuredVehicles = [];
  List<VehicleModel> _popularVehicles = [];

  // Categorías permanecen igual
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

  @override
  void initState() {
    super.initState();
    _loadVehiclesFromDatabase();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadCriticalImages();
    });
  }

  // ✅ MÉTODO ACTUALIZADO: Usar VehicleModel
// ✅ MÉTODO MEJORADO: Cargar vehículos con verificación de disponibilidad por fechas
Future<void> _loadVehiclesFromDatabase() async {
  try {
    setState(() {
      _isLoadingVehicles = true;
    });

    print('🚗 Cargando vehículos disponibles desde la base de datos...');

    // ✅ CONSULTA MEJORADA: Verificar disponibilidad considerando rentas activas
    const sql = '''
      SELECT 
        v.id,
        v.empresa_id,
        v.marca,
        v.modelo,
        v.anio,
        v.placa,
        v.color,
        v.tipo,
        v.estado,
        v.imagen1,
        v.titulo,
        v.precio_por_dia,
        v.capacidad,
        v.transmision,
        v.combustible,
        v.puertas,
        v.soa_number,
        v.circulacion_vence,
        v.soa_vence,
        v.created_at,
        v.updated_at,
        e.nombre as empresa_nombre,
        -- ✅ VERIFICAR SI TIENE RENTAS ACTIVAS EN LAS PRÓXIMAS 24 HORAS
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM public.rentas r 
            WHERE r.vehiculo_id = v.id 
            AND r.status IN ('pendiente', 'confirmada', 'en_curso')
            AND r.fecha_inicio_renta <= NOW() + INTERVAL '24 hours'
            AND r.fecha_entrega_vehiculo >= NOW()
          ) THEN 'ocupado'
          ELSE 'disponible'
        END as disponibilidad_real
      FROM public.vehiculos v
      JOIN public.empresas e ON v.empresa_id = e.id
      WHERE v.estado = 'disponible'
        AND NOT EXISTS (
          -- ✅ EXCLUIR VEHÍCULOS CON RENTAS ACTIVAS EN ESTE MOMENTO
          SELECT 1 FROM public.rentas r 
          WHERE r.vehiculo_id = v.id 
          AND r.status IN ('pendiente', 'confirmada', 'en_curso')
          AND r.fecha_inicio_renta <= NOW()
          AND r.fecha_entrega_vehiculo >= NOW()
        )
      ORDER BY v.created_at DESC
      LIMIT 10;
    ''';

    final result = await RenderDbClient.query(sql);

    print('📊 Vehículos encontrados: ${result.length}');

    if (result.isNotEmpty) {
      final vehicles = result.map((row) => VehicleModel.fromJson(row)).toList();

      setState(() {
        _featuredVehicles = vehicles.take(5).toList();
        _popularVehicles = vehicles;
      });

      print('✅ Vehículos cargados exitosamente: ${vehicles.length}');
      
      // ✅ LOG ADICIONAL PARA DEBUG
      for (final vehicle in vehicles) {
        final disponibilidad = result.firstWhere(
          (r) => r['id'] == vehicle.id,
          orElse: () => {'disponibilidad_real': 'desconocido'}
        )['disponibilidad_real'];
        print('   🚗 ${vehicle.titulo ?? '${vehicle.marca} ${vehicle.modelo}'} - Disponibilidad: $disponibilidad');
      }
    } else {
      print('⚠️ No se encontraron vehículos disponibles');
      _setFallbackData();
    }
  } catch (e, stackTrace) {
    print('❌ Error cargando vehículos: $e');
    print('🔍 Stack trace: $stackTrace');
    _setFallbackData();
  } finally {
    setState(() {
      _isLoadingVehicles = false;
    });
  }
}

  // ✅ MÉTODO ACTUALIZADO: Crear VehicleModel de fallback
  void _setFallbackData() {
    setState(() {
      _featuredVehicles = [
        VehicleModel(
          id: 'fallback-1',
          empresaId: 'fallback-empresa-1',
          marca: 'Audi',
          modelo: 'Q7',
          anio: 2023,
          placa: 'ABC123',
          precioPorDia: 95.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          imagen1: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b',
          titulo: 'Audi Q7 2023',
          estado: 'disponible',
        ),
        VehicleModel(
          id: 'fallback-2',
          empresaId: 'fallback-empresa-2',
          marca: 'Toyota',
          modelo: 'Corolla',
          anio: 2024,
          placa: 'DEF456',
          precioPorDia: 45.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          imagen1: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d',
          titulo: 'Toyota Corolla 2024',
          estado: 'disponible',
        ),
      ];
      _popularVehicles = _featuredVehicles;
    });
  }

  // ✅ MÉTODO ACTUALIZADO: Usar VehicleModel
  Widget _buildVehicleCardWithPlaceholder(VehicleModel vehicle,
      {required VoidCallback onTap}) {
    return VehicleCard(
      key: ValueKey('vehicle_${vehicle.id}'),
      imageUrl: vehicle.imagen1 ?? _getDefaultImage(), // ✅ SOLO imagen1
      title: vehicle.titulo ?? '${vehicle.marca} ${vehicle.modelo}',
      subtitle: _buildSubtitle(vehicle),
      rating: 4.5, // Valor por defecto
      reviewCount: 25, // Valor por defecto
      price: '\$${vehicle.precioPorDia.toStringAsFixed(2)}/día',
      onTap: onTap,
    );
  }

  // ✅ MÉTODO ACTUALIZADO: Construir subtítulo desde VehicleModel
  String _buildSubtitle(VehicleModel vehicle) {
    final transmisionText = vehicle.transmision?.toLowerCase() == 'automatica' 
        ? 'Automática' 
        : 'Manual';
    
    return '${vehicle.marca} ${vehicle.modelo} • $transmisionText • ${vehicle.capacidad ?? 5} pasajeros';
  }

  // ✅ MÉTODO PARA OBTENER IMAGEN POR DEFECTO
  String _getDefaultImage() {
    const defaultImages = [
      'https://images.unsplash.com/photo-1544636331-e26879cd4d9b',
      'https://images.unsplash.com/photo-1552519507-da3b142c6e3d',
      'https://images.unsplash.com/photo-1503376780353-7e6692767b70',
      'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2',
    ];
    return defaultImages[DateTime.now().millisecond % defaultImages.length];
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

  // ✅ MÉTODO ACTUALIZADO: Usar List<VehicleModel>
  Widget _buildVehicleList(List<VehicleModel> vehicles, String emptyMessage) {
    if (_isLoadingVehicles) {
      return _buildLoadingVehicles();
    }

    if (vehicles.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: vehicles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCardWithPlaceholder(
          vehicle,
          onTap: () => _onVehicleTap(vehicle),
        );
      },
    );
  }

  // ✅ WIDGET PARA ESTADO DE CARGA
  Widget _buildLoadingVehicles() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 20),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando vehículos disponibles...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ WIDGET PARA ESTADO VACÍO
  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.car_rental,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedVehicles() {
    return _buildVehicleList(
      _featuredVehicles, 
      'No hay vehículos destacados disponibles en este momento'
    );
  }

  Widget _buildPopularVehicles() {
    return _buildVehicleList(
      _popularVehicles, 
      'No hay vehículos populares disponibles en este momento'
    );
  }

  // ✅ MÉTODO ACTUALIZADO: Usar VehicleModel
// ✅ MÉTODO MEJORADO: Verificar disponibilidad considerando rentas
void _onVehicleTap(VehicleModel vehicle) async {
  if (_isLoadingVehicle) return;

  try {
    setState(() {
      _isLoadingVehicle = true;
    });

    print('🔍 Verificando disponibilidad COMPLETA para vehículo: ${vehicle.id}');

    // ✅ CONSULTA COMPLETA: Verificar estado del vehículo Y rentas activas
    const sql = '''
      SELECT 
        v.empresa_id,
        v.estado,
        -- ✅ VERIFICAR DISPONIBILIDAD EN TIEMPO REAL
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM public.rentas r 
            WHERE r.vehiculo_id = v.id 
            AND r.status IN ('pendiente', 'confirmada', 'en_curso')
            AND r.fecha_inicio_renta <= NOW()
            AND r.fecha_entrega_vehiculo >= NOW()
          ) THEN 'ocupado_ahora'
          WHEN EXISTS (
            SELECT 1 FROM public.rentas r 
            WHERE r.vehiculo_id = v.id 
            AND r.status IN ('pendiente', 'confirmada')
            AND r.fecha_inicio_renta <= NOW() + INTERVAL '24 hours'
            AND r.fecha_entrega_vehiculo >= NOW()
          ) THEN 'ocupado_proximo'
          ELSE 'disponible'
        END as disponibilidad_real
      FROM public.vehiculos v
      WHERE v.id = @vehicle_id;
    ''';

    final result = await RenderDbClient.query(sql, parameters: {
      'vehicle_id': vehicle.id,
    });

    print('📊 Resultado de verificación: ${result.length} registros');

    if (result.isEmpty) {
      throw Exception('No se pudo encontrar información del vehículo');
    }

    final empresaId = result.first['empresa_id'] as String?;
    final estado = result.first['estado'] as String? ?? 'inactivo';
    final disponibilidad = result.first['disponibilidad_real'] as String? ?? 'desconocido';
    
    if (empresaId == null || empresaId.isEmpty) {
      throw Exception('El vehículo no tiene una empresa asociada');
    }

    // ✅ VERIFICACIÓN COMPLETA DE DISPONIBILIDAD
    if (estado != 'disponible' || disponibilidad != 'disponible') {
      String mensaje = 'Vehículo no disponible';
      
      if (estado != 'disponible') {
        // Estado del vehículo no es disponible
        switch (estado) {
          case 'en_renta':
            mensaje = 'Este vehículo está marcado como rentado actualmente';
            break;
          case 'mantenimiento':
            mensaje = 'Vehículo en mantenimiento';
            break;
          case 'reservado':
            mensaje = 'Vehículo reservado';
            break;
          default:
            mensaje = 'Vehículo no disponible';
        }
      } else if (disponibilidad == 'ocupado_ahora') {
        // Tiene rentas activas en este momento
        mensaje = 'Este vehículo está rentado actualmente';
      } else if (disponibilidad == 'ocupado_proximo') {
        // Tiene rentas que empiezan pronto
        mensaje = 'Este vehículo tiene rentas programadas para las próximas 24 horas';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$mensaje 🚫'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // ✅ ACTUALIZAR LA LISTA PARA REFLEJAR EL CAMBIO
      _loadVehiclesFromDatabase();
      return;
    }

    print('✅ Vehículo disponible - Empresa ID: $empresaId');

    GoRouter.of(context).push(
      '/auto-details',
      extra: {
        'vehicleId': vehicle.id,
        'vehicleTitle': vehicle.titulo ?? '${vehicle.marca} ${vehicle.modelo}',
        'vehicleImage': vehicle.imagen1 ?? _getDefaultImage(),
        'dailyPrice': vehicle.precioPorDia,
        'year': vehicle.anio?.toString() ?? '2024',
        'isRented': estado,
        'empresaId': empresaId,
      },
    );
  } catch (e) {
    print('❌ Error cargando vehículo: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cargar vehículo: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isLoadingVehicle = false;
    });
  }
}

// ✅ MÉTODO ADICIONAL: Verificar disponibilidad para fechas específicas
Future<bool> _verificarDisponibilidadFechas(String vehiculoId, DateTime fechaInicio, DateTime fechaFin) async {
  try {
    const sql = '''
      SELECT COUNT(*) as rentas_activas
      FROM public.rentas 
      WHERE vehiculo_id = @vehiculo_id 
        AND status IN ('pendiente', 'confirmada', 'en_curso')
        AND (
          -- ✅ VERIFICAR SOLAPAMIENTO DE FECHAS
          (fecha_inicio_renta BETWEEN @fecha_inicio AND @fecha_fin)
          OR (fecha_entrega_vehiculo BETWEEN @fecha_inicio AND @fecha_fin)
          OR (fecha_inicio_renta <= @fecha_inicio AND fecha_entrega_vehiculo >= @fecha_fin)
        );
    ''';

    final result = await RenderDbClient.query(sql, parameters: {
      'vehiculo_id': vehiculoId,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
    });

    final rentasActivas = (result.first['rentas_activas'] as int?) ?? 0;
    
    print('🔍 Verificación fechas: $fechaInicio - $fechaFin → $rentasActivas rentas activas');
    
    return rentasActivas == 0;
  } catch (e) {
    print('❌ Error verificando disponibilidad por fechas: $e');
    return false;
  }
}

// ✅ MÉTODO OPCIONAL: Cargar vehículos con mejor historial de disponibilidad
Future<void> _loadVehiculosConMejorDisponibilidad() async {
  try {
    const sql = '''
      SELECT 
        v.*,
        e.nombre as empresa_nombre,
        -- ✅ CONTAR RENTAS EN LOS ÚLTIMOS 30 DÍAS
        (
          SELECT COUNT(*) 
          FROM public.rentas r 
          WHERE r.vehiculo_id = v.id 
          AND r.status IN ('finalizada')
          AND r.fecha_inicio_renta >= NOW() - INTERVAL '30 days'
        ) as rentas_recientes,
        -- ✅ CALCULAR PORCENTAJE DE DISPONIBILIDAD
        CASE 
          WHEN (
            SELECT COUNT(*) 
            FROM public.rentas r 
            WHERE r.vehiculo_id = v.id 
            AND r.status IN ('pendiente', 'confirmada', 'en_curso')
            AND r.fecha_inicio_renta >= NOW() - INTERVAL '30 days'
          ) = 0 THEN 100
          ELSE 80 -- Valor por defecto si no hay datos suficientes
        END as porcentaje_disponibilidad
      FROM public.vehiculos v
      JOIN public.empresas e ON v.empresa_id = e.id
      WHERE v.estado = 'disponible'
        AND NOT EXISTS (
          SELECT 1 FROM public.rentas r 
          WHERE r.vehiculo_id = v.id 
          AND r.status IN ('pendiente', 'confirmada', 'en_curso')
          AND r.fecha_inicio_renta <= NOW()
          AND r.fecha_entrega_vehiculo >= NOW()
        )
      ORDER BY porcentaje_disponibilidad DESC, v.created_at DESC
      LIMIT 10;
    ''';

    final result = await RenderDbClient.query(sql);
    
    if (result.isNotEmpty) {
      final vehicles = result.map((row) => VehicleModel.fromJson(row)).toList();
      
      setState(() {
        _popularVehicles = vehicles; // Usar como vehículos populares
      });
      
      print('✅ Vehículos con mejor disponibilidad cargados: ${vehicles.length}');
    }
  } catch (e) {
    print('❌ Error cargando vehículos con mejor disponibilidad: $e');
  }
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Contenido con scroll
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadVehiclesFromDatabase,
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
                ),
              ],
            ),
          ),

          // ✅ Mostrar indicador de carga global
          if (_isLoadingVehicle)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Cargando vehículo...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}