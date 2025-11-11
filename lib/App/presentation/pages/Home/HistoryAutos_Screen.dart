// reservas_widget.dart
import 'package:ezride/App/DATA/models/USERRENT_MODEL.dart';
import 'package:ezride/App/DATA/models/rentas_model.dart';
import 'package:ezride/App/presentation/pages/Home/QRScannerScreen.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Core/widgets/AppBarWidget/CustomAppBarWidget.dart';
import 'package:ezride/Core/widgets/Modals/GlobalModalAction.widget.dart';
import 'package:ezride/Core/widgets/Modals/QRModal_Service.dart';
import 'package:ezride/Feature/Home/HISTORY_AUTOS/model/HistoryAutos_model.dart';
import 'package:ezride/Feature/Home/HISTORY_AUTOS/widgets/HistoryAutors_Card.dart';
import 'package:ezride/Feature/Home/HISTORY_AUTOS/widgets/HistoryAutos_Tab.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:ezride/Services/utils/QRService.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservasWidget extends StatefulWidget {
  const ReservasWidget({super.key});

  static String routeName = 'reservas';
  static String routePath = '/reservas';

  @override
  State<ReservasWidget> createState() => ReservasWidgetState();
}

class ReservasWidgetState extends State<ReservasWidget> {
  late ReservasModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedTabIndex = 0;
  late PageController _pageController;

  final List<String> _tabLabels = ['Activas', 'Solicitudes', 'Historial'];
  final List<UserRentaModel> _rentas = [];
  bool _isLoading = true;
  String? _clienteId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReservasModel());
    _pageController = PageController(initialPage: _selectedTabIndex);
    _clienteId = SessionManager.currentProfile?.id;
    _cargarRentasUsuario();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _model.dispose();
    super.dispose();
  }

  // ✅ NUEVO MÉTODO: Navegar al escáner QR
void _navigateToQRScanner() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => QRScannerScreen()),
  );
}

  Future<void> _cargarRentasUsuario() async {
    if (_clienteId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);

      print('👤 Cargando rentas para usuario: $_clienteId');

      const sql = '''
        SELECT 
          r.id as renta_id,
          r.vehiculo_id,
          r.empresa_id,
          r.tipo,
          r.fecha_reserva,
          r.fecha_inicio_renta as fecha_inicio,
          r.fecha_entrega_vehiculo as fecha_fin,
          r.pickup_method,
          r.pickup_address,
          r.entrega_address,
          r.total,
          r.status,
          r.verification_code,
          
          -- Datos del vehículo
          v.marca,
          v.modelo,
          v.placa,
          v.imagen1 as imagen_vehiculo,
          v.precio_por_dia,
          
          -- Datos de la empresa
          e.nombre as empresa_nombre
          
        FROM public.rentas r
        INNER JOIN public.vehiculos v ON r.vehiculo_id = v.id
        INNER JOIN public.empresas e ON r.empresa_id = e.id
        WHERE r.cliente_id = @cliente_id
        ORDER BY 
          CASE 
            WHEN r.status = 'en_curso' THEN 1
            WHEN r.status = 'confirmada' THEN 2
            WHEN r.status = 'pendiente' THEN 3
            ELSE 4
          END,
          r.fecha_reserva DESC
      ''';

      final result = await RenderDbClient.query(sql, parameters: {
        'cliente_id': _clienteId,
      });

      print('📊 Rentas encontradas: ${result.length}');

      setState(() {
        _rentas.clear();
        for (final row in result) {
          try {
            _rentas.add(UserRentaModel.fromJson(row));
          } catch (e) {
            print('❌ Error parseando renta: $e');
          }
        }
      });

    } catch (e, stackTrace) {
      print('❌ Error cargando rentas: $e');
      print('🔍 Stack trace: $stackTrace');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Métodos para filtrar rentas
  List<UserRentaModel> get _rentasActivas {
    return _rentas.where((r) => r.isActiva).toList();
  }

  List<UserRentaModel> get _rentasSolicitudes {
    return _rentas.where((r) => r.isSolicitud).toList();
  }

  List<UserRentaModel> get _rentasHistorial {
    return _rentas.where((r) => r.isHistorial).toList();
  }

  // Métodos para acciones
  Future<void> _cancelarRenta(String rentaId) async {
    try {
      print('❌ Cancelando renta: $rentaId');

      const sql = '''
        UPDATE public.rentas 
        SET status = 'cancelada', updated_at = NOW()
        WHERE id = @renta_id AND cliente_id = @cliente_id
        RETURNING *
      ''';

      final result = await RenderDbClient.query(sql, parameters: {
        'renta_id': rentaId,
        'cliente_id': _clienteId,
      });

      if (result.isNotEmpty) {
        print('✅ Renta cancelada exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Renta cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarRentasUsuario();
      }
    } catch (e) {
      print('❌ Error cancelando renta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al cancelar renta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _verDetallesRenta(UserRentaModel renta) {
    // Navegar a pantalla de detalles
    print('🔍 Ver detalles de renta: ${renta.rentaId}');
    // context.push('/renta-detalles', extra: {'renta': renta});
  }

  void _contactarSoporte(UserRentaModel renta) {
    print('📞 Contactar soporte para: ${renta.marca} ${renta.modelo}');
    // Abrir chat con la empresa
  }

  void _verificarCodigo(UserRentaModel renta) {
    print('🔐 Verificar código para: ${renta.rentaId}');
    // Mostrar código de verificación
    if (renta.verificationCode != null) {
      showGlobalStatusModalAction(
        context,
        title: 'Código de Verificación',
        message: 'Código: ${renta.verificationCode}\n\nMuestra este código al recoger el vehículo',
        icon: Icons.verified,
        iconColor: Colors.blue,
        confirmText: 'Cerrar',
      );
    }
  }

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar( // ✅ NUEVO: AppBar con botón QR
        title: Text('Mis Rentas'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: _navigateToQRScanner,
            tooltip: 'Escanear QR de confirmación',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton( // ✅ NUEVO: FAB para QR
        onPressed: _navigateToQRScanner,
        child: Icon(Icons.qr_code_2),
        tooltip: 'Escanear QR de Confirmación',
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Barra de pestañas animada - TODO TU CÓDIGO EXISTENTE
          LiquidTabBar(
            tabLabels: _tabLabels,
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) {
              setState(() => _selectedTabIndex = index);
              if ((index - _pageController.page!).abs() > 1) {
                _pageController.jumpToPage(index);
              } else {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                );
              }
            },
          ),

          // Contenido con deslizamiento - TODO TU CÓDIGO EXISTENTE
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    children: [
                      _buildActivas(),
                      _buildSolicitudes(),
                      _buildHistorial(),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildActivas() {
    if (_rentasActivas.isEmpty) {
      return _buildEmptyState('No tienes rentas activas', '🚗');
    }

    return RefreshIndicator(
      onRefresh: _cargarRentasUsuario,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: _rentasActivas.map((renta) => _buildDevolutionCard(renta)).toList(),
      ),
    );
  }

  Widget _buildSolicitudes() {
    if (_rentasSolicitudes.isEmpty) {
      return _buildEmptyState('No tienes solicitudes pendientes', '⏳');
    }

    return RefreshIndicator(
      onRefresh: _cargarRentasUsuario,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: _rentasSolicitudes.map((renta) => _buildRentaCard(renta)).toList(),
      ),
    );
  }

  Widget _buildHistorial() {
    if (_rentasHistorial.isEmpty) {
      return _buildEmptyState('No tienes rentas en el historial', '📋');
    }

    return RefreshIndicator(
      onRefresh: _cargarRentasUsuario,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: _rentasHistorial.map((renta) => _buildRentaCard(renta)).toList(),
      ),
    );
  }

  Widget _buildRentaCard(UserRentaModel renta) {
    return VehiculoCard(
      imageUrl: renta.imagenVehiculo.isNotEmpty 
          ? renta.imagenVehiculo 
          : 'https://images.unsplash.com/photo-1617227130505-49fe8656b3ba?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTk3MTEyOTd8&ixlib=rb-4.1.0&q=80&w=1080',
      marcaModelo: '${renta.marca} ${renta.modelo}',
      descripcion: 'Placa: ${renta.placa} • ${renta.pickupMethod == 'agencia' ? 'Recogida en agencia' : 'Entrega a domicilio'}',
      estado: renta.estadoTexto,
      colorEstado: renta.estadoColor,
      fechaInicio: _formatDate(renta.fechaInicio),
      fechaFin: _formatDate(renta.fechaFin),
      diasRenta: renta.diasRestantes,
      total: '\$${renta.total.toStringAsFixed(2)}',
      tipoCard: _getTipoCard(renta.status),
      onVerDetalles: () => _verDetallesRenta(renta),
      onSoporte: () => _contactarSoporte(renta),
      onVerificar: renta.puedeVerificar ? () => _verificarCodigo(renta) : null,
      onCancelar: renta.puedeCancelar ? () => _showConfirmCancelDialog(renta) : null,
      onRepetir: renta.status == 'finalizada' ? () => _repetirRenta(renta) : null,
      onResena: renta.puedeCalificar ? () => _agregarResena(renta) : null,
    );
  }

  Widget _buildDevolutionCard(UserRentaModel renta) {
  bool mostrarDevolucion = renta.status == 'en_curso' || renta.status == 'confirmada';
  
  return Column(
    children: [
      VehiculoCard(
        // ... todos los parámetros existentes de VehiculoCard ...
        imageUrl: renta.imagenVehiculo.isNotEmpty 
            ? renta.imagenVehiculo 
            : 'https://images.unsplash.com/photo-1617227130505-49fe8656b3ba?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTk3MTEyOTd8&ixlib=rb-4.1.0&q=80&w=1080',
        marcaModelo: '${renta.marca} ${renta.modelo}',
        descripcion: 'Placa: ${renta.placa} • ${renta.pickupMethod == 'agencia' ? 'Recogida en agencia' : 'Entrega a domicilio'}',
        estado: renta.estadoTexto,
        colorEstado: renta.estadoColor,
        fechaInicio: _formatDate(renta.fechaInicio),
        fechaFin: _formatDate(renta.fechaFin),
        diasRenta: renta.diasRestantes,
        total: '\$${renta.total.toStringAsFixed(2)}',
        tipoCard: _getTipoCard(renta.status),
        onVerDetalles: () => _verDetallesRenta(renta),
        onSoporte: () => _contactarSoporte(renta),
        onVerificar: renta.puedeVerificar ? () => _verificarCodigo(renta) : null,
        onCancelar: renta.puedeCancelar ? () => _showConfirmCancelDialog(renta) : null,
        onRepetir: renta.status == 'finalizada' ? () => _repetirRenta(renta) : null,
        onResena: renta.puedeCalificar ? () => _agregarResena(renta) : null,
      ),
      
      // ✅ BOTÓN DE DEVOLUCIÓN SEPARADO (alternativa si no puedes modificar VehiculoCard)
      if (mostrarDevolucion) ...[
        SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Icons.qr_code, color: Colors.blue),
            title: Text('Generar QR Devolución'),
            onTap: () => _generarQRDevolucion(renta),
          ),
        ),
      ],
    ],
  );
}

  String _getTipoCard(String status) {
    switch (status) {
      case 'en_curso':
      case 'confirmada':
        return 'activa';
      case 'pendiente':
        return 'solicitud';
      case 'finalizada':
      case 'cancelada':
      case 'expirada':
        return 'historial';
      default:
        return 'activa';
    }
  }

Widget _buildEmptyState(String message, String emoji) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: TextStyle(fontSize: 64)),
        SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center, // ✅ CORREGIDO
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Las nuevas rentas aparecerán aquí',
          textAlign: TextAlign.center, // ✅ CORREGIDO
          style: TextStyle(
            color: Colors.grey[500],
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _cargarRentasUsuario,
          child: Text('Actualizar'),
        ),
      ],
    ),
  );
}

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showConfirmCancelDialog(UserRentaModel renta) {
    showGlobalStatusModalAction(
      context,
      title: 'Confirmar Cancelación',
      message: '¿Estás seguro de que deseas cancelar la renta de ${renta.marca} ${renta.modelo}?',
      icon: Icons.warning,
      iconColor: Colors.orange,
      confirmText: 'Sí, Cancelar',
      cancelText: 'No',
      onConfirm: () {
        _cancelarRenta(renta.rentaId);
      },
      onCancel: () {
        // No se necesita hacer nada, el modal se cierra automáticamente
      },
    );
  }

  void _repetirRenta(UserRentaModel renta) {
    print('🔄 Repetir renta: ${renta.rentaId}');
    // Navegar a pantalla de renta con los mismos datos
  }

  void _agregarResena(UserRentaModel renta) {
    print('⭐ Agregar reseña para: ${renta.rentaId}');
    // Abrir pantalla de reseñas
  }

  // ==== ✅ MÉTODO NUEVO: Generar QR de Devolución - AGREGAR AL FINAL ====
void _generarQRDevolucion(UserRentaModel renta) {
  QRModalService.showQRDevolucionModal(
    context: context, // Pasar el context de tu widget
    renta: renta,
    clienteId: _clienteId!,
  );
}

  
}