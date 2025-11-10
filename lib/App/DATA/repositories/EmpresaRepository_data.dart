import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/App/DOMAIN/Entities/empresas_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/EmpresaRepository_domain.dart';
import 'package:ezride/Services/render/render_db_client.dart';

class EmpresarepositoryData implements EmpresaRepositoryDomain {
  EmpresarepositoryData();

  /// 🏢 Crear empresa
@override
Future<Empresas> crearEmpresa(Map<String, dynamic> empresaData) async {
  const sql = '''
    INSERT INTO public.empresas (
      owner_id, nombre, nit, nrc, direccion, telefono, email, latitud, longitud, estado_verificacion, created_at, updated_at
    )
    VALUES (
      @owner_id, @nombre, @nit, @nrc, @direccion, @telefono, @email, @latitud, @longitud, 'pendiente', now(), now()
    )
    RETURNING *;
  ''';

  try {
    print('📥 Inserción de empresa con los datos: $empresaData'); // Imprime los datos que se insertan

    final result = await RenderDbClient.query(sql, parameters: empresaData);
    if (result.isEmpty) {
      throw Exception('No se pudo crear la empresa');
    }

    print('📊 Resultado de la inserción: $result'); // Muestra el resultado de la inserción
    return EmpresasModel.fromMap(result.first);
  } catch (e, stack) {
    print('❌ Error al crear empresa: $e');
    print(stack);
    throw Exception('Error creando empresa: $e');
  }
}

  /// 🔄 Cambiar rol
  @override
  Future<bool> actualizarRolUsuario(String userId, String nuevoRol) async {
    const sql = '''
      UPDATE public.profiles
      SET role = @nuevo_rol, updated_at = now()
      WHERE id = @user_id;
    ''';

    try {
      await RenderDbClient.query(sql, parameters: {
        'nuevo_rol': nuevoRol,
        'user_id': userId,
      });
      return true;
    } catch (e, stack) {
      print('❌ Error actualizando rol de usuario: $e');
      print(stack);
      throw Exception('Error actualizando rol: $e');
    }
  }

  /// 🔍 Obtener empresas del owner
  @override
  Future<List<Empresas>> obtenerEmpresasPorOwner(String ownerId) async {
    const sql = '''
      SELECT *
      FROM public.empresas
      WHERE owner_id = @owner_id;
    ''';

    try {
      final result = await RenderDbClient.query(sql, parameters: {
        'owner_id': ownerId,
      });

      return result.map((row) => EmpresasModel.fromMap(row)).toList();
    } catch (e, stack) {
      print('❌ Error obteniendo empresas por owner: $e');
      print(stack);
      throw Exception('Error obteniendo empresas: $e');
    }
  }


/// 🔄 Actualizar empresa
@override
Future<void> actualizarEmpresa(String empresaId, Map<String, dynamic> campos) async {
  // Construir la parte SET de la consulta
  final setClause = campos.keys.map((key) => '$key = @$key').join(', ');
  final sql = '''
    UPDATE public.empresas
    SET $setClause, updated_at = now()
    WHERE id = @empresaId;
  ''';

  // Parámetros: incluir todos los campos y el empresaId
  final parameters = Map<String, dynamic>.from(campos);
  parameters['empresaId'] = empresaId;

  try {
    await RenderDbClient.query(sql, parameters: parameters);
  } catch (e, stack) {
    print('❌ Error actualizando empresa: $e');
    print(stack);
    throw Exception('Error actualizando empresa: $e');
  }
}


}
