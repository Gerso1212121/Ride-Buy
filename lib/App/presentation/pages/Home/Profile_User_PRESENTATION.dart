import 'package:dio/dio.dart';
import 'package:ezride/App/DATA/repositories/Auth/ProfileUser_RepositoryData.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';
import 'package:ezride/App/DOMAIN/usecases/Auth/Auth_UseCase.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Core/widgets/Modals/GlobalModalAction.widget.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Actions_widget.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Header_widget.dart';
import 'package:ezride/Feature/Home/PROFILE_USER/widget/ProfileUser_Information_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProfileUser extends StatefulWidget {
  const ProfileUser({super.key});

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  Profile? profile;
  late final ProfileUserUseCaseGlobal profileUserUseCaseGlobal;
  VoidCallback? _routerListener;

  @override
  void initState() {
    super.initState();

    final userRepository = ProfileUserRepositoryData(dio: Dio());
    profileUserUseCaseGlobal = ProfileUserUseCaseGlobal(userRepository);

    _loadProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _routerListener = () {
        if (!mounted) return; // ✅ evitar usar context muerto

        final currentRoute =
            GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

        if (currentRoute.contains('/main')) {
          _loadProfile();
        }
      };

      GoRouter.of(context).routerDelegate.addListener(_routerListener!);
    });
  }

  Future<void> _loadProfile() async {
    try {
      final local = await SessionManager.loadSession();

      if (local == null) {
        if (mounted) context.go('/auth');
        return;
      }

      if (mounted) {
        setState(() => profile = local);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar perfil')),
        );
      }
    }
  }

  @override
  void dispose() {
    if (_routerListener != null) {
      GoRouter.of(context).routerDelegate.removeListener(_routerListener!);
    }
    super.dispose();
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    showGlobalStatusModalAction(
      context,
      title: "Cerrar sesión",
      message: "¿Quieres cerrar tu sesión?",
      icon: Icons.logout_rounded,
      confirmText: "Cerrar sesión",
      cancelText: "Cancelar",
      onConfirm: () async {
        // Mostrar loading modal
        showGlobalStatusModalAction(
          context,
          title: "Cerrando sesión...",
          isLoading: true,
        );

        final success = await profileUserUseCaseGlobal.logout();

        if (success) {
          await SessionManager.clearProfile();
          if (context.mounted) GoRouter.of(context).go('/auth');
        }

        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      onCancel: () {
        // no haces nada, solo cierra modal
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final currentProfile = profile ?? SessionManager.currentProfile;

    final userData = {
      'userName': currentProfile?.displayName ?? 'Invitado',
      'verificationStatus':
          currentProfile?.verificationStatus?.name ?? 'pendiente',
    };

    final personalInfoItems = [
      PersonalInfoItem(
          icon: Icons.phone_rounded,
          label: 'Teléfono',
          value: currentProfile?.phone ?? 'No disponible'),
      PersonalInfoItem(
          icon: Icons.person_outlined,
          label: 'Rol',
          value: currentProfile?.role?.name ?? 'cliente'),
      PersonalInfoItem(
          icon: Icons.verified_user_outlined,
          label: 'Estado de verificación',
          value: currentProfile?.verificationStatus?.name ?? 'pendiente'),
      PersonalInfoItem(
          icon: Icons.cake_outlined,
          label: 'Fecha de nacimiento',
          value: currentProfile?.dateOfBirth?.toIso8601String() ??
              'No disponible'),
      PersonalInfoItem(
          icon: Icons.badge_outlined,
          label: 'DUI',
          value: currentProfile?.duiNumber ?? 'No disponible'),
      PersonalInfoItem(
          icon: Icons.drive_eta_outlined,
          label: 'Licencia',
          value: currentProfile?.licenseNumber ?? 'No disponible'),
      PersonalInfoItem(
        icon: Icons.calendar_today_rounded,
        label: 'Fecha de registro',
        value: currentProfile?.createdAt != null
            ? DateFormat('dd/MM/yyyy hh:mm a').format(currentProfile!.createdAt)
            : 'No disponible',
      ),
    ];

    final profileActions = [
      ProfileActionItem(
        title: 'Registrar Empresa',
        icon: Icons.business_rounded,
        iconColor: theme.primary,
        onTap: () {
          context.push('/empresa-registro');
        },
      ),
      ProfileActionItem(
        title: 'Configuración',
        icon: Icons.settings_outlined,
        iconColor: theme.primary,
        onTap: () {},
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
              ProfileHeader(
                imageUrl:
                    'https://ui-avatars.com/api/?name=${userData['userName']}', // Avatar dinámico
                userName: userData['userName']!,
                verificationStatus: userData['verificationStatus']!,
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
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
