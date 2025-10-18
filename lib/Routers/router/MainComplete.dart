import 'package:ezride/Core/widgets/AppBarWidget/CustomAppBarWidget.dart';
import 'package:ezride/Core/widgets/CustomBottonBar/CustomBottonBar.dart';
import 'package:ezride/Feature/Favoritos/Favoritos_screen-_PRESENTATION.dart';
import 'package:ezride/Feature/HISTORY_AUTOS/HistoryAutos_screen-_PRESENTATION.dart';
import 'package:ezride/Feature/HOME/home_screen-_PRESENTATION.dart';
import 'package:ezride/Feature/PROFILE_USER/Profile_User-_PRESENTATION.dart';
import 'package:ezride/Feature/SEARCH/Seach_screen-_PRESENTATION.dart';
import 'package:flutter/material.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ReservasWidget(),
    const SearchAutos(),
    const FavCards(),
    const ProfileUser(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'RIDE & BUY',
        onNotificationsPressed: () {
          print('Notifications pressed');
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
