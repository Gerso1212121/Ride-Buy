import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../Core/errors/failure.dart';
import '../../Entities (ordenarlas en base a los features)/Auth/IADocumentAnalisis_Entities.dart';

abstract class IADocumentRepositoryDomain {
  Future<Either<Failure, IAAnalisisResultEntities>> analyzeDocument(
    File file, {
    String? sourceId,
    String? provider,
  });

  Future<Either<Failure, Map<String, dynamic>>> verifyFace({
    required File selfie,
    required File duiFront,
  });
}
