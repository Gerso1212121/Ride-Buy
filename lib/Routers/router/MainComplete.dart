import 'package:ezride/Core/widgets/AppBarWidget/CustomAppBarWidget.dart';
import 'package:ezride/Core/widgets/CustomBottonBar/CustomBottonBar.dart';
import 'package:ezride/App/presentation/pages/Home/Favoritos_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/HistoryAutos_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/Home_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/Notifications_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/ProfileUser_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/ProfileEmpresa.dart';
import 'package:ezride/App/presentation/pages/Home/Seach_Screen.dart';
import 'package:flutter/material.dart';
import 'package:ezride/Core/sessions/session_manager.dart';

// ✅ DECLARA LA GLOBALKEY FUERA DE LAS CLASES
final GlobalKey<_MainShellState> mainShellGlobalKey = GlobalKey<_MainShellState>();

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  int _currentIndex = 0;

  // ... tus listas de screens y titles (mantén todo igual)

  final List<Widget> _screensWithEmpresa = [
    const HomeScreen(),
    const ReservasWidget(),
    const SearchAutos(),
    const FavCards(),
    const PerfilEmpresaWidget(),
    const NotificacionesWidget(),
  ];

  final List<Widget> _screensWithoutEmpresa = [
    const HomeScreen(),
    const ReservasWidget(),
    const SearchAutos(),
    const FavCards(),
    const ProfileUser(),
    const NotificacionesWidget(),
  ];

  final List<String> _titlesWithEmpresa = [
    'Ride & Buy',
    'Historial',
    'Buscar Autos',
    'Favoritos',
    'Notificaciones',
    'Perfil Empresa',
  ];

  final List<String> _titlesWithoutEmpresa = [
    'Ride & Buy',
    'Historial',
    'Buscar Autos',
    'Favoritos',
    'Notificaciones',
    'Perfil Usuario',
  ];
  
  List<String> get _titles => SessionManager.currentEmpresa != null
      ? _titlesWithEmpresa
      : _titlesWithoutEmpresa;

  List<Widget> get _screens => SessionManager.currentEmpresa != null
      ? _screensWithEmpresa
      : _screensWithoutEmpresa;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // ✅ MÉTODO PÚBLICO para cambiar tabs desde fuera
  void changeToTab(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: mainShellGlobalKey, // ✅ Asigna la key al Scaffold
      appBar: CustomAppBar(
        title: _titles[_currentIndex],
        onNotificationsPressed: () {
          _onTabSelected(5);
        },
        onMenuPressed: () {
          print('Menu pressed');
        },
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        items: [
          BottomBarItem(
            icon: Icons.home,
            label: 'Inicio',
            onPressed: () => _onTabSelected(0),
          ),
          BottomBarItem(
            icon: Icons.history,
            label: 'Historial',
            onPressed: () => _onTabSelected(1),
          ),
          BottomBarItem(
            icon: Icons.search,
            label: 'Buscar Autos',
            onPressed: () => _onTabSelected(2),
          ),
          BottomBarItem(
            icon: Icons.favorite,
            label: 'Favoritos',
            onPressed: () => _onTabSelected(3),
          ),
          BottomBarItem(
            icon: Icons.person,
            label: 'Perfil',
            onPressed: () => _onTabSelected(4),
          ),
        ],
      ),
    );
  }
}