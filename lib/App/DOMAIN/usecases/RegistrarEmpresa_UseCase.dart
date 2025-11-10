import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/App/DOMAIN/repositories/EmpresaRepository_domain.dart';
import 'package:ezride/Services/api/s3_service.dart';
import 'dart:io';

class RegistrarEmpresaUseCase {
  final EmpresaRepositoryDomain repository;

  RegistrarEmpresaUseCase(this.repository);

  Future<EmpresasModel> execute({
    required String ownerId,
    required String nombre,
    required String nit,
    required String nrc,
    required String direccion,
    required String telefono,
    String? email,
    required double latitud,
    required double longitud,
    File? imagePerfil,
    File? imageBanner,
  }) async {
    try {
      print('🚀 [USECASE] Iniciando registro de empresa para owner: $ownerId');

      // 1. Crear la empresa en el repositorio (retorna una instancia de Empresas)
      print('📝 [USECASE] Creando empresa en base de datos...');
      final empresa = await repository.crearEmpresa({
        'owner_id': ownerId,
        'nombre': nombre,
        'nit': nit,
        'nrc': nrc,
        'direccion': direccion,
        'telefono': telefono,
        'email': email ?? '',
        'latitud': latitud,
        'longitud': longitud,
      });

      print('✅ [USECASE] Empresa creada en BD con ID: ${empresa.id}');
      print('📊 [USECASE] Datos empresa creada:');
      print('   - Nombre: ${empresa.nombre}');
      print('   - NIT: ${empresa.nit}');
      print('   - Imagen Perfil actual: ${empresa.imagenPerfil}');
      print('   - Imagen Banner actual: ${empresa.imagenBanner}');

      String? keyPerfil;
      String? keyBanner;

      // 2. Subir imagen de perfil si existe
      if (imagePerfil != null) {
        print('📤 [USECASE] Subiendo imagen de perfil...');
        print('📁 [USECASE] Ruta archivo perfil: ${imagePerfil.path}');
        print('📏 [USECASE] Tamaño archivo perfil: ${await imagePerfil.length()} bytes');
        
        try {
          final uploadResult = await S3Service.uploadImage(
            imageFile: imagePerfil,
            fileName: 'perfil_${empresa.id}.jpg',
            folder: 'empresa/${empresa.id}',
            quality: 75,
          );
          
          print('📊 [USECASE] Resultado S3 perfil: $uploadResult');
          keyPerfil = uploadResult['key'];
          print('✅ [USECASE] Imagen de perfil subida. Key: $keyPerfil');
          
          // Obtener signed URL para verificar
          if (keyPerfil != null) {
            try {
              final signedUrl = await S3Service.getSignedUrl(keyPerfil);
              print('🔗 [USECASE] Signed URL perfil: $signedUrl');
            } catch (e) {
              print('⚠️ [USECASE] No se pudo obtener signed URL: $e');
            }
          }
        } catch (e) {
          print('❌ [USECASE] ERROR subiendo imagen de perfil: $e');
          rethrow;
        }
      } else {
        print('⚠️ [USECASE] No hay imagen de perfil para subir');
      }

      // 3. Subir imagen de banner si existe
      if (imageBanner != null) {
        print('📤 [USECASE] Subiendo imagen de banner...');
        print('📁 [USECASE] Ruta archivo banner: ${imageBanner.path}');
        print('📏 [USECASE] Tamaño archivo banner: ${await imageBanner.length()} bytes');
        
        try {
          final uploadResult = await S3Service.uploadImage(
            imageFile: imageBanner,
            fileName: 'banner_${empresa.id}.jpg',
            folder: 'empresa/${empresa.id}',
            quality: 80,
          );
          
          print('📊 [USECASE] Resultado S3 banner: $uploadResult');
          keyBanner = uploadResult['key'];
          print('✅ [USECASE] Imagen de banner subida. Key: $keyBanner');
          
          if (keyBanner != null) {
            try {
              final signedUrl = await S3Service.getSignedUrl(keyBanner);
              print('🔗 [USECASE] Signed URL banner: $signedUrl');
            } catch (e) {
              print('⚠️ [USECASE] No se pudo obtener signed URL banner: $e');
            }
          }
        } catch (e) {
          print('❌ [USECASE] ERROR subiendo imagen de banner: $e');
          // No rethrow aquí para que continúe con el proceso
        }
      } else {
        print('⚠️ [USECASE] No hay imagen de banner para subir');
      }

      // 4. Actualizar empresa con las keys de las imágenes
      if (keyPerfil != null || keyBanner != null) {
        print('🔄 [USECASE] Actualizando empresa con URLs de imágenes...');
        final updateData = <String, dynamic>{};
        if (keyPerfil != null) {
          updateData['imagen_perfil'] = keyPerfil;
          print('   - imagen_perfil: $keyPerfil');
        }
        if (keyBanner != null) {
          updateData['imagen_banner'] = keyBanner;
          print('   - imagen_banner: $keyBanner');
        }
        
        print('📝 [USECASE] Datos para actualizar: $updateData');
        
        try {
          await repository.actualizarEmpresa(empresa.id, updateData);
          print('✅ [USECASE] Empresa actualizada con imágenes en BD');
        } catch (e) {
          print('❌ [USECASE] ERROR actualizando empresa en BD: $e');
          rethrow;
        }
      } else {
        print('⚠️ [USECASE] No hay imágenes para actualizar en BD');
      }

      // 5. Actualizar el rol del usuario
      print('🔄 [USECASE] Actualizando rol del usuario a empresario...');
      try {
        await repository.actualizarRolUsuario(ownerId, 'empresario');
        print('✅ [USECASE] Rol actualizado a empresario');
      } catch (e) {
        print('❌ [USECASE] ERROR actualizando rol: $e');
        rethrow;
      }

      // 6. Crear el modelo final con los datos actualizados
      print('🏗️ [USECASE] Creando modelo final de empresa...');
      final empresaModel = EmpresasModel(
        id: empresa.id,
        ownerId: empresa.ownerId,
        nombre: empresa.nombre,
        nit: empresa.nit ?? '',
        nrc: empresa.nrc ?? '', 
        direccion: empresa.direccion ?? '',
        telefono: empresa.telefono ?? '',
        email: empresa.email ?? '',
        latitud: (empresa.latitud ?? 0).toDouble(),
        longitud: (empresa.longitud ?? 0).toDouble(),
        imagenPerfil: keyPerfil ?? empresa.imagenPerfil,
        imagenBanner: keyBanner ?? empresa.imagenBanner,
        verificationStatus: empresa.verificationStatus,
        createdAt: empresa.createdAt,
        updatedAt: empresa.updatedAt,
      );

      print('🎉 [USECASE] Registro de empresa completado exitosamente');
      print('📋 [USECASE] RESUMEN FINAL:');
      print('   - ID: ${empresaModel.id}');
      print('   - Nombre: ${empresaModel.nombre}');
      print('   - Imagen Perfil: ${empresaModel.imagenPerfil}');
      print('   - Imagen Banner: ${empresaModel.imagenBanner}');
      print('   - Estado: ${empresaModel.verificationStatus}');

      return empresaModel;

    } catch (e) {
      print('❌ [USECASE] Error crítico en RegistrarEmpresaUseCase: $e');
      print('🔍 [USECASE] Stack trace completo:');
      print(e);
      rethrow;
    }
  }
}