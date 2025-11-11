import 'package:ezride/App/DATA/models/rentas_model.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Services/render/render_db_client.dart';

class RentaRemoteDataSource {
  
  // ✅ MÉTODO MEJORADO: Crear renta con manejo de UUID
  Future<RentaModel> createRenta(RentaModel renta) async {
    const sql = '''
      INSERT INTO public.rentas (
        vehiculo_id, empresa_id, cliente_id, tipo, 
        fecha_inicio_renta, fecha_entrega_vehiculo, 
        pickup_method, pickup_address, entrega_address, 
        total, status, verification_code
      ) VALUES (
        @vehiculo_id, @empresa_id, @cliente_id, @tipo,
        @fecha_inicio_renta, @fecha_entrega_vehiculo,
        @pickup_method, @pickup_address, @entrega_address,
        @total, @status, @verification_code
      ) RETURNING *;
    ''';

    final parameters = {
      'vehiculo_id': renta.vehiculoId,
      'empresa_id': renta.empresaId,
      'cliente_id': renta.clienteId,
      'tipo': renta.tipo.name,
      'fecha_inicio_renta': renta.fechaInicioRenta.toIso8601String(),
      'fecha_entrega_vehiculo': renta.fechaEntregaVehiculo.toIso8601String(),
      'pickup_method': renta.pickupMethod.name,
      'pickup_address': renta.pickupAddress,
      'entrega_address': renta.entregaAddress,
      'total': renta.total,
      'status': renta.status.name,
      'verification_code': renta.verificationCode ?? _generateVerificationCode(),
    };

    print('🔍 DEBUG createRenta - Parámetros:');
    parameters.forEach((key, value) {
      print('   $key: $value');
    });

    try {
      final result = await RenderDbClient.query(sql, parameters: parameters);
      
      if (result.isEmpty) {
        throw Exception('No se pudo crear la renta - Resultado vacío');
      }

      print('✅ Renta creada exitosamente:');
      print('   ID generado: ${result.first['id']}');
      print('   Estado: ${result.first['status']}');
      print('   Total: ${result.first['total']}');

      return RentaModel.fromMap(result.first);
    } catch (e, stack) {
      print('❌ Error en createRenta: $e');
      print('🔍 Stack trace: $stack');
      rethrow;
    }
  }

  // ✅ Generar código de verificación si no se proporciona
  String _generateVerificationCode() {
    final now = DateTime.now();
    return 'VR${now.millisecondsSinceEpoch}${_getRandomString(4)}';
  }

  String _getRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final code = StringBuffer();
    
    for (var i = 0; i < length; i++) {
      code.write(chars[random % chars.length]);
    }
    
    return code.toString();
  }

  // ✅ MÉTODO MEJORADO: Obtener renta por ID con más información
  Future<RentaModel> getRentaById(String rentaId) async {
    const sql = '''
      SELECT 
        r.*, 
        v.titulo as vehiculo_titulo, 
        v.marca, 
        v.modelo, 
        v.imagen1,
        p.display_name as cliente_nombre, 
        p.phone as cliente_phone,
        e.nombre as empresa_nombre
      FROM public.rentas r
      JOIN public.vehiculos v ON r.vehiculo_id = v.id
      JOIN public.profiles p ON r.cliente_id = p.id
      JOIN public.empresas e ON r.empresa_id = e.id
      WHERE r.id = @id;
    ''';
    
    final result = await RenderDbClient.query(sql, parameters: {'id': rentaId});
    
    if (result.isEmpty) {
      throw Exception('Renta no encontrada con ID: $rentaId');
    }
    
    return RentaModel.fromMap(result.first);
  }

  // ✅ MÉTODO MEJORADO: Actualizar estado con verificación
  Future<RentaModel> updateRentaStatus(String rentaId, String status) async {
    const sql = '''
      UPDATE public.rentas 
      SET status = @status, updated_at = NOW()
      WHERE id = @id 
      RETURNING *;
    ''';
    
    final result = await RenderDbClient.query(sql, parameters: {
      'id': rentaId, 
      'status': status
    });
    
    if (result.isEmpty) {
      throw Exception('No se pudo actualizar la renta con ID: $rentaId');
    }
    
    print('✅ Estado de renta actualizado: $rentaId -> $status');
    return RentaModel.fromMap(result.first);
  }

  // ✅ MÉTODO MEJORADO: Obtener rentas por cliente
  Future<List<RentaModel>> getRentasByCliente(String clienteId) async {
    const sql = '''
      SELECT 
        r.*, 
        v.titulo as vehiculo_titulo, 
        v.marca, 
        v.modelo, 
        v.imagen1,
        e.nombre as empresa_nombre
      FROM public.rentas r
      JOIN public.vehiculos v ON r.vehiculo_id = v.id
      JOIN public.empresas e ON r.empresa_id = e.id
      WHERE r.cliente_id = @cliente_id 
      ORDER BY r.created_at DESC;
    ''';
    
    final result = await RenderDbClient.query(sql, parameters: {'cliente_id': clienteId});
    return result.map((map) => RentaModel.fromMap(map)).toList();
  }

  // ✅ MÉTODO MEJORADO: Obtener rentas por empresa
  Future<List<RentaModel>> getRentasByEmpresa(String empresaId) async {
    const sql = '''
      SELECT 
        r.*, 
        v.titulo as vehiculo_titulo, 
        v.marca, 
        v.modelo, 
        v.imagen1,
        p.display_name as cliente_nombre,
        p.phone as cliente_phone
      FROM public.rentas r
      JOIN public.vehiculos v ON r.vehiculo_id = v.id
      JOIN public.profiles p ON r.cliente_id = p.id
      WHERE r.empresa_id = @empresa_id 
      ORDER BY r.created_at DESC;
    ''';
    
    final result = await RenderDbClient.query(sql, parameters: {'empresa_id': empresaId});
    return result.map((map) => RentaModel.fromMap(map)).toList();
  }

  // ✅ MÉTODO MEJORADO: Verificar disponibilidad del vehículo
  Future<bool> verificarDisponibilidadVehiculo(
    String vehiculoId, 
    DateTime fechaInicio, 
    DateTime fechaFin
  ) async {
    const sql = '''
      SELECT COUNT(*) as count
      FROM public.rentas 
      WHERE vehiculo_id = @vehiculo_id 
        AND status IN ('pendiente', 'confirmada', 'en_curso')
        AND (
          (fecha_inicio_renta BETWEEN @fecha_inicio AND @fecha_fin)
          OR (fecha_entrega_vehiculo BETWEEN @fecha_inicio AND @fecha_fin)
          OR (fecha_inicio_renta <= @fecha_inicio AND fecha_entrega_vehiculo >= @fecha_fin)
        );
    ''';
    
    final result = await RenderDbClient.query(sql, parameters: {
      'vehiculo_id': vehiculoId,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
    });
    
    final count = (result.first['count'] as int?) ?? 0;
    return count == 0;
  }

  // Resto de los métodos permanecen igual...
  Future<List<RentaModel>> getRentasActivasByVehiculo(String vehiculoId) async {
    const sql = '''
      SELECT * FROM public.rentas 
      WHERE vehiculo_id = @vehiculo_id 
        AND status IN ('confirmada', 'en_curso')
        AND fecha_entrega_vehiculo >= NOW()
      ORDER BY fecha_inicio_renta;
    ''';
    final result = await RenderDbClient.query(sql, parameters: {'vehiculo_id': vehiculoId});
    return result.map((map) => RentaModel.fromMap(map)).toList();
  }

  Future<RentaModel> addPickupPhotos(String rentaId, List<String> photos) async {
    const sql = '''
      UPDATE public.rentas 
      SET pickup_photos = @photos, updated_at = NOW()
      WHERE id = @id 
      RETURNING *;
    ''';
    final result = await RenderDbClient.query(sql, parameters: {'id': rentaId, 'photos': photos});
    if (result.isEmpty) {
      throw Exception('No se pudieron agregar las fotos de recogida');
    }
    return RentaModel.fromMap(result.first);
  }

  Future<RentaModel> addReturnPhotos(String rentaId, List<String> photos) async {
    const sql = '''
      UPDATE public.rentas 
      SET return_photos = @photos, updated_at = NOW()
      WHERE id = @id 
      RETURNING *;
    ''';
    final result = await RenderDbClient.query(sql, parameters: {'id': rentaId, 'photos': photos});
    if (result.isEmpty) {
      throw Exception('No se pudieron agregar las fotos de devolución');
    }
    return RentaModel.fromMap(result.first);
  }
  
}