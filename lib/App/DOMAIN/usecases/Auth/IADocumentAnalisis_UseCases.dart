import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:ezride/Core/errors/failure.dart';

import '../../repositories/Auth/IADocument_RepositoryDomain.dart';
import '../../Entities (ordenarlas en base a los features)/Auth/IADocumentAnalisis_Entities.dart';

class IADocumentAnalisisUseCases {
  final IADocumentRepositoryDomain repository;

  IADocumentAnalisisUseCases(this.repository);

  Future<Either<Failure, IAAnalisisResultEntities>> call(
    File file, {
    String? sourceId,
    String? provider,
  }) async {
    try {
      final result = await repository.analyzeDocument(
        file,
        sourceId: sourceId,
        provider: provider,
      );
      return result;
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
