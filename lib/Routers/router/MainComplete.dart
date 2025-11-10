import 'package:ezride/Core/widgets/AppBarWidget/CustomAppBarWidget.dart';
import 'package:ezride/Core/widgets/CustomBottonBar/CustomBottonBar.dart';
import 'package:ezride/App/presentation/pages/Home/Favoritos_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/HistoryAutos_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/Home_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/Notifications_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/ProfileUser_Screen.dart'; // ProfileUser
import 'package:ezride/App/presentation/pages/Home/ProfileEmpresa.dart'; // PerfilEmpresaWidget
import 'package:ezride/App/presentation/pages/Home/Seach_Screen.dart';
import 'package:flutter/material.dart';
import 'package:ezride/Core/sessions/session_manager.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    _currentIndex = 0; // Reinicia siempre que MainShell se cree
  }

  int _currentIndex = 0;

  // Las pantallas que se mostrarán en el cuerpo de la MainShell si el usuario tiene una empresa
  final List<Widget> _screensWithEmpresa = [
    const HomeScreen(),
    const ReservasWidget(),
    const SearchAutos(),
    const FavCards(),
    const PerfilEmpresaWidget(), // Mostrar PerfilEmpresaWidget si tiene empresa
    const NotificacionesWidget(),
  ];

  // Las pantallas que se mostrarán en el cuerpo si el usuario no tiene empresa
  final List<Widget> _screensWithoutEmpresa = [
    const HomeScreen(),
    const ReservasWidget(),
    const SearchAutos(),
    const FavCards(),
    const ProfileUser(),
    const NotificacionesWidget(), // Si no tiene empresa, mostramos ProfileUser
  ];

  final List<String> _titlesWithEmpresa = [
    'Ride & Buy',
    'Historial',
    'Buscar Autos',
    'Favoritos',
    'Notificaciones',
    'Perfil Empresa', // Título para la pantalla de perfil de empresa
  ];

  final List<String> _titlesWithoutEmpresa = [
    'Ride & Buy',
    'Historial',
    'Buscar Autos',
    'Favoritos',
    'Notificaciones',
    'Perfil Usuario', // Título para la pantalla de perfil de empresa
  ];
  List<String> get _titles => SessionManager.currentEmpresa != null
      ? _titlesWithEmpresa
      : _titlesWithoutEmpresa;

  // Si el usuario tiene una empresa, usamos las pantallas con empresa.
  List<Widget> get _screens => SessionManager.currentEmpresa != null
      ? _screensWithEmpresa // Muestra PerfilEmpresaWidget si tiene empresa
      : _screensWithoutEmpresa; // Muestra ProfileUser si no tiene empresa

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () => _onTabSelected(
                0), // Ahora el índice es 1 ya que la primera pantalla es PerfilEmpresaWidget
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
            onPressed: () => _onTabSelected(
                4), // Cambié el índice a 0 ya que ProfileUser es la primera pantalla si no tiene empresa
          ),
        ],
      ),
    );
  }
}
