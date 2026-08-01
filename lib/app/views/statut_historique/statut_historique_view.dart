import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/statut_historique_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';

class StatutHistoriqueView extends GetView<StatutHistoriqueController> {
  const StatutHistoriqueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Text('SUIVI PATIENT', style: AppTextStyles.sectionKicker),
                      Text('Historique des statuts', style: AppTextStyles.screenTitleMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.status.value == 'loading') {
                    return StatePlaceholder.loading();
                  }
                  if (controller.status.value == 'error') {
                    return StatePlaceholder.error(
                      message: controller.errorMessage.value,
                      onAction: () => controller.loadHistorique(),
                    );
                  }
                  if (controller.historique.isEmpty) {
                    return StatePlaceholder.empty(
                      title: 'Aucun historique',
                      message: 'Aucun changement de statut enregistré pour ce patient.',
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.historique.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = controller.historique[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryLight.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item.statut, style: AppTextStyles.cardName),
                                      StatusBadge.custom(label: item.statut, color: AppColors.primary),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item.dateChangement, style: AppTextStyles.bodySmall),
                                  if (item.noteDegradation != null && item.noteDegradation!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Note: ${item.noteDegradation}',
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
