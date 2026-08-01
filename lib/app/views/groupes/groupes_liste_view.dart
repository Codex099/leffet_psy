import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/groupes_liste_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';

class GroupesListeView extends GetView<GroupesListeController> {
  const GroupesListeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.editGroupe),
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
                      Text('Groupes', style: AppTextStyles.screenTitleMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.fieldBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (val) => controller.search(val),
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom de groupe',
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

              // List of Groups or Empty State
              Expanded(
                child: Obx(() {
                  if (controller.status.value == 'loading') {
                    return StatePlaceholder.loading();
                  }
                  if (controller.status.value == 'error') {
                    return StatePlaceholder.error(
                      message: controller.errorMessage.value,
                      onAction: () => controller.loadGroupes(),
                    );
                  }
                  if (controller.status.value == 'empty') {
                    return StatePlaceholder.empty(
                      title: 'Aucun groupe pour le moment',
                      message: 'Créez un groupe pour organiser les séances collectives et suivre les inscriptions.',
                      actionLabel: '+ Créer un groupe',
                      onAction: () => Get.toNamed(AppRoutes.editGroupe),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.groupes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final groupe = controller.groupes[index];
                      return _buildGroupeCard(groupe);
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

  Widget _buildGroupeCard(dynamic groupe) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.groupeDetail, arguments: groupe.id),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(groupe.nom, style: AppTextStyles.cardName),
                  const SizedBox(height: 4),
                  Text(
                    groupe.description ?? 'Groupe de parole et d\'activités',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            StatusBadge.active(label: groupe.typePlanning),
          ],
        ),
      ),
    );
  }
}
