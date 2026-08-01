import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/taches_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';

class TachesView extends GetView<TachesController> {
  const TachesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.detailTache),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TÂCHES', style: AppTextStyles.sectionKicker),
                      Text('Liste des tâches', style: AppTextStyles.screenTitleMedium),
                      Text('Suivi des actions cliniques et administratives', style: AppTextStyles.bodySmall),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.detailTache),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Ajouter une tâche'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(140, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Toggle filter Assignées à moi / Toutes
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Assignées à moi', style: AppTextStyles.bodyMedium),
                    Obx(() => Switch(
                          value: controller.filterAssignesAMoi.value,
                          onChanged: (val) => controller.toggleFilter(val),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Content Lists / Categories
              Expanded(
                child: Obx(() {
                  if (controller.status.value == 'loading') {
                    return StatePlaceholder.loading();
                  }
                  if (controller.status.value == 'error') {
                    return StatePlaceholder.error(
                      message: controller.errorMessage.value,
                      onAction: () => controller.loadTaches(),
                    );
                  }
                  if (controller.status.value == 'empty') {
                    return StatePlaceholder.empty(
                      title: 'Aucune tâche pour le moment',
                      message: 'Créez une tâche pour suivre les actions à réaliser.',
                      actionLabel: '+ Ajouter une tâche',
                      onAction: () => Get.toNamed(AppRoutes.detailTache),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategorySection('À faire', controller.tachesAFaire, AppColors.primary),
                        const SizedBox(height: 16),
                        _buildCategorySection('En cours', controller.tachesEnCours, AppColors.secondary),
                        const SizedBox(height: 16),
                        _buildCategorySection('Fait', controller.tachesFait, AppColors.statusPresent),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<dynamic> list, Color dotColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.sectionTitle),
              ],
            ),
            Text('${list.length} tâches', style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 10),
        if (list.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text('Aucune tâche dans cette catégorie', style: AppTextStyles.bodySmall),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final t = list[index];
              return _buildTacheCard(t);
            },
          ),
      ],
    );
  }

  Widget _buildTacheCard(dynamic t) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.detailTache, arguments: t.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.titre, style: AppTextStyles.cardName),
                StatusBadge.custom(label: t.prioriteLabel, color: AppColors.primary),
              ],
            ),
            if (t.description != null && t.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(t.description!, style: AppTextStyles.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
