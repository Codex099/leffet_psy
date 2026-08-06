import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/parents_liste_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/state_placeholder.dart';

class ParentsListeView extends GetView<ParentsListeController> {
  const ParentsListeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.editParent),
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
                      Text('Parents', style: AppTextStyles.screenTitleMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.fieldBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (val) => controller.search(val),
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom ou téléphone',
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
                      onAction: () => controller.loadParents(),
                    );
                  }
                  final list = controller.filteredParents;
                  if (list.isEmpty) {
                    return StatePlaceholder.empty(
                      title: 'Aucun parent trouvé',
                      message: 'Ajoutez un parent ou ajustez votre recherche.',
                      actionLabel: '+ Ajouter un parent',
                      onAction: () => Get.toNamed(AppRoutes.editParent),
                    );
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final parent = list[index];
                      return _buildParentCard(parent);
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

  Widget _buildParentCard(dynamic parent) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.editParent, arguments: parent.id),
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
              child: Text(parent.initials, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parent.fullName, style: AppTextStyles.cardName),
                  const SizedBox(height: 4),
                  Text(parent.telephone ?? 'Pas de numéro enregistré', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
