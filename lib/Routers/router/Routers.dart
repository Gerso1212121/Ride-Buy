import 'package:ezride/App/presentation/pages/auth/AuthComplete.dart';
import 'package:ezride/App/presentation/pages/auth/AuthPage.dart';
import 'package:ezride/Feature/Home/Chat/Chat_screen__PRESENTATION.dart';
import 'package:ezride/Feature/PAY_SUCCESS/Pay_Success-%3EPRESENTATION.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/RentVehicle_screen-%3EPRESENTATION.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/VehicleDetail_screen-%3EPRESENTATION.dart';
import 'package:ezride/Routers/router/MainComplete.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) {
      // Obtener el cliente de Supabase
      final supabase = Supabase.instance.client;

      // Verificar si el usuario está autenticado
      final isAuthenticated = supabase.auth.currentSession != null;

      // Obtener la ruta actual - FORMA CORRECTA
      final currentPath = state.uri.path;

      // Rutas que no requieren autenticación
      final publicRoutes = ['/auth', '/auth-complete'];

      // Si está autenticado y trata de ir a auth, redirigir al main
      if (isAuthenticated && publicRoutes.contains(currentPath)) {
        return '/main';
      }

      // Si no está autenticado y trata de acceder a rutas protegidas
      if (!isAuthenticated && !publicRoutes.contains(currentPath)) {
        return '/auth';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => AuthPage(),
      ),
      GoRoute(
        path: '/auth-complete',
        name: 'auth-complete',
        pageBuilder: (context, state) => CustomTransitionPage(
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
        ),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        pageBuilder: (context, state) => CustomTransitionPage(
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
        ),
      ),
      // ... resto de tus rutas existentes ..

      // 🚗 Detalle del vehículo (desde abajo)
      GoRoute(
        path: '/auto-details',
        name: 'auto-details',
        pageBuilder: (context, state) => CustomTransitionPage(
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
        ),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        pageBuilder: (context, state) => CustomTransitionPage(
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
        ),
      ),

      // 🟦 RentVehicleScreen (sale desde la derecha)
      GoRoute(
        path: '/rent-vehicle',
        name: 'rent-vehicle',
        pageBuilder: (context, state) {
          // ✅ Recuperamos los parámetros que enviamos al hacer pushNamed
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
              ? (state.extra as Map<String, dynamic>)['vehicleImageUrl']
                  as String
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
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // ✅ Animación: desde la derecha hacia la izquierda
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0), // empieza desde la derecha
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
      GoRoute(
        path: '/pay-confirm',
        name: 'pay-confirm',
        pageBuilder: (context, state) {
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
              paymentMethod:
                  extra?['paymentMethod'] as String? ?? 'Visa **** 4242',
            ),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
  );
}
