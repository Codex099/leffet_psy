import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/employes_liste_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/status_badge.dart';

class EmployesListeView extends GetView<EmployesListeController> {
 const EmployesListeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Équipe & Praticiens'.tr,
       subtitle: 'Gestion des Droits (Admin)'.tr,
       showBackButton: true,
        actions: [
          BouncyTap(
            onTap: () async {
              final res = await Get.toNamed(AppRoutes.editEmploye);
              if (res == true) controller.loadEmployees();
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
                Icons.person_add_rounded,
                size: 19,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── iOS Search Bar ──
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
                    hintText: 'Rechercher un membre de l\'équipe...'.tr,
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

            // ── Content / List ──
            Expanded(
              child: Obx(() {
                if (controller.status.value == 'loading') {
                 return StatePlaceholder.loading(
                    message: 'Chargement de l\'équipe...'.tr,
                 );
                }
                if (controller.status.value == 'error') {
                 return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadEmployees(),
                  );
                }
                if (controller.employees.isEmpty) {
                  return StatePlaceholder.empty(
                    title: 'Aucun employé enregistré'.tr,
                   message:
                        'Ajoutez des membres de l\'équipe pour configurer leurs accès.'.tr,
                   actionLabel: 'Nouvel employé'.tr,
                   onAction: () async {
                      final res = await Get.toNamed(AppRoutes.editEmploye);
                      if (res == true) controller.loadEmployees();
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadEmployees(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 6, bottom: 120),
                    itemCount: controller.employees.length,
                    itemBuilder: (context, index) {
                      final emp = controller.employees[index];
                      final patientCount = emp.patientsAssignesIds?.length ?? 0;

                      return IosCard(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        children: [
                          IosCardTile(
                            leading: PatientAvatar(
                              initials: emp.initials,
                              radius: 20,
                            ),
                            title: emp.fullName,
                            subtitle:
                                '${emp.telephone ?? emp.username} · $patientCount ${'patient(s) assigné(s)'.tr}',
                           showChevron: true,
                            trailing: StatusBadge.active(label: emp.roleLabel),
                            onTap: () async {
                              final res = await Get.toNamed(
                                AppRoutes.editEmploye,
                                arguments: emp.id,
                              );
                              if (res == true) controller.loadEmployees();
                            },
                          ),
                          // ── Barre d'actions rapides ──────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                            child: Row(
                              children: [
                                // Bouton : Voir et gérer la visibilité des patients
                                Expanded(
                                  child: BouncyTap(
                                    onTap: () async {
                                      await Get.toNamed(
                                        AppRoutes.employeVisibilitePatients,
                                        arguments: emp,
                                      );
                                      controller.loadEmployees(forceRefresh: true);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.visibility_rounded,
                                            size: 15,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '$patientCount ${'patient(s)'.tr}',
                                            style: AppTextStyles.iosCaption1
                                                .copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Bouton : Supprimer le compte
                                BouncyTap(
                                  onTap: () =>
                                      _confirmDelete(context, emp.id, emp.fullName),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.error
                                          .withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 15,
                                          color: AppColors.error,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Supprimer'.tr,
                                         style: AppTextStyles.iosCaption1
                                              .copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
    );
  }

  /// Dialogue de confirmation avant suppression
  void _confirmDelete(BuildContext context, dynamic id, String name) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Supprimer le compte'.tr,
           style: AppTextStyles.iosHeadline
                .copyWith(fontWeight: FontWeight.w800)),
        content: Text(
          '${'Voulez-vous vraiment supprimer le compte de'.tr} $name ? ${'Cette action est irréversible.'.tr}',
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
              Get.back();
              controller.deleteEmployee(id);
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
