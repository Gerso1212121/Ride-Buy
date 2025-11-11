// test_empresas_service.dart
import 'dart:io';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:ezride/Services/utils/EmpresasService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  try {
    // Cargar variables de entorno y conectar a la DB
    await dotenv.load(fileName: ".env");
    await RenderDbClient.init();
    
    print('🚀 INICIANDO PRUEBAS DE EmpresasService CON DATOS REALES\n');

    // ===========================================================
    // TEST 1: OBTENER TODAS LAS EMPRESAS
    // ===========================================================
    print('1. 📊 Probando getAllEmpresas()...');
    final todasEmpresas = await EmpresasService.getAllEmpresas();
    print('   ✅ Total de empresas en DB: ${todasEmpresas.length}');
    
    if (todasEmpresas.isNotEmpty) {
      for (var empresa in todasEmpresas.take(3)) { // Mostrar solo las primeras 3
        print('      - ${empresa['nombre']} (ID: ${empresa['id']})');
      }
      if (todasEmpresas.length > 3) {
        print('      ... y ${todasEmpresas.length - 3} más');
      }
    } else {
      print('      ⚠️ No hay empresas en la base de datos');
    }

    // ===========================================================
    // TEST 2: BUSCAR EMPRESAS
    // ===========================================================
    print('\n2. 🔍 Probando searchEmpresas()...');
    final empresasEncontradas = await EmpresasService.searchEmpresas('auto');
    print('   ✅ Empresas encontradas con "auto": ${empresasEncontradas.length}');
    
    if (empresasEncontradas.isNotEmpty) {
      for (var empresa in empresasEncontradas) {
        print('      - ${empresa['nombre']}');
      }
    }

    // ===========================================================
    // TEST 3: OBTENER EMPRESA POR ID (usando un ID real de tu DB)
    // ===========================================================
    if (todasEmpresas.isNotEmpty) {
      final primeraEmpresaId = todasEmpresas[0]['id'];
      print('\n3. 🆔 Probando getEmpresaById() con ID: $primeraEmpresaId');
      
      final empresa = await EmpresasService.getEmpresaById(primeraEmpresaId);
      if (empresa != null) {
        print('   ✅ Empresa encontrada:');
        print('      Nombre: ${empresa['nombre']}');
        print('      Email: ${empresa['email']}');
        print('      Teléfono: ${empresa['telefono']}');
        print('      Dirección: ${empresa['direccion']}');
        print('      Estado: ${empresa['estado_verificacion']}');
        if (empresa['latitud'] != null && empresa['longitud'] != null) {
          print('      Ubicación: (${empresa['latitud']}, ${empresa['longitud']})');
        }
      } else {
        print('   ❌ Empresa no encontrada');
      }
    }

    // ===========================================================
    // TEST 4: EMPRESAS CERCANAS (usando coordenadas de Guatemala)
    // ===========================================================
    print('\n4. 📍 Probando getEmpresasCercanas()...');
    // Coordenadas del centro de Guatemala City
    final guatemalaLat = 14.6349;
    final guatemalaLng = -90.5069;
    
    final empresasCercanas = await EmpresasService.getEmpresasCercanas(
      guatemalaLat, 
      guatemalaLng, 
      radioKm: 50.0
    );
    
    print('   ✅ Empresas cercanas encontradas: ${empresasCercanas.length}');
    
    if (empresasCercanas.isNotEmpty) {
      for (var empresa in empresasCercanas.take(5)) {
        final distancia = empresa['distancia']?.toStringAsFixed(2) ?? 'N/A';
        print('      - ${empresa['nombre']} (${distancia} km)');
      }
    }

    // ===========================================================
    // TEST 5: ESTADÍSTICAS DE EMPRESA
    // ===========================================================
    if (todasEmpresas.isNotEmpty) {
      final empresaId = todasEmpresas[0]['id'];
      print('\n5. 📈 Probando getEstadisticasEmpresa()...');
      
      final estadisticas = await EmpresasService.getEstadisticasEmpresa(empresaId);
      print('   ✅ Estadísticas obtenidas:');
      print('      Total vehículos: ${estadisticas['total_vehiculos']}');
      print('      Vehículos disponibles: ${estadisticas['vehiculos_disponibles']}');
      print('      Rating promedio: ${estadisticas['rating_promedio']}');
      print('      Total reseñas: ${estadisticas['total_resenas']}');
    }

    // ===========================================================
    // TEST 6: PERFIL COMPLETO DE EMPRESA
    // ===========================================================
    if (todasEmpresas.isNotEmpty) {
      final empresaId = todasEmpresas[0]['id'];
      print('\n6. 🏢 Probando getEmpresaProfileData()...');
      
      try {
        final perfilCompleto = await EmpresasService.getEmpresaProfileData(empresaId);
        print('   ✅ Perfil completo obtenido exitosamente');
        print('      Empresa: ${perfilCompleto['empresa']['nombre']}');
        print('      Servicios adicionales: ${perfilCompleto['servicios_adicionales']?.length ?? 0}');
        print('      Políticas de renta: ${perfilCompleto['politicas_renta']?.length ?? 0}');
        print('      Reseñas recientes: ${perfilCompleto['reseñas_recientes']?.length ?? 0}');
      } catch (e) {
        print('   ❌ Error obteniendo perfil completo: $e');
      }
    }

    // ===========================================================
    // TEST 7: SERVICIOS ADICIONALES
    // ===========================================================
    if (todasEmpresas.isNotEmpty) {
      final empresaId = todasEmpresas[0]['id'];
      print('\n7. 🛠️ Probando getServiciosAdicionales()...');
      
      final servicios = await EmpresasService.getServiciosAdicionales(empresaId);
      print('   ✅ Servicios obtenidos: ${servicios.length}');
      for (var servicio in servicios) {
        print('      - ${servicio['nombre']}');
      }
    }

    // ===========================================================
    // TEST 8: CÁLCULO DE DISTANCIA
    // ===========================================================
    print('\n8. 📏 Probando cálculo de distancia...');
    // Distancia entre dos puntos en Guatemala City
    final puntoA = [14.6349, -90.5069]; // Centro
    final puntoB = [14.6359, -90.5159]; // Zona 10 (aprox 1km)
    
    final distancia = await EmpresasService.calcularDistancia(
      puntoA[0], puntoA[1], 
      puntoB[0], puntoB[1]
    );
    
    print('   ✅ Distancia calculada: ${distancia.toStringAsFixed(2)} km');
    print('      Entre (${puntoA[0]}, ${puntoA[1]}) y (${puntoB[0]}, ${puntoB[1]})');

    print('\n🎉 TODAS LAS PRUEBAS COMPLETADAS EXITOSAMENTE!');

  } catch (e, stack) {
    print('\n❌ ERROR DURANTE LAS PRUEBAS: $e');
    print('Stack trace: $stack');
  } finally {
    await RenderDbClient.close();
    print('\n🔒 Conexión a la base de datos cerrada.');
    exit(0);
  }
}