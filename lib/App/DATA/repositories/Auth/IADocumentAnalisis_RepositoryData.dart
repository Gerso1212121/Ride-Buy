import '../../../DOMAIN/Entities (ordenarlas en base a los features)/Auth/IADocumentAnalisis_Entities.dart';
import '../../../DOMAIN/repositories/Auth/IADocument_RepositoryDomain.dart';
import '../../datasources/Auth/IADocument_DataSourcers.dart';
import 'dart:io';

class IADocumentAnalisisRepositoryData implements IADocumentRepositoryDomain {
  final IADocumentDataSource datasource;

  IADocumentAnalisisRepositoryData(this.datasource);

  @override
  Future<IAAnalisisResultEntities> analyzeDocument(File file,
      {String? sourceId, String? provider}) {
    return datasource.analyzeDocument(file);
  }
}
