import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/plan_therapeutique_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';

class PlanTherapeutiqueView extends GetView<PlanTherapeutiqueController> {
  const PlanTherapeutiqueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Obx(() {
          if (controller.status.value == 'loading') {
            return const StatePlaceholder(type: StatePlaceholderType.loading);
          }
          if (controller.status.value == 'error') {
            return StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadPlan(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PLAN THÉRAPEUTIQUE', style: AppTextStyles.sectionKicker),
                        Text('Plan thérapeutique', style: AppTextStyles.screenTitleMedium),
                        Text('Lucas Bernard · 9 ans', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Card
                Container(
                  padding: const EdgeInsets.all(20),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Overall progress', style: AppTextStyles.sectionTitle),
                              Text('6 of 8 steps completed', style: AppTextStyles.bodySmall),
                            ],
                          ),
                          StatusBadge.active(label: '75%'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: AppColors.border,
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('To do', style: AppTextStyles.bodySmall),
                          Text('In progress', style: AppTextStyles.bodySmall),
                          Text('Done', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Étapes du plan header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Étapes du plan', style: AppTextStyles.sectionTitle),
                    Text('3 étapes', style: AppTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: 12),

                // Step cards
                _buildEtapeCard(
                  title: 'Renforcer l\'attention soutenue',
                  desc: 'Exercices courts de concentration avec pauses guidées.',
                  status: 'Terminé',
                  statusColor: AppColors.statusPresent,
                  etapeId: 1,
                  isValidated: true,
                ),
                const SizedBox(height: 12),
                _buildEtapeCard(
                  title: 'Développer la communication fonctionnelle',
                  desc: 'Utiliser des supports visuels pour formuler une demande simple.',
                  status: 'En cours',
                  statusColor: AppColors.primary,
                  etapeId: 2,
                  inProgress: true,
                ),
                const SizedBox(height: 12),
                _buildEtapeCard(
                  title: 'Réduire les comportements d\'évitement',
                  desc: 'Mettre en place un renforcement positif sur les transitions.',
                  status: 'À faire',
                  statusColor: AppColors.error,
                  etapeId: 3,
                  toPlan: true,
                ),
                const SizedBox(height: 20),

                // Add step button
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une étape'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEtapeCard({
    required String title,
    required String desc,
    required String status,
    required Color statusColor,
    required int etapeId,
    bool isValidated = false,
    bool inProgress = false,
    bool toPlan = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.drag_indicator_rounded, color: AppColors.textHint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              StatusBadge.custom(label: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: AppTextStyles.bodySmall),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => controller.convertEtapeToTache(etapeId),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Convertir en tâche',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (isValidated)
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.statusPresent),
                    const SizedBox(width: 4),
                    Text('Validée', style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusPresent)),
                  ],
                ),
              if (inProgress)
                Row(
                  children: [
                    const Icon(Icons.sync_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('En progression', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                  ],
                ),
              if (toPlan)
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text('À planifier', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
