import 'package:ezride/Routers/router/Routers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'App/DOMAIN/usecases/search_vehicles_usecase.dart';
import 'App/DATA/datasources/vehicle_remote_datasource.dart';
import 'App/DATA/repositories/vehicle_repository_data.dart';
import 'Feature/Home/SEARCH/Seach_screen_PRESENTATION.dart';
import 'package:ezride/Feature/Home/SEARCH/Search_model/Search_controller.dart'
    as EzrideSearch;
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await RenderDbClient.init();

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
      child: MaterialApp.router(
        // 👈 CAMBIO AQUÍ
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router, // 👈 AGREGA TU GoRouter
      ),
    ),
  );
}
