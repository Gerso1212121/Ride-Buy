// lib/Feature/PAYMENT_PENDING/payment_pending_screen.dart
import 'dart:async';

import 'package:ezride/App/DATA/datasources/Auth/rentas_remote_datasource.dart';
import 'package:ezride/App/DATA/datasources/Auth/vehicle_remote_datasource.dart';
import 'package:ezride/App/DATA/repositories/rentas_repository_data.dart';
import 'package:ezride/App/DOMAIN/usecases/Renta/create_renta_usecase.dart';
import 'package:ezride/Core/widgets/Modals/GlobalModalAction.widget.dart';
import 'package:ezride/Services/api/woompi_pay_service.dart';
import 'package:ezride/App/DOMAIN/Entities/rentas_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/rentas_repository_domain.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';

class PaymentPendingScreen extends StatefulWidget {
  final Map<String, dynamic> extra;

  const PaymentPendingScreen({Key? key, required this.extra}) : super(key: key);

  @override
  State<PaymentPendingScreen> createState() => _PaymentPendingScreenState();
}

// Assuming you have a repository for 'renta'
class _PaymentPendingScreenState extends State<PaymentPendingScreen> {
  bool _isChecking = false;
  bool _paymentCompleted = false;
  bool _paymentOpened = false;
  bool _insertingRenta = false;
  late String _referenciaPago;
  late String _tempRentaId;
  late String _paymentUrl;

  // ✅ NUEVO: Variables para datos de renta
  late String _vehiculoId;
  late String _empresaId;
  late String _clienteId;
  late DateTime _fechaInicio;
  late DateTime _fechaFin;
  late double _total;
  late String _vehicleName;
  late String _vehicleType;
  late String _vehicleImageUrl;

  bool _dataLoaded = false;

  // ✅ Para manejo de deep links
  late AppLinks _appLinks;
  StreamSubscription<Uri?>? _linkSubscription;

  // ✅ NUEVO: Caso de uso para crear renta
  late CreateRentaUseCase _createRentaUseCase;

  // Usamos la clase concreta `RentaRepositoryData`
  late RentaRepositoryData _rentaRepositoryData;

  // Asumiendo que tienes los datos necesarios para inicializar las fuentes de datos
  late RentaRemoteDataSource _rentaRemoteDataSource;
  late VehicleRemoteDataSource _vehicleRemoteDataSource;

  @override
  void initState() {
    super.initState();

    // Inicializamos las fuentes de datos (esto debe estar preparado en tu proyecto)
    _rentaRemoteDataSource = RentaRemoteDataSource();
    _vehicleRemoteDataSource = VehicleRemoteDataSource();

    // Ahora, usamos la implementación concreta de `RentaRepositoryDomain`
    _rentaRepositoryData = RentaRepositoryData(
      _rentaRemoteDataSource,
      _vehicleRemoteDataSource,
    );

    // Inicializamos el caso de uso
    _createRentaUseCase = CreateRentaUseCase(_rentaRepositoryData);

    _loadData();
  }

  void _loadData() {
    try {
      // ✅ DATOS DE PAGO
      _referenciaPago = widget.extra['referenciaPago'] as String;
      _tempRentaId = widget.extra['tempRentaId'] as String;
      _paymentUrl = widget.extra['paymentUrl'] as String;

      // ✅ DATOS DE RENTA
      _vehiculoId = widget.extra['vehicleId'] as String;
      _empresaId = widget.extra['empresaId'] as String;
      _clienteId = widget.extra['clienteId'] as String;
      _fechaInicio = DateTime.parse(widget.extra['fechaInicio'] as String);
      _fechaFin = DateTime.parse(widget.extra['fechaFin'] as String);
      _total = (widget.extra['total'] as num).toDouble();
      _vehicleName = widget.extra['vehicleName'] as String;
      _vehicleType = widget.extra['vehicleType'] as String;
      _vehicleImageUrl = widget.extra['vehicleImageUrl'] as String;

      print('🔍 Datos recibidos en PaymentPendingScreen:');
      print('  - referenciaPago: $_referenciaPago');
      print('  - tempRentaId: $_tempRentaId');
      print('  - paymentUrl: $_paymentUrl');
      print('  - vehiculoId: $_vehiculoId');
      print('  - empresaId: $_empresaId');
      print('  - clienteId: $_clienteId');
      print('  - fechaInicio: $_fechaInicio');
      print('  - fechaFin: $_fechaFin');
      print('  - total: $_total');

      _dataLoaded = true;

      // ✅ INICIALIZAR DEEP LINKS
      _initDeepLinks();

      // Abrir el pago automáticamente
      _openPayment();
      _startPaymentMonitoring();
    } catch (e) {
      print('❌ Error cargando datos: $e');
      print('🔍 Extra completo: ${widget.extra}');
      _mostrarError("Error", "Datos de pago incompletos");
    }
  }

  // ✅ Inicializar Deep Links
  void _initDeepLinks() async {
    try {
      _appLinks = AppLinks();

      // ✅ Escuchar deep links en tiempo real
      _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      });

      // ✅ Manejar link inicial
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print('🔗 Initial App Link: $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('❌ Error inicializando deep links: $e');
    }
  }

  // ✅ Manejar Deep Links
  void _handleDeepLink(Uri uri) {
    print('🔗 Deep Link Recibido: $uri');

    try {
      if (uri.scheme == 'ezride' && uri.host == 'payment') {
        final referencia = uri.queryParameters['referencia'];
        final estado = uri.queryParameters['estado'];

        print('📱 Procesando Deep Link:');
        print('   - Referencia: $referencia');
        print('   - Estado: $estado');
        print('   - Nuestra referencia: $_referenciaPago');

        // ✅ VERIFICAR QUE COINCIDA LA REFERENCIA
        if (referencia == _referenciaPago) {
          if (estado == 'aprobado') {
            print('✅ Deep Link: Pago APROBADO!');
            _procesarPagoAprobado();
          } else if (estado == 'rechazado') {
            print('❌ Deep Link: Pago RECHAZADO');
            _mostrarError("Pago Rechazado",
                "El pago fue rechazado. Por favor intenta nuevamente.");
          } else if (estado == 'fallido') {
            print('💥 Deep Link: Pago FALLIDO');
            _mostrarError(
                "Pago Fallido", "El pago falló. Por favor intenta nuevamente.");
          } else {
            print('ℹ️ Deep Link: Estado pendiente o desconocido - $estado');
          }
        } else {
          print(
              '⚠️ Deep Link: Referencia no coincide. Esperada: $_referenciaPago, Recibida: $referencia');
        }
      }
    } catch (e) {
      print('❌ Error procesando deep link: $e');
    }
  }

  // ✅ NUEVO: Método para procesar pago aprobado e insertar renta
  void _procesarPagoAprobado() async {
    if (mounted) {
      setState(() {
        _paymentCompleted = true;
        _insertingRenta = true;
      });
    }

    try {
      print('🚀 Iniciando inserción de renta...');

      // ✅ INSERTAR RENTA EN BASE DE DATOS
      await _insertarRenta();

      if (mounted) {
        setState(() {
          _insertingRenta = false;
        });
      }

      // ✅ NAVEGAR A ÉXITO
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _navigateToSuccess();
        }
      });
    } catch (e) {
      print('❌ Error insertando renta: $e');
      if (mounted) {
        setState(() {
          _insertingRenta = false;
        });
      }
      _mostrarError("Error",
          "Pago exitoso pero error al crear la reserva. Contacta soporte.");
    }
  }

  // ✅ NUEVO: Método para insertar renta usando el caso de uso
  Future<void> _insertarRenta() async {
    print('📦 Insertando renta en base de datos...');
    print('   - Vehículo: $_vehiculoId');
    print('   - Empresa: $_empresaId');
    print('   - Cliente: $_clienteId');
    print('   - Fechas: $_fechaInicio a $_fechaFin');
    print('   - Total: $_total');

    try {
      final rentaCreada = await _createRentaUseCase.execute(
        vehiculoId: _vehiculoId,
        empresaId: _empresaId,
        clienteId: _clienteId,
        fechaInicioRenta: _fechaInicio,
        fechaEntregaVehiculo: _fechaFin,
        total: _total,
        tipo: RentaTipo.renta,
        pickupMethod: PickupMethod.agencia,
      );

      print('✅ Renta creada exitosamente: ${rentaCreada.id}');

      // ✅ Actualizar el tempRentaId con el ID real de la renta
      _tempRentaId = rentaCreada.id;
    } catch (e) {
      print('❌ Error creando renta: $e');
      rethrow;
    }
  }

  Future<void> _openPayment() async {
    if (!_dataLoaded) return;

    await Future.delayed(const Duration(milliseconds: 500));

    print('🔗 Intentando abrir URL: $_paymentUrl');

    final launched = await WompiPaymentService.launchPayment(_paymentUrl);

    print('🌐 Resultado apertura: $launched');

    if (mounted) {
      setState(() {
        _paymentOpened = launched;
      });
    }

    if (!launched) {
      _mostrarError(
          "Error", "No se pudo abrir el enlace de pago. URL: $_paymentUrl");
    }
  }

  void _startPaymentMonitoring() {
    if (!_dataLoaded) return;

    // ✅ Verificar estado cada 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (!_paymentCompleted && _dataLoaded && mounted) {
        _checkPaymentStatus();
        _startPaymentMonitoring();
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking || !_dataLoaded || !mounted) return;

    if (mounted) {
      setState(() {
        _isChecking = true;
      });
    }

    try {
      print('🔄 Verificando estado para referencia: $_referenciaPago');

      final status =
          await WompiPaymentService.checkPaymentStatus(_referenciaPago);

      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }

      print('📊 Estado del pago: $status');

      if (status == WompiPaymentStatus.aprobado) {
        _procesarPagoAprobado();
      } else if (status == WompiPaymentStatus.rechazado) {
        _mostrarError("Pago Rechazado",
            "El pago fue rechazado. Por favor intenta nuevamente.");
      } else if (status == WompiPaymentStatus.fallido) {
        _mostrarError(
            "Pago Fallido", "El pago falló. Por favor intenta nuevamente.");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
      print('❌ Error verificando pago: $e');
    }
  }

  void _navigateToSuccess() {
    if (!_dataLoaded || !mounted) return;

    print('🎯 Navegando a pantalla de éxito con rentaId: $_tempRentaId');

    context.go(
      '/pay-confirm',
      extra: {
        'rentaId': _tempRentaId,
        'vehicleName': _vehicleName,
        'vehicleType': _vehicleType,
        'vehicleImageUrl': _vehicleImageUrl,
        'startDate': widget.extra['startDate'],
        'endDate': widget.extra['endDate'],
        'duration': widget.extra['duration'],
        'totalAmount': widget.extra['totalAmount'],
      },
    );
  }

  void _retryPayment() async {
    if (!_dataLoaded) return;

    final launched = await WompiPaymentService.launchPayment(_paymentUrl);
    if (!launched) {
      _mostrarError("Error", "No se pudo abrir el enlace de pago");
    } else {
      if (mounted) {
        setState(() {
          _paymentOpened = true;
        });
      }
    }
  }

  void _cancelPayment() {
    if (mounted) {
      context.go('/main');
    }
  }

  void _mostrarError(String titulo, String mensaje) {
    if (!mounted) return;

    showGlobalStatusModalAction(
      context,
      title: titulo,
      message: mensaje,
      icon: Icons.error,
      iconColor: Colors.red,
      confirmText: "Aceptar",
      cancelText: "Volver al inicio",
      onConfirm: () {
        // Solo cierra el modal, no hace nada más
      },
      onCancel: () {
        _cancelPayment();
      },
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _cancelPayment,
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 80, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'Error cargando datos de pago',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Por favor intenta nuevamente'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Procesando Pago'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _cancelPayment,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_paymentCompleted) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _paymentOpened ? Icons.payment : Icons.timer,
                  size: 80,
                  color: _paymentOpened ? Colors.orange : Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _paymentOpened ? 'Pago en Proceso' : 'Preparando Pago',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _paymentOpened
                    ? 'Por favor completa el pago en la ventana de Wompi.\n\n'
                        'Esta pantalla se actualizará automáticamente cuando el pago se complete.\n\n'
                        '💡 Si cierras la ventana de pago, puedes usar los botones de abajo.'
                    : 'Abriendo pasarela de pago...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              if (_isChecking) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Verificando estado del pago...'),
              ] else if (!_paymentOpened) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Abriendo Wompi...'),
              ] else ...[
                ElevatedButton(
                  onPressed: _checkPaymentStatus,
                  child: const Text('Verificar Estado Manualmente'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _retryPayment,
                  child: const Text('Reabrir Wompi'),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Referencia: $_referenciaPago',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ] else if (_insertingRenta) ...[
              const Icon(
                Icons.cloud_upload,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Creando Reserva...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Estamos guardando los datos de tu reserva.\n\n'
                'Por favor espera un momento...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ] else ...[
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Pago Confirmado!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Redirigiendo a la confirmación...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
