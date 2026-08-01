import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profil_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/state_placeholder.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: Obx(() {
        if (controller.status.value == 'loading') {
          return const StatePlaceholder(type: StatePlaceholderType.loading);
        }
        if (controller.status.value == 'error') {
          return StatePlaceholder.error(
            message: controller.errorMessage.value,
            onAction: () => controller.loadProfile(),
          );
        }

        final user = controller.currentUser.value;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Hero Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 24),
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        Text('Profil utilisateur', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.secondaryLight,
                          child: Text(
                            user?.initials ?? 'CM',
                            style: AppTextStyles.screenTitle.copyWith(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.fullName ?? 'Claire Moreau', style: AppTextStyles.cardNameHero),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user?.roleLabel ?? 'Admin',
                                style: AppTextStyles.badge.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Informations de contact card
                    _buildCard(
                      title: 'Informations de contact',
                      icon: Icons.contact_page_outlined,
                      child: Column(
                        children: [
                          _buildContactRow(Icons.email_outlined, 'Email', 'claire.moreau@clinique.fr'),
                          const SizedBox(height: 12),
                          _buildContactRow(Icons.phone_outlined, 'Téléphone', user?.telephone ?? '+33 6 12 34 56 78'),
                          const SizedBox(height: 12),
                          _buildContactRow(Icons.badge_outlined, 'Rôle', user?.roleLabel ?? 'Admin'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gestion clinique expandable card
                    _buildCard(
                      title: 'Gestion clinique',
                      icon: Icons.business_outlined,
                      child: Column(
                        children: [
                          _buildNavItemTile(Icons.groups_outlined, 'Groupes', () => Get.toNamed(AppRoutes.groupesListe)),
                          _buildNavItemTile(Icons.person_outline, 'Séances individuelles', () => Get.toNamed(AppRoutes.agenda)),
                          _buildNavItemTile(Icons.badge_outlined, 'Employés', () => Get.toNamed(AppRoutes.employesListe)),
                          _buildNavItemTile(Icons.family_restroom_outlined, 'Parents', () => Get.toNamed(AppRoutes.parentsListe)),
                          _buildNavItemTile(Icons.task_alt_outlined, 'Tâches', () => Get.toNamed(AppRoutes.taches)),
                          _buildNavItemTile(Icons.calendar_month_outlined, 'Calendrier administratif', () => Get.toNamed(AppRoutes.calendrier)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Paramètres du compte card
                    _buildCard(
                      title: 'Paramètres du compte',
                      icon: Icons.tune_outlined,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Text('Notifications', style: AppTextStyles.bodyMedium),
                                ],
                              ),
                              Switch(value: true, onChanged: (v) {}),
                            ],
                          ),
                          _buildNavItemTile(Icons.lock_outline, 'Sécurité & mot de passe', () {}),
                          _buildNavItemTile(Icons.language_outlined, 'Langue', () {}, trailingText: 'Français'),
                          _buildNavItemTile(Icons.help_outline, 'Aide & support', () {}),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Déconnexion Button
                    ElevatedButton.icon(
                      onPressed: () => controller.logout(),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Déconnexion'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
            Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildNavItemTile(IconData icon, String title, VoidCallback onTap, {String? trailingText}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.fieldBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
            if (trailingText != null)
              Text(trailingText, style: AppTextStyles.bodySmall)
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
