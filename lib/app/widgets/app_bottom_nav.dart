import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Barre de navigation inférieure flottante style iOS, identique aux maquettes.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppColors.cardShadow,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Accueil',
                route: AppRoutes.accueil,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.people_alt_rounded,
                label: 'Patients',
                route: AppRoutes.patientsListe,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.calendar_month_rounded,
                label: 'Agenda',
                route: AppRoutes.agenda,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_rounded,
                label: 'Profil',
                route: AppRoutes.profil,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isSelected = index == currentIndex;

    return InkWell(
      onTap: () {
        if (!isSelected) {
          Get.offNamed(route);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.navLabel.copyWith(
                color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
