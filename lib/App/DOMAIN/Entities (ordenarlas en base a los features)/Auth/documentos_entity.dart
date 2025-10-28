import 'package:ezride/Core/enums/enums.dart';

class Documento {
  final String id;
  final DocumentoScope scope;
  final String? empresaId;
  final String? vehiculoId;
  final String? perfilId;
  final DocumentType? tipoVehiculo;
  final DocumentType? tipoEmpresa;
  final DocumentType? tipoPerfil;

  // Datos del archivo
  final String filePath;
  final DateTime? venceEn;

  // Estado de verificación
  final DocumentStatus verificationStatus;
  final bool visibleParaCliente;

  // OCR / AI
  final Map<String, dynamic>? ocrData;
  final String? aiAnalysisId;

  // Info de creación
  final String? createdBy;
  final DateTime createdAt;

  // NUEVOS CAMPOS PARA HASH Y PROVEEDOR
  final String? hash;
  final String? sourceType; // 'document_front', 'document_back', 'selfie'
  final String? provider; // 'AzureDocumentIntelligence', 'FaceAPI', etc.

  Documento({
    required this.id,
    required this.scope,
    this.empresaId,
    this.vehiculoId,
    this.perfilId,
    this.tipoVehiculo,
    this.tipoEmpresa,
    this.tipoPerfil,
    required this.filePath,
    this.venceEn,
    this.verificationStatus = DocumentStatus.pending,
    this.visibleParaCliente = false,
    this.ocrData,
    this.aiAnalysisId,
    this.createdBy,
    required this.createdAt,
    this.hash,
    this.sourceType,
    this.provider,
  });
}
