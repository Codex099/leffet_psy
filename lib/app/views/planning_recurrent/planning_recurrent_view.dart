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
import '../../widgets/searchable_picker.dart';

class PlanningRecurrentView extends GetView<PlanningRecurrentController> {
 const PlanningRecurrentView({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

   return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Planning Récurrent'.tr,
       subtitle: 'Créneaux & Périodicité'.tr,
       showBackButton: true,
      ),
      body: Obx(() {
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Jours de la semaine'.tr,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.5,
                    ),
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
                            'Type d\'horaires'.tr,
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
                                    color: controller.modeCreneaux.value == 'fixe'
                                       ? AppColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: controller.modeCreneaux.value == 'fixe'
                                       ? [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : null,
                                    border: controller.modeCreneaux.value == 'fixe'
                                       ? null
                                        : Border.all(
                                            color: const Color(0xFFE2E8F0),
                                            width: 1.5,
                                          ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Horaires Fixes'.tr,
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
                                    color: controller.modeCreneaux.value == 'ponctuel'
                                       ? AppColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: controller.modeCreneaux.value == 'ponctuel'
                                       ? [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : null,
                                    border: controller.modeCreneaux.value == 'ponctuel'
                                       ? null
                                        : Border.all(
                                            color: const Color(0xFFE2E8F0),
                                            width: 1.5,
                                          ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Ponctuel / Par Jour'.tr,
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Horaires Fixes (Communs)'.tr,
                           icon: Icons.access_time_rounded,
                            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Heure de début'.tr,
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
                                  label: 'Heure de fin'.tr,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Horaires Personnalisés par Jour'.tr,
                         icon: Icons.access_time_rounded,
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                        ),
                        const SizedBox(height: 14),
                        if (controller.selectedDays.isEmpty)
                          Text(
                            'Sélectionnez des jours ci-dessus pour définir leurs horaires.'.tr,
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF1F5F9),
                                  width: 1.5,
                                ),
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
                                      label: 'Début'.tr,
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
                                      label: 'Fin'.tr,
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

                // Psychologues assignés card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Psychologues assignés'.tr,
                       icon: Icons.person_outline,
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        if (controller.employees.isEmpty) {
                          return Text(
                            'Aucun praticien disponible.'.tr,
                           style: AppTextStyles.iosFootnote,
                          );
                        }
                        return SearchablePickerField<dynamic>(
                          label: 'Psychologues'.tr,
                         hintText: 'Rechercher et sélectionner les praticiens...'.tr,
                         title: 'Sélectionner les Praticiens'.tr,
                         isMultiSelect: true,
                          leadingIcon: Icons.badge_outlined,
                          selectedValues: controller.selectedEmployeeIds.toList(),
                          items: controller.employees.map((emp) {
                            return SearchableItem<dynamic>(
                              value: emp.id,
                              label: emp.fullName,
                              subtitle: emp.roleLabel,
                              initials: emp.initials,
                            );
                          }).toList(),
                          onMultiChanged: (vals) {
                            controller.selectedEmployeeIds.assignAll(vals);
                          },
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Créneaux automatiques card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.autorenew_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Créneaux automatiques'.tr,
                                  style: AppTextStyles.sectionTitle,
                                ),
                                Text(
                                  'Génération et renouvellement récurrent'.tr,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Activer les créneaux automatiques'.tr,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            controller.creneauxAutomatiques.value
                                ? 'Génère 4 semaines de séances et renouvelle automatiquement à la fin de chaque créneau final.'.tr
                                : 'Par défaut désactivé (off). Aucune séance ne sera créée automatiquement.'.tr,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          value: controller.creneauxAutomatiques.value,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) =>
                              controller.creneauxAutomatiques.value = val,
                        ),
                      ),
                      Obx(() {
                        if (!controller.creneauxAutomatiques.value) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_repeat_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Créneau de 4 semaines (28 jours)'.tr,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'À chaque fin de séance finale de créneau, une nouvelle période de 4 semaines sera automatiquement générée sur l\'agenda.'.tr,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Enregistrer action button
                AppButton(
                  label: 'Enregistrer'.tr,
                  onPressed: () => controller.savePlanning(),
                ),
              ],
            ),
          );
        }),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
        ),
        child: Text(
          day,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
