import 'package:ezride/App/DATA/datasources/Auth/vehicle_remote_datasource.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Routers/router/Routers.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// ✅ Render DB
import 'package:ezride/Services/render/render_db_client.dart';

// ✅ Search Data
import 'package:ezride/App/DATA/repositories/vehicle_repository_data.dart';
import 'package:ezride/App/DOMAIN/usecases/search_vehicles_usecase.dart';

// ✅ Search controller con alias
import 'package:ezride/Feature/Home/SEARCH/Search_model/Search_controller.dart'
    as EzrideSearch;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await RenderDbClient.init();
  await SessionManager.loadSession(); // ✅ carga sesión
  await FlutterFlowTheme.initialize();

  final dataSource = VehicleRemoteDataSource();
  final repo = VehicleRepositoryData(dataSource);
  final useCase = SearchVehiclesUseCase(repo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EzrideSearch.SearchController(useCase),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
