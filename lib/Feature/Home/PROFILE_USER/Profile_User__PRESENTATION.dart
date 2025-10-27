import 'package:ezride/App/DATA/repositories/Auth/ProfileUser_RepositoryData.dart';
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PROFILE_user_entity.dart';
import 'package:ezride/App/DOMAIN/usecases/Auth/Auth_UseCase.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Actions_widget.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Header_widget.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Information_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileUser extends StatefulWidget {
  const ProfileUser({super.key});

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  Profile? profile;

  late final ProfileUserUseCaseGlobal profileUserUseCaseGlobal;

  @override
  void initState() {
    super.initState();
    final supabaseClient = Supabase.instance.client;
    final userRepository = ProfileUserRepositoryData(supabaseClient);
    profileUserUseCaseGlobal = ProfileUserUseCaseGlobal(userRepository);

    _loadProfile(); // Cargar perfil al iniciar
  }

  Future<void> _loadProfile() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      try {
        final fetchedProfile =
            await profileUserUseCaseGlobal.getProfile(currentUser.id);

        // Guardar en sesión y estado local
        if (fetchedProfile != null) {
          SessionManager.setProfile(fetchedProfile);
          setState(() {
            profile = fetchedProfile;
          });
        }
      } catch (e) {
        print('Error loading profile: $e');
      }
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Cerrar Sesión'),
            content: isLoading
                ? const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const Text('¿Estás seguro de que quieres cerrar sesión?'),
            actions: isLoading
                ? []
                : [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        setState(() => isLoading = true);

                        // ✅ Usar el use case global para logout
                        final success = await profileUserUseCaseGlobal.logout();

                        setState(() => isLoading = false);

                        if (success) {
                          // Limpiar sesión local
                          await SessionManager.clearProfile();

                          // Navegar al auth
                          if (context.mounted) {
                            GoRouter.of(context).push('/auth');
                          }
                        } else {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Error al cerrar sesión')),
                            );
                          }
                        }
                      },
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final currentProfile = profile ?? SessionManager.currentProfile;

    // Datos basados únicamente en la entity Profile
    final userData = {
      'userName': currentProfile?.displayName ?? 'Invitado',
      'verificationStatus':
          currentProfile?.verificationStatus?.name ?? 'pendiente',
    };

    // Información personal usando solo datos disponibles en la entity
    final personalInfoItems = [
      PersonalInfoItem(
        icon: Icons.phone_rounded,
        label: 'Teléfono',
        value: currentProfile?.phone ?? 'No disponible',
      ),
      PersonalInfoItem(
        icon: Icons.person_outlined,
        label: 'Rol',
        value: currentProfile?.role?.name ?? 'cliente',
      ),
      PersonalInfoItem(
        icon: Icons.verified_user_outlined,
        label: 'Estado de verificación',
        value: currentProfile?.verificationStatus?.name ?? 'pendiente',
      ),
      PersonalInfoItem(
        icon: Icons.cake_outlined,
        label: 'Fecha de nacimiento',
        value:
            currentProfile?.dateOfBirth?.toIso8601String() ?? 'No disponible',
      ),
      PersonalInfoItem(
        icon: Icons.badge_outlined,
        label: 'DUI',
        value: currentProfile?.duiNumber ?? 'No disponible',
      ),
      PersonalInfoItem(
        icon: Icons.drive_eta_outlined,
        label: 'Licencia',
        value: currentProfile?.licenseNumber ?? 'No disponible',
      ),
      PersonalInfoItem(
        icon: Icons.calendar_today_rounded,
        label: 'Fecha de registro',
        value: currentProfile?.createdAt != null
            ? DateFormat('dd/MM/yyyy hh:mm a').format(currentProfile!.createdAt)
            : 'No disponible',
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
}
