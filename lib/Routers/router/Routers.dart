import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:ezride/App/DATA/repositories/Auth/ProfileUser_RepositoryData.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';
import 'package:ezride/App/presentation/pages/Home/ProfileSearchRent_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/ProfileUser_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/QRDevolucionScannerScreen.dart';
import 'package:ezride/App/presentation/pages/Home/QRScannerScreen.dart';
import 'package:ezride/App/presentation/pages/Home/VEHICULOSSOLICITADOS.dart';
import 'package:ezride/App/presentation/pages/Home/VEHICULOS_EMPRESAS.dart';
import 'package:ezride/App/presentation/pages/Home/VehiculosRENTADOS.dart';
import 'package:ezride/App/presentation/pages/Home/payment_pending_screen.dart';
import 'package:ezride/App/presentation/pages/auth/AuthComplete.dart';
import 'package:ezride/App/presentation/pages/auth/AuthOtpPage.dart';
import 'package:ezride/App/presentation/pages/auth/AuthPage.dart';
import 'package:ezride/App/presentation/pages/auth/CameraSelfiePage.dart';
import 'package:ezride/App/presentation/pages/auth/UploadDocumentPage.dart';
import 'package:ezride/App/presentation/pages/auth/CameraCapturePage.dart';
import 'package:ezride/App/presentation/pages/auth/PersonalDataForm.dart';
import 'package:ezride/Feature/Form_Empresa/FORMEMPRESAS.dart';
import 'package:ezride/Feature/Form_Empresa/IMAGENES_SELECT.dart';
import 'package:ezride/Feature/Form_Vehiculo/FORM_VEHICULO.dart';
import 'package:ezride/Feature/Form_Vehiculo/VEHICLE_TEST_REAL.dart';
import 'package:ezride/Feature/PAY_SUCCESS/Pay_Success_PRESENTATION.dart';
import 'package:ezride/App/presentation/pages/Home/RentVehicle_Screen.dart';
import 'package:ezride/App/presentation/pages/Home/VehicleDetail_Screen.dart';
import 'package:ezride/Feature/VERIFICACIONES/Coverage/widgets/Coverage_Complete.dart';
import 'package:ezride/Feature/VERIFICACIONES/Error/widgets/Error_Auth.dart';
import 'package:ezride/Routers/router/MainComplete.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/auth',
    redirect: (context, state) async {
      print('🔄 REDIRECT: ${state.uri}');
// FORZAR carga de sesión ANTES DE USAR hasSession
      final profile = await SessionManager.loadSession();
      final hasSession = profile != null;
      final isVerified = SessionManager.isVerified;
      final location = state.uri.toString();

      print(
          '📊 Session: $hasSession, Verified: $isVerified, Location: $location');

      // Cargar sesión completa (perfil + empresa)
      Profile? userProfile;
      if (hasSession) {
        userProfile = await SessionManager.loadSession();
      }

      final publicRoutes = ['/auth', '/otp', '/empresa-registro'];
      final isPublic = publicRoutes.any((r) => location.startsWith(r));

      // Rutas permitidas para usuarios no verificados
      final verificationRoutes = [
        '/capture-document',
        '/selfie-camera',
        '/upload-document',
        '/personal-data',
        '/verificacion-completa',
        '/error-verificacion'
      ];

      final isInVerificationFlow =
          verificationRoutes.any((r) => location.startsWith(r));

      // ===========================================================
      // 1. Si no tiene sesión y no está en ruta pública → /auth
      // ===========================================================
      if (!hasSession && !isPublic) {
        print('🚫 No session, redirecting to /auth');
        return '/auth';
      }

      // ===========================================================
      // 2. Si tiene sesión pero el usuario no existe en BD → /auth
      // ===========================================================
      if (hasSession && userProfile == null) {
        print('⚠️ Usuario no existe en BD, redirigiendo a /auth');
        await SessionManager.clearProfile();
        return '/auth';
      }

      // ===========================================================
      // 3. Si está autenticado pero no verificado → /capture-document
      // ===========================================================
      if (hasSession && userProfile != null && !isVerified) {
        // Permitir acceso al flujo de verificación y rutas públicas
        if (!isInVerificationFlow && !isPublic) {
          print('📄 Usuario no verificado, redirigiendo a /capture-document');
          return '/capture-document';
        }

        print(
            '📄 Usuario no verificado, pero está en flujo de verificación o ruta pública');
        return null;
      }

      // ===========================================================
      // 4. Si está autenticado y verificado → /main (si está en auth)
      // ===========================================================
      if (hasSession && isVerified && location.startsWith('/auth')) {
        print('✅ Usuario verificado, redirigiendo a /main');
        return '/main';
      }

      // ===========================================================
      // 5. Si está en flujo de verificación pero ya está verificado → /main
      // ===========================================================
      if (hasSession && isVerified && isInVerificationFlow) {
        print(
            '✅ Usuario ya verificado, redirigiendo a /main desde flujo de verificación');
        return '/main';
      }

      // ===========================================================
      // 6. Verificar datos de empresa (solo logging informativo)
      // ===========================================================
      if (hasSession && isVerified && SessionManager.currentEmpresa != null) {
        print(
            '🏢 Usuario tiene empresa asociada: ${SessionManager.currentEmpresa!.nombre}');
      } else if (hasSession && isVerified) {
        print('👤 Usuario verificado pero sin empresa asociada');
      }

      print('➡️ No redirect needed');
      return null;
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
          final extra = state.extra as Map<String, dynamic>? ?? {};
          print('🚗 Building AutoDetails with extra: $extra');
          return CustomTransitionPage(
            child: VehicleDetailScreen(
              vehicleId: extra['vehicleId'] ?? '',
              vehicleTitle: extra['vehicleTitle'] ?? '',
              vehicleImage: extra['vehicleImage'] ?? '',
              dailyPrice: extra['dailyPrice'] ?? 0.0,
              year: extra['year'] ?? '',
              isRented: extra['isRented'] ?? 'disponible',
              empresaId: extra['empresaId'] ?? '',
              // ✅ AGREGAR LOS NUEVOS PARÁMETROS
              brand: extra['brand'] ?? '',
              model: extra['model'] ?? '',
              plate: extra['plate'] ?? '',
              color: extra['color'] ?? '',
              fuelType: extra['fuelType'] ?? '',
              transmission: extra['transmission'] ?? '',
              passengerCapacity: extra['passengerCapacity'] ?? 5,
            ),
            transitionsBuilder: (context, animation, _, child) {
              final offset = Tween(begin: const Offset(0, 1), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic));
              return SlideTransition(position: offset, child: child);
            },
          );
        },
      ),

      GoRoute(
        path: '/rent-vehicle',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RentVehicleScreen(
            vehicleId: extra['vehicleId'] ?? '',
            vehicleName: extra['vehicleName'] ?? '',
            vehicleType: extra['vehicleType'] ?? '',
            vehicleImageUrl: extra['vehicleImageUrl'] ?? '',
            dailyPrice: extra['dailyPrice'] ?? 0.0,
            empresaId: extra['empresaId'] ?? '', // ✅ Nuevo parámetro
          );
        },
      ),
      // En tu archivo de rutas
      GoRoute(
        path: '/vehiculos-rentados',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const VehiculosRentadosScreen(),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
// En tu archivo de configuración de rutas (app_router.dart o similar)
      GoRoute(
        path: '/empresa-profile',
        name: 'EmpresaProfile',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final empresaId = extra?['empresaId']?.toString() ?? '';

          return ProfileScreenBussines(
            empresaId: empresaId,
            
          );
        },
      ),
      GoRoute(
        path: '/empresa-vehiculos',
        builder: (context, _) {
          print('🏢 Building EmpresaVehiculosScreen');
          return const EmpresaVehiculosScreen(); // Add the EmpresaVehiculosScreen here
        },
      ),
      // En tu archivo de rutas
      GoRoute(
        path: '/payment-pending',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PaymentPendingScreen(extra: extra);
        },
      ),
      GoRoute(
        path: '/empresa-solicitudes',
        builder: (context, _) {
          print('🏢 Building EmpresaVehiculosScreen');
          return const SolicitudesPendientesScreen(); // Add the EmpresaVehiculosScreen here
        },
      ),

      GoRoute(
        path: '/pay-confirm',
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
            rentaId: extra['rentaId'], // ✅ Nuevo parámetro
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
              print('✅ Verificación completa, redirigiendo a /main');
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
                final fullName = extra['fullName'] as String? ?? 'Default Name';
                final duiNumber = extra['duiNumber'] as String? ?? '0000000';
                final dateOfBirth =
                    extra['dateOfBirth'] as String? ?? '01/01/2000';
                final perfilId = extra['perfilId'] as String? ?? '';

                await ProfileUserRepositoryData(dio: Dio()).updateUserProfile(
                  id: perfilId,
                  displayName: fullName,
                  phone: phone,
                  duiNumber: duiNumber,
                  dateOfBirth: DateTime.parse(dateOfBirth).toIso8601String(),
                  verificationStatus: "verificado",
                );

                print(
                    '✅ Perfil actualizado, redirigiendo a /verificacion-completa');
                context.go('/verificacion-completa');
              } catch (e) {
                print('❌ Error al guardar: $e');
                context.go('/error-verificacion', extra: {
                  'reason': e.toString(),
                });
              }
            },
            onCancelPressed: () {
              print('❌ Cancel pressed, going to /auth');
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

      GoRoute(
        path: '/profile',
        builder: (context, _) {
          print('👤 Building ProfileUser');
          return const ProfileUser();
        },
      ),

      // Ruta adicional para ver datos de empresa (opcional)
      GoRoute(
        path: '/empresa-imagenes',
        builder: (context, state) {
          final datos = state.extra as Map<String, dynamic>?;
          return ImagenesSelectWidget(datosEmpresa: datos); // ✅ ahora existe
        },
      ),
      GoRoute(
        path: '/test-vehiculos',
        builder: (context, state) {
          return const VehicleTestRealWidget();
        },
      ),

      // AGREGAR EN LA LISTA DE RUTAS
      GoRoute(
        path: '/qr-devolucion-scanner',
        builder: (context, state) {
          print('📱 Building QRDevolucionScannerScreen');
          return const QRDevolucionScannerScreen();
        },
      ),

      GoRoute(
        path: '/qr-scanner',
        builder: (context, state) {
          print('📱 Building QRScannerScreen');
          return const QRScannerScreen();
        },
      ),

      GoRoute(
        path: '/crear-vehiculo',
        builder: (context, state) {
          return const FormularioVehiculoWidget();
        },
      ),
    ],
  );

  // Widget auxiliar para mostrar datos de empresa
}
