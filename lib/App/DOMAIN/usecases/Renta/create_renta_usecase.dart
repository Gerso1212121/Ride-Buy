import 'package:ezride/App/DOMAIN/Entities/rentas_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/rentas_repository_domain.dart';
import 'package:ezride/Core/enums/enums.dart';

class CreateRentaUseCase {
  final RentaRepositoryDomain repository;

  CreateRentaUseCase(this.repository);

  Future<Renta> execute({
    required String vehiculoId,
    required String empresaId,
    required String clienteId,
    required DateTime fechaInicioRenta,
    required DateTime fechaEntregaVehiculo,
    required double total,
    RentaTipo tipo = RentaTipo.renta,
    PickupMethod pickupMethod = PickupMethod.agencia,
    String? pickupAddress,
    String? entregaAddress,
  }) async {
    // ✅ VALIDACIONES MEJORADAS
    _validarDatosEntrada(
      vehiculoId: vehiculoId,
      empresaId: empresaId,
      clienteId: clienteId,
      fechaInicioRenta: fechaInicioRenta,
      fechaEntregaVehiculo: fechaEntregaVehiculo,
      total: total,
    );

    // ✅ LOGS DETALLADOS PARA DEBUG
    _logDatosRenta(
      vehiculoId: vehiculoId,
      empresaId: empresaId,
      clienteId: clienteId,
      fechaInicioRenta: fechaInicioRenta,
      fechaEntregaVehiculo: fechaEntregaVehiculo,
      total: total,
      tipo: tipo,
      pickupMethod: pickupMethod,
    );

    final renta = Renta(
      id: '', // ✅ Se generará automáticamente en la base de datos
      vehiculoId: vehiculoId,
      empresaId: empresaId,
      clienteId: clienteId,
      tipo: tipo,
      fechaReserva: DateTime.now(),
      fechaInicioRenta: fechaInicioRenta,
      fechaEntregaVehiculo: fechaEntregaVehiculo,
      pickupMethod: pickupMethod,
      pickupAddress: pickupAddress,
      entregaAddress: entregaAddress,
      total: total,
      status: RentalStatus.pendiente,
      createdAt: DateTime.now(),
    );

    return await repository.createRenta(renta);
  }

  // ✅ MÉTODO PRIVADO PARA VALIDACIONES
  void _validarDatosEntrada({
    required String vehiculoId,
    required String empresaId,
    required String clienteId,
    required DateTime fechaInicioRenta,
    required DateTime fechaEntregaVehiculo,
    required double total,
  }) {
    // Validar IDs vacíos
    if (vehiculoId.isEmpty) {
      throw Exception('❌ El ID del vehículo es requerido');
    }
    if (empresaId.isEmpty) {
      throw Exception('❌ El ID de la empresa es requerido');
    }
    if (clienteId.isEmpty) {
      throw Exception('❌ El ID del cliente es requerido');
    }

    // Validar formato de UUID (opcional pero recomendado)
    if (!_esUUIDValido(vehiculoId)) {
      throw Exception('❌ El ID del vehículo no tiene un formato válido');
    }
    if (!_esUUIDValido(empresaId)) {
      throw Exception('❌ El ID de la empresa no tiene un formato válido');
    }
    if (!_esUUIDValido(clienteId)) {
      throw Exception('❌ El ID del cliente no tiene un formato válido');
    }

    // Validar fechas
    final ahora = DateTime.now();
    if (fechaInicioRenta.isBefore(ahora.subtract(const Duration(minutes: 1)))) {
      throw Exception('❌ La fecha de inicio no puede ser en el pasado');
    }

    if (fechaInicioRenta.isAfter(fechaEntregaVehiculo)) {
      throw Exception('❌ La fecha de inicio debe ser anterior a la fecha de entrega');
    }

    final diferenciaDias = fechaEntregaVehiculo.difference(fechaInicioRenta).inDays;
    if (diferenciaDias < 1) {
      throw Exception('❌ La renta debe ser de al menos 1 día');
    }

    if (diferenciaDias > 365) {
      throw Exception('❌ La renta no puede exceder 1 año');
    }

    // Validar total
    if (total <= 0) {
      throw Exception('❌ El total debe ser mayor a 0');
    }

    if (total > 100000) {
      throw Exception('❌ El total excede el límite permitido');
    }
  }

  // ✅ MÉTODO PRIVADO PARA LOGS DETALLADOS
  void _logDatosRenta({
    required String vehiculoId,
    required String empresaId,
    required String clienteId,
    required DateTime fechaInicioRenta,
    required DateTime fechaEntregaVehiculo,
    required double total,
    required RentaTipo tipo,
    required PickupMethod pickupMethod,
  }) {
    final diferenciaDias = fechaEntregaVehiculo.difference(fechaInicioRenta).inDays;
    
    print('🚀 CREANDO RENTA - DATOS DE ENTRADA:');
    print('   📋 Vehículo ID: $vehiculoId');
    print('   🏢 Empresa ID: $empresaId');
    print('   👤 Cliente ID: $clienteId');
    print('   📅 Fecha inicio: ${fechaInicioRenta.toIso8601String()}');
    print('   📅 Fecha fin: ${fechaEntregaVehiculo.toIso8601String()}');
    print('   ⏱️  Días de renta: $diferenciaDias');
    print('   💰 Total: \$${total.toStringAsFixed(2)}');
    print('   🏷️  Tipo: ${tipo.name}');
    print('   🚚 Método recogida: ${pickupMethod.name}');
    print('   🕐 Fecha reserva: ${DateTime.now().toIso8601String()}');
  }

  // ✅ MÉTODO AUXILIAR PARA VALIDAR UUID
  bool _esUUIDValido(String uuid) {
    final regex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    return regex.hasMatch(uuid);
  }

  // ❌ ELIMINAR EL MÉTODO _verificarDisponibilidadVehiculo - ahora está en el repository
}