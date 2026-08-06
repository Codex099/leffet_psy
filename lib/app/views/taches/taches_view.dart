import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/taches_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
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

                  return RefreshIndicator(
                    onRefresh: () => controller.refreshData(),
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
    final Color statutColor = t.statut == 'fait'
        ? AppColors.statusPresent
        : t.statut == 'en_cours'
            ? AppColors.secondary
            : AppColors.primary;

    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.detailTache, arguments: t.id),
      onLongPress: () async {
        // Cycle rapide du statut sans ouvrir l'écran
        final order = ['a_faire', 'en_cours', 'fait'];
        final idx = order.indexOf(t.statut);
        final next = order[(idx + 1) % order.length];
        final labels = {'a_faire': 'À faire', 'en_cours': 'En cours', 'fait': 'Fait'};
        final confirm = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Changer le statut'),
            content: Text('Passer « ${t.titre} » en "${labels[next]}" ?'),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
              ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Confirmer')),
            ],
          ),
        );
        if (confirm == true) {
          await controller.updateStatutFromList(t.id, next);
        }
      },
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
                Expanded(
                  child: Text(t.titre,
                      style: AppTextStyles.cardName,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statutColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t.prioriteLabel,
                    style: AppTextStyles.badge.copyWith(color: statutColor),
                  ),
                ),
              ],
            ),
            if (t.description != null && t.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(t.description!,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.touch_app_outlined,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Appui long pour changer le statut',
                    style: AppTextStyles.bodySmall
                        .copyWith(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

