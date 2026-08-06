import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_employe_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_placeholder.dart';

class EditEmployeView extends GetView<EditEmployeController> {
  const EditEmployeView({super.key});

  static const List<Map<String, String>> _roles = [
    {'value': 'admin', 'label': 'Admin'},
    {'value': 'psychologue', 'label': 'Psychologue'},
    {'value': 'educatrice', 'label': 'Éducatrice'},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = controller.employeId != null;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Obx(() {
          if (controller.status.value == 'loading' && isEditMode &&
              controller.nom.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
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
                        Text('EMPLOYÉ', style: AppTextStyles.sectionKicker),
                        Text(
                          isEditMode ? 'Édition Employé' : 'Ajout Employé',
                          style: AppTextStyles.screenTitleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Form fields card
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
                        label: 'Prénom',
                        hintText: 'Ex. Camille',
                        initialValue: controller.prenom.value,
                        onChanged: (v) => controller.prenom.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Nom',
                        hintText: 'Ex. Moreau',
                        initialValue: controller.nom.value,
                        onChanged: (v) => controller.nom.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Téléphone',
                        hintText: '06 12 34 56 78',
                        keyboardType: TextInputType.phone,
                        initialValue: controller.telephone.value,
                        onChanged: (v) => controller.telephone.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Nom d\'utilisateur',
                        hintText: 'c.moreau',
                        initialValue: controller.username.value,
                        onChanged: (v) => controller.username.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: isEditMode
                            ? 'Nouveau mot de passe (laisser vide pour conserver)'
                            : 'Mot de passe *',
                        hintText: '••••••••',
                        obscureText: true,
                        onChanged: (v) => controller.password.value = v,
                      ),
                      const SizedBox(height: 14),

                      // Role chips
                      Text('Rôle', style: AppTextStyles.fieldLabel),
                      const SizedBox(height: 8),
                      Obx(() => Row(
                            children: _roles.map((r) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildRoleChip(r['value']!, r['label']!),
                                ),
                              );
                            }).toList(),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Patients assignés card (live from API)
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
                          Text('Patients assignés', style: AppTextStyles.sectionTitle),
                          const Icon(Icons.people_outline_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                      Text('Sélection multiple des patients suivis', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 14),

                      // Patient search field
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          onChanged: (v) => controller.patientSearch.value = v,
                          decoration: InputDecoration(
                            hintText: 'Rechercher un patient...',
                            hintStyle: AppTextStyles.fieldHint.copyWith(fontSize: 13),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Patient list
                      Obx(() {
                        if (controller.patientsStatus.value == 'loading') {
                          return const SizedBox(
                            height: 80,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        }
                        final patients = controller.filteredPatients;
                        if (patients.isEmpty) {
                          return StatePlaceholder.empty(
                            title: 'Aucun patient actif trouvé',
                            message: '',
                          );
                        }
                        return Column(
                          children: patients.map((p) {
                            final isChecked = controller.selectedPatientIds.contains(p.id);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => controller.togglePatient(p.id),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isChecked
                                        ? AppColors.primary.withOpacity(0.08)
                                        : AppColors.fieldBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isChecked ? AppColors.primary : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isChecked,
                                        onChanged: (_) => controller.togglePatient(p.id),
                                        activeColor: AppColors.primary,
                                      ),
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: AppColors.secondaryLight,
                                        child: Text(
                                          p.initials,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(p.fullName,
                                                style: AppTextStyles.bodyMedium
                                                    .copyWith(fontWeight: FontWeight.w600)),
                                            if (p.age != null)
                                              Text('${p.age} ans',
                                                  style: AppTextStyles.bodySmall),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                Obx(() => AppButton(
                      label: controller.status.value == 'loading'
                          ? 'Enregistrement...'
                          : isEditMode
                              ? 'Mettre à jour'
                              : 'Créer l\'employé',
                      onPressed: controller.status.value == 'loading'
                          ? null
                          : () => controller.saveEmployee(),
                    )),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRoleChip(String value, String label) {
    final isSelected = controller.role.value == value;
    return InkWell(
      onTap: () => controller.role.value = value,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.fieldBackground,
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
