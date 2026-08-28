import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/groupes_liste_controller.dart';
import '../../models/groupe_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/status_badge.dart';

class GroupesListeView extends GetView<GroupesListeController> {
  const GroupesListeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Groupes Thérapeutiques'.tr,
        subtitle: 'Ateliers & Séances'.tr,
        showBackButton: true,
        actions: [
          BouncyTap(
            onTap: () => Get.toNamed(AppRoutes.editGroupe),
            child: Container(
              padding: const EdgeInsets.all(9),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: AppColors.groupHeaderGradient,
                shape: BoxShape.circle,
                boxShadow: AppColors.softShadow,
              ),
              child: const Icon(
                Icons.group_add_rounded,
                size: 19,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 0.9),
                  boxShadow: AppColors.softShadow,
                ),
                child: TextField(
                  onChanged: (val) => controller.search(val),
                  style: AppTextStyles.iosBody,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un groupe thérapeutique...'.tr,
                    hintStyle: AppTextStyles.iosSubhead.copyWith(
                      color: AppColors.textHint,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    isDense: true,
                  ),
                ),
              ),
            ),

            // ── Groups List ──
            Expanded(
              child: Obx(() {
                if (controller.status.value == 'loading') {
                  return StatePlaceholder.loading(
                    message: 'Chargement des groupes...',
                  );
                }
                if (controller.status.value == 'error') {
                  return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadGroupes(),
                  );
                }
                if (controller.groupes.isEmpty) {
                  return StatePlaceholder.empty(
                    title: 'Aucun groupe thérapeutique'.tr,
                    message:
                        'Créez un groupe pour planifier des ateliers cliniques collectifs.',
                    actionLabel: 'Créer un groupe',
                    onAction: () => Get.toNamed(AppRoutes.editGroupe),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => controller.loadGroupes(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 120),
                    itemCount: controller.groupes.length,
                    itemBuilder: (context, index) {
                      final groupe = controller.groupes[index];
                      return _buildGroupeCard(groupe);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupeCard(GroupeModel groupe) {
    return IosCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      children: [
        IosCardTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.groupHeaderGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: groupe.nom,
          subtitle: '${groupe.membresCount} participant(s) inscrit(s)'.tr,
          trailing: StatusBadge.active(label: 'Atelier Actif'.tr),
          showChevron: true,
          onTap: () =>
              Get.toNamed(AppRoutes.groupeDetail, arguments: groupe.id),
        ),
      ],
    );
  }
}
