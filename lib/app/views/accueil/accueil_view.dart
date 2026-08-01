import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/accueil_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';

class AccueilView extends GetView<AccueilController> {
  const AccueilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SafeArea(
        child: Obx(() {
          if (controller.status.value == 'loading') {
            return StatePlaceholder.loading();
          }
          if (controller.status.value == 'error') {
            return StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadDashboard(),
            );
          }

          final user = controller.currentUser.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.psychology, color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('PsyCare', style: AppTextStyles.sectionTitle),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user?.roleLabel ?? 'Employé',
                                    style: AppTextStyles.badge.copyWith(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.secondaryLight,
                            child: Icon(Icons.person, size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'Dr. Martin',
                                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                              ),
                              Text(
                                user?.roleLabel ?? 'Admin',
                                style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Dashbord', style: AppTextStyles.screenTitle),
                const SizedBox(height: 16),

                // Stat Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_outline_rounded,
                        iconColor: AppColors.primary,
                        title: 'Patients',
                        value: '${controller.totalPatients.value}',
                        subtitle: 'Total suivis',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.primary,
                        title: 'Aujourd\'hui',
                        value: '${controller.seancesPrevuesCount.value}',
                        subtitle: 'Séances prévues',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.error_outline_rounded,
                        iconColor: AppColors.error,
                        title: 'Alertes',
                        value: '${controller.alertesCount.value}',
                        subtitle: 'En attente',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Mes séances block
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text('Mes séances', style: AppTextStyles.sectionTitle),
                            ],
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed(AppRoutes.agenda),
                            child: const Text('Tout voir'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSeanceTypeTile(
                        icon: Icons.calendar_month_rounded,
                        title: 'Séances individuelles',
                        onTap: () => Get.toNamed(AppRoutes.agenda),
                      ),
                      const SizedBox(height: 10),
                      _buildSeanceTypeTile(
                        icon: Icons.groups_rounded,
                        title: 'Séances groupe',
                        onTap: () => Get.toNamed(AppRoutes.groupesListe),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Prochaines séances header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prochaines séances', style: AppTextStyles.sectionTitle),
                        Text('Les rendez-vous à venir aujourd\'hui', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.prochainesSeances.length} à venir',
                        style: AppTextStyles.badge.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Seances list
                if (controller.prochainesSeances.isEmpty)
                  StatePlaceholder.empty(
                    title: 'Aucune séance',
                    message: 'Aucune séance prévue pour aujourd\'hui.',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.prochainesSeances.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final seance = controller.prochainesSeances[index];
                      return _buildSeanceCard(seance);
                    },
                  ),
                const SizedBox(height: 24),

                // Big Button "Voir mon agenda"
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.agenda),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Voir mon agenda'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.dashboardLabel.copyWith(color: AppColors.secondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.dashboardNumber),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.dashboardLabel),
        ],
      ),
    );
  }

  Widget _buildSeanceTypeTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSeanceCard(dynamic seance) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${seance.heureDebut} — ${seance.patientFullName.isNotEmpty ? seance.patientFullName : "Séance"}',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Séance individuelle · Cabinet 1',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          StatusBadge.present(label: 'Assisté'),
        ],
      ),
    );
  }
}
