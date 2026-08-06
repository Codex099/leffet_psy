import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/groupe_detail_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';

class GroupeDetailView extends GetView<GroupeDetailController> {
  const GroupeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: Obx(() {
        if (controller.status.value == 'loading') {
          return const StatePlaceholder(type: StatePlaceholderType.loading);
        }
        if (controller.status.value == 'error') {
          return StatePlaceholder.error(
            message: controller.errorMessage.value,
            onAction: () => controller.loadGroupe(),
          );
        }

        final g = controller.groupe.value;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Hero Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 24),
                decoration: const BoxDecoration(
                  gradient: AppColors.groupHeaderGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                              onPressed: () => Get.back(),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DÉTAIL SÉANCE', style: AppTextStyles.sectionKicker.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                                Text('Détail séance de groupe', style: AppTextStyles.screenTitleMedium.copyWith(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.white),
                          onPressed: () => Get.toNamed(AppRoutes.editGroupe, arguments: controller.groupeId),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  g?.nom ?? 'Groupe Compétences sociales',
                                  style: AppTextStyles.screenTitleMedium.copyWith(color: Colors.white),
                                ),
                              ),
                              StatusBadge.active(label: 'Planifiée'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text('12 mai 2025', style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 14, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text('14:30 - 15:15', style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Participants Card
                    Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Participants', style: AppTextStyles.sectionTitle),
                              Text('8 inscrits', style: AppTextStyles.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const CircleAvatar(radius: 16, backgroundColor: AppColors.secondaryLight, child: Text('LB')),
                              const CircleAvatar(radius: 16, backgroundColor: AppColors.secondaryLight, child: Text('ER')),
                              const CircleAvatar(radius: 16, backgroundColor: AppColors.secondaryLight, child: Text('NF')),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Lucas Bernard, Emma Rousseau, Nina Faure\n+4 autres participants',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Informations générales Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Informations générales', style: AppTextStyles.sectionTitle),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.timer_outlined, 'Durée', '45 minutes'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.groups_outlined, 'Type de séance', 'Séance de groupe'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.person_outline, 'Professionnel assigné', 'Dr. Lefevre'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Add Compte-Rendu
                    ElevatedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.compteRenduGroupe, arguments: controller.groupeId),
                      icon: const Icon(Icons.note_add_outlined),
                      label: const Text('Ajouter un compte-rendu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cancel / Delete Group Action
                    TextButton(
                      onPressed: () => controller.deleteGroupe(),
                      child: Text('Annuler la séance', style: AppTextStyles.buttonDestructive.copyWith(fontSize: 14)),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
              Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
