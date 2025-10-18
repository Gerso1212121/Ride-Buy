import 'package:flutter/material.dart';
import 'widgets/Pay_AppBar_widget.dart';
import 'widgets/Pay_IconAnimation.dart';
import 'widgets/Pay_ResumeCard_widget.dart';
import 'widgets/Pay_PrimaryButton_widget.dart';
import 'widgets/Pay_SecondaryButton_widget.dart';

class PayConfirmScreen extends StatelessWidget {
  const PayConfirmScreen({Key? key}) : super(key: key);

  void _onClosePressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _onViewReservationPressed(BuildContext context) {
    // Navegar a pantalla de reservas
    print('Navegar a mis reservas');
    // Navigator.push(context, MaterialPageRoute(builder: (_) => ReservationScreen()));
  }

  void _onBackToHomePressed(BuildContext context) {
    // Navegar al home y limpiar stack
    print('Volver al inicio');
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppbarPaycWidgets(
        onClosePressed: () => _onClosePressed(context),
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

              // Resumen de la transacción
              ResumeCardPaycWidgets(
                vehicleImageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e',
                vehicleName: 'BMW Serie 3 2024',
                vehicleType: 'Sedán Premium',
                startDate: '15 Dic 2024, 10:00 AM',
                endDate: '18 Dic 2024, 10:00 AM',
                duration: '3 días',
                paymentMethod: 'Visa **** 4242',
                totalAmount: '\$2,850.00 MXN',
              ),

              const SizedBox(height: 32),

              // Información adicional (opcional)
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
          onPressed: () => _onViewReservationPressed(context),
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