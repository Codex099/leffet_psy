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
      body: SafeArea(
        child: Column(
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
                    message: 'Chargement de l\'équipe...',
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
                        'Ajoutez des membres de l\'équipe pour configurer leurs accès.',
                    actionLabel: 'Nouvel employé',
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
                                '${emp.telephone ?? emp.username} · $patientCount patient(s) assigné(s)'.tr,
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
                                // Bouton : Voir les patients
                                Expanded(
                                  child: BouncyTap(
                                    onTap: () => _showPatientsSheet(context, emp),
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
                                            Icons.people_alt_rounded,
                                            size: 15,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '$patientCount patient(s)'.tr,
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
          'Voulez-vous vraiment supprimer le compte de $name ? Cette action est irréversible.'.tr,
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

  /// Bottom-sheet des patients assignés
  void _showPatientsSheet(BuildContext context, emp) {
    final ids = emp.patientsAssignesIds ?? [];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (ctx, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            children: [
              // Poignée
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Titre
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    PatientAvatar(initials: emp.initials, radius: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emp.fullName,
                              style: AppTextStyles.iosHeadline
                                  .copyWith(fontWeight: FontWeight.w800)),
                          Text(
                            '${ids.length} patient(s) assigné(s)'.tr,
                            style: AppTextStyles.iosCaption1.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),
              // Liste des IDs patients (si le backend ne retourne que les IDs)
              Expanded(
                child: ids.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_off_outlined,
                                size: 48, color: AppColors.textHint),
                            const SizedBox(height: 8),
                            Text(
                              'Aucun patient assigné'.tr,
                              style: AppTextStyles.iosSubhead.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: ids.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (_, i) => ListTile(
                          leading: PatientAvatar(
                            initials: '#${i + 1}',
                            radius: 16,
                          ),
                          title: Text(
                            'Patient #${ids[i]}',
                            style: AppTextStyles.iosSubhead
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          dense: true,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
