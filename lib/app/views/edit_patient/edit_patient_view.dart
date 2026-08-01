import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_patient_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_text_field.dart';

class EditPatientView extends GetView<EditPatientController> {
  const EditPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
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
                      Text('ADMIN', style: AppTextStyles.sectionKicker),
                      Text('Ajout / Édition Patient', style: AppTextStyles.screenTitleMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Step Wizard Tabs
              Obx(() => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStepChip('Perso', 1),
                            _buildStepChip('Médical', 2),
                            _buildStepChip('Tuteur', 3),
                            _buildStepChip('Plan', 4),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Étape ${controller.currentStep.value} sur 4',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),

              // Form Section Card
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
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.secondaryLight,
                            child: Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.camera_alt_rounded, size: 16),
                            label: const Text('Ajouter une photo'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(140, 36),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Informations personnelles', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Prénom',
                      hintText: 'Ex. Léa',
                      onChanged: (val) => controller.prenom.value = val,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Nom',
                      hintText: 'Ex. Dupont',
                      onChanged: (val) => controller.nom.value = val,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Date de naissance',
                      hintText: 'JJ / MM / AAAA',
                      onChanged: (val) => controller.dateNaissance.value = val,
                    ),
                    const SizedBox(height: 14),

                    // Gender toggle selector
                    Text('Sexe', style: AppTextStyles.fieldLabel),
                    const SizedBox(height: 6),
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: _buildGenderTile('Garçon'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGenderTile('Fille'),
                            ),
                          ],
                        )),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Parent lié',
                      hintText: 'Rechercher ou créer un parent',
                      suffixIcon: const Icon(Icons.search_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Overview Section Card
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
                        Text('Aperçu du dossier', style: AppTextStyles.sectionTitle),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Brouillon', style: AppTextStyles.badge.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewRow('Photo', 'Ajoutée'),
                    const Divider(),
                    _buildOverviewRow('Identité', 'À compléter'),
                    const Divider(),
                    _buildOverviewRow('Parent lié', 'À rechercher'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bottom Navigation Wizard Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Navigation de l\'assistant', style: AppTextStyles.bodyMedium),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Enregistrer un brouillon'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => controller.previousStep(),
                            child: const Text('Précédent'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.nextStep(),
                            child: const Text('Suivant'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepChip(String label, int step) {
    final isSelected = controller.currentStep.value == step;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(
          color: isSelected ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildGenderTile(String value) {
    final isSelected = controller.sexe.value == value;
    return InkWell(
      onTap: () => controller.sexe.value = value,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.fieldBackground,
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary)),
        ],
      ),
    );
  }
}
