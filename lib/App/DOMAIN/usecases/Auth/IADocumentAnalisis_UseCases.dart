import '../../repositories/Auth/IADocument_RepositoryDomain.dart';
import '../../Entities (ordenarlas en base a los features)/Auth/IADocumentAnalisis_Entities.dart';
import 'dart:io';

class IADocumentAnalisisUseCases {
  final IADocumentRepositoryDomain repository;

  IADocumentAnalisisUseCases(this.repository);

  Future<IAAnalisisResultEntities> call(File file,
      {String? sourceId, String? provider}) {
    return repository.analyzeDocument(file,
        sourceId: sourceId, provider: provider);
  }
}
