import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/creation_seance_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class CreationSeanceView extends GetView<CreationSeanceController> {
  const CreationSeanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      Text('PLANIFICATION', style: AppTextStyles.sectionKicker),
                      Text('Nouvelle séance', style: AppTextStyles.screenTitleMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Etape 1 : Choisir le type de séance
              Text('Étape 1 : Type de séance', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 10),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: _buildTypeCard(
                          type: 'individuelle',
                          title: 'Individuelle',
                          icon: Icons.person_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeCard(
                          type: 'groupe',
                          title: 'Groupe',
                          icon: Icons.groups_rounded,
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 24),

              // Etape 2 : Détails & sélection
              Text('Étape 2 : Détails de la séance', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Obx(() {
                  if (controller.status.value == 'loading') {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.typeSeance.value == 'individuelle') ...[
                        Text('Sélectionner un patient', style: AppTextStyles.fieldLabel),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: controller.selectedPatientId.value,
                              items: controller.patients
                                  .map((p) => DropdownMenuItem<int>(
                                        value: p.id,
                                        child: Text(p.fullName),
                                      ))
                                  .toList(),
                              onChanged: (val) => controller.selectedPatientId.value = val,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text('Sélectionner un groupe', style: AppTextStyles.fieldLabel),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: controller.selectedGroupeId.value,
                              items: controller.groupes
                                  .map((g) => DropdownMenuItem<int>(
                                        value: g.id,
                                        child: Text(g.nom),
                                      ))
                                  .toList(),
                              onChanged: (val) => controller.selectedGroupeId.value = val,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Date de la séance',
                        hintText: 'AAAA-MM-JJ',
                        controller: TextEditingController(text: controller.date.value),
                        onChanged: (v) => controller.date.value = v,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Heure de début',
                              hintText: '10:00',
                              controller: TextEditingController(text: controller.heureDebut.value),
                              onChanged: (v) => controller.heureDebut.value = v,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Heure de fin',
                              hintText: '10:45',
                              controller: TextEditingController(text: controller.heureFin.value),
                              onChanged: (v) => controller.heureFin.value = v,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),
              Obx(() => AppButton(
                    label: 'Planifier la séance',
                    isLoading: controller.status.value == 'loading',
                    onPressed: () => controller.createSeance(),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String type,
    required String title,
    required IconData icon,
  }) {
    final isSelected = controller.typeSeance.value == type;
    return InkWell(
      onTap: () => controller.typeSeance.value = type,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
