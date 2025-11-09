import 'package:ezride/Feature/PAY_SUCCESS/Pay_Success_PRESENTATION.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../Feature/RENTAR_VEHICLE/widgets/appbar_RentVehicleWidgets.dart';
import '../../../../Feature/RENTAR_VEHICLE/widgets/bottombar_RentVehicleDetails.dart';
import '../../../../Feature/RENTAR_VEHICLE/widgets/costSummaryCard_RentVehicleWidgets.dart';
import '../../../../Feature/RENTAR_VEHICLE/widgets/daySelector_RentVehicleWidgets.dart';
import '../../../../Feature/RENTAR_VEHICLE/widgets/detailCard_RentVehicleWidgets.dart';
import '../../../../Feature/RENTAR_VEHICLE/widgets/infoCard_RentVehicleWidgets.dart';
import '../../../../Feature/RENTAR_VEHICLE/widgets/paymentModal_RentVehicleWidgets.dart';
import '../../../../Feature/RENTAR_VEHICLE/widgets/timePickerField_RentVehicleWidgets.dart';
import '../../../../Feature/RENTAR_VEHICLE/widgets/timeSelection_RentVehicleWidgets.dart';

class RentVehicleScreen extends StatefulWidget {
  const RentVehicleScreen({
    Key? key,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleType,
    required this.vehicleImageUrl,
    required this.dailyPrice,
  }) : super(key: key);

  final String vehicleId;
  final String vehicleName;
  final String vehicleType;
  final String vehicleImageUrl;
  final double dailyPrice;

  @override
  State<RentVehicleScreen> createState() => _RentVehicleScreenState();
}

class _RentVehicleScreenState extends State<RentVehicleScreen> {
  String? _selectedDays;
  String _selectedTimeOption = 'Para ahora';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  bool _isLoading = false;

  // Datos de ejemplo para el vehículo
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
    // Seleccionar 1 día por defecto
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

  // Obtener los costos basados en la selección actual
  List<CostItem> get _costItems {
    if (_selectedDays == null) return [];
    
    final days = _getDaysFromSelection(_selectedDays!);
    final dailyPrice = widget.dailyPrice;
    final subtotal = dailyPrice * days;
    final insurance = 50.0 * days;
    final taxes = 30.0 * days;
    final total = subtotal + insurance + taxes;

    return [
      CostItem(
        label: 'Precio por día (x$days días)', 
        value: '\$${(dailyPrice * days).toStringAsFixed(2)}'
      ),
      CostItem(label: 'Seguro', value: '\$${insurance.toStringAsFixed(2)}'),
      CostItem(label: 'Impuestos', value: '\$${taxes.toStringAsFixed(2)}'),
    ];
  }

  String get _totalAmount {
    if (_selectedDays == null) return '\$0.00';
    
    final days = _getDaysFromSelection(_selectedDays!);
    final dailyPrice = widget.dailyPrice;
    const insurance = 50.0;
    const taxes = 30.0;
    
    final total = (dailyPrice + insurance + taxes) * days;
    return '\$${total.toStringAsFixed(2)}';
  }

  String get _dailyPriceFormatted {
    return '\$${widget.dailyPrice.toStringAsFixed(2)}/día';
  }

  // Obtener el período formateado para el modal
  String get _periodForModal {
    if (_selectedDays == null) return 'Diario';
    
    final days = _getDaysFromSelection(_selectedDays!);
    if (days >= 7 && days < 30) return 'Semanal';
    if (days >= 30) return 'Mensual';
    return 'Diario';
  }

  // Obtener el monto formateado para el modal
  String get _amountForModal {
    if (_selectedDays == null) return '\$0';
    
    final days = _getDaysFromSelection(_selectedDays!);
    final dailyPrice = widget.dailyPrice;
    const insurance = 50.0;
    const taxes = 30.0;
    
    final total = (dailyPrice + insurance + taxes) * days;
    return '\$${total.toStringAsFixed(0)}'; // Sin decimales para el modal
  }

  int _getDaysFromSelection(String selection) {
    switch (selection) {
      case '1 día': return 1;
      case '2 días': return 2;
      case '3 días': return 3;
      case '4 días': return 4;
      case '5 días': return 5;
      case '7 días': return 7;
      case '10 días': return 10;
      case '14 días': return 14;
      case '21 días': return 21;
      default: return 1;
    }
  }

  void _onBottomBarPayPressed() {
    if (_selectedDays == null) {
      _showDaysSelectionRequiredDialog();
      return;
    }

    // Mostrar modal de confirmación de pago
    _showPaymentConfirmationModal();
  }

  void _showDaysSelectionRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Días requeridos',
          style: TextStyle(
            color: Color(0xFF081535),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text('Por favor selecciona los días de renta antes de continuar con el pago.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Aceptar',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentConfirmationModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PaymentModalRentVehicleWidgets(
        amount: _amountForModal,
        period: _periodForModal,
        onPayPressed: _redirectToPaymentGateway,
        
      ),
    );
  }

  void _redirectToPaymentGateway() {
    setState(() {
      _isLoading = true;
    });

    // Cerrar el modal primero
    Navigator.of(context).pop();

    // Simular redirección a pasarela de pago
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      _navigateToPayConfirmScreen();
    });
  }

void _navigateToPayConfirmScreen() {
  final reservationData = _calculateReservationData();
  
  // Usamos GoRouter para navegar a la pantalla de confirmación de pago
  context.goNamed(
    'pay-confirm',
    extra: {
      'vehicleName': widget.vehicleName,
      'vehicleType': widget.vehicleType,
      'vehicleImageUrl': widget.vehicleImageUrl,
      'startDate': reservationData['startDate']!,
      'endDate': reservationData['endDate']!,
      'duration': reservationData['duration']!,
      'totalAmount': _totalAmount,
      // paymentMethod se puede omitir porque tiene valor por defecto
    },
  );
}

  Map<String, String> _calculateReservationData() {
    final days = _selectedDays != null ? _getDaysFromSelection(_selectedDays!) : 1;
    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: days));
    
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    final startDateFormatted = '${startDate.day} ${months[startDate.month - 1]} ${startDate.year}, ${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour >= 12 ? 'PM' : 'AM'}';
    final endDateFormatted = '${endDate.day} ${months[endDate.month - 1]} ${endDate.year}, ${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour >= 12 ? 'PM' : 'AM'}';
    
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
        isLoading: _isLoading,
        enabled: _selectedDays != null,
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          // Tarjeta de detalles del vehículo
          DetailCardRentVehiclewidgets(
            vehicleName: widget.vehicleName,
            vehicleType: widget.vehicleType,
            imageUrl: widget.vehicleImageUrl,
            features: _vehicleFeatures,
            dailyPrice: _dailyPriceFormatted,
          ),
          
          const SizedBox(height: 16),
          
          // Selector de cuándo necesitas el vehículo
          OptimizedTimeSelectionRentVehicleWidgets(
            onTimeSelected: _onTimeOptionSelected,
            initialSelection: _selectedTimeOption,
          ),
          
          const SizedBox(height: 16),
          
          // Selector de días de renta
          OptimizedDaysDropdown(
            onDaysSelected: _onDaysSelected,
            initialValue: _selectedDays,
          ),
          
          const SizedBox(height: 16),
          
          // Selector de hora de recogida
          OptimizedTimePickerField(
            onTimeSelected: _onTimeSelected,
            initialTime: _selectedTime,
          ),
          
          const SizedBox(height: 16),
          
          // Card de información de devolución
          InfocardRentVehiclewidgets(
            returnDate: _calculateReturnDate(),
            returnTime: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            mainInstruction: 'Asegúrate de devolver el vehículo a tiempo para evitar cargos adicionales.',
            additionalInfo: 'La devolución tardía puede generar cargos adicionales.',
          ),
          
          const SizedBox(height: 16),
          
          // Resumen de costos
          CostSummaryCardRentVehicleWidgets(
            costItems: _costItems,
            subtotal: _totalAmount,
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _calculateReturnDate() {
    final now = DateTime.now();
    final days = _selectedDays != null ? _getDaysFromSelection(_selectedDays!) : 1;
    final returnDate = now.add(Duration(days: days));
    
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${returnDate.day} de ${months[returnDate.month - 1]}, ${returnDate.year}';
  }
}