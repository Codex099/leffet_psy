import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/parents_liste_controller.dart';
import '../../models/parent_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';

class ParentsListeView extends GetView<ParentsListeController> {
 const ParentsListeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Annuaire Parents'.tr,
       subtitle: 'Contacts & Tuteurs'.tr,
       showBackButton: true,
        actions: [
          BouncyTap(
            onTap: () => Get.toNamed(AppRoutes.editParent),
            child: Container(
              padding: const EdgeInsets.all(9),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: AppColors.oceanGradient,
                shape: BoxShape.circle,
                boxShadow: AppColors.softShadow,
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
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
            const SizedBox(height: 90),
            // iOS Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.iosSystemGray5,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  onChanged: (val) => controller.search(val),
                  style: AppTextStyles.iosBody,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un parent (nom, téléphone)...'.tr,
                   hintStyle: AppTextStyles.iosSubhead,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.iosSystemGray,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
            ),

            // Content List
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

                // Force reactivity on search query
                final query = controller.searchQuery.value;
                final list = controller.filteredParents;

                if (list.isEmpty) {
                  return StatePlaceholder.empty(
                    title: query.isNotEmpty
                        ? 'Aucun résultat'.tr
                       : 'Aucun parent enregistré',
                   message: query.isNotEmpty
                        ? 'Aucun parent ne correspond à  "$query".'
                       : 'Ajoutez des parents pour les associer aux fiches des patients.',
                   actionLabel: 'Nouveau parent',
                   onAction: () => Get.toNamed(AppRoutes.editParent),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 6, bottom: 120),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final parent = list[index];
                    return IosCard(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      children: [
                        IosCardTile(
                          leading: PatientAvatar(
                            initials: parent.initials,
                            radius: 20,
                          ),
                          title: parent.fullName,
                          subtitle:
                              parent.telephone != null &&
                                  parent.telephone!.isNotEmpty
                              ? parent.telephone
                              : 'Aucun téléphone renseigné',
                         showChevron: true,
                          trailing:
                              parent.telephone != null &&
                                  parent.telephone!.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.iosGreen.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.phone_rounded,
                                        size: 14,
                                        color: AppColors.iosGreen,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Appeler'.tr,
                                       style: AppTextStyles.iosCaption1
                                            .copyWith(
                                              color: AppColors.iosGreen,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                          onTap: () => _showParentDetailSheet(context, parent),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showParentDetailSheet(BuildContext context, ParentModel parent) {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.iosSystemGray4,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                PatientAvatar(initials: parent.initials, radius: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parent.fullName,
                        style: AppTextStyles.iosTitle2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (parent.etatCivil != null &&
                          parent.etatCivil!.isNotEmpty)
                        Text(
                          'État civil : ${parent.etatCivil}'.tr,
                         style: AppTextStyles.iosFootnote,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            IosCard(
              margin: EdgeInsets.zero,
              children: [
                IosCardTile(
                  leading: const Icon(
                    Icons.phone_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  title: 'Téléphone'.tr,
                 subtitle: parent.telephone ?? 'Non renseigné'.tr,
               ),
                if (parent.adresse != null && parent.adresse!.isNotEmpty)
                  IosCardTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    title: 'Adresse'.tr,
                   subtitle: parent.adresse,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(AppRoutes.editParent, arguments: parent.id);
                    },
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: Text('Modifier'.tr),
                 ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDeleteParent(context, parent.id, parent.fullName),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    label: Text(
                      'Supprimer'.tr,
                     style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Fermer'.tr),
                 ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDeleteParent(BuildContext context, dynamic id, String name) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Supprimer le parent'.tr,
           style: AppTextStyles.iosHeadline
                .copyWith(fontWeight: FontWeight.w800)),
        content: Text(
          'Voulez-vous vraiment supprimer le parent $name ? Cette action est irréversible.'.tr,
         style: AppTextStyles.iosSubhead,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'.tr,
               style:
                    AppTextStyles.iosBody.copyWith(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              Get.back(); // close bottom sheet
              controller.deleteParent(id);
            },
            child: Text(
              'Supprimer'.tr,
              style: AppTextStyles.iosBody.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
