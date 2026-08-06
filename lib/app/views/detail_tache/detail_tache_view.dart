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
                // ── Header ──
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
                        Obx(() => Text(
                              controller.isNew ? 'Nouvelle tâche' : 'Modifier la tâche',
                              style: AppTextStyles.screenTitleMedium,
                            )),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Infos principales ──
                _card(children: [
                  AppTextField(
                    label: 'Titre de la tâche *',
                    hintText: 'Ex: Contacter le parent de Lucas',
                    initialValue: controller.titre.value,
                    onChanged: (v) => controller.titre.value = v,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Description',
                    hintText: 'Détails supplémentaires...',
                    maxLines: 4,
                    initialValue: controller.description.value,
                    onChanged: (v) => controller.description.value = v,
                  ),
                  const SizedBox(height: 14),

                  // ── Priorité ──
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

                  // ── Statut ──
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
                ]),
                const SizedBox(height: 16),

                // ── Assignation employé (US-M37) ──
                _card(children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Assigné à', style: AppTextStyles.sectionTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.employeesStatus.value == 'loading') {
                      return const SizedBox(
                        height: 40,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    if (controller.availableEmployees.isEmpty) {
                      return Text('Aucun professionnel disponible.',
                          style: AppTextStyles.bodySmall);
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.fieldBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: controller.assigneA.value,
                          isExpanded: true,
                          hint: Text('Sélectionner un intervenant',
                              style: AppTextStyles.fieldHint),
                          dropdownColor: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('— Non assigné —'),
                            ),
                            ...controller.availableEmployees.map(
                              (emp) => DropdownMenuItem<int?>(
                                value: emp.id,
                                child: Text(emp.fullName),
                              ),
                            ),
                          ],
                          onChanged: (val) => controller.assigneA.value = val,
                        ),
                      ),
                    );
                  }),
                ]),
                const SizedBox(height: 16),

                // ── Date d'échéance (US-M38) ──
                _card(children: [
                  Row(
                    children: [
                      const Icon(Icons.event_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Date d\'échéance', style: AppTextStyles.sectionTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() => InkWell(
                        onTap: () async {
                          final initial = controller.dateEcheance.value.isNotEmpty
                              ? DateTime.tryParse(controller.dateEcheance.value) ?? DateTime.now()
                              : DateTime.now().add(const Duration(days: 7));
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: initial,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (picked != null) {
                            controller.dateEcheance.value =
                                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.dateEcheance.value.isEmpty
                                    ? 'Aucune échéance définie'
                                    : controller.dateEcheance.value,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: controller.dateEcheance.value.isEmpty
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined,
                                  color: AppColors.primary, size: 18),
                            ],
                          ),
                        ),
                      )),
                  if (controller.dateEcheance.value.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => controller.dateEcheance.value = '',
                        child: Text('Effacer',
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ),
                ]),
                const SizedBox(height: 24),

                // ── Actions ──
                Obx(() => AppButton(
                      label: controller.isNew ? 'Créer la tâche' : 'Enregistrer',
                      isLoading: controller.status.value == 'loading',
                      onPressed: () => controller.saveTache(),
                    )),
                if (!controller.isNew) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Supprimer la tâche',
                    isDestructive: true,
                    onPressed: () => controller.deleteTache(),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildPriorityChip(String value, String label, Color color) {
    final isSelected = controller.priorite.value == value;
    return InkWell(
      onTap: () => controller.priorite.value = value,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.border),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.border),
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
