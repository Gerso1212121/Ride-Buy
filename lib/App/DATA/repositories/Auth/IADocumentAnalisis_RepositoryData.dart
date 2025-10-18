import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:ezride/App/DATA/datasources/Auth/IADocument_DataSourcers.dart';
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/IADocumentAnalisis_Entities.dart';
import 'package:ezride/App/DOMAIN/repositories/Auth/IADocument_RepositoryDomain.dart';
import 'package:ezride/Core/errors/failure.dart';

class IADocumentRepository implements IADocumentRepositoryDomain {
  final IADocumentDataSourcers datasource;

  IADocumentRepository(this.datasource);

  @override
  Future<Either<Failure, IAAnalisisResultEntities>> analyzeDocument(
    File file, {
    String? sourceId,
    String? provider,
  }) async {
    try {
      final data = await datasource.analyzeDocument(
        file,
        sourceId: sourceId,
        provider: provider,
      );
      return Right(IAAnalisisResultEntities.fromModel(data));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyFace({
    required File selfie,
    required File duiFront,
  }) async {
    try {
      final data =
          await datasource.verifyFace(selfie: selfie, duiFront: duiFront);
      return Right(data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
