import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/compte_rendu_seance_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/media_picker_widget.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';

class CompteRenduSeanceView extends GetView<CompteRenduSeanceController> {
  const CompteRenduSeanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: SafeArea(
        child: Obx(() {
          if (controller.status.value == 'loading') {
            return const StatePlaceholder(type: StatePlaceholderType.loading);
          }
          if (controller.status.value == 'error') {
            return StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadSeance(),
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
                        Text('Rapport de séance', style: AppTextStyles.screenTitleMedium),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('Jeudi 18 juillet 2026', style: AppTextStyles.bodySmall),
                            const SizedBox(width: 8),
                            const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('14:30 — 15:15', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StatusBadge.active(label: 'Séance individuelle'),
                const SizedBox(height: 16),

                // Résumé / notes Card
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
                        children: [
                          const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Résumé / notes de la séance', style: AppTextStyles.sectionTitle),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: '',
                        hintText: 'Décrivez les échanges, observations, exercices réalisés et points de suivi...',
                        maxLines: 5,
                        onChanged: (v) => controller.descriptionEtat.value = v,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.segment_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text('Lien avec le plan thérapeutique', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            hint: Text('Sélectionner une étape (optionnel)', style: AppTextStyles.fieldHint),
                            isExpanded: true,
                            value: controller.etapePlanId.value,
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('Étape 1 : Évaluation initiale')),
                              DropdownMenuItem(value: 2, child: Text('Étape 2 : Suivi émotionnel')),
                            ],
                            onChanged: (val) => controller.etapePlanId.value = val,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pièces jointes Card
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
                        children: [
                          const Icon(Icons.attach_file_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Pièces jointes', style: AppTextStyles.sectionTitle),
                        ],
                      ),
                      Text('Ajouter une photo ou une vidéo liée à la séance', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 14),
                      MediaPickerWidget(
                        initialMediaUrls: controller.medias,
                        onMediasChanged: (urls) => controller.medias.value = urls,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                AppButton(
                  label: 'Enregistrer le rapport',
                  icon: Icons.save_alt_rounded,
                  onPressed: () => controller.saveRapport(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
