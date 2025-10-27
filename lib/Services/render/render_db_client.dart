import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RenderDbClient {
  static Connection? _connection;

  /// Inicializa la conexión global con Render
  static Future<void> init() async {
    final uri = dotenv.env['KEY_RENDER_DB'];
    if (uri == null) {
      throw Exception('No se ha establecido la conexión con la base de datos');
    }

    final connectionUri = Uri.parse(uri);

    _connection = await Connection.open(
      Endpoint(
        host: connectionUri.host,
        port: connectionUri.port,
        database: connectionUri.path.substring(1),
        username: connectionUri.userInfo.split(':')[0],
        password: connectionUri.userInfo.split(':')[1],
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.require,
      ),
    );

    print('Conexión a Render DB establecida correctamente.');
  }

  /// Obtiene la conexión activa
  static Future<Connection> getConnection() async {
    if (_connection == null) {
      print('Restableciendo conexión...');
      await init();
    }
    return _connection!;
  }

  /// Ejecuta una transacción segura
  static Future<T> runTransaction<T>(
      Future<T> Function(TxSession session) operation) async {
    final conn = await getConnection();
    return await conn.runTx((session) async {
      try {
        return await operation(session);
      } catch (e, stack) {
        print('Error en la transacción: $e');
        print(stack);
        rethrow;
      }
    });
  }

  /// Ejecuta una query simple y devuelve la lista de mapas
  static Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    final conn = await getConnection();
    try {
      final result = await conn.execute(
        Sql.named(sql),
        parameters: parameters,
      );

      // Convertimos cada fila a Map<String, dynamic>
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e, stack) {
      print('Error al ejecutar la query: $e');
      print(stack);
      rethrow;
    }
  }

  /// Cierra la conexión
  static Future<void> close() async {
    if (_connection != null) {
      await _connection!.close(force: true);
      _connection = null;
      print('Conexión cerrada correctamente.');
    }
  }
}
