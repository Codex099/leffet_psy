import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/planning_recurrent_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/state_placeholder.dart';

class PlanningRecurrentView extends GetView<PlanningRecurrentController> {
  const PlanningRecurrentView({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const CreativeAppBar(
        title: 'Planning Récurrent',
        subtitle: 'Créneaux & Périodicité',
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
              onAction: () => controller.loadPlanning(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Jours de la semaine card
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
                          const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Jours de la semaine', style: AppTextStyles.sectionTitle),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: days.map((d) => _buildDayChip(d)).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Horaires card
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
                          const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Horaires', style: AppTextStyles.sectionTitle),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Heure de début',
                              hintText: '09:00',
                              onChanged: (v) => controller.heureDebut.value = v,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Heure de fin',
                              hintText: '09:45',
                              onChanged: (v) => controller.heureFin.value = v,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Date de début',
                              hintText: '14/06/2026',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Date de fin',
                              hintText: '14/09/2026',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Psychologue assigné card
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
                          const Icon(Icons.person_outline, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Psychologue assigné', style: AppTextStyles.sectionTitle),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Dr. Moreau', style: AppTextStyles.bodyMedium),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Enregistrer action button
                AppButton(
                  label: 'Enregistrer',
                  onPressed: () => controller.savePlanning(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayChip(String day) {
    final isSelected = controller.selectedDays.contains(day);
    return InkWell(
      onTap: () {
        if (isSelected) {
          controller.selectedDays.remove(day);
        } else {
          controller.selectedDays.add(day);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          day,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
