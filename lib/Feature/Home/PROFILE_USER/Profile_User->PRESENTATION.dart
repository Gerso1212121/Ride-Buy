import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Actions_widget.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Header_widget.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Information_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class ProfileUser extends StatelessWidget {
  const ProfileUser({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    // Datos de ejemplo - puedes reemplazar con datos reales
    final userData = {
      'imageUrl': 'https://example.com/profile.jpg',
      'userName': 'Juan Pérez',
      'verificationStatus': 'Verificado',
    };

    // Información personal
    final personalInfoItems = [
      PersonalInfoItem(
        icon: Icons.email_outlined,
        label: 'Correo electrónico',
        value: 'juan.perez@example.com',
      ),
      PersonalInfoItem(
        icon: Icons.phone_rounded,
        label: 'Teléfono',
        value: '+1 234 567 8900',
      ),
      PersonalInfoItem(
        icon: Icons.calendar_today_rounded,
        label: 'Fecha de registro',
        value: '15 de Enero, 2024',
      ),
      PersonalInfoItem(
        icon: Icons.location_on_outlined,
        label: 'Ubicación',
        value: 'Ciudad de México, MX',
      ),
    ];

    // Acciones del perfil
    final profileActions = [
      ProfileActionItem(
        title: 'Editar Perfil',
        icon: Icons.edit_outlined,
        iconColor: theme.primary,
        onTap: () {
          // Navegar a edición de perfil
          print('Editar perfil');
        },
      ),
      ProfileActionItem(
        title: 'Configuración',
        icon: Icons.settings_outlined,
        iconColor: theme.primary,
        onTap: () {
          // Navegar a configuración
          print('Configuración');
        },
      ),
      ProfileActionItem(
        title: 'Historial de Viajes',
        icon: Icons.history_rounded,
        iconColor: theme.primary,
        onTap: () {
          // Navegar a historial
          print('Historial de viajes');
        },
      ),
      ProfileActionItem(
        title: 'Métodos de Pago',
        icon: Icons.payment_rounded,
        iconColor: theme.primary,
        onTap: () {
          // Navegar a métodos de pago
          print('Métodos de pago');
        },
      ),
      ProfileActionItem(
        title: 'Ayuda y Soporte',
        icon: Icons.help_outline_rounded,
        iconColor: theme.primary,
        onTap: () {
          // Navegar a ayuda
          print('Ayuda y soporte');
        },
      ),
      ProfileActionItem(
        title: 'Cerrar Sesión',
        icon: Icons.logout_rounded,
        iconColor: theme.error,
        textColor: theme.error,
        onTap: () {
          // Cerrar sesión
          _showLogoutDialog(context);
        },
      ),
    ];

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header del perfil
              ProfileHeader(
                imageUrl: userData['imageUrl']!,
                userName: userData['userName']!,
                verificationStatus: userData['verificationStatus']!,
              ),

              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Sección de información personal
                    PersonalInfoSection(
                      personalInfoItems: personalInfoItems,
                      title: 'Información Personal',
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      dividerColor:
                          Colors.black.withOpacity(0.2), // ← MISMO COLOR
                      dividerThickness: 1, // ← MISMO GROSOR
                      dividerIndent: 56, // ← MISMO ESPACIO IZQUIERDO
                      dividerEndIndent: 16, // ← MISMO ESPACIO DERECHO
                    ),

                    const SizedBox(height: 32),

                    // Sección de acciones
                    ProfileActionsSection(
                      sectionTitle: 'Configuración y Más',
                      actions: profileActions,
                      showDividers: true,
                      dividerColor:
                          Colors.black.withOpacity(0.2), // ← MISMO COLOR
                      dividerThickness: 1, // ← MISMO GROSOR
                      dividerIndent: 56, // ← MISMO ESPACIO IZQUIERDO
                      dividerEndIndent: 16, // ← MISMO ESPACIO DERECHO
                      containerBorderColor: Colors.transparent,
                      containerBorderWidth: 0,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: theme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.titleLarge?.copyWith(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
            letterSpacing: 0.0,
          ),
        ),
        Text(
          label,
          style: theme.labelMedium?.copyWith(
            fontFamily: 'Figtree',
            color: theme.secondaryText,
            letterSpacing: 0.0,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Lógica para cerrar sesión
                Navigator.of(context).pop();
                // Aquí iría la lógica real de logout
                print('Sesión cerrada');
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
