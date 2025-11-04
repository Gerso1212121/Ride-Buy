
import 'package:ezride/Routers/router/Routers.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ CARGAR VARIABLES DE ENTORNO
  await dotenv.load(fileName: '.env');
  
  
  await FlutterFlowTheme.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      themeMode: FlutterFlowTheme.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}