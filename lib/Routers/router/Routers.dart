import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:ezride/App/DATA/repositories/Auth/ProfileUser_RepositoryData.dart';
import 'package:ezride/App/presentation/pages/auth/AuthComplete.dart';
import 'package:ezride/App/presentation/pages/auth/AuthOtpPage.dart';
import 'package:ezride/App/presentation/pages/auth/AuthPage.dart';
import 'package:ezride/App/presentation/pages/auth/CAPTURESELFIE_SCREEN.dart';
import 'package:ezride/App/presentation/pages/auth/UPLOAD_DOCUMENT.dart';
import 'package:ezride/App/presentation/pages/auth/CAPTURE_SCREEN.dart';
import 'package:ezride/App/presentation/pages/auth/UPLOAD_identity.dart';
import 'package:ezride/Feature/Form_Empresa/FORMEMPRESAS.dart';
import 'package:ezride/Feature/Home/Chat/Chat_screen_PRESENTATION.dart';
import 'package:ezride/Feature/PAY_SUCCESS/Pay_Success_PRESENTATION.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/RentVehicle_screen_PRESENTATION.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/VehicleDetail_screen_PRESENTATION.dart';
import 'package:ezride/Feature/VERIFICACIONES/Coverage/widgets/Coverage_Complete.dart';
import 'package:ezride/Feature/VERIFICACIONES/Error/widgets/Error_Auth.dart';
import 'package:ezride/Routers/router/MainComplete.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ezride/Services/render/render_db_client.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/auth', // Ruta inicial
    redirect: (context, state) async {
      print('🔄 REDIRECT: ${state.uri}');
      final hasSession = SessionManager.hasSession;
      final isVerified = SessionManager.isVerified;
      final location = state.uri.toString();

      print(
          '📊 Session: $hasSession, Verified: $isVerified, Location: $location');

      final publicRoutes = ['/auth', '/otp', '/empresa-registro'];
      final isPublic = publicRoutes.any((r) => location.startsWith(r));

      // Si no tiene sesión y no está en una ruta pública, redirige a /auth
      if (!hasSession && !isPublic) {
        print('🚫 No session, redirecting to /auth');
        return '/auth'; // Redirige siempre a /auth si no tiene sesión
      }

      // Si está autenticado pero no verificado, no redirigir automáticamente a /capture-document
      if (hasSession && !isVerified) {
        print('📄 Not verified, staying on current page');
        return null; // No redirigimos a /capture-document automáticamente
      }

      // Cargar la sesión y verificar que el usuario existe en la base de datos
      if (hasSession) {
        final user = await SessionManager.loadSession(); // Cargar la sesión
        if (user == null) {
          print(
              '⚠️ Usuario no existe en la base de datos, redirigiendo a /auth');
          return '/auth'; // Redirige a /auth si el usuario no está registrado
        }
      }

      // Si está autenticado y verificado, redirige a /main
      if (hasSession && isVerified && location.startsWith('/auth')) {
        print('✅ Verified, redirecting to /main');
        return '/main'; // Redirige a la página principal si está verificado
      }

      print('➡️ No redirect needed');
      return null; // No hace ninguna redirección si no es necesario
    },
    routes: [
      // Rutas de autenticación
      GoRoute(
        path: '/auth',
        builder: (context, _) {
          print('🏠 Building AuthPage');
          return const AuthPage();
        },
      ),
      GoRoute(
        path: '/empresa-registro',
        builder: (context, _) {
          print('🏢 Building FormularioEmpresaWidget');
          return const FormularioEmpresaWidget();
        },
      ),
      GoRoute(
        path: '/auth-complete',
        builder: (context, _) {
          print('✅ Building AuthComplete');
          return const AuthComplete();
        },
      ),
      GoRoute(
        path: '/main',
        builder: (context, _) {
          print('🏠 Building MainShell');
          return const MainShell();
        },
      ),

      // Rutas del flujo de vehículo y pagos
      GoRoute(
        path: '/auto-details',
        pageBuilder: (context, state) {
          print('🚗 Building AutoDetails');
          final extra = state.extra as Map<String, dynamic>? ?? {};
          print('📦 AutoDetails extra: $extra');
          return CustomTransitionPage(
            child: VehicleDetailScreen(
              vehicleId: extra['vehicleId'] ?? '',
              vehicleTitle: extra['vehicleTitle'] ?? '',
              vehicleImage: extra['vehicleImage'] ?? '',
              dailyPrice: extra['dailyPrice'] ?? 0.0,
              year: extra['year'] ?? '',
              isRented: extra['isRented'] ?? 'disponible',
            ),
            transitionsBuilder: (_, animation, __, child) {
              final offset = Tween(begin: const Offset(0, 1), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic));
              return SlideTransition(position: offset, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (context, _) {
          print('💬 Building ChatsUser');
          return const ChatsUser();
        },
      ),
      GoRoute(
        path: '/rent-vehicle',
        builder: (context, state) {
          print('🚘 Building RentVehicle');
          final extra = state.extra as Map<String, dynamic>? ?? {};
          print('📦 RentVehicle extra: $extra');
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
        builder: (context, state) {
          print('💳 Building PayConfirm');
          final extra = state.extra as Map<String, dynamic>? ?? {};
          print('📦 PayConfirm extra: $extra');
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

      // Rutas de verificación de documentos
      GoRoute(
        path: '/capture-document',
        builder: (context, state) {
          print('📷 Building CameraCapturePage');
          final extra = (state.extra as Map<String, dynamic>?) ?? {};
          print('📦 CaptureDocument extra: $extra');
          return CameraCapturePage(
            camera: extra['camera'],
            perfilId: extra['perfilId'],
          );
        },
      ),
      GoRoute(
        path: '/selfie-camera',
        builder: (context, state) {
          print('🤳 Building CameraSelfiePage');
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CameraSelfiePage(
            camera: extra['camera'],
            perfilId: extra['perfilId'],
            duiImagePath: extra['duiImagePath'],
          );
        },
      ),
      GoRoute(
        path: '/upload-document',
        builder: (context, state) {
          print('📤 Building UploadDocumentPage');
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return UploadDocumentPage(
            perfilId: extra['perfilId'] ?? '',
            duiImagePath: extra['duiImagePath'] ?? '',
            selfiePath: extra['selfiePath'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/verificacion-completa',
        builder: (context, _) {
          print('🎉 Building VerificacionCompleta');
          return VerificacionCompletaWidget(
            onContinuePressed: () {
              context.go('/auth');
            },
          );
        },
      ),
      GoRoute(
        path: '/error-verificacion',
        builder: (context, state) {
          print('❌ Building ErrorVerificacion');
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PantallaErrorVerificacionWidget(
            title: 'Error en la verificación',
            description: extra['reason'] ?? 'Error desconocido',
            onReintentarPressed: () {
              print('🔄 Reintentar pressed, going to /auth');
              context.go('/auth');
            },
          );
        },
      ),

      // Rutas de datos personales
      GoRoute(
        path: '/personal-data',
        builder: (context, state) {
          print('👤 Building PersonalDataForm');
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PersonalDataForm(
            fullName: extra['fullName'],
            duiNumber: extra['duiNumber'],
            dateOfBirth: extra['dateOfBirth'],
            animationsMap: {},
            parentContext: context,
            onSavePressed: (phone) async {
              print('💾 Save pressed with phone: $phone');
              try {
                final fullName = extra['fullName'] as String? ??
                    'Default Name'; // Use 'Default Name' if fullName is null
                final duiNumber = extra['duiNumber'] as String? ??
                    '0000000'; // Default value if null
                final dateOfBirth = extra['dateOfBirth'] as String? ??
                    '01/01/2000'; // Default value if null
                final perfilId = extra['perfilId'] as String? ??
                    ''; // Default to empty string if null

                await ProfileUserRepositoryData(dio: Dio()).updateUserProfile(
                  id: perfilId,
                  displayName: fullName,
                  phone: phone,
                  duiNumber: duiNumber,
                  dateOfBirth: DateTime.parse(dateOfBirth).toIso8601String(),
                  verificationStatus: "verificado",
                );

                context.go('/verificacion-completa');
              } catch (e) {
                print('❌ Error al guardar: $e');
                context.go('/error-verificacion', extra: {
                  'reason': e.toString(), // Aquí pasas un Map<String, dynamic>
                });
              }
            },
            onCancelPressed: () {
              context.go('/auth');
            },
          );
        },
      ),

      GoRoute(
        path: '/otp',
        builder: (context, state) {
          print('🔑 Building AuthOtpPage');
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AuthOtpPage(
            email: extra['email'],
            password: extra['password'],
            profileUserUseCaseGlobal: extra['profileUserUseCaseGlobal'],
          );
        },
      ),
    ],
  );

  // Widget auxiliar para mostrar pantallas de error
}
