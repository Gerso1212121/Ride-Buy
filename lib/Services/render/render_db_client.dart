import 'dart:async';

import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RenderDbClient {
  static Connection? _connection;
  static bool _isConnecting = false;
  static DateTime? _lastConnectionTime;

  // ✅ Configuración de reconexión
  static const int _maxRetries = 3;
  static const Duration _reconnectDelay = Duration(seconds: 2);

  /// Inicializa la conexión global con Render
  static Future<void> init() async {
    if (_isConnecting) {
      print('⏳ Ya se está conectando, esperando...');
      await Future.delayed(_reconnectDelay);
      return;
    }

    _isConnecting = true;

    try {
      final uri = dotenv.env['KEY_RENDER_DB'];
      if (uri == null) {
        throw Exception(
            'No se ha establecido la conexión con la base de datos');
      }

      final connectionUri = Uri.parse(uri);

      print('🔌 Conectando a la base de datos...');

      // Cerrar conexión anterior si existe
      if (_connection != null) {
        try {
          await _connection!.close();
        } catch (e) {
          print('⚠️ Error cerrando conexión anterior: $e');
        }
        _connection = null;
      }

      _connection = await Connection.open(
        Endpoint(
          host: connectionUri.host,
          port: connectionUri.port != 0 ? connectionUri.port : 5432,
          database: connectionUri.path.substring(1),
          username: connectionUri.userInfo.split(':')[0],
          password: connectionUri.userInfo.split(':')[1],
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.require,
          // ✅ En la nueva versión, el timeout se maneja diferente
        ),
      );

      _lastConnectionTime = DateTime.now();
      print('✅ Conexión a Render DB establecida correctamente.');
    } catch (e) {
      print('❌ Error conectando a BD: $e');
      _connection = null;
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  /// Obtiene la conexión activa con reconexión automática
  static Future<Connection> getConnection({int retryCount = 0}) async {
    try {
      if (_connection == null || _isConnectionClosed()) {
        print(
            '🔄 Conexión cerrada, reconectando... (intento ${retryCount + 1})');
        await init();
      }
      return _connection!;
    } catch (e) {
      if (retryCount < _maxRetries) {
        print(
            '🔄 Reintentando conexión en ${_reconnectDelay.inSeconds} segundos...');
        await Future.delayed(_reconnectDelay);
        return getConnection(retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  /// Verifica si la conexión está cerrada
  static bool _isConnectionClosed() {
    if (_lastConnectionTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_lastConnectionTime!);

    // Si pasaron más de 5 minutos desde la última conexión, asumimos que está cerrada
    return difference.inMinutes > 5;
  }

  /// Ejecuta una transacción segura con reconexión
  static Future<T> runTransaction<T>(
      Future<T> Function(TxSession session) operation) async {
    return await _executeWithRetry(() async {
      final conn = await getConnection();
      return await conn.runTx((session) async {
        try {
          return await operation(session);
        } catch (e, stack) {
          print('❌ Error en la transacción: $e');
          print(stack);
          rethrow;
        }
      });
    });
  }

// En RenderDbClient.dart - AGREGAR ESTE MÉTODO
static Future<List<Map<String, dynamic>>> queryWithTimeout(
  String sql, {
  Map<String, dynamic>? parameters,
  Duration timeout = const Duration(seconds: 15),
}) async {
  final completer = Completer<List<Map<String, dynamic>>>();
  final timer = Timer(timeout, () {
    if (!completer.isCompleted) {
      completer.completeError(
        TimeoutException('Query timeout after $timeout'),
      );
    }
  });

  try {
    final result = await query(sql, parameters: parameters);
    timer.cancel();
    completer.complete(result);
    return await completer.future;
  } catch (e) {
    timer.cancel();
    rethrow;
  }
}
  /// Ejecuta una query simple con reconexión automática
/// Ejecuta una query simple con reconexión automática
static Future<List<Map<String, dynamic>>> query(
  String sql, {
  Map<String, dynamic>? parameters,
}) async {
  return await _executeWithRetry(() async {
    final conn = await getConnection();
    try {
      // ✅ CORREGIDO: Manejar strings cortos
      final queryPreview = sql.length > 50 ? '${sql.substring(0, 50)}...' : sql;
      print('📊 Ejecutando query: $queryPreview');
      
      if (parameters != null) {
        print('📋 Parámetros: $parameters');
      }

      final result = await conn.execute(
        Sql.named(sql),
        parameters: parameters,
      );

      final mappedResult = result.map((row) => row.toColumnMap()).toList();
      print('✅ Query ejecutado exitosamente. Resultados: ${mappedResult.length}');
      return mappedResult;
      
    } catch (e, stack) {
      print('❌ Error al ejecutar la query: $e');
      print(stack);
      
      // Si es error de conexión, forzar reconexión
      if (_isConnectionError(e)) {
        print('🔌 Error de conexión detectado, forzando reconexión...');
        _connection = null;
      }
      rethrow;
    }
  });
}

  /// Ejecuta una operación con reintentos automáticos
  static Future<T> _executeWithRetry<T>(
    Future<T> Function() operation, {
    int retryCount = 0,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (_shouldRetry(e) && retryCount < _maxRetries) {
        print('🔄 Reintentando operación (${retryCount + 1}/$_maxRetries)...');
        await Future.delayed(_reconnectDelay);
        return _executeWithRetry(operation, retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  /// Verifica si el error es de conexión
  static bool _isConnectionError(dynamic e) {
    final errorString = e.toString().toLowerCase();
    return errorString.contains('connection') ||
        errorString.contains('closed') ||
        errorString.contains('not open') ||
        errorString.contains('socket') ||
        errorString.contains('timeout') ||
        errorString.contains('broken') ||
        errorString.contains('terminated');
  }

  /// Determina si se debe reintentar la operación
  static bool _shouldRetry(dynamic e) {
    return _isConnectionError(e);
  }

  /// Verifica el estado de la conexión
  static Future<bool> checkConnection() async {
    try {
      final conn = await getConnection();
      await conn.execute(Sql.named('SELECT 1 as test'));
      print('✅ Verificación de conexión exitosa');
      return true;
    } catch (e) {
      print('❌ Verificación de conexión fallida: $e');
      return false;
    }
  }

  /// Cierra la conexión explícitamente
  static Future<void> close() async {
    if (_connection != null) {
      try {
        await _connection!.close();
        _connection = null;
        _lastConnectionTime = null;
        print('🔌 Conexión cerrada correctamente.');
      } catch (e) {
        print('⚠️ Error cerrando conexión: $e');
      }
    }
  }

  /// Inserta un documento en la DB con reconexión
  static Future<void> insertDocument({
    required Map<String, dynamic> ocrData,
    required String hash,
    required DateTime createdAt,
    String? sourceType,
    String? provider,
  }) async {
    await query(
      '''
      INSERT INTO documentos (ocr_data, hash, created_at, source_type, provider)
      VALUES (@ocrData, @hash, @createdAt, @sourceType, @provider)
      ''',
      parameters: {
        'ocrData': ocrData,
        'hash': hash,
        'createdAt': createdAt.toIso8601String(),
        'sourceType': sourceType,
        'provider': provider,
      },
    );
  }
}
