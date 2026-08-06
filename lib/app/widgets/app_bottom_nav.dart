import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Barre de navigation inférieure — navigation style grandes apps (no push animation).
/// Les onglets principaux ne rechargent PAS leurs données si déjà fraîches (cache TTL).
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  /// Routes principales liées aux onglets du nav bar.
  static const _tabRoutes = [
    AppRoutes.accueil,
    AppRoutes.patientsListe,
    AppRoutes.agenda,
    AppRoutes.profil,
  ];

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
        if (isSelected) return;

        // ── Navigation style grandes applis ──
        // On efface uniquement jusqu'à la dernière route "onglet" pour
        // éviter d'empiler des onglets dans le stack.
        // Transition.noTransition = pas d'animation push/slide.
        Get.offNamedUntil(
          route,
          // Garder les écrans qui NE sont PAS des onglets (ex: patientInfo)
          // mais détruire l'onglet précédent.
          (r) => !_tabRoutes.contains(r.settings.name),
          // ↑ Si vous souhaitez vider complètement le stack, utilisez:
          // (r) => false
        );
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
                color:
                    isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
