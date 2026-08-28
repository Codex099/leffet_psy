import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/compte_rendu_seance_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/media_picker_widget.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/app_section_header.dart';

class CompteRenduSeanceView extends GetView<CompteRenduSeanceController> {
  const CompteRenduSeanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Compte-rendu Séance'.tr,
        subtitle: 'Bilan Clinique'.tr,
        showBackButton: true,
      ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge.active(label: 'Séance individuelle'.tr),
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
                          const Icon(
                            Icons.description_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          SectionHeader(
                            title: 'Résumé / notes de la séance'.tr,
                            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: '',
                        hintText:
                            'Décrivez les échanges, observations, exercices réalisés et points de suivi...'.tr,
                        maxLines: 5,
                        onChanged: (v) => controller.descriptionEtat.value = v,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            Icons.segment_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Lien avec le plan thérapeutique'.tr,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                          child: DropdownButton<dynamic>(
                            hint: Text(
                              'Sélectionner une étape (optionnel)'.tr,
                              style: AppTextStyles.fieldHint,
                            ),
                            isExpanded: true,
                            value: controller.etapePlanId.value,
                            items: [
                              DropdownMenuItem<dynamic>(
                                value: null,
                                child: Text('-- Aucune étape --'.tr),
                              ),
                              DropdownMenuItem<dynamic>(
                                value: 1,
                                child: Text('Étape 1 : Évaluation initiale'.tr),
                              ),
                              DropdownMenuItem<dynamic>(
                                value: 2,
                                child: Text('Étape 2 : Suivi émotionnel'.tr),
                              ),
                            ],
                            onChanged: (val) =>
                                controller.etapePlanId.value = val,
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
                          const Icon(
                            Icons.attach_file_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          SectionHeader(
                            title: 'Pièces jointes'.tr,
                            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                          ),
                        ],
                      ),
                      Text(
                        'Ajouter une photo ou une vidéo liée à  la séance'.tr,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 14),
                      MediaPickerWidget(
                        initialMediaUrls: controller.medias,
                        onMediasChanged: (urls) =>
                            controller.medias.value = urls,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                AppButton(
                  label: 'Enregistrer le rapport'.tr,
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
