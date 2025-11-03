import 'package:ezride/App/DOMAIN/Entities/vehicle_entity.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Services/render/render_db_client.dart';

class VehicleRemoteDataSource {
  Future<List<Vehicle>> searchVehicles({
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
      return Vehicle(
        id: row['id'],
        empresaId: row['empresa_id'],
        titulo: row['titulo'],
        marca: row['marca'],
        modelo: row['modelo'],
        year: row['anio'],
        placa: row['placa'],
        precioPorDia: double.parse(row['precio_por_dia'].toString()),
        status: VehicleStatus.values.firstWhere(
          (e) => e.name == row['status'],
          orElse: () => VehicleStatus.disponible,
        ),
        transmision: row['transmision'],
        combustible: row['combustible'],
        capacidad: row['capacidad'],
        puertas: row['puertas'],
        multasPendientes: row['multas_pendientes'],
        telemetriaEnabled: row['telemetria_enabled'],
        createdAt: row['created_at'],
        updatedAt: row['updated_at'],
      );
    }).toList();
  }

  Future<List<Vehicle>> getRecommendedVehicles() async {
    return searchVehicles(
      query: '',
      type: null,
      transmission: null,
      minPrice: null,
      maxPrice: null,
    );
  }
}
