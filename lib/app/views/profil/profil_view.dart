import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profil_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/status_badge.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      appBar: const CreativeAppBar(
        title: 'Mon Espace Praticien',
        subtitle: 'Profil & Paramètres',
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
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
          final isAdmin = user?.role == 'admin';

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 12, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Carte Profil En-tête iOS ──
                IosCard(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          PatientAvatar(
                            initials: user?.initials ?? 'U',
                            radius: 30,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.fullName ?? 'Utilisateur', style: AppTextStyles.iosTitle2),
                                const SizedBox(height: 2),
                                Text('@${user?.username ?? "user"}', style: AppTextStyles.iosFootnote),
                                const SizedBox(height: 6),
                                StatusBadge.active(label: user?.roleLabel ?? 'Employé'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Coordonnées ──
                IosCard(
                  title: 'Coordonnées & Compte',
                  children: [
                    IosCardTile(
                      leading: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                      title: 'Téléphone',
                      subtitle: user?.telephone != null && user!.telephone!.isNotEmpty
                          ? user.telephone!
                          : 'Non renseigné',
                    ),
                    IosCardTile(
                      leading: const Icon(Icons.badge_outlined, color: AppColors.primary, size: 20),
                      title: 'Identifiant système',
                      subtitle: '${user?.id ?? "—"}',
                    ),
                    IosCardTile(
                      leading: const Icon(Icons.security_rounded, color: AppColors.primary, size: 20),
                      title: 'Niveau d\'accès',
                      subtitle: user?.roleLabel ?? 'Standard',
                    ),
                  ],
                ),

                // ── Modules Cliniques & Raccourcis ──
                IosCard(
                  title: 'Gestion Clinique',
                  children: [
                    IosCardTile(
                      leading: const Icon(Icons.groups_outlined, color: AppColors.primary, size: 20),
                      title: 'Groupes Thérapeutiques',
                      subtitle: 'Séances collectives et plannings',
                      showChevron: true,
                      onTap: () => Get.toNamed(AppRoutes.groupesListe),
                    ),
                    IosCardTile(
                      leading: const Icon(Icons.family_restroom_outlined, color: AppColors.secondary, size: 20),
                      title: 'Parents & Tuteurs',
                      subtitle: 'Annuaire des contacts familiaux',
                      showChevron: true,
                      onTap: () => Get.toNamed(AppRoutes.parentsListe),
                    ),
                    IosCardTile(
                      leading: const Icon(Icons.task_alt_outlined, color: AppColors.accentCoral, size: 20),
                      title: 'Tâches & Actions',
                      subtitle: 'Gestion des todo-lists cliniques',
                      showChevron: true,
                      onTap: () => Get.toNamed(AppRoutes.taches),
                    ),
                    IosCardTile(
                      leading: const Icon(Icons.calendar_month_outlined, color: AppColors.primaryLight, size: 20),
                      title: 'Calendrier Administratif',
                      subtitle: 'Événements et réunions',
                      showChevron: true,
                      onTap: () => Get.toNamed(AppRoutes.calendrier),
                    ),
                    if (isAdmin)
                      IosCardTile(
                        leading: const Icon(Icons.badge_outlined, color: AppColors.primary, size: 20),
                        title: 'Gestion de l\'Équipe (Admin)',
                        subtitle: 'Comptes et droits d\'accès (Admin)',
                        showChevron: true,
                        onTap: () => Get.toNamed(AppRoutes.employesListe),
                      ),
                  ],
                ),

                // ── Préférences ──
                IosCard(
                  title: 'Préférences',
                  children: [
                    IosCardTile(
                      leading: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 20),
                      title: 'Notifications push',
                      trailing: Switch.adaptive(
                        value: true,
                        activeTrackColor: AppColors.iosGreen,
                        onChanged: (_) {},
                      ),
                    ),
                    IosCardTile(
                      leading: const Icon(Icons.language_rounded, color: AppColors.primary, size: 20),
                      title: 'Langue de l\'application',
                      trailing: Text('Français', style: AppTextStyles.iosSubhead),
                      showChevron: true,
                      onTap: () {},
                    ),
                    IosCardTile(
                      leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                      title: 'Version de l\'application',
                      trailing: Text('1.0.0 (Build 2026)', style: AppTextStyles.iosFootnote),
                    ),
                  ],
                ),

                // ── Déconnexion (US-M39) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: AppButton(
                    label: 'Se déconnecter',
                    icon: Icons.logout_rounded,
                    isDestructive: true,
                    onPressed: () => _confirmLogout(context),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter de votre session PsyCare ?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              controller.logout();
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
