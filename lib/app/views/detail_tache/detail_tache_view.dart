import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/detail_tache_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_placeholder.dart';

class DetailTacheView extends GetView<DetailTacheController> {
  const DetailTacheView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Obx(() {
          if (controller.status.value == 'loading') {
            return const StatePlaceholder(type: StatePlaceholderType.loading);
          }
          if (controller.status.value == 'error') {
            return StatePlaceholder.error(
              message: controller.errorMessage.value,
            );
          }

          return SingleChildScrollView(
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
                        Text('TÂCHE', style: AppTextStyles.sectionKicker),
                        Text(
                          controller.isNew ? 'Nouvelle tâche' : 'Modifier la tâche',
                          style: AppTextStyles.screenTitleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                      AppTextField(
                        label: 'Titre de la tâche',
                        hintText: 'Ex: Contacter le parent de Lucas',
                        onChanged: (v) => controller.titre.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Description',
                        hintText: 'Détails supplémentaires...',
                        maxLines: 4,
                        onChanged: (v) => controller.description.value = v,
                      ),
                      const SizedBox(height: 14),
                      Text('Priorité', style: AppTextStyles.fieldLabel),
                      const SizedBox(height: 8),
                      Obx(() => Wrap(
                            spacing: 8,
                            children: [
                              _buildPriorityChip('haute', 'Haute', AppColors.error),
                              _buildPriorityChip('normale', 'Normale', AppColors.secondary),
                              _buildPriorityChip('basse', 'Basse', AppColors.statusPresent),
                            ],
                          )),
                      const SizedBox(height: 14),
                      Text('Statut', style: AppTextStyles.fieldLabel),
                      const SizedBox(height: 8),
                      Obx(() => Wrap(
                            spacing: 8,
                            children: [
                              _buildStatusChip('a_faire', 'À faire', AppColors.primary),
                              _buildStatusChip('en_cours', 'En cours', AppColors.secondary),
                              _buildStatusChip('fait', 'Fait', AppColors.statusPresent),
                            ],
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: controller.isNew ? 'Créer la tâche' : 'Enregistrer',
                  onPressed: () => controller.saveTache(),
                ),
                if (!controller.isNew) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Supprimer la tâche',
                    isDestructive: true,
                    onPressed: () => controller.deleteTache(),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPriorityChip(String value, String label, Color color) {
    final isSelected = controller.priorite.value == value;
    return InkWell(
      onTap: () => controller.priorite.value = value,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.badge.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String value, String label, Color color) {
    final isSelected = controller.statut.value == value;
    return InkWell(
      onTap: () => controller.statut.value = value,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.badge.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
