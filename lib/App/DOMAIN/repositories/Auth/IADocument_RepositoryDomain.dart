import '../../Entities (ordenarlas en base a los features)/Auth/IADocumentAnalisis_Entities.dart';
import 'dart:io';

abstract class IADocumentRepositoryDomain {
  Future<IAAnalisisResultEntities> analyzeDocument(File file,
      {String? sourceId, String? provider});
}
