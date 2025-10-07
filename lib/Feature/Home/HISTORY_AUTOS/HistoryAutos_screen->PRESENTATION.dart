import 'package:ezride/Core/widgets/AppBarWidget/CustomAppBarWidget.dart';
import 'package:ezride/Feature/Home/HISTORY_AUTOS/model/HistoryAutos_model.dart';
import 'package:ezride/Feature/Home/HISTORY_AUTOS/widgets/HistoryAutors_Card.dart';
import 'package:ezride/Feature/Home/HISTORY_AUTOS/widgets/HistoryAutos_Tab.dart';
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
  late PageController _pageController; // 👈 Controlador para el PageView

  final List<String> _tabLabels = ['Activas', 'Solicitudes', 'Historial'];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReservasModel());
    _pageController = PageController(initialPage: _selectedTabIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose(); // 👈 Importante liberar el controlador
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Barra de pestañas animada
            LiquidTabBar(
              tabLabels: _tabLabels,
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() => _selectedTabIndex = index);

                if ((index - _pageController.page!).abs() > 1) {
                  _pageController
                      .jumpToPage(index); // salto directo si está lejos
                } else {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
            ),

            // Contenido con deslizamiento
            Expanded(
              child: PageView(
                controller: _pageController, // 👈 Controlador vinculado
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

  Widget _buildContent() {
    switch (_selectedTabIndex) {
      case 0: // Activas
        return _buildActivas();
      case 1: // Solicitudes
        return _buildSolicitudes();
      case 2: // Historial
        return _buildHistorial();
      default:
        return _buildActivas();
    }
  }

  Widget _buildActivas() {
    return ListView(
      padding: const EdgeInsets.only(top: 16),
      shrinkWrap: true,
      children: [
        VehiculoCard(
          imageUrl:
              'https://images.unsplash.com/photo-1617227130505-49fe8656b3ba?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTk3MTEyOTd8&ixlib=rb-4.1.0&q=80&w=1080',
          marcaModelo: 'Toyota Corolla 2023',
          descripcion: 'Sedán • Automático',
          estado: 'En curso',
          colorEstado: FlutterFlowTheme.of(context).success,
          fechaInicio: '15 Dic 2024',
          fechaFin: '22 Dic 2024',
          tipoCard: 'activa',
          onVerDetalles: () => print('Ver detalles pressed'),
          onSoporte: () => print('Soporte pressed'),
        ),
        const SizedBox(height: 16),
        VehiculoCard(
          imageUrl:
              'https://images.unsplash.com/photo-1616534846636-2372539a94a8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTk3MTEyOTd8&ixlib=rb-4.1.0&q=80&w=1080',
          marcaModelo: 'Honda CR-V 2024',
          descripcion: 'SUV • Automático',
          estado: 'Retrasada',
          colorEstado: FlutterFlowTheme.of(context).error,
          fechaInicio: '10 Dic 2024',
          fechaFin: '17 Dic 2024',
          tipoCard: 'activa',
          onVerDetalles: () => print('Ver detalles pressed'),
          onSoporte: () => print('Soporte pressed'),
        ),
      ],
    );
  }

  Widget _buildSolicitudes() {
    return ListView(
      padding: const EdgeInsets.only(top: 16),
      shrinkWrap: true,
      children: [
        VehiculoCard(
          imageUrl:
              'https://images.unsplash.com/photo-1719765653892-cf8e63bd4f94?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTk3MTEyOTd8&ixlib=rb-4.1.0&q=80&w=1080',
          marcaModelo: 'Ford F-150 2023',
          descripcion: 'Pickup • Manual',
          estado: 'Pendiente',
          colorEstado: Colors.blue,
          fechaInicio: '25 Dic 2024',
          fechaFin: '',
          diasRenta: '5 días',
          tipoCard: 'solicitud',
          onVerificar: () => print('Verificar pressed'),
          onPagar: () => print('Pagar pressed'),
          onCancelar: () => print('Cancelar pressed'),
        ),
      ],
    );
  }

  Widget _buildHistorial() {
    return ListView(
      padding: const EdgeInsets.only(top: 16),
      shrinkWrap: true,
      children: [
        // Aquí puedes agregar cards de historial
        VehiculoCard(
          imageUrl:
              'https://images.unsplash.com/photo-1617227130505-49fe8656b3ba?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTk3MTEyOTd8&ixlib=rb-4.1.0&q=80&w=1080',
          marcaModelo: 'Nissan Sentra 2022',
          descripcion: 'Sedán • Automático',
          estado: 'Completada',
          colorEstado: Colors.green,
          fechaInicio: '01 Nov 2024',
          fechaFin: '05 Nov 2024',
          tipoCard: 'historial',
          onRepetir: () => print('Repetir pressed'),
          onResena: () => print('Reseña pressed'),
        ),
      ],
    );
  }
}
