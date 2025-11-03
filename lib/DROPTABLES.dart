import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> dropAllTables() async {
  try {
    await dotenv.load(fileName: ".env");
    await RenderDbClient.init();

    print('⚠️ Iniciando eliminación completa de las tablas...');

    // 🧨 Eliminar tablas (si existen)
    await RenderDbClient.query('DROP TABLE IF EXISTS public.documentos CASCADE;');
    print('🧾 Tabla "documentos" eliminada.');

    await RenderDbClient.query('DROP TABLE IF EXISTS public.vehiculos CASCADE;');
    print('🚗 Tabla "vehiculos" eliminada.');

    await RenderDbClient.query('DROP TABLE IF EXISTS public.empresas CASCADE;');
    print('🏢 Tabla "empresas" eliminada.');

    await RenderDbClient.query('DROP TABLE IF EXISTS public.register_pending CASCADE;');
    print('📨 Tabla "register_pending" eliminada.');

    await RenderDbClient.query('DROP TABLE IF EXISTS public.profiles CASCADE;');
    print('👤 Tabla "profiles" eliminada.');

    // 🔁 Reactivar restricciones
    print('✅ Todas las tablas fueron eliminadas completamente.');
  } catch (e, stack) {
    print('❌ Error al eliminar las tablas: $e');
    print(stack);
  } finally {
    await RenderDbClient.close();
    print('✅ Conexión cerrada correctamente.');
  }
}

void main() async {
  await dropAllTables();
}
