import 'package:ezride/App/DATA/repositories/Auth/AuthProfileUser_RepositoryData.dart';
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PPROFILE_user_entity.dart';
import 'package:ezride/App/DOMAIN/usecases/Auth/ProfileUser_UseCase.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Actions_widget.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Header_widget.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Information_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileUser extends StatefulWidget {
  const ProfileUser({super.key});

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  Profile? profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      // Llamar tu UseCase para traer el perfil desde el repositorio
      final repository = AuthProfileUserRepositoryData();
      final useCase = ProfileUserUsecase(repository);
      final fetchedProfile = await useCase.call(currentUser.id);

      // Guardar en sesión y estado local
      if (fetchedProfile != null) {
        SessionManager.setProfile(fetchedProfile);
        setState(() {
          profile = fetchedProfile;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final profile = SessionManager.currentProfile;

    // Datos basados únicamente en la entity Profile
    final userData = {
      'userName': profile?.displayName ?? 'Invitado',
      'verificationStatus': profile?.verificationStatus?.name ?? 'pendiente',
    };

    // Información personal usando solo datos disponibles en la entity
    final personalInfoItems = [
      PersonalInfoItem(
        icon: Icons.phone_rounded,
        label: 'Teléfono',
        value: profile?.phone ?? 'No disponible',
      ),
      PersonalInfoItem(
        icon: Icons.person_outlined,
        label: 'Rol',
        value: profile?.role.name ?? 'cliente',
      ),
      PersonalInfoItem(
        icon: Icons.verified_user_outlined,
        label: 'Estado de verificación',
        value: profile?.verificationStatus?.name ?? 'pendiente',
      ),
      PersonalInfoItem(
        icon: Icons.location_on_outlined,
        label: 'País',
        value: profile?.country ?? 'No disponible',
      ),
      PersonalInfoItem(
        icon: Icons.cake_outlined,
        label: 'Fecha de nacimiento',
        value: profile?.dateOfBirth?.toIso8601String() ?? 'No disponible',
      ),
      PersonalInfoItem(
        icon: Icons.badge_outlined,
        label: 'DUI',
        value: profile?.duiNumber ?? 'No disponible',
      ),
      PersonalInfoItem(
        icon: Icons.drive_eta_outlined,
        label: 'Licencia',
        value: profile?.licenseNumber ?? 'No disponible',
      ),
      PersonalInfoItem(
        icon: Icons.calendar_today_rounded,
        label: 'Fecha de registro',
          value: profile?.createdAt != null
              ? DateFormat('dd/MM/yyyy hh:mm a').format(profile!.createdAt)
              : 'No disponible',
        ),
      PersonalInfoItem(
        icon: Icons.score_outlined,
        label: 'Puntuación de verificación',
        value: profile?.verificationScore?.toString() ?? '0',
      ),
    ];

    // Acciones del perfil
    final profileActions = [
      ProfileActionItem(
        title: 'Editar Perfil',
        icon: Icons.edit_outlined,
        iconColor: theme.primary,
        onTap: () {
          print('Editar perfil');
        },
      ),
      ProfileActionItem(
        title: 'Configuración',
        icon: Icons.settings_outlined,
        iconColor: theme.primary,
        onTap: () {
          print('Configuración');
        },
      ),
      ProfileActionItem(
        title: 'Cerrar Sesión',
        icon: Icons.logout_rounded,
        iconColor: theme.error,
        textColor: theme.error,
        onTap: () => _showLogoutDialog(context),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header del perfil
              ProfileHeader(
                imageUrl: 'https://example.com/profile.jpg',
                userName: userData['userName']!,
                verificationStatus: userData['verificationStatus']!,
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Información personal
                    PersonalInfoSection(
                      personalInfoItems: personalInfoItems,
                      title: 'Información Personal',
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      dividerColor: Colors.black.withOpacity(0.2),
                      dividerThickness: 1,
                      dividerIndent: 56,
                      dividerEndIndent: 16,
                    ),

                    const SizedBox(height: 32),

                    // Acciones
                    ProfileActionsSection(
                      sectionTitle: 'Configuración y Más',
                      actions: profileActions,
                      showDividers: true,
                      dividerColor: Colors.black.withOpacity(0.2),
                      dividerThickness: 1,
                      dividerIndent: 56,
                      dividerEndIndent: 16,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                SessionManager.clearProfile();
                Navigator.of(context).pop();
                print('Sesión cerrada');
              },
              child: const Text('Cerrar Sesión',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
