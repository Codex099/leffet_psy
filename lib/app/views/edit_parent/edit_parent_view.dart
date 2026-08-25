import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_parent_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/creative_app_bar.dart';

class EditParentView extends GetView<EditParentController> {
  const EditParentView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = controller.parentId != null;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: isEditMode ? 'Modifier le Parent' : 'Nouveau Parent / Tuteur',
        subtitle: 'Tuteur Légal & Famille',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.status.value == 'loading' && isEditMode) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Error Banner (for 409 and other errors)
                if (controller.status.value == 'error' && controller.errorMessage.value.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Form card
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
                      Text('Informations de contact', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Prénom',
                        hintText: 'Ex. Sophie',
                        initialValue: controller.prenom.value,
                        onChanged: (v) => controller.prenom.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Nom',
                        hintText: 'Ex. Martin',
                        initialValue: controller.nom.value,
                        onChanged: (v) => controller.nom.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Téléphone',
                        hintText: '+213 666 65 846',
                        keyboardType: TextInputType.phone,
                        initialValue: controller.telephone.value,
                        onChanged: (v) => controller.telephone.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'État civil',
                        hintText: 'Marié(e), Divorcé(e)...',
                        initialValue: controller.etatCivil.value,
                        onChanged: (v) => controller.etatCivil.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Adresse',
                        hintText: 'Adresse du domicile',
                        maxLines: 2,
                        initialValue: controller.adresse.value,
                        onChanged: (v) => controller.adresse.value = v,
                      ),
                      const SizedBox(height: 14),

                      // Role familial dropdown
                      Text('Rôle familial', style: AppTextStyles.fieldLabel),
                      const SizedBox(height: 8),
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.fieldBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.role.value,
                                isExpanded: true,
                                style: AppTextStyles.bodyMedium,
                                dropdownColor: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                items: EditParentController.roleChoices
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item['value'],
                                          child: Text(item['label']!),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) controller.role.value = val;
                                },
                              ),
                            ),
                          )),
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
                              : 'Enregistrer le parent',
                      onPressed: controller.status.value == 'loading'
                          ? null
                          : () => controller.saveParent(),
                    )),
              ],
            ),
          );
        }),
      ),
    );
  }
}
