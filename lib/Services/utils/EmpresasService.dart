// lib/Services/utils/EmpresasService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ezride/Services/render/render_db_client.dart';
import 'dart:math' as math;

class EmpresasService {
  // ✅ BUSCAR EMPRESAS - VERSIÓN MÍNIMA
  static Future<List<dynamic>> searchEmpresas(String searchText) async {
    try {
      print('🔍 Buscando empresas con texto: "$searchText"');

      final result = await RenderDbClient.query('''
      SELECT *
      FROM public.empresas 
      WHERE LOWER(nombre) LIKE LOWER(@search_pattern)
      ORDER BY nombre
    ''', parameters: {'search_pattern': '%$searchText%'});

      print('📊 Empresas encontradas: ${result.length}');
      return result;
    } catch (e) {
      print('❌ Error buscando empresas: $e');
      return [];
    }
  }

  // ✅ OBTENER TODAS LAS EMPRESAS
  static Future<List<dynamic>> getAllEmpresas() async {
    try {
      final result = await RenderDbClient.query('''
      SELECT * FROM public.empresas ORDER BY nombre
    ''');
      return result;
    } catch (e) {
      print('❌ Error obteniendo empresas: $e');
      return [];
    }
  }

  // ✅ OBTENER EMPRESA POR ID - CORREGIDO
  static Future<Map<String, dynamic>?> getEmpresaById(String id) async {
    try {
      print('🔍 Obteniendo empresa por ID: $id');

      final result = await RenderDbClient.query('''
        SELECT 
          id,
          nombre,
          direccion,
          telefono,
          email,
          latitud,
          longitud,
          imagen_perfil,
          imagen_banner,
          estado_verificacion,
          owner_id,
          nit,
          nrc,
          created_at,
          updated_at
        FROM public.empresas 
        WHERE id = @id
      ''', parameters: {'id': id});

      if (result.isNotEmpty) {
        print('✅ Empresa encontrada: ${result[0]['nombre']}');
        return result[0];
      } else {
        print('⚠️ Empresa no encontrada con ID: $id');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo empresa por ID: $e');
      return null;
    }
  }

  // ✅ OBTENER EMPRESAS CERCANAS CON DISTANCIA CALCULADA
  static Future<List<dynamic>> getEmpresasCercanas(
      double userLat, double userLng,
      {double radioKm = 50}) async {
    try {
      print('📍 Buscando empresas cercanas a ($userLat, $userLng) en radio de $radioKm km');

      final empresas = await getAllEmpresas();

      final empresasConCoordenadas = empresas.where((empresa) {
        return empresa['latitud'] != null && empresa['longitud'] != null;
      }).toList();

      print('📊 Empresas con coordenadas: ${empresasConCoordenadas.length}');

      final empresasConDistancia = <Map<String, dynamic>>[];

      for (var empresa in empresasConCoordenadas) {
        try {
          final distancia = await _calcularDistancia(userLat, userLng,
              empresa['latitud'] as double, empresa['longitud'] as double);

          if (distancia <= radioKm) {
            empresasConDistancia.add({
              ...empresa,
              'distancia': distancia,
            });
          }
        } catch (e) {
          print('⚠️ Error calculando distancia para empresa ${empresa['nombre']}: $e');
        }
      }

      empresasConDistancia.sort((a, b) {
        final distA = a['distancia'] ?? double.infinity;
        final distB = b['distancia'] ?? double.infinity;
        return distA.compareTo(distB);
      });

      print('🎯 Empresas dentro del radio: ${empresasConDistancia.length}');
      return empresasConDistancia;
    } catch (e) {
      print('❌ Error obteniendo empresas cercanas: $e');
      return [];
    }
  }

  // ✅ CALCULAR DISTANCIA ENTRE DOS PUNTOS (Fórmula Haversine) - PRIVADA
  static Future<double> _calcularDistancia(
      double lat1, double lng1, double lat2, double lng2) async {
    try {
      const radioTierra = 6371.0;

      final dLat = _toRadians(lat2 - lat1);
      final dLng = _toRadians(lng2 - lng1);

      final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(_toRadians(lat1)) *
              math.cos(_toRadians(lat2)) *
              math.sin(dLng / 2) *
              math.sin(dLng / 2);

      final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      final distancia = radioTierra * c;

      return distancia;
    } catch (e) {
      print('❌ Error en cálculo de distancia: $e');
      return double.infinity;
    }
  }

  // ✅ CONVERTIR GRADOS A RADIANES
  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  // ✅ OBTENER ESTADÍSTICAS DE EMPRESA - CORREGIDO (SIN TABLA RESENAS)
  static Future<Map<String, dynamic>> getEstadisticasEmpresa(String empresaId) async {
    try {
      print('📊 Obteniendo estadísticas para empresa: $empresaId');

      // Total de vehículos
      final vehiculosResult = await RenderDbClient.query('''
        SELECT COUNT(*) as total_vehiculos
        FROM public.vehiculos 
        WHERE empresa_id = @empresaId
      ''', parameters: {'empresaId': empresaId});

      // Vehículos disponibles
      final disponiblesResult = await RenderDbClient.query('''
        SELECT COUNT(*) as vehiculos_disponibles
        FROM public.vehiculos 
        WHERE empresa_id = @empresaId AND estado = 'disponible'
      ''', parameters: {'empresaId': empresaId});

      // ✅ CORREGIDO: No consultar tabla resenas que no existe
      // Usar valores por defecto para rating y reseñas
      final totalVehiculos = vehiculosResult[0]['total_vehiculos'] ?? 0;
      final vehiculosDisponibles = disponiblesResult[0]['vehiculos_disponibles'] ?? 0;

      // Calcular rating basado en disponibilidad (temporal)
      final ratingBase = 4.0;
      final ratingBonus = (vehiculosDisponibles / (totalVehiculos == 0 ? 1 : totalVehiculos)) * 1.0;
      final ratingPromedio = (ratingBase + ratingBonus).clamp(1.0, 5.0);

      return {
        'total_vehiculos': totalVehiculos,
        'vehiculos_disponibles': vehiculosDisponibles,
        'rating_promedio': ratingPromedio,
        'total_resenas': 0, // Por ahora 0 hasta que tengamos la tabla
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return {
        'total_vehiculos': 0,
        'vehiculos_disponibles': 0,
        'rating_promedio': 4.0,
        'total_resenas': 0,
      };
    }
  }

  // ✅ OBTENER SERVICIOS ADICIONALES DE EMPRESA
  static Future<List<Map<String, dynamic>>> getServiciosAdicionales(String empresaId) async {
    try {
      return [
        {
          'nombre': 'Entrega a domicilio',
          'icono': 'local_shipping',
          'descripcion': 'Llevamos el vehículo hasta tu ubicación'
        },
        {
          'nombre': 'Seguro incluido',
          'icono': 'security',
          'descripcion': 'Protección completa durante la renta'
        },
        {
          'nombre': 'Asistencia 24/7',
          'icono': 'support_agent',
          'descripcion': 'Soporte técnico disponible todo el día'
        },
        {
          'nombre': 'Limpieza incluida',
          'icono': 'clean_hands',
          'descripcion': 'Vehículo limpio y desinfectado'
        },
      ];
    } catch (e) {
      print('❌ Error obteniendo servicios: $e');
      return [];
    }
  }

  // ✅ OBTENER POLÍTICAS DE RENTA
  static Future<List<String>> getPoliticasRenta(String empresaId) async {
    try {
      return [
        'Edad mínima: 21 años',
        'Licencia de conducir vigente requerida',
        'Depósito de seguridad reembolsable',
        'Kilometraje ilimitado',
        'Combustible por cuenta del cliente',
        'Prohibido fumar en el vehículo',
        'Mascotas permitidas con cargo adicional',
        'Cancelación gratuita hasta 24 horas antes',
      ];
    } catch (e) {
      print('❌ Error obteniendo políticas: $e');
      return [];
    }
  }

  // ✅ OBTENER RESEÑAS RECIENTES
  static Future<List<Map<String, dynamic>>> getResenasRecientes(String empresaId) async {
    try {
      // Por ahora retornamos lista vacía hasta que tengamos la tabla
      return [];
    } catch (e) {
      print('❌ Error obteniendo reseñas: $e');
      return [];
    }
  }

  // ✅ PERFIL COMPLETO DE EMPRESA - CORREGIDO
  static Future<Map<String, dynamic>> getEmpresaProfileData(String empresaId) async {
    try {
      print('🏢 Obteniendo perfil completo de empresa: $empresaId');

      final empresa = await getEmpresaById(empresaId);
      if (empresa == null) {
        throw Exception('Empresa no encontrada');
      }

      // Cargar datos en paralelo para mejor rendimiento
      final resultados = await Future.wait([
        getEstadisticasEmpresa(empresaId),
        getServiciosAdicionales(empresaId),
        getPoliticasRenta(empresaId),
        getResenasRecientes(empresaId),
      ], eagerError: false);

      final estadisticas = resultados[0] as Map<String, dynamic>;
      final servicios = resultados[1] as List<Map<String, dynamic>>;
      final politicas = resultados[2] as List<String>;
      final resenas = resultados[3] as List<Map<String, dynamic>>;

      return {
        'empresa': empresa, // ✅ Esto es un Map<String, dynamic>, no EmpresasModel
        ...estadisticas,
        'servicios_adicionales': servicios,
        'politicas_renta': politicas,
        'reseñas_recientes': resenas,
      };
    } catch (e) {
      print('❌ Error obteniendo perfil de empresa: $e');
      rethrow;
    }
  }
}