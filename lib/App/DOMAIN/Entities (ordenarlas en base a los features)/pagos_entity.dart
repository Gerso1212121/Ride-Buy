import 'package:ezride/Core/enums/enums.dart';

class Pago {
  final String id;
  final String rentaId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? metodo;
  final String? proveedorPasarela;
  final String? reference;
  final bool isRefund;
  final String? parentPaymentId;
  final DateTime? paidAt;
  final DateTime createdAt;

  Pago({
    required this.id,
    required this.rentaId,
    required this.amount,
    this.currency = 'USD',
    this.status = PaymentStatus.pendiente,
    this.metodo,
    this.proveedorPasarela,
    this.reference,
    this.isRefund = false,
    this.parentPaymentId,
    this.paidAt,
    required this.createdAt,
  });
}
