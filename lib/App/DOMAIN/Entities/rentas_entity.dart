import 'package:ezride/Core/enums/enums.dart';

class Renta {
  final String id;
  final String vehiculoId;
  final String empresaId;
  final String clienteId;
  final RentaTipo tipo;
  final DateTime fechaReserva;
  final DateTime fechaInicioRenta;
  final DateTime fechaEntregaVehiculo;
  final PickupMethod pickupMethod;
  final String? pickupAddress;
  final String? entregaAddress;
  final double total;
  final RentalStatus status;
  final String? verificationCode;
  final List<String>? pickupPhotos;
  final List<String>? returnPhotos;
  final bool damageDetected;
  final DateTime createdAt;

  Renta({
    required this.id,
    required this.vehiculoId,
    required this.empresaId,
    required this.clienteId,
    this.tipo = RentaTipo.reserva,
    required this.fechaReserva,
    required this.fechaInicioRenta,
    required this.fechaEntregaVehiculo,
    this.pickupMethod = PickupMethod.agencia,
    this.pickupAddress,
    this.entregaAddress,
    required this.total,
    this.status = RentalStatus.pendiente,
    this.verificationCode,
    this.pickupPhotos,
    this.returnPhotos,
    this.damageDetected = false,
    required this.createdAt,
  });
}
