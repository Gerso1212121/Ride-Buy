import 'package:ezride/App/DATA/datasources/Auth/IADocument_DataSourcers.dart';
import 'package:ezride/App/presentation/pages/auth/AuthComplete.dart';
import 'package:ezride/App/presentation/pages/auth/AuthPage.dart';
import 'package:ezride/App/presentation/pages/auth/UPLOAD_DOCUMENT.dart';
import 'package:ezride/App/presentation/pages/auth/CAPTURE_SCREEN.dart';
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
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/auth-complete',
        name: 'auth-complete',
        builder: (context, state) => const AuthComplete(),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/auto-details',
        name: 'auto-details',
        builder: (context, state) => const VehicleDetailScreen(vehicleId: '1'),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatsUser(),
      ),
      GoRoute(
        path: '/rent-vehicle',
        name: 'rent-vehicle',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RentVehicleScreen(
            vehicleId: extra['vehicleId'] ?? '',
            vehicleName: extra['vehicleName'] ?? '',
            vehicleType: extra['vehicleType'] ?? '',
            vehicleImageUrl: extra['vehicleImageUrl'] ?? '',
            dailyPrice: extra['dailyPrice'] ?? 0.0,
          );
        },
      ),
      GoRoute(
        path: '/pay-confirm',
        name: 'pay-confirm',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PayConfirmScreen(
            vehicleName: extra['vehicleName'] ?? '',
            vehicleType: extra['vehicleType'] ?? '',
            vehicleImageUrl: extra['vehicleImageUrl'] ?? '',
            startDate: extra['startDate'] ?? '',
            endDate: extra['endDate'] ?? '',
            duration: extra['duration'] ?? '',
            totalAmount: extra['totalAmount'] ?? '',
            paymentMethod: extra['paymentMethod'] ?? 'Visa **** 4242',
          );
        },
      ),

      // 🌟 RUTAS DE DOCUMENTOS / VERIFICACIÓN
      GoRoute(
        path: '/upload-document',
        name: 'upload-document',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          final perfilId = extras['perfilId'] ?? '';
          return UploadDocumentPage(perfilId: perfilId);
        },
      ),
      GoRoute(
        path: '/capture-document',
        name: 'capture-document',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          final perfilId = extras['perfilId'] ?? '';

          // No necesitamos dataSource ni sourceType aquí
          return CaptureScreen(perfilId: perfilId);
        },
      ),
    ],
  );
}
