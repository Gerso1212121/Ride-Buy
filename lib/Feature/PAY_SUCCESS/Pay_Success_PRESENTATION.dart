import 'package:ezride/Feature/PAY_SUCCESS/widgets/Pay_AppBar_widget.dart';
import 'package:ezride/Feature/PAY_SUCCESS/widgets/Pay_IconAnimation.dart';
import 'package:ezride/Feature/PAY_SUCCESS/widgets/Pay_PrimaryButton_widget.dart';
import 'package:ezride/Feature/PAY_SUCCESS/widgets/Pay_ResumeCard_widget.dart';
import 'package:ezride/Feature/PAY_SUCCESS/widgets/Pay_SecondaryButton_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PayConfirmScreen extends StatelessWidget {
  const PayConfirmScreen({
    Key? key,
    required this.vehicleName,
    required this.vehicleType,
    required this.vehicleImageUrl,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.totalAmount,
    this.paymentMethod = 'Visa **** 4242', // Valor por defecto
  }) : super(key: key);

  final String vehicleName;
  final String vehicleType;
  final String vehicleImageUrl;
  final String startDate;
  final String endDate;
  final String duration;
  final String totalAmount;
  final String paymentMethod;

  void _onClosePressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _onViewReservationPressed(BuildContext context) {
    // Navegar a pantalla de reservas
    print('Navegar a mis reservas');
    // Navigator.push(context, MaterialPageRoute(builder: (_) => ReservationScreen()));
  }

void _onBackToHomePressed(BuildContext context) async {
  print('Volver al inicio');


  // 3️⃣ Limpia el stack (quita la pantalla anterior)
  GoRouter.of(context).go('/main');
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppbarPaycWidgets(
        onClosePressed: () => _onBackToHomePressed(context),
        title: 'Confirmación de pago',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Widget de éxito
              const SucessPaycWidgets(
                title: '¡Pago realizado con éxito!',
                subtitle: 'Tu reserva ha sido confirmada. Recibirás un email con todos los detalles de tu reserva.',
              ),

              const SizedBox(height: 32),

              // Resumen de la transacción con datos dinámicos
              ResumeCardPaycWidgets(
                vehicleImageUrl: vehicleImageUrl,
                vehicleName: vehicleName,
                vehicleType: vehicleType,
                startDate: startDate,
                endDate: endDate,
                duration: duration,
                paymentMethod: paymentMethod,
                totalAmount: totalAmount,
              ),

              const SizedBox(height: 32),

              // Información adicional
              _buildAdditionalInfo(),

              const SizedBox(height: 40),

              // Botones de acción
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: const Color(0xFF0EA5E9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Información importante',
                style: TextStyle(
                  color: const Color(0xFF0C4A6E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Presenta tu identificación y licencia de conducir al recoger el vehículo.\n• Llega 15 minutos antes de tu horario de recogida.\n• Revisa el vehículo antes de salir del estacionamiento.',
            style: TextStyle(
              color: const Color(0xFF0C4A6E),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        PrimaryButtonPaycWidgets(
          onPressed: () => _onBackToHomePressed(context),
          text: 'Ver mi reserva',
        ),
        const SizedBox(height: 12),
        SecondaryButtonPaycWidgets(
          onPressed: () => _onBackToHomePressed(context),
          text: 'Volver al inicio',
        ),
      ],
    );
  }
}