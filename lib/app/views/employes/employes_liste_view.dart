import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/employes_liste_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';

class EmployesListeView extends GetView<EmployesListeController> {
  const EmployesListeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.editEmploye),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
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
                      Text('GESTION CLINIQUE', style: AppTextStyles.sectionKicker),
                      Text('Employés', style: AppTextStyles.screenTitleMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.fieldBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (val) => controller.search(val),
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom',
                    hintStyle: AppTextStyles.fieldHint.copyWith(fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Content / List
              Expanded(
                child: Obx(() {
                  if (controller.status.value == 'loading') {
                    return StatePlaceholder.loading();
                  }
                  if (controller.status.value == 'error') {
                    return StatePlaceholder.error(
                      message: controller.errorMessage.value,
                      onAction: () => controller.loadEmployees(),
                    );
                  }
                  if (controller.status.value == 'empty') {
                    return StatePlaceholder.empty(
                      title: 'Aucun employé enregistré',
                      message: 'Ajoutez un membre de l\'équipe pour commencer à gérer les rôles et les contacts.',
                      actionLabel: '+ Ajouter un employé',
                      onAction: () => Get.toNamed(AppRoutes.editEmploye),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.employees.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final emp = controller.employees[index];
                      return _buildEmployeeCard(emp);
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

  Widget _buildEmployeeCard(dynamic emp) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.editEmploye, arguments: emp.id),
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
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.secondaryLight,
              child: Text(emp.initials, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emp.fullName, style: AppTextStyles.cardName),
                  const SizedBox(height: 4),
                  Text(emp.telephone ?? emp.username, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            StatusBadge.active(label: emp.roleLabel),
          ],
        ),
      ),
    );
  }
}
