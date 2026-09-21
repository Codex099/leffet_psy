import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/employes_liste_controller.dart';
import '../../models/employee_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_dialogs.dart';
import '../../utils/phone_utils.dart';
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
                    final hasPhone = emp.telephone != null &&
                        emp.telephone!.trim().isNotEmpty;

                    return IosCard(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
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
                          onTap: () => _showEmployeDetailsModal(context, emp),
                        ),
                        // ── Barre d'actions rapides ──────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                          child: Row(
                            children: [
                              // Bouton : Gérer visibilité des patients
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

                              // Bouton Appel direct rapide (si numéro disponible)
                              if (hasPhone) ...[
                                BouncyTap(
                                  onTap: () => PhoneUtils.call(emp.telephone!),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.3),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.phone_in_talk_rounded,
                                          size: 14,
                                          color: Color(0xFF10B981),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Appeler'.tr,
                                          style: AppTextStyles.iosCaption1
                                              .copyWith(
                                            color: const Color(0xFF10B981),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],

                              // Bouton : Modifier les informations
                              BouncyTap(
                                onTap: () async {
                                  final res = await Get.toNamed(
                                    AppRoutes.editEmploye,
                                    arguments: emp.id,
                                  );
                                  if (res == true) controller.loadEmployees();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.edit_rounded,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Modifier'.tr,
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
                              const SizedBox(width: 8),

                              // Bouton : Supprimer le compte
                              BouncyTap(
                                onTap: () => _confirmDelete(
                                    context, emp.id, emp.fullName),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.error
                                        .withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: AppColors.error,
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

  /// Feuille modale des détails de l'employé avec appel direct et modification
  void _showEmployeDetailsModal(BuildContext context, EmployeeModel emp) {
    final hasPhone =
        emp.telephone != null && emp.telephone!.trim().isNotEmpty;
    final patientCount = emp.patientsAssignesIds?.length ?? 0;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: AppColors.cardShadow,
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 26,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poignée iOS
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // En-tête : Avatar + Identité + Icône Modifier
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PatientAvatar(
                      initials: emp.initials,
                      radius: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emp.fullName,
                            style: AppTextStyles.iosTitle3.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              StatusBadge.active(label: emp.roleLabel),
                              const SizedBox(width: 8),
                              Text(
                                '@${emp.username}',
                                style: AppTextStyles.iosCaption1.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bouton Modifier rond en haut à droite
                    BouncyTap(
                      onTap: () async {
                        Navigator.pop(ctx);
                        final res = await Get.toNamed(
                          AppRoutes.editEmploye,
                          arguments: emp.id,
                        );
                        if (res == true) controller.loadEmployees();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Bouton Fermer
                    BouncyTap(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Bloc Numéro de téléphone & Appel direct ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: hasPhone
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF10B981).withValues(alpha: 0.14),
                              const Color(0xFF059669).withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: hasPhone ? null : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasPhone
                          ? const Color(0xFF10B981).withValues(alpha: 0.35)
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: hasPhone
                              ? const Color(0xFF10B981).withValues(alpha: 0.18)
                              : AppColors.fieldBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          hasPhone
                              ? Icons.phone_in_talk_rounded
                              : Icons.phone_disabled_rounded,
                          color: hasPhone
                              ? const Color(0xFF10B981)
                              : AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Numéro de téléphone'.tr,
                              style: AppTextStyles.iosCaption2.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasPhone
                                  ? emp.telephone!
                                  : 'Non renseigné'.tr,
                              style: AppTextStyles.iosBody.copyWith(
                                fontWeight: FontWeight.w800,
                                color: hasPhone
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                letterSpacing: hasPhone ? 0.6 : 0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (hasPhone) ...[
                        // Bouton copier
                        BouncyTap(
                          onTap: () => PhoneUtils.copyToClipboard(emp.telephone!),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: AppColors.border,
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Bouton Appel Direct
                        BouncyTap(
                          onTap: () => PhoneUtils.call(emp.telephone!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.call_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Appeler'.tr,
                                  style: AppTextStyles.iosCaption1.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Informations & Permissions ──
                Text(
                  'INFORMATIONS & ACCÈS'.tr,
                  style: AppTextStyles.iosCaption2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      // Ligne Nom d'utilisateur
                      _buildInfoRow(
                        icon: Icons.alternate_email_rounded,
                        iconColor: AppColors.primary,
                        title: 'Nom d\'utilisateur'.tr,
                        value: emp.username,
                      ),
                      const Divider(height: 1, indent: 48, color: AppColors.border),

                      // Ligne Rôle
                      _buildInfoRow(
                        icon: Icons.workspace_premium_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'Rôle & Spécialité'.tr,
                        value: emp.roleLabel,
                      ),
                      const Divider(height: 1, indent: 48, color: AppColors.border),

                      // Ligne Patients assignés
                      _buildInfoRow(
                        icon: Icons.people_alt_rounded,
                        iconColor: AppColors.secondary,
                        title: 'Patients assignés'.tr,
                        value: '$patientCount ${'patient(s)'.tr}',
                        trailing: BouncyTap(
                          onTap: () async {
                            Navigator.pop(ctx);
                            await Get.toNamed(
                              AppRoutes.employeVisibilitePatients,
                              arguments: emp,
                            );
                            controller.loadEmployees(forceRefresh: true);
                          },
                          child: Text(
                            'Gérer'.tr,
                            style: AppTextStyles.iosCaption1.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 48, color: AppColors.border),

                      // Ligne Création de tâches
                      _buildInfoRow(
                        icon: Icons.task_alt_rounded,
                        iconColor: emp.canAssignTasks
                            ? const Color(0xFF10B981)
                            : AppColors.textSecondary,
                        title: 'Gestion des tâches'.tr,
                        value: emp.canAssignTasks
                            ? 'Autorisé à assigner'.tr
                            : 'Lecture seule'.tr,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ── Bouton d'action principal en bas ──
                Row(
                  children: [
                    // Bouton Modifier
                    Expanded(
                      child: BouncyTap(
                        onTap: () async {
                          Navigator.pop(ctx);
                          final res = await Get.toNamed(
                            AppRoutes.editEmploye,
                            arguments: emp.id,
                          );
                          if (res == true) controller.loadEmployees();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            gradient: AppColors.oceanGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppColors.softShadow,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.edit_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Modifier le profil'.tr,
                                style: AppTextStyles.iosBody.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.iosCaption2.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: AppTextStyles.iosSubhead.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  /// Dialogue de confirmation avant suppression
  Future<void> _confirmDelete(
      BuildContext context, dynamic id, String name) async {
    final confirmed = await AppDialogs.confirmDelete(
      title: 'Supprimer le compte'.tr,
      message:
          '${'Voulez-vous vraiment supprimer le compte de'.tr} $name ? ${'Cette action est irréversible.'.tr}',
      confirmLabel: 'Supprimer'.tr,
      cancelLabel: 'Annuler'.tr,
    );

    if (confirmed) {
      await controller.deleteEmployee(id);
    }
  }
}
