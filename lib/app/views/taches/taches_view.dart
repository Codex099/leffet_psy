import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/taches_controller.dart';
import '../../models/tache_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/ios_segmented_control.dart';
import '../../widgets/state_placeholder.dart';

class TachesView extends GetView<TachesController> {
 const TachesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Tâches & Actions'.tr,
       subtitle: 'Suivi Clinique'.tr,
       showBackButton: true,
        actions: [
          BouncyTap(
            onTap: () async {
              final res = await Get.toNamed(AppRoutes.detailTache);
              if (res == true) controller.loadTaches(forceRefresh: true);
            },
            child: Container(
              padding: const EdgeInsets.all(9),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                shape: BoxShape.circle,
                boxShadow: AppColors.accentShadow,
              ),
              child: const Icon(
                Icons.add_task_rounded,
                size: 19,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Segmented Control (Assignées à moi / Toutes) ──
          Obx(
            () => IosSegmentedControl<bool>(
              segments: {
                false: 'Toutes les tâches'.tr,
                true: 'Mes tâches'.tr,
              },
              selectedValue: controller.filterAssignesAMoi.value,
              onValueChanged: (val) => controller.toggleFilter(val),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),

          // ── Content / List ──
          Expanded(
              child: Obx(() {
                if (controller.status.value == 'loading') {
                 return StatePlaceholder.loading(
                    message: 'Chargement des tâches...'.tr,
                 );
                }
                if (controller.status.value == 'error') {
                 return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadTaches(forceRefresh: true),
                  );
                }
                if (controller.taches.isEmpty) {
                  return StatePlaceholder.empty(
                    title: 'Aucune tâche pour le moment'.tr,
                   message: controller.filterAssignesAMoi.value
                        ? 'Aucune tâche ne vous est assignée actuellement.'.tr
                       : 'Créez une tâche pour suivre les actions à réaliser.'.tr,
                   actionLabel: 'Nouvelle tâche'.tr,
                   onAction: () async {
                      final res = await Get.toNamed(AppRoutes.detailTache);
                      if (res == true) {
                        controller.loadTaches(forceRefresh: true);
                      }
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refreshData(),
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 120),
                    children: [
                      if (controller.tachesAFaire.isNotEmpty)
                        _buildCategorySection(
                          'À faire'.tr,
                         controller.tachesAFaire,
                          AppColors.accentCoral,
                        ),
                      if (controller.tachesEnCours.isNotEmpty)
                        _buildCategorySection(
                          'En cours'.tr,
                         controller.tachesEnCours,
                          AppColors.primary,
                        ),
                      if (controller.tachesFait.isNotEmpty)
                        _buildCategorySection(
                          'Terminées'.tr,
                         controller.tachesFait,
                          AppColors.secondary,
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
    );
  }

  Widget _buildCategorySection(
    String title,
    List<TacheModel> list,
    Color dotColor,
  ) {
    return IosCard(
      title: '$title (${list.length})'.tr,
      children: list.map((t) => _buildTacheTile(t)).toList(),
    );
  }

  Widget _buildTacheTile(TacheModel t) {
    final bool isDone =
        t.statut == 'fait' || t.statut == 'terminee' || t.statut == 'cloturee';
   final Color prioColor = t.priorite == 'haute'
       ? AppColors.accentCoral
        : t.priorite == 'normale'
       ? AppColors.primary
        : AppColors.secondary;

    return IosCardTile(
      leading: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          final nextStatut = isDone ? 'a_faire' : 'fait';
         controller.updateStatutFromList(t.id, nextStatut);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.iosGreen : Colors.transparent,
            border: Border.all(
              color: isDone ? AppColors.iosGreen : AppColors.iosSystemGray3,
              width: 1.8,
            ),
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : null,
        ),
      ),
      title: t.titre,
      subtitle:
          "${t.description != null && t.description!.isNotEmpty ? '${t.description!} - ' : ''}${t.dateEcheance != null ? '${'Échéance'.tr} : ${t.dateEcheance}' : ''}",
      showChevron: true,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: prioColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          t.prioriteLabel,
          style: AppTextStyles.iosCaption1.copyWith(
            color: prioColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: () async {
        final res = await Get.toNamed(AppRoutes.detailTache, arguments: t.id);
        if (res == true) controller.loadTaches(forceRefresh: true);
      },
    );
  }
}
