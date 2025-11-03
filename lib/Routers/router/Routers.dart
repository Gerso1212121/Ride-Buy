import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:ezride/App/DATA/datasources/Auth/IADocument_DataSourcers.dart';
import 'package:ezride/App/DATA/repositories/Auth/ProfileUser_RepositoryData.dart';
import 'package:ezride/App/presentation/pages/auth/AuthComplete.dart';
import 'package:ezride/App/presentation/pages/auth/AuthOtpPage.dart';
import 'package:ezride/App/presentation/pages/auth/AuthPage.dart';
import 'package:ezride/App/presentation/pages/auth/CAPTURESELFIE_SCREEN.dart';
import 'package:ezride/App/presentation/pages/auth/UPLOAD_DOCUMENT.dart';
import 'package:ezride/App/presentation/pages/auth/CAPTURE_SCREEN.dart';
import 'package:ezride/App/presentation/pages/auth/UPLOAD_identity.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Feature/Home/Chat/Chat_screen_PRESENTATION.dart';
import 'package:ezride/Feature/PAY_SUCCESS/Pay_Success_PRESENTATION.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/RentVehicle_screen_PRESENTATION.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/VehicleDetail_screen_PRESENTATION.dart';
import 'package:ezride/Feature/VERIFICACIONES/Coverage/widgets/Coverage_Complete.dart';
import 'package:ezride/Feature/VERIFICACIONES/Error/widgets/Error_Auth.dart';
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
        path: '/capture-document',
        name: 'capture-document',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          final camera = extras['camera'] as CameraDescription;
          final perfilId = extras['perfilId'] as String? ?? '';

          return CameraCapturePage(camera: camera, perfilId: perfilId);
        },
      ),
      GoRoute(
        path: '/selfie-camera',
        name: 'selfie-camera',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          final perfilId = extras['perfilId'] ?? '';
          final camera = extras['camera'] as CameraDescription;
          final duiImagePath =
              extras['duiImagePath'] as String?; // 👈 nuevo parámetro

          return CameraSelfiePage(
            camera: camera,
            perfilId: perfilId,
            duiImagePath: duiImagePath,
          );
        },
      ),
      GoRoute(
        path: '/upload-document',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return UploadDocumentPage(
            perfilId: data['perfilId'] as String,
            duiImagePath: data['duiImagePath'] as String,
            selfiePath: data['selfiePath'] as String,
          );
        },
      ),

      GoRoute(
        path: '/verificacion-completa',
        name: 'verificacion-completa',
        builder: (context, state) {
          return VerificacionCompletaWidget(
            onContinuePressed: () {
              context.go('/main');
            },
          );
        },
      ),
      GoRoute(
        path: '/error-verificacion',
        name: 'error-verificacion',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final reason = extra['reason'] as String? ??
              'Ocurrió un error desconocido durante la verificación.';

          return PantallaErrorVerificacionWidget(
            title: 'Error en la verificación',
            description: reason,
            onReintentarPressed: () {
              context.go('/auth'); // o donde quieras mandarlo
            },
          );
        },
      ),

      GoRoute(
        path: '/personal-data',
        name: 'personal-data',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          final fullName = extras['fullName'] as String?;
          final duiNumber = extras['duiNumber'] as String?;
          final dateOfBirth = extras['dateOfBirth'] as String?;

          return Scaffold(
            body: PersonalDataForm(
              fullName: fullName,
              duiNumber: duiNumber,
              dateOfBirth: dateOfBirth,
              animationsMap: {}, // ✅ Parámetro requerido
              parentContext: context, // ✅ Parámetro requerido
              onSavePressed: (phone) async {
                try {
                  // 📌 Tomar datos del OCR/extra
                  final fullName = extras['fullName'] as String?;
                  final duiNumber = extras['duiNumber'] as String?;
                  final dateOfBirth = extras['dateOfBirth'] as String?;

                  if (fullName == null ||
                      duiNumber == null ||
                      dateOfBirth == null) {
                    throw Exception("Datos incompletos");
                  }

                  // ✅ Crear un objeto perfil temporal para actualizar BD
                  final updatedData = {
                    "displayName": fullName,
                    "phone": phone,
                    "duiNumber": duiNumber,
                    "dateOfBirth": dateOfBirth,
                    "verificationStatus": "verificado",
                  };

                  final dio = Dio();
                  final repo = ProfileUserRepositoryData(dio: dio);

                  await repo.updateUserProfile(
                    id: extras[
                        'perfilId'], // 👈 debes haber mandado esto desde el OTP
                    displayName: fullName,
                    phone: phone,
                    duiNumber: duiNumber,
                    dateOfBirth: DateTime.parse(dateOfBirth).toIso8601String(),
                    verificationStatus: "verificado",
                  );

                  // 🚫 NO guardamos sesión aún — se crea recién después
                  // await SessionManager.setProfile(...)

                  // ✅ Enviar a pantalla final
                  context.go('/verificacion-completa');
                } catch (e) {
                  debugPrint("❌ Error guardando perfil: $e");

                  // ✅ Mandar a pantalla de error y NO crear sesión
                  context.go('/error-verificacion', extra: {
                    'reason': 'El DUI ya está asociado a otra cuenta.',
                  });
                }
              },

              onCancelPressed: () {
                context.go('/auth');
              },
            ),
          );
        },
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return AuthOtpPage(
            email: extras['email'],
            password: extras['password'],
            profileUserUseCaseGlobal: extras['profileUserUseCaseGlobal'],
          );
        },
      ),
    ],
  );
}
