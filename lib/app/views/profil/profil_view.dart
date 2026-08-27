import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                            waveColor: AppColors.secondary.withValues(alpha: 0.18),
                            accentColor: AppColors.secondaryLight.withValues(alpha: 0.10),
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
                                      border: Border.all(color: Colors.white, width: 3),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user?.fullName ?? 'Utilisateur',
                                          style: AppTextStyles.iosTitle2.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '@${user?.username ?? "user"}',
                                          style: AppTextStyles.iosFootnote.copyWith(
                                            color: Colors.white.withValues(alpha: 0.80),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        StatusBadge.active(label: user?.roleLabel ?? 'Employé'),
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
                'Mon Profil',
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
                    title: 'Coordonnées & Compte',
                    children: [
                      IosCardTile(
                        leading: _iconCircle(Icons.phone_outlined, AppColors.oceanGradient),
                        title: 'Téléphone',
                        subtitle: user?.telephone != null && user!.telephone!.isNotEmpty
                            ? user.telephone!
                            : 'Non renseigné',
                      ),
                      IosCardTile(
                        leading: _iconCircle(Icons.badge_outlined, AppColors.oceanGradient),
                        title: 'Identifiant système',
                        subtitle: '${user?.id ?? "—"}',
                      ),
                      IosCardTile(
                        leading: _iconCircle(Icons.security_rounded, AppColors.oceanGradient),
                        title: 'Niveau d\'accès',
                        subtitle: user?.roleLabel ?? 'Standard',
                      ),
                    ],
                  ).animate(delay: 80.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

                  // Gestion Clinique
                  IosCard(
                    title: 'Gestion Clinique',
                    children: [
                      IosCardTile(
                        leading: _iconCircle(Icons.person_outline_rounded, const LinearGradient(
                          colors: [Color(0xFF064973), Color(0xFF1A7CB0)],
                        )),
                        title: 'Séances Individuelles',
                        subtitle: 'Consultations & créneaux récurrents',
                        showChevron: true,
                        onTap: () => Get.toNamed(AppRoutes.seancesIndividuelles),
                      ),
                      IosCardTile(
                        leading: _iconCircle(Icons.groups_outlined, AppColors.groupHeaderGradient),
                        title: 'Groupes Thérapeutiques',
                        subtitle: 'Séances collectives et plannings',
                        showChevron: true,
                        onTap: () => Get.toNamed(AppRoutes.groupesListe),
                      ),
                      IosCardTile(
                        leading: _iconCircle(Icons.family_restroom_outlined, const LinearGradient(
                          colors: [Color(0xFF0A5C8F), Color(0xFF75AABF)],
                        )),
                        title: 'Parents & Tuteurs',
                        subtitle: 'Annuaire des contacts familiaux',
                        showChevron: true,
                        onTap: () => Get.toNamed(AppRoutes.parentsListe),
                      ),
                      IosCardTile(
                        leading: _iconCircle(Icons.task_alt_outlined, AppColors.accentGradient),
                        title: 'Tâches & Actions',
                        subtitle: 'Gestion des todo-lists cliniques',
                        showChevron: true,
                        onTap: () => Get.toNamed(AppRoutes.taches),
                      ),
                      IosCardTile(
                        leading: _iconCircle(Icons.calendar_month_outlined, const LinearGradient(
                          colors: [Color(0xFF064973), Color(0xFF75AABF)],
                        )),
                        title: 'Calendrier Administratif',
                        subtitle: 'Événements et réunions',
                        showChevron: true,
                        onTap: () => Get.toNamed(AppRoutes.calendrier),
                      ),
                      if (isAdmin)
                        IosCardTile(
                          leading: _iconCircle(Icons.badge_rounded, AppColors.accentGradient),
                          title: 'Gestion de l\'Équipe (Admin)',
                          subtitle: 'Comptes et droits d\'accès',
                          showChevron: true,
                          onTap: () => Get.toNamed(AppRoutes.employesListe),
                        ),
                    ],
                  ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

                  // Préférences
                  IosCard(
                    title: 'Préférences',
                    children: [
                      IosCardTile(
                        leading: _iconCircle(Icons.notifications_none_rounded, AppColors.oceanGradient),
                        title: 'Notifications push',
                        trailing: Switch.adaptive(
                          value: true,
                          activeTrackColor: AppColors.iosGreen,
                          onChanged: (_) {},
                        ),
                      ),
                      IosCardTile(
                        leading: _iconCircle(Icons.language_rounded, AppColors.oceanGradient),
                        title: 'Langue de l\'application',
                        trailing: Text('Français', style: AppTextStyles.iosSubhead),
                        showChevron: true,
                        onTap: () {},
                      ),
                      IosCardTile(
                        leading: _iconCircle(Icons.info_outline_rounded, AppColors.oceanGradient),
                        title: 'Version de l\'application',
                        trailing: Text('1.0.0 (Build 2026)', style: AppTextStyles.iosFootnote),
                      ),
                    ],
                  ).animate(delay: 220.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

                  // Déconnexion
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: AppButton(
                      label: 'Se déconnecter',
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
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter de votre session PsyCare ?'),
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
