import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezride/App/presentation/pages/auth/AuthComplete.dart';
import 'package:ezride/App/presentation/pages/auth/AuthPage.dart';
import 'package:ezride/App/presentation/pages/auth/Capture_screen.dart';
import 'package:ezride/App/presentation/pages/auth/upload_document_page.dart';
import 'package:ezride/Feature/Home/Chat/Chat_screen__PRESENTATION.dart';
import 'package:ezride/Feature/PAY_SUCCESS/Pay_Success-PRESENTATION.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/RentVehicle_screen-PRESENTATION.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/VehicleDetail_screen-%EF%80%BEPRESENTATION.dart';
import 'package:ezride/Routers/router/MainComplete.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
        path: '/capture_verification',
        name: 'capture_verification',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          final perfilId = extras['perfilId'] ?? '';
          return CaptureScreen(perfilId: perfilId);
        },
      ),
    ],
  );
}

/// Splash seguro con inicialización
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await RenderDbClient.init();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      GoRouter.of(context).go('/auth');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inicializando app: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
