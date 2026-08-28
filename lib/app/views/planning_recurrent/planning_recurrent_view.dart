import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/planning_recurrent_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/app_section_header.dart';

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
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
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
                      SectionHeader(
                        title: 'Jours de la semaine',
                        icon: Icons.calendar_today_outlined,
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
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

                // Type d'horaires (Fixe vs Ponctuel)
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
                            Icons.tune_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Type d\'horaires',
                            style: AppTextStyles.sectionTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.setModeCreneaux('fixe'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        controller.modeCreneaux.value == 'fixe'
                                        ? AppColors.primary
                                        : AppColors.fieldBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          controller.modeCreneaux.value ==
                                              'fixe'
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Horaires Fixes',
                                      style: AppTextStyles.iosCaption1.copyWith(
                                        color:
                                            controller.modeCreneaux.value ==
                                                'fixe'
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    controller.setModeCreneaux('ponctuel'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        controller.modeCreneaux.value ==
                                            'ponctuel'
                                        ? AppColors.primary
                                        : AppColors.fieldBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          controller.modeCreneaux.value ==
                                              'ponctuel'
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Ponctuel / Par Jour',
                                      style: AppTextStyles.iosCaption1.copyWith(
                                        color:
                                            controller.modeCreneaux.value ==
                                                'ponctuel'
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Horaires card
                Obx(() {
                  if (controller.modeCreneaux.value == 'fixe') {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Horaires Fixes (Communs)',
                            icon: Icons.access_time_rounded,
                            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Heure de début',
                                  hintText: '09:00',
                                  controller: TextEditingController(
                                    text: controller.heureDebut.value,
                                  ),
                                  onChanged: (v) =>
                                      controller.heureDebut.value = v,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  label: 'Heure de fin',
                                  hintText: '09:45',
                                  controller: TextEditingController(
                                    text: controller.heureFin.value,
                                  ),
                                  onChanged: (v) =>
                                      controller.heureFin.value = v,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  // Mode Ponctuel / Par Jour
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Horaires Personnalisés par Jour',
                          icon: Icons.access_time_rounded,
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                        ),
                        const SizedBox(height: 14),
                        if (controller.selectedDays.isEmpty)
                          Text(
                            'Sélectionnez des jours ci-dessus pour définir leurs horaires.',
                            style: AppTextStyles.bodySmall,
                          )
                        else
                          ...controller.selectedDays.map((d) {
                            final start = controller.getSlotStartForDay(d);
                            final end = controller.getSlotEndForDay(d);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.fieldBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      d,
                                      style: AppTextStyles.iosCaption1.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Début',
                                      hintText: '09:00',
                                      controller: TextEditingController(
                                        text: start,
                                      ),
                                      onChanged: (v) => controller
                                          .updateSlotForDay(d, debut: v),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Fin',
                                      hintText: '09:45',
                                      controller: TextEditingController(
                                        text: end,
                                      ),
                                      onChanged: (v) => controller
                                          .updateSlotForDay(d, fin: v),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  );
                }),
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
                      SectionHeader(
                        title: 'Psychologue assigné',
                        icon: Icons.person_outline,
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Dr. Moreau', style: AppTextStyles.bodyMedium),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary,
                            ),
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
