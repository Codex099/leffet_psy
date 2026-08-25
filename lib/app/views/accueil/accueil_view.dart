import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/accueil_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/status_badge.dart';

class AccueilView extends GetView<AccueilController> {
  const AccueilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.status.value == 'loading') {
            return StatePlaceholder.loading(message: 'Chargement de votre espace...');
          }
          if (controller.status.value == 'error') {
            return StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadDashboard(forceRefresh: true),
            );
          }

          final user = controller.currentUser.value;
          final today = DateTime.now();
          final formattedDate = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(today);

          return RefreshIndicator(
            onRefresh: () => controller.refreshData(),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.only(top: 10, bottom: 120),
              children: [
                // ── En-tête Bienvenue Zen ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.oceanGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppColors.heroShadow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: ZenWavePainter(
                                waveColor: AppColors.secondary.withValues(alpha: 0.25),
                                accentColor: AppColors.secondaryLight.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.20),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.30),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const PulseDot(color: Colors.white, size: 7),
                                          const SizedBox(width: 6),
                                          Text(
                                            formattedDate,
                                            style: AppTextStyles.iosCaption2.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    BouncyTap(
                                      onTap: () => Get.toNamed(AppRoutes.profil),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: PatientAvatar(
                                          initials: user?.initials ?? 'U',
                                          radius: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  user != null ? 'Bonjour ${user.prenom} 👋' : 'Bonjour 👋',
                                  style: AppTextStyles.iosLargeTitle.copyWith(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Voici le résumé de vos consultations et dossiers du jour.',
                                  style: AppTextStyles.iosSubhead.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── 4 Actions Rapides Évidentes ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIONS RAPIDES',
                        style: AppTextStyles.iosCaption2.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              label: '+ Patient',
                              subtitle: 'Créer dossier',
                              icon: Icons.person_add_rounded,
                              color: AppColors.primary,
                              onTap: () => Get.toNamed(AppRoutes.editPatient),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickActionButton(
                              label: '+ Séance',
                              subtitle: 'Planifier RDV',
                              icon: Icons.add_alarm_rounded,
                              color: AppColors.secondary,
                              onTap: () => Get.toNamed(AppRoutes.creationSeance),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              label: '+ Tâche',
                              subtitle: 'Action à faire',
                              icon: Icons.check_circle_outline_rounded,
                              color: AppColors.accentCoral,
                              onTap: () => Get.toNamed(AppRoutes.detailTache),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickActionButton(
                              label: '+ Groupe',
                              subtitle: 'Atelier collectif',
                              icon: Icons.groups_rounded,
                              color: AppColors.primaryLight,
                              onTap: () => Get.toNamed(AppRoutes.editGroupe),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Résumé Activité (2 Cartes Claires) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSimpleMetricCard(
                          title: 'Séances aujourd\'hui',
                          count: '${controller.seancesPrevuesCount.value}',
                          icon: Icons.calendar_today_rounded,
                          color: AppColors.primary,
                          onTap: () => Get.toNamed(AppRoutes.agenda),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSimpleMetricCard(
                          title: 'Patients suivis',
                          count: '${controller.totalPatients.value}',
                          icon: Icons.people_alt_rounded,
                          color: AppColors.secondary,
                          onTap: () => Get.toNamed(AppRoutes.patientsListe),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── Consultations du Jour ──
                IosCard(
                  title: 'Séances du jour',
                  subtitle: controller.prochainesSeances.isNotEmpty
                      ? '${controller.prochainesSeances.length} rendez-vous programmé(s)'
                      : 'Aucun rendez-vous prévu',
                  children: [
                    if (controller.prochainesSeances.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.event_available_rounded,
                              color: AppColors.secondary,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Planning libre pour le moment',
                              style: AppTextStyles.iosHeadline.copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vous pouvez ajouter une nouvelle séance en un clic.',
                              style: AppTextStyles.iosFootnote.copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            BouncyTap(
                              onTap: () => Get.toNamed(AppRoutes.creationSeance),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: AppColors.oceanGradient,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Text(
                                  '+ Planifier une séance',
                                  style: AppTextStyles.iosCaption1.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...controller.prochainesSeances.map((s) {
                        return IosCardTile(
                          leading: PatientAvatar(
                            initials: s.patientFullName.isNotEmpty ? s.patientFullName[0] : 'P',
                            radius: 20,
                          ),
                          title: s.patientFullName,
                          subtitle: '${s.heureDebut} — ${s.heureFin} (${s.duree})',
                          trailing: StatusBadge.active(label: s.statutLabel),
                          showChevron: true,
                          onTap: () => Get.toNamed(AppRoutes.compteRenduSeance, arguments: s.id),
                        );
                      }),
                  ],
                ),

                // ── Modules de Navigation ──
                IosCard(
                  title: 'Espaces de travail',
                  children: [
                    IosCardTile(
                      leading: _buildIconCircle(Icons.folder_shared_outlined, AppColors.primary),
                      title: 'Dossiers Patients',
                      subtitle: 'Consulter et rechercher parmi tous les patients',
                      showChevron: true,
                      onTap: () => Get.toNamed(AppRoutes.patientsListe),
                    ),
                    IosCardTile(
                      leading: _buildIconCircle(Icons.calendar_month_outlined, AppColors.secondary),
                      title: 'Planning & Agenda',
                      subtitle: 'Vue globale jour et semaine',
                      showChevron: true,
                      onTap: () => Get.toNamed(AppRoutes.agenda),
                    ),
                    IosCardTile(
                      leading: _buildIconCircle(Icons.groups_outlined, AppColors.secondaryLight),
                      title: 'Groupes & Ateliers',
                      subtitle: 'Séances collectives et participants',
                      showChevron: true,
                      onTap: () => Get.toNamed(AppRoutes.groupesListe),
                    ),
                    IosCardTile(
                      leading: _buildIconCircle(Icons.task_alt_rounded, AppColors.accentCoral),
                      title: 'Tâches & Actions',
                      subtitle: 'Suivi de vos actions et bilans cliniques',
                      showChevron: true,
                      onTap: () => Get.toNamed(AppRoutes.taches),
                    ),
                    if (user?.role == 'admin')
                      IosCardTile(
                        leading: _buildIconCircle(Icons.badge_outlined, AppColors.accentDeep),
                        title: 'Gestion de l\'Équipe (Admin)',
                        subtitle: 'Comptes praticiens et permissions',
                        showChevron: true,
                        onTap: () => Get.toNamed(AppRoutes.employesListe),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 0.9),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.iosHeadline.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.iosCaption2.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 0.9),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 22),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textHint),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: AppTextStyles.iosTitle1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: AppTextStyles.iosFootnote.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconCircle(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
