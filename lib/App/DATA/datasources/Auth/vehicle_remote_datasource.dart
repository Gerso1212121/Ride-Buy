import 'package:ezride/App/DATA/models/Vehiculo_model.dart';
import 'package:ezride/Services/render/render_db_client.dart';

class VehicleRemoteDataSource {
  // Método para mapear los nombres de la base de datos al modelo - CORREGIDO
// Método para mapear los nombres de la base de datos al modelo - CORREGIDO
// Método para mapear los nombres de la base de datos al modelo - CORREGIDO
// Método para mapear los nombres de la base de datos al modelo - CON DEBUG
  Map<String, dynamic> _mapRowToModel(Map<String, dynamic> row) {
    // DEBUG para ver qué tipos de datos devuelve PostgreSQL
    print('🔍 DEBUG _mapRowToModel - Tipos de datos recibidos:');
    print(
        '   created_at: ${row['created_at']} (${row['created_at']?.runtimeType})');
    print(
        '   updated_at: ${row['updated_at']} (${row['updated_at']?.runtimeType})');
    print(
        '   circulacion_vence: ${row['circulacion_vence']} (${row['circulacion_vence']?.runtimeType})');
    print(
        '   soa_vence: ${row['soa_vence']} (${row['soa_vence']?.runtimeType})');

    final result = {
      'id': row['id'],
      'empresaId': row['empresa_id'],
      'marca': row['marca'],
      'modelo': row['modelo'],
      'anio': row['anio'],
      'placa': row['placa'],
      'color': row['color'],
      'tipo': row['tipo'],
      'estado': row['estado'],
      'imagen1': row['imagen1'],
      'imagen2': row['imagen2'],
      'titulo': row['titulo'],
      'precioPorDia': _parseDoubleFromRow(row['precio_por_dia']),
      'capacidad': row['capacidad'] ?? 5,
      'transmision': row['transmision'] ?? 'automatica',
      'combustible': row['combustible'] ?? 'gasolina',
      'puertas': row['puertas'] ?? 4,
      'soaNumber': row['soa_number'],
      'circulacionVence': _parseDateTimeFromRow(row['circulacion_vence']),
      'soaVence': _parseDateTimeFromRow(row['soa_vence']),
      'createdAt': _parseDateTimeFromRow(row['created_at']),
      'updatedAt': _parseDateTimeFromRow(row['updated_at']),
    };

    print('🔍 DEBUG _mapRowToModel - Resultado parseado:');
    print(
        '   createdAt: ${result['createdAt']} (${result['createdAt']?.runtimeType})');
    print(
        '   updatedAt: ${result['updatedAt']} (${result['updatedAt']?.runtimeType})');

    return result;
  }

  double _parseDoubleFromRow(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

// ✅ NUEVO: Método auxiliar para parsear DateTime seguro
  DateTime? _parseDateTimeFromRow(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value; // ✅ Ya es DateTime
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Método existente de búsqueda - CORREGIDO
  Future<List<VehicleModel>> searchVehicles({
    required String query,
    String? type,
    String? transmission,
    double? minPrice,
    double? maxPrice,
  }) async {
    const sql = '''
      SELECT 
        id,
        empresa_id,
        marca,
        modelo,
        anio,
        placa,
        color,
        tipo,
        estado,  -- CAMBIADO: de 'status' a 'estado'
        imagen1,
        imagen2,
        titulo,
        precio_por_dia,
        capacidad,
        transmision,
        combustible,
        puertas,
        soa_number,
        circulacion_vence,
        soa_vence,
        created_at,
        updated_at
      FROM vehiculos
      WHERE 
        estado != 'inactivo'  -- CAMBIADO: de 'status' a 'estado'
        AND (
          COALESCE(@q, '') = '' OR
          LOWER(marca) LIKE LOWER('%' || @q || '%') OR
          LOWER(modelo) LIKE LOWER('%' || @q || '%') OR
          LOWER(placa) LIKE LOWER('%' || @q || '%') OR
          LOWER(titulo) LIKE LOWER('%' || @q || '%')  -- Agregado búsqueda por título
        )
        AND (COALESCE(@type::text, '') = '' OR LOWER(tipo) = LOWER(@type))
        AND (COALESCE(@trans::text, '') = '' OR LOWER(transmision) = LOWER(@trans))
        AND (@minPrice::numeric IS NULL OR precio_por_dia >= @minPrice)
        AND (@maxPrice::numeric IS NULL OR precio_por_dia <= @maxPrice)
      ORDER BY created_at DESC
      LIMIT 20;
    ''';

    final rows = await RenderDbClient.query(
      sql,
      parameters: {
        'q': query,
        'type': type?.isEmpty == true ? null : type,
        'trans': transmission?.isEmpty == true ? null : transmission,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
      },
    );

    return rows.map((row) {
      return VehicleModel.fromJson(_mapRowToModel(row));
    }).toList();
  }

  // Crear vehículo - CORREGIDO
// Crear vehículo - CORREGIDO CON MANEJO DE NULOS
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    const sql = '''
    INSERT INTO vehiculos (
      id, empresa_id, marca, modelo, anio, placa, color, tipo,
      estado, imagen1, imagen2, titulo, precio_por_dia, capacidad,
      transmision, combustible, puertas, soa_number,
      circulacion_vence, soa_vence, created_at, updated_at
    ) VALUES (
      @id, @empresa_id, @marca, @modelo, @anio, @placa, @color, @tipo,
      @estado, @imagen1, @imagen2, @titulo, @precio_por_dia, @capacidad,
      @transmision, @combustible, @puertas, @soa_number,
      @circulacion_vence, @soa_vence, @created_at, @updated_at
    ) RETURNING *;
  ''';

    final parameters = {
      'id': vehicle.id.isEmpty ? null : vehicle.id,
      'empresa_id': vehicle.empresaId,
      'marca': vehicle.marca,
      'modelo': vehicle.modelo,
      'anio': vehicle.anio,
      'placa': vehicle.placa,

      // ✅ MANEJAR CAMPOS OPCIONALES QUE PUEDEN SER NULL
      'color': vehicle.color ?? '', // Si es null, usar string vacío
      'tipo': vehicle.tipo ?? '', // Si es null, usar string vacío
      'estado': vehicle.estado,
      'imagen1': vehicle.imagen1 ?? '', // Si es null, usar string vacío
      'imagen2': vehicle.imagen2 ?? '', // Si es null, usar string vacío
      'titulo': vehicle.titulo ?? '', // Si es null, usar string vacío

      'precio_por_dia': vehicle.precioPorDia,
      'capacidad': vehicle.capacidad,
      'transmision': vehicle.transmision,
      'combustible': vehicle.combustible,
      'puertas': vehicle.puertas,
      'soa_number': vehicle.soaNumber ?? '', // Si es null, usar string vacío

      // ✅ MANEJAR FECHAS NULL
      'circulacion_vence': vehicle.circulacionVence?.toIso8601String(),
      'soa_vence': vehicle.soaVence?.toIso8601String(),
      'created_at': vehicle.createdAt.toIso8601String(),
      'updated_at': vehicle.updatedAt.toIso8601String(),
    };

    // DEBUG temporal para verificar parámetros
    print('🔍 DEBUG createVehicle parameters:');
    parameters.forEach((key, value) {
      print('   $key: $value (${value?.runtimeType})');
    });

    try {
      final rows = await RenderDbClient.query(
        sql,
        parameters: parameters,
      );

      if (rows.isEmpty) {
        throw Exception('No se pudo crear el vehículo');
      }

      return VehicleModel.fromJson(_mapRowToModel(rows.first));
    } catch (e) {
      print('❌ Error en createVehicle: $e');
      print('🔍 Stack trace completo: $e');
      rethrow;
    }
  }

// Obtener vehículos por empresa - VERSIÓN MEJORADA Y ROBUSTA
  Future<List<VehicleModel>> getVehiclesByEmpresa(String empresaId) async {
    try {
      print('🏢 INICIANDO: Obteniendo vehículos para empresa: $empresaId');

      // Validar que el empresaId no esté vacío
      if (empresaId.isEmpty) {
        throw Exception('El ID de la empresa no puede estar vacío');
      }

      const sql = '''
      SELECT 
        id,
        empresa_id,
        marca,
        modelo,
        anio,
        placa,
        color,
        tipo,
        estado,
        imagen1,
        imagen2,
        titulo,
        precio_por_dia,
        capacidad,
        transmision,
        combustible,
        puertas,
        soa_number,
        circulacion_vence,
        soa_vence,
        created_at,
        updated_at
      FROM vehiculos 
      WHERE empresa_id = @empresa_id
      ORDER BY 
        CASE estado 
          WHEN 'disponible' THEN 1
          WHEN 'en_renta' THEN 2
          WHEN 'mantenimiento' THEN 3
          WHEN 'inactivo' THEN 4
          ELSE 5
        END,
        created_at DESC;
    ''';

      print('🔍 Ejecutando consulta SQL...');

      final rows = await RenderDbClient.query(
        sql,
        parameters: {'empresa_id': empresaId},
      );

      print(
          '📊 RESULTADO: ${rows.length} vehículos encontrados para empresa $empresaId');

      // DEBUG: Mostrar información de cada vehículo encontrado
      if (rows.isNotEmpty) {
        print('🔍 DETALLE DE VEHÍCULOS ENCONTRADOS:');
        for (int i = 0; i < rows.length; i++) {
          final row = rows[i];
          print('   🚗 Vehículo ${i + 1}:');
          print('      ID: ${row['id']}');
          print('      Título: ${row['titulo']}');
          print('      Marca: ${row['marca']}');
          print('      Modelo: ${row['modelo']}');
          print('      Placa: ${row['placa']}');
          print('      Estado: ${row['estado']}');
          print('      Precio: ${row['precio_por_dia']}');
          print('      Imagen1: ${row['imagen1'] != null ? "✅" : "❌"}');
        }
      }

      // Mapear los resultados usando el método existente _mapRowToModel
      final vehicles = rows.map((row) {
        try {
          return VehicleModel.fromJson(_mapRowToModel(row));
        } catch (e) {
          print('❌ Error mapeando vehículo ${row['id']}: $e');
          rethrow;
        }
      }).toList();

      print('✅ FINALIZADO: ${vehicles.length} vehículos mapeados exitosamente');
      return vehicles;
    } catch (e) {
      print('❌ ERROR CRÍTICO en getVehiclesByEmpresa: $e');
      print('🔍 Stack trace:');
      print(e.toString());

      // Relanzar el error para que la interfaz pueda manejarlo
      rethrow;
    }
  }

// Método auxiliar para mapear las filas de la base de datos
  Map<String, dynamic> _mapRowToJson(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'empresaId': row['empresa_id'],
      'marca': row['marca'],
      'modelo': row['modelo'],
      'anio': row['anio'],
      'placa': row['placa'],
      'color': row['color'],
      'tipo': row['tipo'],
      'estado': row['estado'],
      'imagen1': row['imagen1'],
      'imagen2': row['imagen2'],
      'titulo': row['titulo'],
      'precioPorDia': row['precio_por_dia'],
      'capacidad': row['capacidad'],
      'transmision': row['transmision'],
      'combustible': row['combustible'],
      'puertas': row['puertas'],
      'soaNumber': row['soa_number'],
      'circulacionVence': row['circulacion_vence'],
      'soaVence': row['soa_vence'],
      'createdAt': row['created_at'],
      'updatedAt': row['updated_at'],
    };
  }

  // Obtener vehículo por ID - CORREGIDO
  Future<VehicleModel?> getVehicleById(String id) async {
    const sql = '''
      SELECT 
        id,
        empresa_id,
        marca,
        modelo,
        anio,
        placa,
        color,
        tipo,
        estado,  -- CAMBIADO: de 'status' a 'estado'
        imagen1,
        imagen2,
        titulo,
        precio_por_dia,
        capacidad,
        transmision,
        combustible,
        puertas,
        soa_number,
        circulacion_vence,
        soa_vence,
        created_at,
        updated_at
      FROM vehiculos 
      WHERE id = @id;
    ''';

    final rows = await RenderDbClient.query(
      sql,
      parameters: {'id': id},
    );

    if (rows.isEmpty) return null;

    return VehicleModel.fromJson(_mapRowToModel(rows.first));
  }

  // Actualizar vehículo - CORREGIDO
  Future<VehicleModel> updateVehicle(VehicleModel vehicle) async {
    const sql = '''
      UPDATE vehiculos 
      SET 
        marca = @marca,
        modelo = @modelo,
        anio = @anio,
        placa = @placa,
        color = @color,
        tipo = @tipo,
        estado = @estado,  -- CAMBIADO: de 'status' a 'estado'
        imagen1 = @imagen1,
        imagen2 = @imagen2,
        titulo = @titulo,
        precio_por_dia = @precio_por_dia,
        capacidad = @capacidad,
        transmision = @transmision,
        combustible = @combustible,
        puertas = @puertas,
        soa_number = @soa_number,
        circulacion_vence = @circulacion_vence,
        soa_vence = @soa_vence,
        updated_at = @updated_at
      WHERE id = @id
      RETURNING *;
    ''';

    final parameters = {
      'id': vehicle.id,
      'marca': vehicle.marca,
      'modelo': vehicle.modelo,
      'anio': vehicle.anio,
      'placa': vehicle.placa,
      'color': vehicle.color,
      'tipo': vehicle.tipo,
      'estado': vehicle.estado, // CAMBIADO: usar directamente
      'imagen1': vehicle.imagen1,
      'imagen2': vehicle.imagen2,
      'titulo': vehicle.titulo,
      'precio_por_dia': vehicle.precioPorDia,
      'capacidad': vehicle.capacidad,
      'transmision': vehicle.transmision,
      'combustible': vehicle.combustible,
      'puertas': vehicle.puertas,
      'soa_number': vehicle.soaNumber,
      'circulacion_vence': vehicle.circulacionVence?.toIso8601String(),
      'soa_vence': vehicle.soaVence?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final rows = await RenderDbClient.query(
      sql,
      parameters: parameters,
    );

    if (rows.isEmpty) {
      throw Exception('No se pudo actualizar el vehículo');
    }

    return VehicleModel.fromJson(_mapRowToModel(rows.first));
  }

  // Eliminar vehículo (soft delete) - CORREGIDO
  Future<bool> deleteVehicle(String id) async {
    const sql = '''
      UPDATE vehiculos 
      SET estado = 'inactivo', updated_at = @updated_at  -- CAMBIADO: de 'status' a 'estado'
      WHERE id = @id;
    ''';

    final result = await RenderDbClient.query(
      sql,
      parameters: {
        'id': id,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );

    return result.isNotEmpty;
  }

  // Método para vehículos recomendados
  Future<List<VehicleModel>> getRecommendedVehicles() async {
    return searchVehicles(
      query: '',
      type: null,
      transmission: null,
      minPrice: null,
      maxPrice: null,
    );
  }

    // ✅ MÉTODO PARA VERIFICAR DISPONIBILIDAD DEL VEHÍCULO
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

  // ✅ MÉTODO PARA OBTENER ESTADO ACTUAL DEL VEHÍCULO
  Future<String> getEstadoVehiculo(String vehiculoId) async {
    const sql = '''
      SELECT estado 
      FROM public.vehiculos 
      WHERE id = @vehiculo_id;
    ''';

    final result = await RenderDbClient.query(sql, parameters: {
      'vehiculo_id': vehiculoId,
    });

    if (result.isEmpty) {
      throw Exception('Vehículo no encontrado');
    }

    return result.first['estado'] as String? ?? 'inactivo';
  }

  // ✅ MÉTODO PARA ACTUALIZAR ESTADO DEL VEHÍCULO
  Future<void> actualizarEstadoVehiculo(String vehiculoId, String estado) async {
    const sql = '''
      UPDATE public.vehiculos 
      SET estado = @estado, updated_at = NOW()
      WHERE id = @vehiculo_id;
    ''';

    await RenderDbClient.query(sql, parameters: {
      'vehiculo_id': vehiculoId,
      'estado': estado,
    });

    print('✅ Estado del vehículo actualizado: $vehiculoId -> $estado');
  }

//METODÓ PARA VEHÍCULOS DISPONIBLES
  Future<List<Map<String, dynamic>>> getVehiculosDisponibles() async {
  const sql = '''
    SELECT 
      v.*,
      e.nombre as empresa_nombre
    FROM public.vehiculos v
    JOIN public.empresas e ON v.empresa_id = e.id
    WHERE v.estado = 'disponible'
    ORDER BY v.created_at DESC;
  ''';

  final result = await RenderDbClient.query(sql);
  return result;
}

}
