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
    final formattedDate = DateFormat('EEEE d MMMM', 'fr_FR').format(today);

    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.oceanGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: AppColors.glowShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
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
                  // ── Logo Clinique Intégral & Centré en Arrière-Plan (Sans Rogne / Sans Animation) ──
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Opacity(
                            opacity: 0.22,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (ctx, e, st) => const SizedBox.shrink(),
                            ),
                          ),
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
                                      color: Colors.black.withValues(
                                        alpha: 0.20,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: PatientAvatar(
                                  initials: user?.initials ?? 'U',
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
                              ? 'Espace clinique de suivi thérapeutique • Dr. ${user.prenom}'
                              : 'Espace clinique de suivi & prise en charge thérapeutique.',
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
        )
        .animate()
        .fadeIn(duration: 700.ms)
        .slideY(begin: -0.08, curve: Curves.easeOut);
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
              'ACTIONS RAPIDES',
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
                  label: 'Nouveau Patient',
                  icon: Icons.person_add_rounded,
                  gradient: AppColors.emeraldGradient,
                  glowColor: const Color(0xFF059669),
                  onTap: () async {
                    final res = await Get.toNamed(AppRoutes.editPatient);
                    if (res == true) controller.loadDashboard();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _quickAction(
                  label: 'Planifier Séance',
                  icon: Icons.calendar_month_rounded,
                  gradient: AppColors.violetGradient,
                  glowColor: const Color(0xFF4F46E5),
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
                  label: 'Nouvelle Tâche',
                  icon: Icons.task_alt_rounded,
                  gradient: AppColors.coralGlowGradient,
                  glowColor: const Color(0xFFE11D48),
                  onTap: () async {
                    final res = await Get.toNamed(AppRoutes.detailTache);
                    if (res == true) controller.loadDashboard();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _quickAction(
                  label: 'Nouveau Groupe',
                  icon: Icons.groups_rounded,
                  gradient: AppColors.amberGoldGradient,
                  glowColor: const Color(0xFFD97706),
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
              title: 'Séances aujourd\'hui',
              value: controller.seancesPrevuesCount.value,
              icon: Icons.calendar_today_rounded,
              gradient: AppColors.violetGradient,
              onTap: () => Get.toNamed(AppRoutes.agenda),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _metricCard(
              title: 'Patients suivis',
              value: controller.totalPatients.value,
              icon: Icons.people_alt_rounded,
              gradient: AppColors.emeraldGradient,
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
                        color: (gradient is LinearGradient ? gradient.colors.first : AppColors.primary).withValues(alpha: 0.28),
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
                  gradient: AppColors.indigoGradient,
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
                      'Espace Comptes-Rendus',
                      style: AppTextStyles.iosHeadline.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Bilans cliniques & rappels de suivi',
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
      title: 'Séances du jour',
      subtitle: controller.prochainesSeances.isNotEmpty
          ? '${controller.prochainesSeances.length} rendez-vous programmé(s)'
          : 'Planning libre aujourd\'hui',
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
                  'Planning libre pour le moment',
                  style: AppTextStyles.iosHeadline.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ajoutez une nouvelle séance en un clic.',
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
                      gradient: AppColors.violetGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
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
              leading: s.isGroupe
                  ? Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.amberGoldGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD97706).withValues(alpha: 0.30),
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
      title: 'Espaces de travail',
      children: [
        IosCardTile(
          leading: _iconBox(
            Icons.folder_shared_rounded,
            AppColors.azureGradient,
          ),
          title: 'Dossiers Patients',
          subtitle: 'Consulter et rechercher vos dossiers',
          showChevron: true,
          onTap: () => Get.toNamed(AppRoutes.patientsListe),
        ),
        IosCardTile(
          leading: _iconBox(
            Icons.calendar_month_rounded,
            AppColors.violetGradient,
          ),
          title: 'Planning & Agenda',
          subtitle: 'Vue globale jour et semaine',
          showChevron: true,
          onTap: () => Get.toNamed(AppRoutes.agenda),
        ),
        IosCardTile(
          leading: _iconBox(
            Icons.person_outline_rounded,
            AppColors.emeraldGradient,
          ),
          title: 'Séances Individuelles',
          subtitle: 'Consultations & créneaux',
          showChevron: true,
          onTap: () => Get.toNamed(AppRoutes.seancesIndividuelles),
        ),
        IosCardTile(
          leading: _iconBox(
            Icons.groups_rounded,
            AppColors.amberGoldGradient,
          ),
          title: 'Groupes & Ateliers',
          subtitle: 'Séances collectives et participants',
          showChevron: true,
          onTap: () => Get.toNamed(AppRoutes.groupesListe),
        ),
        IosCardTile(
          leading: _iconBox(Icons.task_alt_rounded, AppColors.coralGlowGradient),
          title: 'Tâches & Actions',
          subtitle: 'Suivi de vos actions cliniques',
          showChevron: true,
          onTap: () => Get.toNamed(AppRoutes.taches),
        ),
        if (user?.role == 'admin')
          IosCardTile(
            leading: _iconBox(
              Icons.badge_rounded,
              AppColors.fuchsiaGradient,
            ),
            title: 'Gestion de l\'Équipe',
            subtitle: 'Comptes praticiens et permissions',
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
