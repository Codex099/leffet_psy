import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/accueil_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_animations.dart';
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
            return Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                Expanded(child: ShimmerListLoader(count: 4)),
              ],
            );
          }
          if (controller.status.value == 'error') {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () =>
                        controller.loadDashboard(forceRefresh: true),
                  ),
                ),
              ],
            );
          }

          return PremiumRefreshIndicator(
            onRefresh: () => controller.refreshData(),
            child: ListView(
              padding: const EdgeInsets.only(top: 0, bottom: 120),
              children: [
                // ── Header Hero ──────────────────────────────────────────────
                _buildHeader(context),
                const SizedBox(height: 16),

                // ── Quick Actions ────────────────────────────────────────────
                _buildQuickActions()
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.15),
                const SizedBox(height: 18),

                // ── Métriques ────────────────────────────────────────────────
                _buildMetrics()
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.15),
                const SizedBox(height: 14),

                // ── Lien Comptes-Rendus ──────────────────────────────────────
                _buildCompteRenduBanner()
                    .animate(delay: 280.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.15),
                const SizedBox(height: 18),

                // ── Séances du Jour ──────────────────────────────────────────
                _buildSeancesCard()
                    .animate(delay: 350.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.15),

                // ── Espaces de Travail ───────────────────────────────────────
                _buildWorkspaces()
                    .animate(delay: 450.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.15),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Header Hero ────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final user = controller.currentUser.value;
    final today = DateTime.now();
    final String langCode = Get.locale?.languageCode ?? 'fr';
    final formattedDate = DateFormat('EEEE d MMMM', langCode).format(today);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.headerGradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Vagues décoratives
              Positioned.fill(
                child: CustomPaint(
                  painter: ZenWavePainter(
                    waveColor: AppColors.secondary.withValues(alpha: 0.20),
                    accentColor: AppColors.secondaryLight.withValues(
                      alpha: 0.12,
                    ),
                  ),
                ),
              ),
              // ── Bannière Panoramique Clinique Largeur Pleine Carte ──
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.25,
                    child: Image.asset(
                      'assets/images/hero_banner.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (ctx, e, st) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row : Date badge à gauche, Profil à droite
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Date badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const PulseDot(color: Colors.white, size: 6),
                              const SizedBox(width: 7),
                              Text(
                                _capitalize(formattedDate),
                                style: AppTextStyles.iosCaption2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Avatar profil
                        BouncyTap(
                          onTap: () => Get.toNamed(AppRoutes.profil),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: PatientAvatar(
                              initials: user?.initialLetter ?? 'U',
                              radius: 19,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Greeting Clinique
                    Text(
                      'clinique l\'Effet de Papillon 🦋',
                      style: AppTextStyles.iosLargeTitle.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user != null
                          ? '${'Espace clinique de suivi thérapeutique'.tr} • ${user.prenom}'
                          : 'Espace clinique de suivi & prise en charge thérapeutique.'.tr,
                      style: AppTextStyles.iosSubhead.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 700.ms).slideY(begin: -0.08, curve: Curves.easeOut);
  }

  // ─── Quick Actions ───────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'ACTIONS RAPIDES'.tr,
              style: AppTextStyles.iosCaption2.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _quickAction(
                  label: 'Nouveau Patient'.tr,
                  icon: Icons.person_add_rounded,
                  gradient: AppColors.primaryLogoGradient,
                  glowColor: const Color(0xFF032B45),
                  onTap: () async {
                    final res = await Get.toNamed(AppRoutes.editPatient);
                    if (res == true) controller.loadDashboard();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _quickAction(
                  label: 'Planifier Séance'.tr,
                  icon: Icons.calendar_month_rounded,
                  gradient: AppColors.secondaryLogoGradient,
                  glowColor: const Color(0xFF064973),
                  onTap: () async {
                    final res = await Get.toNamed(AppRoutes.creationSeance);
                    if (res == true) controller.loadDashboard();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _quickAction(
                  label: 'Nouvelle Tâche'.tr,
                  icon: Icons.task_alt_rounded,
                  gradient: AppColors.coralLogoGradient,
                  glowColor: const Color(0xFFA62929),
                  onTap: () async {
                    final res = await Get.toNamed(AppRoutes.detailTache);
                    if (res == true) controller.loadDashboard();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _quickAction(
                  label: 'Nouveau Groupe'.tr,
                  icon: Icons.groups_rounded,
                  gradient: AppColors.coralSoftLogoGradient,
                  glowColor: const Color(0xFFD93636),
                  onTap: () async {
                    final res = await Get.toNamed(AppRoutes.editGroupe);
                    if (res == true) controller.loadDashboard();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.32),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.iosFootnote.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Métriques Animées ───────────────────────────────────────────────────────
  Widget _buildMetrics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _metricCard(
              title: 'Séances aujourd\'hui'.tr,
              value: controller.seancesPrevuesCount.value,
              icon: Icons.calendar_today_rounded,
              gradient: AppColors.primaryLogoGradient,
              onTap: () => Get.toNamed(AppRoutes.agenda),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _metricCard(
              title: 'Patients suivis'.tr,
              value: controller.totalPatients.value,
              icon: Icons.people_alt_rounded,
              gradient: AppColors.secondaryLogoGradient,
              onTap: () => Get.toNamed(AppRoutes.patientsListe),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required int value,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderLight, width: 0.6),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (gradient is LinearGradient
                                    ? gradient.colors.first
                                    : AppColors.primary)
                                .withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textHint,
                ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedCounter(
              value: value,
              style: AppTextStyles.iosTitle1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 3),
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

  // ─── Bannière Comptes-Rendus ─────────────────────────────────────────────────
  Widget _buildCompteRenduBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BouncyTap(
        onTap: () => Get.toNamed(AppRoutes.compteRenduHub),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight, width: 0.6),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryLogoGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Espace Comptes-Rendus'.tr,
                      style: AppTextStyles.iosHeadline.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Bilans cliniques & rappels de suivi'.tr,
                      style: AppTextStyles.iosFootnote.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.fieldBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Séances du Jour ─────────────────────────────────────────────────────────
  Widget _buildSeancesCard() {
    return IosCard(
      title: 'Séances du jour'.tr,
      subtitle: controller.prochainesSeances.isNotEmpty
          ? '${controller.prochainesSeances.length} ${'rendez-vous programmé(s)'.tr}'
          : 'Planning libre aujourd\'hui'.tr,
      children: [
        if (controller.prochainesSeances.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.statusPresentLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: AppColors.secondary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Planning libre pour le moment'.tr,
                  style: AppTextStyles.iosHeadline.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ajoutez une nouvelle séance en un clic.'.tr,
                  style: AppTextStyles.iosFootnote.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                BouncyTap(
                  onTap: () => Get.toNamed(AppRoutes.creationSeance),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryLogoGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF7C3AED,
                          ).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      '+ Planifier une séance'.tr,
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
              leading: s.isGroupe
                  ? Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.coralSoftLogoGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFD97706,
                            ).withValues(alpha: 0.30),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    )
                  : PatientAvatar(
                      photoUrl: s.photoUrl,
                      initials: s.initials,
                      radius: 22,
                    ),
              title: s.title,
              subtitle: s.subtitle,
              trailing: StatusBadge.active(label: s.statutLabel),
              showChevron: true,
              onTap: () async {
                if (s.isGroupe) {
                  await Get.toNamed(
                    AppRoutes.compteRenduGroupe,
                    arguments: s.id,
                  );
                } else {
                  await Get.toNamed(
                    AppRoutes.compteRenduSeance,
                    arguments: s.id,
                  );
                }
                controller.loadDashboard(forceRefresh: true);
              },
            );
          }),
      ],
    );
  }

  // ─── Espaces de Travail ──────────────────────────────────────────────────────
  Widget _buildWorkspaces() {
    final user = controller.currentUser.value;
    return IosCard(
      title: 'Espaces de travail'.tr,
      children: [
        IosCardTile(
          leading: _iconBox(
            Icons.folder_shared_rounded,
            AppColors.secondaryLogoGradient,
          ),
          title: 'Dossiers Patients'.tr,
          subtitle: 'Consulter et rechercher vos dossiers'.tr,
          showChevron: true,
          onTap: () => Get.toNamed(AppRoutes.patientsListe),
        ),
        IosCardTile(
          leading: _iconBox(
            Icons.calendar_month_rounded,
            AppColors.primaryLogoGradient,
          ),
          title: 'Planning & Agenda'.tr,
          subtitle: 'Vue globale jour et semaine'.tr,
          showChevron: true,
          onTap: () => Get.toNamed(AppRoutes.agenda),
        ),
        IosCardTile(
          leading: _iconBox(
            Icons.person_outline_rounded,
            AppColors.secondaryLogoGradient,
          ),
          title: 'Séances Individuelles'.tr,
          subtitle: 'Consultations & créneaux'.tr,
          showChevron: true,
          onTap: () => Get.toNamed(AppRoutes.seancesIndividuelles),
        ),
        IosCardTile(
          leading: _iconBox(Icons.groups_rounded, AppColors.coralSoftLogoGradient),
          title: 'Groupes & Ateliers'.tr,
          subtitle: 'Séances collectives et participants'.tr,
          showChevron: true,
          onTap: () => Get.toNamed(AppRoutes.groupesListe),
        ),
        IosCardTile(
          leading: _iconBox(
            Icons.task_alt_rounded,
            AppColors.coralLogoGradient,
          ),
          title: 'Tâches & Actions'.tr,
          subtitle: 'Suivi de vos actions cliniques'.tr,
          showChevron: true,
          onTap: () => Get.toNamed(AppRoutes.taches),
        ),
        if (user?.role == 'admin')
          IosCardTile(
            leading: _iconBox(Icons.badge_rounded, AppColors.coralLogoGradient),
            title: 'Gestion de l\'Équipe'.tr,
            subtitle: 'Comptes praticiens et permissions'.tr,
            showChevron: true,
            onTap: () => Get.toNamed(AppRoutes.employesListe),
          ),
      ],
    );
  }

  Widget _iconBox(IconData icon, Gradient gradient) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.softShadow,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
