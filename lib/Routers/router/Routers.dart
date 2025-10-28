import 'package:ezride/App/presentation/pages/auth/AuthComplete.dart';
import 'package:ezride/App/presentation/pages/auth/AuthPage.dart';
import 'package:ezride/Feature/Home/Chat/Chat_screen__PRESENTATION.dart';
import 'package:ezride/Feature/PAY_SUCCESS/Pay_Success-%3EPRESENTATION.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/RentVehicle_screen-%3EPRESENTATION.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/VehicleDetail_screen-%3EPRESENTATION.dart';
import 'package:ezride/Routers/router/MainComplete.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth',
    
    // ✅ REDIRECT CORREGIDO: Usar SessionManager en vez de Supabase
    redirect: (context, state) async {
      final currentPath = state.uri.path;
      
      // Rutas públicas que no requieren autenticación
      final publicRoutes = ['/auth', '/auth-complete'];
      
      // Verificar si hay sesión guardada
      final session = await SessionManager.loadSession();
      final isAuthenticated = session != null && session.emailVerified;
      
      print('🔍 Redirect check:');
      print('  Path: $currentPath');
      print('  Authenticated: $isAuthenticated');
      print('  Email verified: ${session?.emailVerified ?? false}');
      
      // Si está autenticado y trata de ir a auth, redirigir al main
      if (isAuthenticated && publicRoutes.contains(currentPath)) {
        print('  ➡️ Redirigiendo a /main (ya autenticado)');
        return '/main';
      }
      
      // Si no está autenticado y trata de acceder a rutas protegidas
      if (!isAuthenticated && !publicRoutes.contains(currentPath)) {
        print('  ➡️ Redirigiendo a /auth (no autenticado)');
        return '/auth';
      }
      
      print('  ✅ Sin redirección');
      return null;
    },
    
    routes: [
      // ========== AUTENTICACIÓN ==========
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) {
          print('📍 Navegando a: /auth');
          return const AuthPage();
        },
      ),
      
      GoRoute(
        path: '/auth-complete',
        name: 'auth-complete',
        pageBuilder: (context, state) {
          print('📍 Navegando a: /auth-complete');
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AuthComplete(),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              );
            },
          );
        },
      ),
      
      // ========== MAIN APP ==========
      GoRoute(
        path: '/main',
        name: 'main',
        pageBuilder: (context, state) {
          print('📍 Navegando a: /main');
          return CustomTransitionPage(
            key: state.pageKey,
            child: const MainShell(),
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
                reverseCurve: Curves.easeInCubic,
              );

              return FadeTransition(
                opacity: curved,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - curved.value)),
                  child: Transform.scale(
                    scale: 0.95 + (0.05 * curved.value),
                    child: child,
                  ),
                ),
              );
            },
          );
        },
      ),
      
      // ========== CHAT ==========
      GoRoute(
        path: '/chat',
        name: 'chat',
        pageBuilder: (context, state) {
          print('📍 Navegando a: /chat');
          return CustomTransitionPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: const ChatsUser(),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          );
        },
      ),
      
      // ========== DETALLE DE VEHÍCULO ==========
      GoRoute(
        path: '/auto-details',
        name: 'auto-details',
        pageBuilder: (context, state) {
          print('📍 Navegando a: /auto-details');
          return CustomTransitionPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: const VehicleDetailScreen(vehicleId: '1'),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          );
        },
      ),
      
      // ========== RENTAR VEHÍCULO ==========
      GoRoute(
        path: '/rent-vehicle',
        name: 'rent-vehicle',
        pageBuilder: (context, state) {
          print('📍 Navegando a: /rent-vehicle');
          
          final vehicleId = state.extra != null
              ? (state.extra as Map<String, dynamic>)['vehicleId'] as String
              : '';
          final vehicleName = state.extra != null
              ? (state.extra as Map<String, dynamic>)['vehicleName'] as String
              : '';
          final vehicleType = state.extra != null
              ? (state.extra as Map<String, dynamic>)['vehicleType'] as String
              : '';
          final vehicleImageUrl = state.extra != null
              ? (state.extra as Map<String, dynamic>)['vehicleImageUrl'] as String
              : '';
          final dailyPrice = state.extra != null
              ? (state.extra as Map<String, dynamic>)['dailyPrice'] as double
              : 0.0;

          return CustomTransitionPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: RentVehicleScreen(
              vehicleId: vehicleId,
              vehicleName: vehicleName,
              vehicleType: vehicleType,
              vehicleImageUrl: vehicleImageUrl,
              dailyPrice: dailyPrice,
            ),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          );
        },
      ),
      
      // ========== CONFIRMACIÓN DE PAGO ==========
      GoRoute(
        path: '/pay-confirm',
        name: 'pay-confirm',
        pageBuilder: (context, state) {
          print('📍 Navegando a: /pay-confirm');
          
          final extra = state.extra as Map<String, dynamic>?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: PayConfirmScreen(
              vehicleName: extra?['vehicleName'] as String? ?? '',
              vehicleType: extra?['vehicleType'] as String? ?? '',
              vehicleImageUrl: extra?['vehicleImageUrl'] as String? ?? '',
              startDate: extra?['startDate'] as String? ?? '',
              endDate: extra?['endDate'] as String? ?? '',
              duration: extra?['duration'] as String? ?? '',
              totalAmount: extra?['totalAmount'] as String? ?? '',
              paymentMethod: extra?['paymentMethod'] as String? ?? 'Visa **** 4242',
            ),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          );
        },
      ),
    ],
    
    // Manejo de errores de navegación
    errorBuilder: (context, state) {
      print('❌ Error de navegación: ${state.uri}');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Ruta no encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('${state.uri}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/main'),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      );
    },
  );
}