//Las enumeraciones globales de la app
//(restrinciones especificas en una tabla de la base de datos)

enum UserRole { cliente, empresario, empleado, soporte, admin }

enum VerificationStatus { pendiente, enRevision, verificado, rechazado }

enum VehicleStatus {
  disponible,
  reservado,
  enRenta,
  mantenimiento,
  noDisponible
}

enum RentalStatus {
  pendiente,
  confirmada,
  enCurso,
  finalizada,
  cancelada,
  expirada,
  rechazada
}

enum PaymentStatus {
  pendiente,
  enProceso,
  parcial,
  pagado,
  fallido,
  reembolsado
}

enum DocumentType {
  tarjetaCirculacion,
  soa,
  seguro,
  licenciaConducir,
  dui,
  pasaporte,
  contratoRenta,
  factura,
  otros
}

enum UserDocumentType { dui, licenciaConducir, pasaporte, otros }

enum DocumentStatus { pending, approved, rejected, expired }

enum GovernmentEntity { vmt, ministerioHacienda, registroNacional }

enum GovVerificationType {
  vehicleRegistration,
  identity,
  taxStatus,
  soaVigente,
  placaSinMultas
}

enum SessionType { biometria, documento, mixta }

enum SessionStatus { inProgress, completed, expired, failed }

enum MLAnalysisType {
  livenessDetection,
  damageDetection,
  fraudCheck,
  documentOcr
}

enum MLSourceType { usuario, vehiculo, renta, documento, imagen, camera }

enum PickupMethod { agencia, domicilio }

enum RentaTipo { reserva, renta }

enum DocumentoScope { vehiculo, empresa, perfil }

enum EmpresaStatus { pendiente, activo, suspendido, cerrado }
