import 'package:ezride/Core/widgets/AppBarWidget/CustomAppBarWidget.dart';
import 'package:ezride/Core/widgets/CustomBottonBar/CustomBottonBar.dart';
import 'package:ezride/Feature/Home/Favoritos/Favoritos_screen_PRESENTATION.dart';
import 'package:ezride/Feature/Home/HISTORY_AUTOS/HistoryAutos_screen_PRESENTATION.dart';
import 'package:ezride/Feature/Home/HOME/home_screen_PRESENTATION.dart';
import 'package:ezride/Feature/Home/Notifications/Notifications_screen_PRESENTATION_Optimizar.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/Profile_User_PRESENTATION.dart';
import 'package:ezride/Feature/Home/SEARCH/Seach_screen_PRESENTATION.dart';
import 'package:flutter/material.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';

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

  final List<Widget> _screens = [
    const HomeScreen(),
    const ReservasWidget(),
    const SearchAutos(),
    const FavCards(),
    const ProfileUser(),
    const NotificacionesWidget(),
  ];

  final List<String> _titles = [
    'Ride & Buy',
    'Historial',
    'Buscar Autos',
    'Favoritos',
    'Perfil',
    'Notificaciones',
  ];

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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens, // Todas las pantallas ya están instanciadas
      ),
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
            label: 'Search',
            onPressed: () => _onTabSelected(2),
          ),
          BottomBarItem(
            icon: Icons.favorite,
            label: 'Search',
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
