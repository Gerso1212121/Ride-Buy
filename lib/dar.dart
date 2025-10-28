import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ezride/Services/render/render_db_client.dart';

Future<void> clearProfilesTable() async {
  try {
    // Inicializar la conexión antes de ejecutar cualquier query
    await RenderDbClient.init();

    await RenderDbClient.query('TRUNCATE TABLE profiles RESTART IDENTITY;');
    print('✅ Todos los registros de la tabla profiles fueron eliminados.');
  } catch (e, st) {
    print('❌ Error eliminando datos de profiles: $e');
    print(st);
  } finally {
    await RenderDbClient.close();
  }
}

Future<void> main() async {
  // ⚠️ Cargar dotenv antes de inicializar RenderDbClient
  await dotenv.load(fileName: ".env");

  await clearProfilesTable();
}
