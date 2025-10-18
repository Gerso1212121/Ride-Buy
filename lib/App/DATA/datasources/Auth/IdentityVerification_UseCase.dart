import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/IADocumentAnalisis_Entities.dart';
import 'package:ezride/App/DOMAIN/repositories/Auth/IADocument_RepositoryDomain.dart';
import 'package:ezride/Core/errors/failure.dart';

class IdentityVerificationUseCase {
  final IADocumentRepositoryDomain repository;

  IdentityVerificationUseCase(this.repository);

  Future<Either<Failure, IAAnalisisResultEntities>> call({
    required File duiFront,
    required File duiBack,
    File? selfie,
    String? sourceId,
    String? provider,
  }) async {
    try {
      // 1️⃣ Analizar frontal
      final frontResult = await repository.analyzeDocument(
        duiFront,
        sourceId: sourceId,
        provider: provider,
      );

      // 2️⃣ Analizar trasera
      final backResult = await repository.analyzeDocument(
        duiBack,
        sourceId: sourceId,
        provider: provider,
      );

      // 3️⃣ Verificación facial (opcional)
      if (selfie != null) {
        final faceResult = await repository.verifyFace(
          selfie: selfie,
          duiFront: duiFront,
        );
        print('Resultado verificación facial: $faceResult');
      }

      // Retornamos frontal como principal (puedes combinar datos si quieres)
      return Right(frontResult as IAAnalisisResultEntities);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
