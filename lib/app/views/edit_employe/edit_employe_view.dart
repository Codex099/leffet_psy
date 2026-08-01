import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_employe_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class EditEmployeView extends GetView<EditEmployeController> {
  const EditEmployeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      Text('Ajout / Édition Employé', style: AppTextStyles.screenTitleMedium),
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
                      label: 'Nom complet',
                      hintText: 'Camille Moreau',
                      onChanged: (v) => controller.nom.value = v,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Téléphone',
                      hintText: '06 12 34 56 78',
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => controller.telephone.value = v,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Nom d\'utilisateur',
                      hintText: 'c.moreau',
                      onChanged: (v) => controller.username.value = v,
                    ),
                    const SizedBox(height: 14),
                    Text('Rôle', style: AppTextStyles.fieldLabel),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                          children: [
                            Expanded(child: _buildRoleChip('Admin')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildRoleChip('Psychologue')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildRoleChip('Éducatrice')),
                          ],
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Patients assignés card
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
                    _buildPatientAssignTile('Lucas Bernard', 1, isChecked: true),
                    const SizedBox(height: 8),
                    _buildPatientAssignTile('Emma Rousseau', 2, isChecked: false),
                    const SizedBox(height: 8),
                    _buildPatientAssignTile('Nina Faure', 3, isChecked: true),
                    const SizedBox(height: 8),
                    _buildPatientAssignTile('Camille Moreau', 4, isChecked: false),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              AppButton(
                label: 'Enregistrer',
                onPressed: () => controller.saveEmployee(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String r) {
    final isSelected = controller.role.value == r;
    return InkWell(
      onTap: () => controller.role.value = r,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.fieldBackground,
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            r,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientAssignTile(String name, int id, {required bool isChecked}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (v) => controller.togglePatient(id),
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          const CircleAvatar(radius: 18, backgroundColor: AppColors.secondaryLight, child: Icon(Icons.person, size: 18)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              Text('Patient suivi', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
