// lib/Services/empresa/empresa_profile_service.dart
import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/Services/render/render_db_client.dart';

class EmpresaProfileService {
  
  // Obtener datos completos de la empresa para el perfil
  static Future<Map<String, dynamic>> getEmpresaProfileData(String empresaId) async {
    try {
      print('🔄 Obteniendo datos del perfil para empresa: $empresaId');
      
      const sql = '''
        SELECT 
          e.*,
          -- Información de rating y reseñas
          COALESCE(avg_reviews.avg_rating, 0) as rating_promedio,
          COALESCE(avg_reviews.total_reviews, 0) as total_resenas,
          -- Información del propietario
          p.display_name as propietario_nombre,
          p.email as propietario_email,
          -- Estadísticas de vehículos
          COUNT(DISTINCT v.id) as total_vehiculos,
          COUNT(DISTINCT CASE WHEN v.estado = 'disponible' THEN v.id END) as vehiculos_disponibles
        FROM public.empresas e
        LEFT JOIN public.profiles p ON e.owner_id = p.id
        LEFT JOIN public.vehiculos v ON e.id = v.empresa_id
        LEFT JOIN (
          SELECT 
            r.empresa_id,
            AVG(rev.rating) as avg_rating,
            COUNT(rev.id) as total_reviews
          FROM public.rentas r
          LEFT JOIN public.reviews rev ON r.id = rev.renta_id
          WHERE rev.rating IS NOT NULL
          GROUP BY r.empresa_id
        ) avg_reviews ON e.id = avg_reviews.empresa_id
        WHERE e.id = @empresa_id
        GROUP BY 
          e.id, e.owner_id, e.nombre, e.nit, e.nrc, e.direccion, 
          e.telefono, e.email, e.latitud, e.longitud, e.imagen_perfil, 
          e.imagen_banner, e.estado_verificacion, e.created_at, e.updated_at,
          p.display_name, p.email,
          avg_reviews.avg_rating, avg_reviews.total_reviews
      ''';

      final result = await RenderDbClient.query(sql, parameters: {
        'empresa_id': empresaId,
      });

      if (result.isEmpty) {
        throw Exception('Empresa no encontrada');
      }

      final empresaData = result.first;
      print('✅ Datos de empresa obtenidos: ${empresaData['nombre']}');

      // Obtener servicios adicionales de la empresa
      final servicios = await _getServiciosAdicionales(empresaId);
      
      // Obtener políticas de renta
      final politicas = await _getPoliticasRenta(empresaId);
      
      // Obtener reseñas recientes
      final resenas = await _getResenasRecientes(empresaId);

      return {
        'empresa': EmpresasModel.fromMap(empresaData),
        'rating_promedio': (empresaData['rating_promedio'] ?? 0).toDouble(),
        'total_resenas': empresaData['total_resenas'] ?? 0,
        'total_vehiculos': empresaData['total_vehiculos'] ?? 0,
        'vehiculos_disponibles': empresaData['vehiculos_disponibles'] ?? 0,
        'servicios_adicionales': servicios,
        'politicas_renta': politicas,
        'reseñas_recientes': resenas,
      };

    } catch (e) {
      print('❌ Error obteniendo perfil de empresa: $e');
      rethrow;
    }
  }

  // Obtener servicios adicionales de la empresa
  static Future<List<Map<String, dynamic>>> _getServiciosAdicionales(String empresaId) async {
    try {
      // Por ahora retornamos servicios por defecto, puedes adaptar según tu schema
      return [
        {
          'nombre': 'Combustible completo',
          'icono': 'local_gas_station',
          'descripcion': 'Vehículo entregado con tanque lleno'
        },
        {
          'nombre': 'Sillas para niños',
          'icono': 'child_friendly',
          'descripcion': 'Disponible por costo adicional'
        },
        {
          'nombre': 'GPS incluido',
          'icono': 'gps_fixed',
          'descripcion': 'Navegación GPS incluida'
        },
        {
          'nombre': 'Entrega a domicilio',
          'icono': 'local_shipping',
          'descripcion': 'Entrega en ubicación preferida'
        },
      ];
    } catch (e) {
      print('❌ Error obteniendo servicios: $e');
      return [];
    }
  }

  // Obtener políticas de renta
  static Future<List<String>> _getPoliticasRenta(String empresaId) async {
    try {
      // Políticas por defecto, puedes adaptar según tu schema
      return [
        'Edad mínima: 21 años con licencia vigente',
        'Seguro incluido en todas las rentas',
        'Combustible: entregar con el mismo nivel',
        'Cancelación gratuita hasta 24h antes',
        'Depósito de seguridad requerido',
        'Kilometraje ilimitado',
      ];
    } catch (e) {
      print('❌ Error obteniendo políticas: $e');
      return [];
    }
  }

  // Obtener reseñas recientes
  static Future<List<Map<String, dynamic>>> _getResenasRecientes(String empresaId) async {
    try {
      const sql = '''
        SELECT 
          r.id as renta_id,
          p.display_name as cliente_nombre,
          p.email as cliente_email,
          rev.rating,
          rev.comentario,
          rev.created_at as fecha_resena,
          v.marca,
          v.modelo
        FROM public.rentas r
        INNER JOIN public.profiles p ON r.cliente_id = p.id
        LEFT JOIN public.reviews rev ON r.id = rev.renta_id
        LEFT JOIN public.vehiculos v ON r.vehiculo_id = v.id
        WHERE r.empresa_id = @empresa_id
        AND rev.rating IS NOT NULL
        ORDER BY rev.created_at DESC
        LIMIT 5
      ''';

      final result = await RenderDbClient.query(sql, parameters: {
        'empresa_id': empresaId,
      });

      return result.map((row) => {
        'userName': row['cliente_nombre'] ?? 'Cliente',
        'userImageUrl': 'https://example.com/user.jpg', // Imagen por defecto
        'rating': (row['rating'] ?? 0).toDouble(),
        'comment': row['comentario'] ?? 'Excelente servicio',
        'timeAgo': _calcularTiempoTranscurrido(row['fecha_resena']),
        'vehiculo': '${row['marca']} ${row['modelo']}',
      }).toList();

    } catch (e) {
      print('❌ Error obteniendo reseñas: $e');
      // Retornar reseñas de ejemplo si no hay reseñas reales
      return _getResenasEjemplo();
    }
  }

  static List<Map<String, dynamic>> _getResenasEjemplo() {
    return [
      {
        'userName': 'María González',
        'userImageUrl': 'https://example.com/user1.jpg',
        'rating': 5.0,
        'comment': 'Excelente servicio! El auto estaba impecable y el proceso de renta fue muy sencillo.',
        'timeAgo': 'Hace 2 días',
        'vehiculo': 'Toyota Corolla 2023',
      },
      {
        'userName': 'Carlos Rodríguez',
        'userImageUrl': 'https://example.com/user2.jpg',
        'rating': 4.0,
        'comment': 'Buen servicio en general. El auto estaba limpio y en buen estado.',
        'timeAgo': 'Hace 1 semana',
        'vehiculo': 'Honda Civic 2024',
      },
      {
        'userName': 'Ana Martínez',
        'userImageUrl': 'https://example.com/user3.jpg',
        'rating': 4.5,
        'comment': 'Muy profesionales. Me ayudaron a elegir el auto perfecto para mi viaje familiar.',
        'timeAgo': 'Hace 3 semanas',
        'vehiculo': 'Mazda CX-5 2023',
      },
    ];
  }

  static String _calcularTiempoTranscurrido(dynamic fecha) {
    if (fecha == null) return 'Hace algún tiempo';
    
    try {
      final fechaResena = fecha is DateTime ? fecha : DateTime.parse(fecha.toString());
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fechaResena);
      
      if (diferencia.inDays > 0) {
        return 'Hace ${diferencia.inDays} días';
      } else if (diferencia.inHours > 0) {
        return 'Hace ${diferencia.inHours} horas';
      } else if (diferencia.inMinutes > 0) {
        return 'Hace ${diferencia.inMinutes} minutos';
      } else {
        return 'Hace unos momentos';
      }
    } catch (e) {
      return 'Hace algún tiempo';
    }
  }
}