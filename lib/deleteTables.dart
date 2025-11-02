import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> clearAllTables() async {
  try {
    await dotenv.load(fileName: ".env");
    await RenderDbClient.init();

    print('⚠️ Iniciando limpieza completa de registros (sin borrar tablas)...');

    // 🔄 Desactivar temporalmente validaciones de FK para evitar errores

    // 🧹 Borrar el contenido de las tablas en orden correcto
    await RenderDbClient.query('DELETE FROM public.documentos;');
    print('🧾 Tabla "documentos" limpiada.');

    await RenderDbClient.query('DELETE FROM public.vehiculos;');
    print('🚗 Tabla "vehiculos" limpiada.');

    await RenderDbClient.query('DELETE FROM public.empresas;');
    print('🏢 Tabla "empresas" limpiada.');

    await RenderDbClient.query('DELETE FROM public.register_pending;');
    print('📨 Tabla "register_pending" limpiada.');

    await RenderDbClient.query('DELETE FROM public.profiles;');
    print('👤 Tabla "profiles" limpiada.');

    // ✅ Reactivar validaciones FK

    print(
        '✅ Todas las tablas fueron limpiadas correctamente (estructuras intactas).');
  } catch (e, stack) {
    print('❌ Error limpiando tablas: $e');
    print(stack);
  } finally {
    await RenderDbClient.close();
    print('✅ Conexión cerrada correctamente.');
  }
}

void main() async {
  await clearAllTables();
}
