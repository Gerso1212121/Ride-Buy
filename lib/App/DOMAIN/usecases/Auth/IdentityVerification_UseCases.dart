import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/IADocumentAnalisis_Entities.dart';
import 'package:ezride/App/DOMAIN/repositories/Auth/IADocument_RepositoryDomain.dart';
import 'package:ezride/Core/errors/failure.dart';

class IdentityVerificationUseCase {
  final IADocumentRepositoryDomain repository;

  IdentityVerificationUseCase(this.repository);

  Future<Either<Failure, IAAnalisisResultEntities>> call({
    required File photoFront,
    required File photoBack,
    File? selfie,
  }) async {
    try {
      // Analizar frontal
      final frontResultEither = await repository.analyzeDocument(photoFront);
      final frontResult = frontResultEither.fold(
        (failure) => throw Exception(failure.message),
        (success) => success,
      );

      // Analizar trasera
      final backResultEither = await repository.analyzeDocument(photoBack);
      final backResult = backResultEither.fold(
        (failure) => throw Exception(failure.message),
        (success) => success,
      );

      // Verificación facial (opcional)
      Map<String, dynamic>? faceResultData;
      if (selfie != null) {
        final faceResultEither =
            await repository.verifyFace(selfie: selfie, duiFront: photoFront);
        faceResultData = faceResultEither.fold(
          (failure) {
            print('Error facial: ${failure.message}');
            return null;
          },
          (success) => success,
        );
      }

      // Retornamos el objeto combinado
      return Right(IAAnalisisResultEntities(
        id: frontResult.id,
        analysisType: frontResult.analysisType,
        sourceType: frontResult.sourceType,
        sourceId: frontResult.sourceId,
        provider: frontResult.provider,
        providerRef: frontResult.providerRef,
        confidenceScore: frontResult.confidenceScore,
        isApproved: frontResult.isApproved,
        primaryFinding: frontResult.primaryFinding,
        featuresUsed: frontResult.featuresUsed,
        analysisDurationMs: frontResult.analysisDurationMs,
        costUnits: frontResult.costUnits,
        findings: {
          'front': frontResult.findings,
          'back': backResult.findings,
          'face': faceResultData,
        },
        recommendations: frontResult.recommendations,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
