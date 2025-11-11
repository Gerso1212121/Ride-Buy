import 'package:ezride/App/presentation/widgets/profile_scroll_content_body.dart';
import 'package:flutter/material.dart';
import 'package:ezride/App/presentation/widgets/profile_screen_models.dart';

class ProfileScrollContent extends StatelessWidget {
  final ScrollController controller;
  final ProfileData profileData;
  final VoidCallback onContact;
  final VoidCallback onViewCars;
  final VoidCallback onOpenLocation;
  final bool isLoading;
  final bool hasInitialData;

  const ProfileScrollContent({
    super.key,
    required this.controller,
    required this.profileData,
    required this.onContact,
    required this.onViewCars,
    required this.onOpenLocation,
    this.isLoading = false,
    this.hasInitialData = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
        const SliverAppBar(
          expandedHeight: 250,
          flexibleSpace: SizedBox(),
          pinned: false,
          snap: false,
          floating: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          collapsedHeight: 0,
        ),
        SliverToBoxAdapter(
          child: isLoading
              ? _buildLoadingState()
              : ProfileContentBody(
                  profileData: profileData,
                  onContact: onContact,
                  onViewCars: onViewCars,
                  onOpenLocation: onOpenLocation,
                  hasInitialData: hasInitialData,
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando perfil de la empresa...'),
          ],
        ),
      ),
    );
  }
}