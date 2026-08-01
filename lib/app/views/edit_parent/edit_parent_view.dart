import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_parent_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class EditParentView extends GetView<EditParentController> {
  const EditParentView({super.key});

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
                      Text('GESTION PARENTS', style: AppTextStyles.sectionKicker),
                      Text('Ajout / Édition Parent', style: AppTextStyles.screenTitleMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                      onChanged: (v) => controller.prenom.value = v,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Nom',
                      hintText: 'Ex. Martin',
                      onChanged: (v) => controller.nom.value = v,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Téléphone',
                      hintText: '+213 666 65 846',
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => controller.telephone.value = v,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'État civil',
                      hintText: 'Marié(e), Divorcé(e)...',
                      onChanged: (v) => controller.etatCivil.value = v,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Adresse',
                      hintText: 'Adresse du domicile',
                      maxLines: 2,
                      onChanged: (v) => controller.adresse.value = v,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              AppButton(
                label: 'Enregistrer le parent',
                onPressed: () => controller.saveParent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
