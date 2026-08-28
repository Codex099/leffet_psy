import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/profil_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/clinical_decorations.dart';
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: Obx(() {
        if (controller.status.value == 'loading') {
          return const SafeArea(
            child: StatePlaceholder(type: StatePlaceholderType.loading),
          );
        }
        if (controller.status.value == 'error') {
          return SafeArea(
            child: StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadProfile(),
            ),
          );
        }

        final user = controller.currentUser.value;
        final isAdmin = user?.role == 'admin';

        return CustomScrollView(
          slivers: [
            // ── Hero AppBar Expandable ──────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                  ),
                  child: Stack(
                    children: [
                      // Vagues de fond
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ZenWavePainter(
                            waveColor: AppColors.secondary.withValues(
                              alpha: 0.18,
                            ),
                            accentColor: AppColors.secondaryLight.withValues(
                              alpha: 0.10,
                            ),
                          ),
                        ),
                      ),
                      // Contenu profil
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Avatar grand format avec ring
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: AppColors.glowShadow,
                                    ),
                                    child: PatientAvatar(
                                      initials: user?.initials ?? 'U',
                                      radius: 36,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user?.fullName ?? 'Utilisateur',
                                          style: AppTextStyles.iosTitle2
                                              .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '@${user?.username ?? "user"}'.tr,
                                          style: AppTextStyles.iosFootnote
                                              .copyWith(
                                                color: Colors.white.withValues(
                                                  alpha: 0.80,
                                                ),
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        StatusBadge.active(
                                          label: user?.roleLabel ?? 'Employé',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // AppBar titre condensé (quand scrollé)
              title: Text(
                'Mon Profil'.tr,
                style: AppTextStyles.iosTitle3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
            ),

            // ── Contenu Liste ──────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.only(top: 12, bottom: 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Coordonnées
                  IosCard(
                        title: 'Coordonnées & Compte'.tr,
                        children: [
                          IosCardTile(
                            leading: _iconCircle(
                              Icons.phone_outlined,
                              AppColors.primaryLogoGradient,
                            ),
                            title: 'Téléphone'.tr,
                            subtitle:
                                user?.telephone != null &&
                                    user!.telephone!.isNotEmpty
                                ? user.telephone!
                                : 'Non renseigné'.tr,
                          ),
                          IosCardTile(
                            leading: _iconCircle(
                              Icons.badge_outlined,
                              AppColors.primaryLogoGradient,
                            ),
                            title: 'Identifiant système'.tr,
                            subtitle: '${user?.id ?? "—"}'.tr,
                          ),
                          IosCardTile(
                            leading: _iconCircle(
                              Icons.security_rounded,
                              AppColors.primaryLogoGradient,
                            ),
                            title: 'Niveau d\'.traccès',
                            subtitle: user?.roleLabel ?? 'Standard',
                          ),
                        ],
                      )
                      .animate(delay: 80.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1),

                  // Gestion Clinique
                  IosCard(
                        title: 'Gestion Clinique'.tr,
                        children: [
                          IosCardTile(
                            leading: _iconCircle(
                              Icons.person_outline_rounded,
                              AppColors.secondaryLogoGradient,
                            ),
                            title: 'Séances Individuelles'.tr,
                            subtitle: 'Consultations & créneaux récurrents'.tr,
                            showChevron: true,
                            onTap: () =>
                                Get.toNamed(AppRoutes.seancesIndividuelles),
                          ),
                          IosCardTile(
                            leading: _iconCircle(
                              Icons.groups_outlined,
                              AppColors.coralSoftLogoGradient,
                            ),
                            title: 'Groupes Thérapeutiques'.tr,
                            subtitle: 'Séances collectives et plannings'.tr,
                            showChevron: true,
                            onTap: () => Get.toNamed(AppRoutes.groupesListe),
                          ),
                          IosCardTile(
                            leading: _iconCircle(
                              Icons.family_restroom_outlined,
                              AppColors.secondaryLogoGradient,
                            ),
                            title: 'Parents & Tuteurs'.tr,
                            subtitle: 'Annuaire des contacts familiaux'.tr,
                            showChevron: true,
                            onTap: () => Get.toNamed(AppRoutes.parentsListe),
                          ),
                          IosCardTile(
                            leading: _iconCircle(
                              Icons.task_alt_outlined,
                              AppColors.coralLogoGradient,
                            ),
                            title: 'Tâches & Actions'.tr,
                            subtitle: 'Gestion des todo-lists cliniques'.tr,
                            showChevron: true,
                            onTap: () => Get.toNamed(AppRoutes.taches),
                          ),
                          IosCardTile(
                            leading: _iconCircle(
                              Icons.calendar_month_outlined,
                              AppColors.primaryLogoGradient,
                            ),
                            title: 'Calendrier Administratif'.tr,
                            subtitle: 'Événements et réunions'.tr,
                            showChevron: true,
                            onTap: () => Get.toNamed(AppRoutes.calendrier),
                          ),
                          if (isAdmin)
                            IosCardTile(
                              leading: _iconCircle(
                                Icons.badge_rounded,
                                AppColors.coralLogoGradient,
                              ),
                              title: 'Gestion de l\'.trÉquipe (Admin)',
                              subtitle: 'Comptes et droits d\'.traccès',
                              showChevron: true,
                              onTap: () => Get.toNamed(AppRoutes.employesListe),
                            ),
                        ],
                      )
                      .animate(delay: 150.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1),

                  // Préférences
                  IosCard(
                        title: 'Préférences'.tr,
                        children: [
                          IosCardTile(
                            leading: _iconCircle(
                              Icons.notifications_none_rounded,
                              AppColors.primaryLogoGradient,
                            ),
                            title: 'Notifications push'.tr,
                            trailing: Switch.adaptive(
                              value: true,
                              activeTrackColor: AppColors.iosGreen,
                              onChanged: (_) {},
                            ),
                          ),
                          IosCardTile(
                            leading: _iconCircle(
                              Icons.language_rounded,
                              AppColors.secondaryLogoGradient,
                            ),
                            title: 'Langue de l\'application'.tr,
                            trailing: Text(
                              Get.locale?.languageCode == 'ar' ? 'العربية' : 'Français',
                              style: AppTextStyles.iosSubhead,
                            ),
                            showChevron: true,
                            onTap: () {
                              if (Get.locale?.languageCode == 'ar') {
                                Get.updateLocale(const Locale('fr', 'FR'));
                              } else {
                                Get.updateLocale(const Locale('ar', 'DZ'));
                              }
                            },
                          ),
                          IosCardTile(
                            leading: _iconCircle(
                              Icons.info_outline_rounded,
                              AppColors.secondaryLogoGradient,
                            ),
                            title: 'Version de l\'.trapplication',
                            trailing: Text(
                              '1.0.0 (Build 2026)'.tr,
                              style: AppTextStyles.iosFootnote,
                            ),
                          ),
                        ],
                      )
                      .animate(delay: 220.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1),

                  // Déconnexion
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: AppButton(
                      label: 'Se déconnecter'.tr,
                      icon: Icons.logout_rounded,
                      isDestructive: true,
                      isGradient: false,
                      onPressed: () => _confirmLogout(context),
                    ),
                  ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _iconCircle(IconData icon, Gradient gradient) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.softShadow,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  void _confirmLogout(BuildContext context) {
    HapticFeedback.lightImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fermer'.tr,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
              ],
              border: Border.all(color: AppColors.borderLight, width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône illustrée rouge avec aura douce
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentCoral.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Titre
                  Text(
                    'Se déconnecter ?'.tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.iosTitle2.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  Text(
                    'Êtes-vous certain de vouloir fermer votre session clinique ? Vous devrez vous ré-authentifier pour accéder aux dossiers.'.tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 26),

                  // Boutons d'action
                  Row(
                    children: [
                      // Bouton Annuler
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.fieldBackground,
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Annuler'.tr,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Bouton Déconnexion
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(ctx);
                            controller.logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: AppColors.error.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Déconnexion'.tr,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
