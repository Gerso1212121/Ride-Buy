import 'package:ezride/App/DATA/models/Vehiculo_model.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Services/render/render_db_client.dart';

class VehicleRemoteDataSource {
  // Método existente de búsqueda
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
        titulo,
        marca,
        modelo,
        anio,
        placa,
        precio_por_dia,
        status,
        transmision,
        combustible,
        capacidad,
        puertas,
        multas_pendientes,
        telemetria_enabled,
        created_at,
        updated_at
      FROM vehiculos
      WHERE 
        (
          COALESCE(@q, '') = '' OR
          LOWER(titulo) LIKE LOWER('%' || @q || '%') OR
          LOWER(marca) LIKE LOWER('%' || @q || '%') OR
          LOWER(modelo) LIKE LOWER('%' || @q || '%')
        )
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
        'trans': transmission?.isEmpty == true ? null : transmission,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
      },
    );

    return rows.map((row) {
      return VehicleModel.fromMap(row);
    }).toList();
  }

  // NUEVO: Crear vehículo
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    const sql = '''
      INSERT INTO vehiculos (
        id, empresa_id, titulo, marca, modelo, anio, placa,
        precio_por_dia, status, capacidad, transmision, combustible,
        kilometraje, color, puertas, dueno_actual, soa_number,
        circulacion_vence, soa_vence, multas_pendientes, gps_device_id,
        insurance_provider, telemetria_enabled, telemetria_tracker_id,
        imagen1, imagen2
      ) VALUES (
        @id, @empresa_id, @titulo, @marca, @modelo, @anio, @placa,
        @precio_por_dia, @status, @capacidad, @transmision, @combustible,
        @kilometraje, @color, @puertas, @dueno_actual, @soa_number,
        @circulacion_vence, @soa_vence, @multas_pendientes, @gps_device_id,
        @insurance_provider, @telemetria_enabled, @telemetria_tracker_id,
        @imagen1, @imagen2
      ) RETURNING *;
    ''';

    final rows = await RenderDbClient.query(
      sql,
      parameters: vehicle.toMap(),
    );

    if (rows.isEmpty) {
      throw Exception('No se pudo crear el vehículo');
    }

    return VehicleModel.fromMap(rows.first);
  }

  // NUEVO: Obtener vehículos por empresa
  Future<List<VehicleModel>> getVehiclesByEmpresa(String empresaId) async {
    const sql = '''
      SELECT * FROM vehiculos 
      WHERE empresa_id = @empresaId
      ORDER BY created_at DESC;
    ''';

    final rows = await RenderDbClient.query(
      sql,
      parameters: {'empresaId': empresaId},
    );

    return rows.map((row) => VehicleModel.fromMap(row)).toList();
  }

  Future<List<VehicleModel>> getRecommendedVehicles() async {
    return searchVehicles(
      query: '',
      type: null,
      transmission: null,
      minPrice: null,
      maxPrice: null,
    );
  }
}
