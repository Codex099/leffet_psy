import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patients_liste_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';

class PatientsListeView extends GetView<PatientsListeController> {
  const PatientsListeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Patients', style: AppTextStyles.screenTitle),
                          const SizedBox(width: 8),
                          Obx(() => Text(
                                '${controller.patients.length} résultats',
                                style: AppTextStyles.bodySmall,
                              )),
                        ],
                      ),
                      Text('Vue adaptée au rôle connecté', style: AppTextStyles.screenSubtitle),
                    ],
                  ),
                  InkWell(
                    onTap: () => Get.toNamed(AppRoutes.editPatient),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.softShadow,
                      ),
                      child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.fieldBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (val) => controller.search(val),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un nom, prénom ou téléphone parent',
                    hintStyle: AppTextStyles.fieldHint.copyWith(fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filters Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Professionnel assigné', isDropdown: true),
                    const SizedBox(width: 8),
                    _buildFilterChip('Statut', isDropdown: true, isSelected: true),
                    const SizedBox(width: 8),
                    _buildFilterChip('Âge', isDropdown: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // List of Patients
              Expanded(
                child: Obx(() {
                  if (controller.status.value == 'loading') {
                    return StatePlaceholder.loading();
                  }
                  if (controller.status.value == 'error') {
                    return StatePlaceholder.error(
                      message: controller.errorMessage.value,
                      onAction: () => controller.loadPatients(),
                    );
                  }
                  if (controller.status.value == 'empty') {
                    return StatePlaceholder.empty(
                      title: 'Aucun patient trouvé',
                      message: 'Essayez un autre terme de recherche ou ajoutez un nouveau patient.',
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.patients.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final patient = controller.patients[index];
                      return _buildPatientCard(patient);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isDropdown = false, bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary : AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? AppColors.secondary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (isDropdown) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientCard(dynamic patient) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.patientInfo, arguments: patient.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            PatientAvatar(
              initials: patient.initials,
              photoUrl: patient.photo,
              radius: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(patient.fullName, style: AppTextStyles.cardName),
                      if (patient.estActif)
                        StatusBadge.present(label: 'Assisté')
                      else
                        StatusBadge.absent(label: 'Inactif'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${patient.age ?? 7} ans · Dr. Legrand · Individuel/Groupe',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Parent: 06 12 34 56 78',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
