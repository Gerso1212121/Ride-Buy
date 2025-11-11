// rentas_activas_screen.dart
import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/App/DATA/models/RentaClienteModel.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Core/utils/VehiculoRentadosCacheService.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VehiculosRentadosScreen extends StatefulWidget {
  const VehiculosRentadosScreen({super.key});

  @override
  State<VehiculosRentadosScreen> createState() => _RentasActivasScreenState();
}

class _RentasActivasScreenState extends State<VehiculosRentadosScreen> {
  final List<RentaClienteModel> _rentasActivas = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _usingCachedData = false;
  EmpresasModel? _empresaData;
  int _selectedFilter = 0; // 0: Todas, 1: En Curso, 2: Confirmadas

  // Colores personalizados para la paleta verde/azul
  static const Color primaryGreen = Color(0xFF00B894);
  static const Color primaryBlue = Color(0xFF0984E3);
  static const Color secondaryBlue = Color(0xFF74B9FF);
  static const Color lightBlue = Color(0xFFDFF6FF);
  static const Color darkGreen = Color(0xFF00A085);
  static const Color accentTeal = Color(0xFF00CEC9);

  @override
  void initState() {
    super.initState();
    print('🚀 INICIANDO VehiculosRentadosScreen');
    _initializeScreen();
  }

  void _initializeScreen() {
    try {
      _empresaData = SessionManager.currentEmpresa;
      print('🏢 Empresa data: ${_empresaData?.id}');

      if (_empresaData == null) {
        print('❌ No hay empresa data disponible');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // ✅ PRIMERO: Intentar cargar datos del cache
      _loadFromCacheOrFetch();
    } catch (e) {
      print('❌ Error en initializeScreen: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadFromCacheOrFetch() {
    if (_empresaData == null) return;

    // Intentar obtener datos del cache
    final cachedRentas = RentasCacheService().getCachedRentas(_empresaData!.id);

    if (cachedRentas != null) {
      print('📦 Cargando datos desde cache...');
      setState(() {
        _rentasActivas.clear();
        _rentasActivas.addAll(cachedRentas);
        _usingCachedData = true;
        _isLoading = false;
      });

      // Cargar datos frescos en segundo plano
      _cargarRentasActivas(silent: true);
    } else {
      print('🔄 No hay cache disponible, cargando desde servidor...');
      _cargarRentasActivas(silent: false);
    }
  }

  Future<void> _cargarRentasActivas({bool silent = false}) async {
    if (_empresaData == null) {
      if (!silent) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      if (!silent) {
        setState(() {
          _isRefreshing = true;
          if (!_usingCachedData) {
            _isLoading = true;
          }
        });
      }

      print('🔄 Cargando rentas activas para empresa: ${_empresaData!.id}');

      const sql = '''
SELECT 
  r.id as renta_id,
  r.vehiculo_id,
  r.cliente_id,
  r.fecha_inicio_renta as fecha_inicio,
  r.fecha_entrega_vehiculo as fecha_fin,
  r.fecha_reserva,
  r.total,
  r.status,
  
  -- Datos del vehículo
  v.marca,
  v.modelo,
  v.placa,
  v.color,
  v.anio,
  v.imagen1 as imagen_vehiculo,
  v.precio_por_dia,
  
  -- Datos del cliente
  p.display_name as nombre_cliente,
  p.email as email_cliente,
  p.phone as telefono_cliente,
  p.dui_number as dui_cliente
  
FROM public.rentas r
INNER JOIN public.vehiculos v ON r.vehiculo_id = v.id
INNER JOIN public.profiles p ON r.cliente_id = p.id
WHERE r.empresa_id = @empresa_id
AND r.status IN ('confirmada', 'en_curso')
-- ✅ CAMBIO: Permitir rentas confirmadas que empiecen en el futuro
AND (
  (r.status = 'en_curso' AND r.fecha_entrega_vehiculo >= CURRENT_TIMESTAMP) OR
  (r.status = 'confirmada' AND r.fecha_entrega_vehiculo >= CURRENT_TIMESTAMP)
)
ORDER BY 
  CASE 
    WHEN r.status = 'en_curso' THEN 1
    WHEN r.status = 'confirmada' THEN 2
    ELSE 3
  END,
  r.fecha_inicio_renta ASC
''';

      final result = await RenderDbClient.query(sql, parameters: {
        'empresa_id': _empresaData!.id,
      });

      print('✅ Query ejecutada. Resultados: ${result.length}');

      final nuevasRentas = <RentaClienteModel>[];
      for (final row in result) {
        try {
          nuevasRentas.add(RentaClienteModel.fromJson(row));
        } catch (e) {
          print('❌ Error parseando renta: $e');
        }
      }

      // ✅ GUARDAR EN CACHE
      RentasCacheService().saveRentasToCache(_empresaData!.id, nuevasRentas);

      if (mounted) {
        setState(() {
          _rentasActivas.clear();
          _rentasActivas.addAll(nuevasRentas);
          _usingCachedData = false;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error cargando rentas activas: $e');
      print('📋 StackTrace: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }

      // Si estaba usando cache y falló la actualización, mantener los datos cacheados
      if (!_usingCachedData && !silent) {
        _mostrarSnackbar('❌ Error cargando rentas: $e', Colors.red);
      }
    }
  }

  Future<void> _marcarComoEnCurso(String rentaId) async {
    try {
      const sql = '''
      UPDATE public.rentas 
      SET status = 'en_curso'
      WHERE id = @renta_id
      RETURNING *
    ''';

      final result = await RenderDbClient.query(sql, parameters: {
        'renta_id': rentaId,
      });

      if (result.isNotEmpty) {
        _mostrarSnackbar('✅ Renta marcada como en curso', primaryGreen);
        // ✅ INVALIDAR CACHE Y RECARGAR
        RentasCacheService().invalidateCache(_empresaData!.id);
        _cargarRentasActivas(silent: false);
      }
    } catch (e) {
      _mostrarSnackbar('❌ Error al actualizar renta: $e', Colors.red);
    }
  }

Future<void> _finalizarRenta(String rentaId) async {
  try {
    const sql = '''
    UPDATE public.rentas 
    SET status = 'finalizada'  -- ← CAMBIAR AQUÍ
    WHERE id = @renta_id
    RETURNING *
    ''';

    final result = await RenderDbClient.query(sql, parameters: {
      'renta_id': rentaId,
    });

    if (result.isNotEmpty) {
      _mostrarSnackbar('✅ Renta finalizada exitosamente', primaryGreen);
      // ✅ INVALIDAR CACHE Y RECARGAR
      RentasCacheService().invalidateCache(_empresaData!.id);
      _cargarRentasActivas(silent: false);
    }
  } catch (e) {
    _mostrarSnackbar('❌ Error al finalizar renta: $e', Colors.red);
  }
}

  void _mostrarSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  List<RentaClienteModel> get _rentasFiltradas {
    switch (_selectedFilter) {
      case 1: // En Curso
        return _rentasActivas.where((r) => r.status == 'en_curso').toList();
      case 2: // Confirmadas
        return _rentasActivas.where((r) => r.status == 'confirmada').toList();
      default: // Todas
        return _rentasActivas;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.light(
          primary: primaryGreen,
          onPrimary: Colors.white,
          secondary: primaryBlue,
          surface: Colors.white,
          onSurface: Color(0xFF2D3436),
          surfaceVariant: lightBlue,
          onSurfaceVariant: Color(0xFF636E72),
          outline: Color(0xFFDFE6E9),
          background: Color(0xFFF8F9FA),
        ),
        useMaterial3: true,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildFiltrosSection(),
            _buildContadorSection(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _rentasFiltradas.isEmpty
                      ? _buildEmptyState()
                      : _buildListaRentas(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Text(
            'Rentas Activas',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          if (_usingCachedData) ...[
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'CACHE',
                style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: primaryGreen.withOpacity(0.3),
      actions: [
        if (_isRefreshing)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          )
        else
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // ✅ INVALIDAR CACHE Y FORZAR RECARGA
              if (_empresaData != null) {
                RentasCacheService().invalidateCache(_empresaData!.id);
              }
              _cargarRentasActivas(silent: false);
            },
          ),
      ],
    );
  }

  Widget _buildFiltrosSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(0, 'Todas las Rentas', Icons.list_alt),
            const SizedBox(width: 8),
            _buildFilterChip(1, 'En Curso', Icons.directions_car),
            const SizedBox(width: 8),
            _buildFilterChip(2, 'Confirmadas', Icons.check_circle),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String text, IconData icon) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? primaryGreen : const Color(0xFFDFE6E9),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : primaryGreen,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContadorSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [lightBlue.withOpacity(0.5), Colors.white],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFDFE6E9)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.bar_chart, color: primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_rentasFiltradas.length} renta${_rentasFiltradas.length != 1 ? 's' : ''} activa${_rentasFiltradas.length != 1 ? 's' : ''}',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                  fontSize: 16,
                ),
              ),
              Text(
                '${_rentasActivas.where((r) => r.status == 'en_curso').length} en curso',
                style: GoogleFonts.lato(
                  color: primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: CircularProgressIndicator(
              color: primaryGreen,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando rentas activas...',
            style: GoogleFonts.lato(
              color: Color(0xFF636E72),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final Map<int, Map<String, String>> emptyStates = {
      1: {
        'icon': '🚗',
        'title': 'No hay rentas en curso',
        'subtitle': 'No hay vehículos en uso en este momento'
      },
      2: {
        'icon': '✅',
        'title': 'No hay rentas confirmadas',
        'subtitle': 'Todas las rentas confirmadas están en curso'
      },
      0: {
        'icon': '📊',
        'title': 'No hay rentas activas',
        'subtitle': 'No hay rentas confirmadas o en curso actualmente'
      },
    };

    final state = emptyStates[_selectedFilter]!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                state['icon']!,
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              state['title']!,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3436),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              state['subtitle']!,
              style: GoogleFonts.lato(
                color: Color(0xFF636E72),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildCustomButton(
              text: 'Actualizar Lista',
              onPressed: _cargarRentasActivas,
              backgroundColor: primaryGreen,
              textColor: Colors.white,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaRentas() {
    return RefreshIndicator(
      onRefresh: _cargarRentasActivas,
      backgroundColor: Colors.white,
      color: primaryGreen,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _rentasFiltradas.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final renta = _rentasFiltradas[index];
          return _buildTarjetaRenta(renta);
        },
      ),
    );
  }

  Widget _buildTarjetaRenta(RentaClienteModel renta) {
    final bool estaEnCurso = renta.status == 'en_curso';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con vehículo y estado
            Row(
              children: [
                // Imagen del vehículo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: lightBlue,
                    image: renta.imagenVehiculo.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(renta.imagenVehiculo),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: renta.imagenVehiculo.isEmpty
                      ? Icon(Icons.directions_car, color: primaryBlue, size: 36)
                      : null,
                ),
                const SizedBox(width: 16),

                // Información del vehículo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${renta.marca} ${renta.modelo}',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Placa: ${renta.placa}',
                        style: GoogleFonts.lato(
                          color: Color(0xFF636E72),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${renta.anio} • ${renta.color}',
                        style: GoogleFonts.lato(
                          color: Color(0xFF636E72),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge de estado
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: estaEnCurso
                        ? primaryGreen.withOpacity(0.1)
                        : primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: estaEnCurso
                          ? primaryGreen.withOpacity(0.3)
                          : primaryBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        estaEnCurso
                            ? Icons.play_circle_fill
                            : Icons.check_circle,
                        size: 14,
                        color: estaEnCurso ? primaryGreen : primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        estaEnCurso ? 'EN CURSO' : 'CONFIRMADA',
                        style: GoogleFonts.lato(
                          color: estaEnCurso ? primaryGreen : primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Color(0xFFDFE6E9)),
            const SizedBox(height: 12),

            // Información del cliente
            _buildInfoRow(
              icon: Icons.person_outline,
              text: renta.nombreCliente,
              onTap: () => _mostrarDetallesCliente(renta),
            ),

            const SizedBox(height: 8),

            // Fechas de renta
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              text:
                  '${_formatDate(renta.fechaInicio)} - ${_formatDate(renta.fechaFin)}',
            ),

            const SizedBox(height: 8),

            // Tiempo restante
            _buildInfoRow(
              icon: Icons.access_time,
              text: '${_calcularDiasRestantes(renta.fechaFin)} días restantes',
            ),

            const SizedBox(height: 8),

            // Total de la renta
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.attach_money_outlined,
                      size: 16, color: primaryGreen),
                ),
                const SizedBox(width: 8),
                Text(
                  'Total: \$${renta.total.toStringAsFixed(2)}',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w700,
                    color: primaryGreen,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_calcularDias(renta.fechaInicio, renta.fechaFin)} días',
                  style: GoogleFonts.lato(
                    color: Color(0xFFB2BEC3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // Botones de acción
            if (!estaEnCurso) ...[
              const SizedBox(height: 16),
              Divider(color: Color(0xFFDFE6E9)),
              const SizedBox(height: 16),
              _buildCustomButton(
                text: 'Marcar como En Curso',
                onPressed: () => _marcarComoEnCurso(renta.rentaId),
                backgroundColor: primaryGreen,
                textColor: Colors.white,
                icon: Icons.play_arrow,
              ),
            ] else ...[
              const SizedBox(height: 16),
              Divider(color: Color(0xFFDFE6E9)),
              const SizedBox(height: 16),
              _buildCustomButton(
                text: 'Finalizar Renta',
                onPressed: () => _finalizarRenta(renta.rentaId),
                backgroundColor: primaryBlue,
                textColor: Colors.white,
                icon: Icons.stop_circle,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ... (los métodos restantes _buildInfoRow, _buildCustomButton, _mostrarDetallesCliente,
  // _buildSectionTitle, _buildDetailItem, _formatDate, _formatDateTime, _calcularDias
  // se mantienen similares a los de la interfaz anterior)

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: primaryBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.lato(
                  color: onTap != null ? primaryBlue : Color(0xFF2D3436),
                  fontSize: 14,
                  fontWeight:
                      onTap != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 18, color: primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    IconData? icon,
    double height = 48.0,
  }) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetallesCliente(RentaClienteModel renta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetallesCliente(renta),
    );
  }

  Widget _buildDetallesCliente(RentaClienteModel renta) {
    final bool estaEnCurso = renta.status == 'en_curso';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFFDFE6E9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Información del Cliente', Icons.person_outline),
          const SizedBox(height: 16),
          _buildDetailItem('Nombre', renta.nombreCliente),
          _buildDetailItem('Email', renta.emailCliente),
          _buildDetailItem(
              'Teléfono',
              renta.telefonoCliente.isNotEmpty
                  ? renta.telefonoCliente
                  : 'No proporcionado'),
          _buildDetailItem(
              'DUI',
              renta.duiCliente.isNotEmpty
                  ? renta.duiCliente
                  : 'No proporcionado'),
          const SizedBox(height: 24),
          _buildSectionTitle('Detalles de la Renta', Icons.car_rental_outlined),
          const SizedBox(height: 16),
          _buildDetailItem('Vehículo', '${renta.marca} ${renta.modelo}'),
          _buildDetailItem('Placa', renta.placa),
          _buildDetailItem('Estado', estaEnCurso ? 'En Curso' : 'Confirmada'),
          _buildDetailItem('Fecha Inicio', _formatDateTime(renta.fechaInicio)),
          _buildDetailItem('Fecha Fin', _formatDateTime(renta.fechaFin)),
          _buildDetailItem('Días Totales',
              '${_calcularDias(renta.fechaInicio, renta.fechaFin)} días'),
          _buildDetailItem('Días Restantes',
              '${_calcularDiasRestantes(renta.fechaFin)} días'),
          _buildDetailItem('Total', '\$${renta.total.toStringAsFixed(2)}'),
          const SizedBox(height: 32),
          _buildCustomButton(
            text: 'Cerrar Detalles',
            onPressed: () => Navigator.pop(context),
            backgroundColor: Color(0xFFF8F9FA),
            textColor: Color(0xFF636E72),
            borderColor: Color(0xFFDFE6E9),
            icon: Icons.close,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                color: Color(0xFF636E72),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.lato(
                color: Color(0xFF2D3436),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  int _calcularDias(DateTime inicio, DateTime fin) {
    return fin.difference(inicio).inDays;
  }

  int _calcularDiasRestantes(DateTime fechaFin) {
    final ahora = DateTime.now();
    final diferencia = fechaFin.difference(ahora);
    return diferencia.inDays
        .clamp(0, 365); // Máximo 1 año para evitar números negativos grandes
  }
}
