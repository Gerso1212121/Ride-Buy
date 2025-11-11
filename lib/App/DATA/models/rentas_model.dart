import 'package:ezride/App/DOMAIN/Entities/rentas_entity.dart';
import 'package:ezride/Core/enums/enums.dart';

class RentaModel extends Renta {
  // ✅ CAMPOS ADICIONALES para información relacionada
  final String? vehiculoTitulo;
  final String? vehiculoMarca;
  final String? vehiculoModelo;
  final String? vehiculoImagen;
  final String? clienteNombre;
  final String? clientePhone;
  final String? empresaNombre;

  RentaModel({
    required String id,
    required String vehiculoId,
    required String empresaId,
    required String clienteId,
    RentaTipo tipo = RentaTipo.reserva,
    required DateTime fechaReserva,
    required DateTime fechaInicioRenta,
    required DateTime fechaEntregaVehiculo,
    PickupMethod pickupMethod = PickupMethod.agencia,
    String? pickupAddress,
    String? entregaAddress,
    required double total,
    RentalStatus status = RentalStatus.pendiente,
    String? verificationCode,
    List<String>? pickupPhotos,
    List<String>? returnPhotos,
    bool damageDetected = false,
    required DateTime createdAt,
    
    // ✅ NUEVOS CAMPOS ADICIONALES (opcionales)
    this.vehiculoTitulo,
    this.vehiculoMarca,
    this.vehiculoModelo,
    this.vehiculoImagen,
    this.clienteNombre,
    this.clientePhone,
    this.empresaNombre,
  }) : super(
          id: id,
          vehiculoId: vehiculoId,
          empresaId: empresaId,
          clienteId: clienteId,
          tipo: tipo,
          fechaReserva: fechaReserva,
          fechaInicioRenta: fechaInicioRenta,
          fechaEntregaVehiculo: fechaEntregaVehiculo,
          pickupMethod: pickupMethod,
          pickupAddress: pickupAddress,
          entregaAddress: entregaAddress,
          total: total,
          status: status,
          verificationCode: verificationCode,
          pickupPhotos: pickupPhotos,
          returnPhotos: returnPhotos,
          damageDetected: damageDetected,
          createdAt: createdAt,
        );

  factory RentaModel.fromMap(Map<String, dynamic> map) {
    // ✅ DEBUG: Ver qué datos recibimos
    print('🔍 DEBUG RentaModel.fromMap - Datos recibidos:');
    map.forEach((key, value) {
      print('   $key: $value (${value?.runtimeType})');
    });

    return RentaModel(
      // ✅ PARSING SEGURO con valores por defecto
      id: map['id'] as String? ?? '',
      vehiculoId: map['vehiculo_id'] as String? ?? '',
      empresaId: map['empresa_id'] as String? ?? '',
      clienteId: map['cliente_id'] as String? ?? '',
      
      // ✅ PARSING SEGURO de enums
      tipo: _parseRentaTipo(map['tipo'] as String?),
      pickupMethod: _parsePickupMethod(map['pickup_method'] as String?),
      status: _parseRentalStatus(map['status'] as String?),
      
      // ✅ PARSING SEGURO de fechas
      fechaReserva: _parseDateTime(map['fecha_reserva']),
      fechaInicioRenta: _parseDateTime(map['fecha_inicio_renta']),
      fechaEntregaVehiculo: _parseDateTime(map['fecha_entrega_vehiculo']),
      createdAt: _parseDateTime(map['created_at']),
      
      // ✅ Campos opcionales
      pickupAddress: map['pickup_address'] as String?,
      entregaAddress: map['entrega_address'] as String?,
      verificationCode: map['verification_code'] as String?,
      
      // ✅ PARSING SEGURO de números y booleanos
      total: _parseDouble(map['total']),
      damageDetected: map['damage_detected'] as bool? ?? false,
      
      // ✅ PARSING SEGURO de listas
      pickupPhotos: map['pickup_photos'] != null 
          ? List<String>.from(map['pickup_photos'] as List) 
          : null,
      returnPhotos: map['return_photos'] != null 
          ? List<String>.from(map['return_photos'] as List) 
          : null,
      
      // ✅ NUEVOS CAMPOS ADICIONALES
      vehiculoTitulo: map['vehiculo_titulo'] as String?,
      vehiculoMarca: map['marca'] as String?,
      vehiculoModelo: map['modelo'] as String?,
      vehiculoImagen: map['imagen1'] as String?,
      clienteNombre: map['cliente_nombre'] as String?,
      clientePhone: map['cliente_phone'] as String?,
      empresaNombre: map['empresa_nombre'] as String?,
    );
  }

  // ✅ MÉTODOS AUXILIARES PARA PARSING SEGURO

  static RentaTipo _parseRentaTipo(String? value) {
    if (value == null) return RentaTipo.reserva;
    try {
      return RentaTipo.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return RentaTipo.reserva;
    }
  }

  static PickupMethod _parsePickupMethod(String? value) {
    if (value == null) return PickupMethod.agencia;
    try {
      return PickupMethod.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return PickupMethod.agencia;
    }
  }

  static RentalStatus _parseRentalStatus(String? value) {
    if (value == null) return RentalStatus.pendiente;
    try {
      return RentalStatus.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return RentalStatus.pendiente;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'vehiculo_id': vehiculoId,
      'empresa_id': empresaId,
      'cliente_id': clienteId,
      'tipo': tipo.name,
      'fecha_reserva': fechaReserva.toIso8601String(),
      'fecha_inicio_renta': fechaInicioRenta.toIso8601String(),
      'fecha_entrega_vehiculo': fechaEntregaVehiculo.toIso8601String(),
      'pickup_method': pickupMethod.name,
      'pickup_address': pickupAddress,
      'entrega_address': entregaAddress,
      'total': total,
      'status': status.name,
      'verification_code': verificationCode,
      'pickup_photos': pickupPhotos,
      'return_photos': returnPhotos,
      'damage_detected': damageDetected,
      'created_at': createdAt.toIso8601String(),
    };

    // ✅ AGREGAR CAMPOS ADICIONALES SI EXISTEN
    if (vehiculoTitulo != null) map['vehiculo_titulo'] = vehiculoTitulo;
    if (vehiculoMarca != null) map['marca'] = vehiculoMarca;
    if (vehiculoModelo != null) map['modelo'] = vehiculoModelo;
    if (vehiculoImagen != null) map['imagen1'] = vehiculoImagen;
    if (clienteNombre != null) map['cliente_nombre'] = clienteNombre;
    if (clientePhone != null) map['cliente_phone'] = clientePhone;
    if (empresaNombre != null) map['empresa_nombre'] = empresaNombre;

    return map;
  }

  // ✅ MÉTODO PARA CREAR DESDE ENTITY (sin campos adicionales)
  factory RentaModel.fromEntity(Renta entity) {
    return RentaModel(
      id: entity.id,
      vehiculoId: entity.vehiculoId,
      empresaId: entity.empresaId,
      clienteId: entity.clienteId,
      tipo: entity.tipo,
      fechaReserva: entity.fechaReserva,
      fechaInicioRenta: entity.fechaInicioRenta,
      fechaEntregaVehiculo: entity.fechaEntregaVehiculo,
      pickupMethod: entity.pickupMethod,
      pickupAddress: entity.pickupAddress,
      entregaAddress: entity.entregaAddress,
      total: entity.total,
      status: entity.status,
      verificationCode: entity.verificationCode,
      pickupPhotos: entity.pickupPhotos,
      returnPhotos: entity.returnPhotos,
      damageDetected: entity.damageDetected,
      createdAt: entity.createdAt,
    );
  }

  // ✅ GETTERS ÚTILES PARA INFORMACIÓN FORMATEADA

  String get vehiculoInfo {
    if (vehiculoTitulo != null) return vehiculoTitulo!;
    if (vehiculoMarca != null && vehiculoModelo != null) {
      return '$vehiculoMarca $vehiculoModelo';
    }
    return 'Vehículo';
  }

  String get clienteInfo {
    return clienteNombre ?? 'Cliente';
  }

  String get empresaInfo {
    return empresaNombre ?? 'Empresa';
  }

  String get periodoRenta {
    final dias = fechaEntregaVehiculo.difference(fechaInicioRenta).inDays;
    return '$dias ${dias == 1 ? 'día' : 'días'}';
  }

  String get estadoFormateado {
    switch (status) {
      case RentalStatus.pendiente:
        return 'Pendiente';
      case RentalStatus.confirmada:
        return 'Confirmada';
      case RentalStatus.enCurso:
        return 'En curso';
      case RentalStatus.finalizada:
        return 'Finalizada';
      case RentalStatus.cancelada:
        return 'Cancelada';
      case RentalStatus.expirada:
        return 'Expirada';
      case RentalStatus.rechazada:
        return 'Rechazada';
      default:
        return 'Desconocido';
    }
  }

  // ✅ MÉTODO PARA VERIFICAR SI LA RENTA ESTÁ ACTIVA
  bool get estaActiva {
    return status == RentalStatus.confirmada || status == RentalStatus.enCurso;
  }

  // ✅ MÉTODO PARA VERIFICAR SI PUEDE SER CANCELADA
  bool get puedeCancelar {
    return status == RentalStatus.pendiente || status == RentalStatus.confirmada;
  }

  // ✅ MÉTODO PARA OBTENER DÍAS RESTANTES
  int get diasRestantes {
    final ahora = DateTime.now();
    if (ahora.isAfter(fechaEntregaVehiculo)) return 0;
    return fechaEntregaVehiculo.difference(ahora).inDays;
  }

  // =========================================================================
  // ✅ MÉTODOS PARA EL SISTEMA DE QR (ENFOQUE HÍBRIDO)
  // =========================================================================

  // ✅ GENERAR DATOS PARA EL QR (CONTROLADO Y SEGURO)
Map<String, dynamic> toQRData() {
  return {
    'type': 'renta_confirmation',
    'rentaId': id,
    'empresaId': empresaId,
    'clienteId': clienteId,
    'vehiculoId': vehiculoId,
    // ✅ INFORMACIÓN PARA MOSTRAR (solo visual)
    'clienteNombre': clienteNombre ?? 'Cliente',
    'vehiculoInfo': vehiculoInfo,
    'empresaNombre': empresaNombre ?? 'Empresa',
    'fechaInicio': fechaInicioRenta.toIso8601String(),
    'fechaFin': fechaEntregaVehiculo.toIso8601String(),
    'total': total,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };
}


  // ✅ VALIDAR INTEGRIDAD DE DATOS DEL QR
bool validarDatosQR(Map<String, dynamic> qrData) {
  try {
    // ✅ VALIDACIÓN SIMPLIFICADA - solo ID de renta
    return qrData['rentaId'] == id;
  } catch (e) {
    return false;
  }
}

  // ✅ DATOS BASE DEL QR (INFORMACIÓN ESENCIAL)


  // ✅ DATOS ADICIONALES (INFORMACIÓN PARA MOSTRAR)
  Map<String, dynamic> _getQRAdditionalData() {
    return {
      'clienteNombre': clienteNombre ?? 'Cliente',
      'clienteTelefono': clientePhone ?? 'N/A',
      'vehiculoInfo': vehiculoInfo,
      'empresaNombre': empresaNombre ?? 'Empresa',
      'periodo': '${fechaInicioRenta.day}/${fechaInicioRenta.month}/${fechaInicioRenta.year} - ${fechaEntregaVehiculo.day}/${fechaEntregaVehiculo.month}/${fechaEntregaVehiculo.year}',
      'total': total,
      'diasRenta': fechaEntregaVehiculo.difference(fechaInicioRenta).inDays,
      'estado': status.name,
    };
  }


  // ✅ INFORMACIÓN LEGIBLE PARA MOSTRAR EN UI
  String get informacionQR {
    return '''
📋 Renta: ${id.substring(0, 8)}...
👤 Cliente: $clienteNombre
📞 Teléfono: $clientePhone
🚗 Vehículo: $vehiculoInfo
🏢 Empresa: $empresaNombre
📅 Período: ${fechaInicioRenta.day}/${fechaInicioRenta.month}/${fechaInicioRenta.year} - ${fechaEntregaVehiculo.day}/${fechaEntregaVehiculo.month}/${fechaEntregaVehiculo.year}
💰 Total: \$$total
🔒 Código: ${verificationCode ?? 'No generado'}
''';
  }

  // ✅ MÉTODO PARA FORMATEAR FECHA LEGIBLE
  String get fechaInicioFormateada {
    return '${fechaInicioRenta.day}/${fechaInicioRenta.month}/${fechaInicioRenta.year}';
  }

  String get fechaFinFormateada {
    return '${fechaEntregaVehiculo.day}/${fechaEntregaVehiculo.month}/${fechaEntregaVehiculo.year}';
  }

  // ✅ MÉTODO PARA VERIFICAR SI EL QR ES VÁLIDO (NO EXPIRADO)
  bool get esQRValido {
    // El QR es válido por 24 horas
    final ahora = DateTime.now();
    final creacion = DateTime.fromMillisecondsSinceEpoch(
      createdAt.millisecondsSinceEpoch
    );
    return ahora.difference(creacion).inHours <= 24;
  }

  // ✅ MÉTODO PARA OBTENER RESUMEN PARA MOSTRAR EN CONFIRMACIÓN
  Map<String, String> get resumenConfirmacion {
    return {
      'Cliente': clienteNombre ?? 'No disponible',
      'Vehículo': vehiculoInfo,
      'Empresa': empresaNombre ?? 'No disponible',
      'Período': '$fechaInicioFormateada - $fechaFinFormateada',
      'Días': periodoRenta,
      'Total': '\$${total.toStringAsFixed(2)}',
      'Estado': estadoFormateado,
    };
  }

  
  // =========================================================================
  // ✅ MÉTODOS PARA EL SISTEMA DE QR DE DEVOLUCIÓN (NUEVOS)
  // =========================================================================

  // ✅ GENERAR DATOS PARA EL QR DE DEVOLUCIÓN
  Map<String, dynamic> toQRDataDevolucion() {
    final baseData = _getQRBaseDataDevolucion();
    final additionalData = _getQRAdditionalDataDevolucion();

    return {
      ...baseData,
      ...additionalData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'hash': _generateSecurityHashDevolucion(),
      'action': 'devolucion_vehiculo',
    };
  }

  // ✅ VERIFICAR CÓDIGO DE DEVOLUCIÓN
  bool verificarCodigoDevolucion(String codigo) {
    if (verificationCode == null) return false;
    // Para devolución, podemos usar el mismo código o generar uno específico
    final codigoDevolucion = _generarCodigoDevolucion();
    return codigoDevolucion == codigo;
  }

  // ✅ VALIDAR INTEGRIDAD DE DATOS DEL QR DE DEVOLUCIÓN
  bool validarDatosQRDevolucion(Map<String, dynamic> qrData) {
    try {
      return qrData['rentaId'] == id &&
             qrData['action'] == 'devolucion_vehiculo' &&
             qrData['clienteId'] == clienteId &&
             qrData['empresaId'] == empresaId;
    } catch (e) {
      return false;
    }
  }

  // ✅ DATOS BASE DEL QR DE DEVOLUCIÓN
  Map<String, dynamic> _getQRBaseDataDevolucion() {
    return {
      'type': 'devolucion_vehiculo',
      'rentaId': id,
      'verificationCode': _generarCodigoDevolucion(),
      'empresaId': empresaId,
      'clienteId': clienteId,
      'action': 'devolucion_vehiculo',
    };
  }

  // ✅ DATOS ADICIONALES PARA DEVOLUCIÓN
  Map<String, dynamic> _getQRAdditionalDataDevolucion() {
    return {
      'clienteNombre': clienteNombre ?? 'Cliente',
      'clienteTelefono': clientePhone ?? 'N/A',
      'vehiculoInfo': vehiculoInfo,
      'empresaNombre': empresaNombre ?? 'Empresa',
      'periodo': '${fechaInicioFormateada} - ${fechaFinFormateada}',
      'total': total,
      'diasRenta': fechaEntregaVehiculo.difference(fechaInicioRenta).inDays,
      'estado': status.name,
      'fechaDevolucion': DateTime.now().toIso8601String(),
    };
  }

  // ✅ GENERAR CÓDIGO DE DEVOLUCIÓN
  String _generarCodigoDevolucion() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'DV${id.substring(0, 4).toUpperCase()}$random';
  }

  // ✅ GENERAR HASH DE SEGURIDAD PARA DEVOLUCIÓN
  String _generateSecurityHashDevolucion() {
    final data = '$id${_generarCodigoDevolucion()}$clienteId${DateTime.now().millisecondsSinceEpoch}';
    return data.hashCode.toString();
  }

  // ✅ INFORMACIÓN LEGIBLE PARA DEVOLUCIÓN
  String get informacionQRDevolucion {
    return '''
  📋 Devolución: ${id.substring(0, 8)}...
  👤 Cliente: $clienteNombre
  📞 Teléfono: $clientePhone
  🚗 Vehículo: $vehiculoInfo
  🏢 Empresa: $empresaNombre
  📅 Período: $fechaInicioFormateada - $fechaFinFormateada
  💰 Total: \$$total
  🔒 Código Devolución: ${_generarCodigoDevolucion()}
  🕐 Fecha Devolución: ${DateTime.now().toString()}
  ''';
  }
}