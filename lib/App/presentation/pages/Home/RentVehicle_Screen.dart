import 'package:ezride/App/DATA/datasources/Auth/rentas_remote_datasource.dart';
import 'package:ezride/App/DATA/datasources/Auth/vehicle_remote_datasource.dart';
import 'package:ezride/App/DATA/repositories/rentas_repository_data.dart';
import 'package:ezride/App/DOMAIN/usecases/Renta/create_renta_usecase.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Core/widgets/Modals/GlobalModalAction.widget.dart';
import 'package:ezride/Feature/PAY_SUCCESS/Pay_Success_PRESENTATION.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/widgets/appbar_RentVehicleWidgets.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/widgets/bottombar_RentVehicleDetails.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/widgets/costSummaryCard_RentVehicleWidgets.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/widgets/daySelector_RentVehicleWidgets.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/widgets/detailCard_RentVehicleWidgets.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/widgets/infoCard_RentVehicleWidgets.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/widgets/paymentModal_RentVehicleWidgets.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/widgets/timePickerField_RentVehicleWidgets.dart';
import 'package:ezride/Feature/RENTAR_VEHICLE/widgets/timeSelection_RentVehicleWidgets.dart';
import 'package:ezride/Services/api/woompi_pay_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RentVehicleScreen extends StatefulWidget {
  const RentVehicleScreen({
    Key? key,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleType,
    required this.vehicleImageUrl,
    required this.dailyPrice,
    required this.empresaId,
  }) : super(key: key);

  final String vehicleId;
  final String vehicleName;
  final String vehicleType;
  final String vehicleImageUrl;
  final double dailyPrice;
  final String empresaId;

  @override
  State<RentVehicleScreen> createState() => _RentVehicleScreenState();
}

class _RentVehicleScreenState extends State<RentVehicleScreen> {
  String? _selectedDays;
  String _selectedTimeOption = 'Para ahora';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  bool _isLoading = false;
  bool _creandoRenta = false;

  final List<VehicleFeature> _vehicleFeatures = const [
    VehicleFeature(icon: Icons.people, text: '5 pasajeros'),
    VehicleFeature(icon: Icons.settings, text: 'Automático'),
    VehicleFeature(icon: Icons.ac_unit, text: 'Aire acondicionado'),
    VehicleFeature(icon: Icons.local_gas_station, text: 'Gasolina'),
    VehicleFeature(icon: Icons.luggage, text: '4 maletas'),
    VehicleFeature(icon: Icons.security, text: 'Airbags'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDays = '1 día';
    _calculateTotal();
  }

  void _onDaysSelected(String? days) {
    setState(() {
      _selectedDays = days;
    });
    _calculateTotal();
  }

  void _onTimeOptionSelected(String option) {
    setState(() {
      _selectedTimeOption = option;
    });
  }

  void _onTimeSelected(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
  }

  void _calculateTotal() {
    // El cálculo se hace en el getter _totalAmount
  }

  List<CostItem> get _costItems {
    if (_selectedDays == null) return [];

    final days = _getDaysFromSelection(_selectedDays!);
    final dailyPrice = widget.dailyPrice;
    final subtotal = dailyPrice * days;
    final insurance = 0.0 * days;
    final taxes = 0.0 * days;
    final total = subtotal + insurance + taxes;

    return [
      CostItem(
          label: 'Precio por día (x$days días)',
          value: '\$${(dailyPrice * days).toStringAsFixed(2)}'),
      CostItem(label: 'Seguro', value: '\$${insurance.toStringAsFixed(2)}'),
      CostItem(label: 'Impuestos', value: '\$${taxes.toStringAsFixed(2)}'),
    ];
  }

  String get _totalAmount {
    if (_selectedDays == null) return '\$0.00';

    final days = _getDaysFromSelection(_selectedDays!);
    final dailyPrice = widget.dailyPrice;
    const insurance = 0.0;
    const taxes = 0.0;

    final total = (dailyPrice + insurance + taxes) * days;
    return '\$${total.toStringAsFixed(2)}';
  }

  double get _totalNumerico {
    if (_selectedDays == null) return 0.0;

    final days = _getDaysFromSelection(_selectedDays!);
    final dailyPrice = widget.dailyPrice;

    return (dailyPrice) * days;
  }

  String get _dailyPriceFormatted {
    return '\$${widget.dailyPrice.toStringAsFixed(2)}/día';
  }

  String get _periodForModal {
    if (_selectedDays == null) return 'Diario';

    final days = _getDaysFromSelection(_selectedDays!);
    if (days >= 7 && days < 30) return 'Semanal';
    if (days >= 30) return 'Mensual';
    return 'Diario';
  }

  String get _amountForModal {
    if (_selectedDays == null) return '\$0';

    final days = _getDaysFromSelection(_selectedDays!);
    final dailyPrice = widget.dailyPrice;


    final total = (dailyPrice) * days;
    return '\$${total.toStringAsFixed(0)}';
  }

  int _getDaysFromSelection(String selection) {
    switch (selection) {
      case '1 día':
        return 1;
      case '2 días':
        return 2;
      case '3 días':
        return 3;
      case '4 días':
        return 4;
      case '5 días':
        return 5;
      case '7 días':
        return 7;
      case '10 días':
        return 10;
      case '14 días':
        return 14;
      case '21 días':
        return 21;
      default:
        return 1;
    }
  }

  void _onBottomBarPayPressed() {
    if (_selectedDays == null) {
      _showDaysSelectionRequiredDialog();
      return;
    }

    _showPaymentConfirmationModal();
  }

  void _showDaysSelectionRequiredDialog() {
    showGlobalStatusModalAction(
      context,
      title: 'Días requeridos',
      message: 'Por favor selecciona los días de renta antes de continuar con el pago.',
      icon: Icons.calendar_today,
      confirmText: 'Aceptar',
    );
  }

  void _showPaymentConfirmationModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PaymentModalRentVehicleWidgets(
        amount: _amountForModal,
        period: _periodForModal,
        onPayPressed: _crearRentaYProcesarPago,
      ),
    );
  }

  Future<void> _crearRentaYProcesarPago() async {
    Navigator.of(context).pop();

    setState(() {
      _creandoRenta = true;
    });

    try {
      final cliente = SessionManager.currentProfile;
      if (cliente == null) {
        _mostrarError(
            "Sesión Requerida", "Debes iniciar sesión para crear una renta");
        return;
      }

      final descripcion =
          "Renta ${widget.vehicleName} - ${_selectedDays ?? '1 día'}";

      final paymentResult = await WompiPaymentService.generatePaymentLink(
        amount: _totalNumerico,
        description: descripcion,
        clientId: cliente.id,
        rentaId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      );

// ✅ AGREGAR ESTO TEMPORALMENTE PARA DEBUGGEAR
      print('🔍 DEBUG MONTO:');
      print('  - _totalNumerico: $_totalNumerico');
      print('  - dailyPrice: ${widget.dailyPrice}');
      print('  - días: ${_getDaysFromSelection(_selectedDays!)}');
      print('  - montoCents enviado: ${(_totalNumerico).toInt()}');

      if (!paymentResult.success || paymentResult.paymentUrl == null) {
        _mostrarError("Error de Pago",
            paymentResult.error ?? "No se pudo generar el enlace de pago");
        return;
      }

      // ✅ CORREGIDO: Pasar los 4 argumentos requeridos
      _navigateToPaymentPendingScreen(
          'pending_${DateTime.now().millisecondsSinceEpoch}', // tempRentaId
          paymentResult.reference!, // referenciaPago
          paymentResult.paymentUrl!, // paymentUrl
          cliente.id // clienteId
          );
    } catch (e) {
      print('❌ Error procesando pago: $e');
      _mostrarError("Error", "Error procesando el pago: $e");
    } finally {
      setState(() {
        _creandoRenta = false;
      });
    }
  }

  // ✅ MÉTODO CORREGIDO - Ahora recibe 4 parámetros
  void _navigateToPaymentPendingScreen(
      String tempRentaId,
      String referenciaPago,
      String paymentUrl,
      String clienteId // ✅ CUARTO PARÁMETRO AÑADIDO
      ) {
    final reservationData = _calculateReservationData();
    final fechaInicio = _calcularFechaInicio();
    final fechaFin = _calcularFechaFin(fechaInicio);

    context.go(
      '/payment-pending',
      extra: {
        'tempRentaId': tempRentaId,
        'referenciaPago': referenciaPago,
        'paymentUrl': paymentUrl,
        'vehicleId': widget.vehicleId,
        'empresaId': widget.empresaId,
        'clienteId': clienteId,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'total': _totalNumerico,
        'vehicleName': widget.vehicleName,
        'vehicleType': widget.vehicleType,
        'vehicleImageUrl': widget.vehicleImageUrl,
        'startDate': reservationData['startDate']!,
        'endDate': reservationData['endDate']!,
        'duration': reservationData['duration']!,
        'totalAmount': _totalAmount,
      },
    );
  }

  DateTime _calcularFechaInicio() {
    final now = DateTime.now();

    if (_selectedTimeOption == 'Para ahora') {
      return DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
    } else {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
    }
  }

  DateTime _calcularFechaFin(DateTime fechaInicio) {
    final days =
        _selectedDays != null ? _getDaysFromSelection(_selectedDays!) : 1;
    return fechaInicio.add(Duration(days: days));
  }

  void _mostrarError(String titulo, String mensaje) {
    showGlobalStatusModalAction(
      context,
      title: titulo,
      message: mensaje,
      icon: Icons.error,
      iconColor: Colors.red,
      confirmText: "OK",
    );
  }

  void _mostrarExitoYProcesarPago(String rentaId) {
    _redirectToPaymentGateway(rentaId);
  }

  void _redirectToPaymentGateway(String rentaId) {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      _navigateToPayConfirmScreen(rentaId);
    });
  }

  void _navigateToPayConfirmScreen(String rentaId) {
    final reservationData = _calculateReservationData();

    context.go(
      '/pay-confirm',
      extra: {
        'rentaId': rentaId,
        'vehicleName': widget.vehicleName,
        'vehicleType': widget.vehicleType,
        'vehicleImageUrl': widget.vehicleImageUrl,
        'startDate': reservationData['startDate']!,
        'endDate': reservationData['endDate']!,
        'duration': reservationData['duration']!,
        'totalAmount': _totalAmount,
      },
    );
  }

  Map<String, String> _calculateReservationData() {
    final days =
        _selectedDays != null ? _getDaysFromSelection(_selectedDays!) : 1;
    final startDate = _calcularFechaInicio();
    final endDate = _calcularFechaFin(startDate);

    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];

    final startDateFormatted =
        '${startDate.day} ${months[startDate.month - 1]} ${startDate.year}, ${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour >= 12 ? 'PM' : 'AM'}';
    final endDateFormatted =
        '${endDate.day} ${months[endDate.month - 1]} ${endDate.year}, ${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour >= 12 ? 'PM' : 'AM'}';

    return {
      'startDate': startDateFormatted,
      'endDate': endDateFormatted,
      'duration': '$days ${days == 1 ? 'día' : 'días'}',
    };
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppbarRentVehicleDetails(
        onBackPressed: _onBackPressed,
        title: 'Rentar Vehículo',
      ),
      body: _buildBody(),
      bottomNavigationBar: OptimizedRentBottomBar(
        totalAmount: _totalAmount,
        onPayPressed: _onBottomBarPayPressed,
        isLoading: _isLoading || _creandoRenta,
        enabled: _selectedDays != null && !_creandoRenta,
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              DetailCardRentVehiclewidgets(
                vehicleName: widget.vehicleName,
                vehicleType: widget.vehicleType,
                imageUrl: widget.vehicleImageUrl,
                features: _vehicleFeatures,
                dailyPrice: _dailyPriceFormatted,
              ),
              const SizedBox(height: 16),
              OptimizedTimeSelectionRentVehicleWidgets(
                onTimeSelected: _onTimeOptionSelected,
                initialSelection: _selectedTimeOption,
              ),
              const SizedBox(height: 16),
              OptimizedDaysDropdown(
                onDaysSelected: _onDaysSelected,
                initialValue: _selectedDays,
              ),
              const SizedBox(height: 16),
              OptimizedTimePickerField(
                onTimeSelected: _onTimeSelected,
                initialTime: _selectedTime,
              ),
              const SizedBox(height: 16),
              InfocardRentVehiclewidgets(
                returnDate: _calculateReturnDate(),
                returnTime:
                    '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                mainInstruction:
                    'Asegúrate de devolver el vehículo a tiempo para evitar cargos adicionales.',
                additionalInfo:
                    'La devolución tardía puede generar cargos adicionales.',
              ),
              const SizedBox(height: 16),
              CostSummaryCardRentVehicleWidgets(
                costItems: _costItems,
                subtotal: _totalAmount,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        if (_creandoRenta)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Creando reserva...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _calculateReturnDate() {
    final now = DateTime.now();
    final days =
        _selectedDays != null ? _getDaysFromSelection(_selectedDays!) : 1;
    final returnDate = now.add(Duration(days: days));

    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    return '${returnDate.day} de ${months[returnDate.month - 1]}, ${returnDate.year}';
  }
}
