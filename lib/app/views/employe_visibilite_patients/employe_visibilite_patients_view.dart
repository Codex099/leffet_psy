import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/employe_visibilite_patients_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/status_badge.dart';

class EmployeVisibilitePatientsView
    extends GetView<EmployeVisibilitePatientsController> {
  const EmployeVisibilitePatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Visibilité des patients'.tr,
        subtitle: controller.employee.value != null
            ? '${controller.employee.value!.fullName} · ${controller.employee.value!.roleLabel}'
            : 'Droits d\'accès aux dossiers'.tr,
        showBackButton: true,
        actions: [
          Obx(() {
            if (!controller.isAdmin.value) return const SizedBox.shrink();
            return PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (action) => _confirmGlobalAction(context, action),
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'grant_all',
                  child: Row(
                    children: [
                      const Icon(Icons.group_add_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Text('Tout autoriser pour toute l\'équipe'.tr),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'revoke_all',
                  child: Row(
                    children: [
                      const Icon(Icons.group_remove_rounded,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Text('Tout révoquer pour toute l\'équipe'.tr),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.status.value == 'loading') {
          return StatePlaceholder.loading(
            message: 'Chargement des droits de visibilité...'.tr,
          );
        }

        if (controller.status.value == 'error') {
          return StatePlaceholder.error(
            message: controller.errorMessage.value,
            onAction: controller.loadVisibilityData,
          );
        }

        return Column(
          children: [
            // ── Résumé & Statistiques ──
            _buildHeaderMetrics(context),

            // ── Barre de recherche & Filtres ──
            _buildSearchAndFilters(context),

            // ── Liste des patients ──
            Expanded(
              child: _buildPatientsList(context),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.status.value != 'success' || !controller.isAdmin.value) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.borderLight, width: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: AppButton(
            label: '${'Enregistrer les modifications'.tr} (${controller.visibleCount})',
            icon: Icons.check_circle_outline_rounded,
            isLoading: controller.isSaving.value,
            onPressed: controller.saveVisibility,
          ),
        );
      }),
    );
  }

  // ─── Header Metrics ────────────────────────────────────────────────────────
  Widget _buildHeaderMetrics(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // Bandeau Admin
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestion des accès aux dossiers patients'.tr,
                      style: AppTextStyles.iosSubhead.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      controller.isAdmin.value
                          ? 'Seul l\'administrateur peut modifier ces visibilités.'.tr
                          : 'Mode consultation (droits restreints aux administrateurs).'.tr,
                      style: AppTextStyles.iosCaption2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 3 métriques
          Row(
            children: [
              Expanded(
                child: _metricPill(
                  label: 'Total'.tr,
                  count: controller.totalCount,
                  color: AppColors.textSecondary,
                  bgColor: AppColors.fieldBackground,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricPill(
                  label: 'Visibles'.tr,
                  count: controller.visibleCount,
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricPill(
                  label: 'Masqués'.tr,
                  count: controller.invisibleCount,
                  color: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
          if (controller.isAdmin.value) ...[
            const SizedBox(height: 12),
            // Boutons d'action rapide : Tout donner / Tout retirer pour cet employé
            Row(
              children: [
                Expanded(
                  child: BouncyTap(
                    onTap: controller.grantAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.visibility_rounded,
                              size: 16, color: Color(0xFF10B981)),
                          const SizedBox(width: 6),
                          Text(
                            'Tout autoriser'.tr,
                            style: AppTextStyles.iosCaption1.copyWith(
                              color: const Color(0xFF047857),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BouncyTap(
                    onTap: controller.revokeAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.visibility_off_rounded,
                              size: 16, color: Color(0xFFEF4444)),
                          const SizedBox(width: 6),
                          Text(
                            'Tout masquer'.tr,
                            style: AppTextStyles.iosCaption1.copyWith(
                              color: const Color(0xFFB91C1C),
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
        ],
      ),
    );
  }

  Widget _metricPill({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: AppTextStyles.iosHeadline.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.iosCaption2.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Barre de recherche et onglets de filtrage ──────────────────────────────
  Widget _buildSearchAndFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          // Champ de recherche
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight, width: 0.8),
            ),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              style: AppTextStyles.iosBody,
              decoration: InputDecoration(
                hintText: 'Rechercher un patient...'.tr,
                hintStyle: AppTextStyles.iosSubhead.copyWith(
                  color: AppColors.textHint,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Onglets de filtre (Tous, Visibles, Masqués)
          Row(
            children: [
              _filterTab(
                id: 'all',
                label: '${'Tous'.tr} (${controller.totalCount})',
              ),
              const SizedBox(width: 8),
              _filterTab(
                id: 'visible',
                label: '${'Visibles'.tr} (${controller.visibleCount})',
                badgeColor: const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              _filterTab(
                id: 'invisible',
                label: '${'Masqués'.tr} (${controller.invisibleCount})',
                badgeColor: const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterTab({
    required String id,
    required String label,
    Color? badgeColor,
  }) {
    final isSelected = controller.activeFilter.value == id;
    return Expanded(
      child: BouncyTap(
        onTap: () => controller.activeFilter.value = id,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: 0.8,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.iosCaption1.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Liste des patients ─────────────────────────────────────────────────────
  Widget _buildPatientsList(BuildContext context) {
    final list = controller.displayedPatients;

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Aucun patient ne correspond aux critères.'.tr,
            style: AppTextStyles.iosSubhead.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
      itemCount: list.length,
      itemBuilder: (ctx, index) {
        final patient = list[index];
        final pid = patient.id.toString();
        final isVisible = controller.visiblePatientIds.contains(pid);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isVisible
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : AppColors.borderLight,
              width: isVisible ? 1.2 : 0.8,
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: PatientAvatar(
              photoUrl: patient.photo,
              initials: patient.initials,
              radius: 20,
            ),
            title: Text(
              patient.fullName,
              style: AppTextStyles.iosHeadline.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Row(
              children: [
                if (patient.sexe != null) ...[
                  Text(
                    patient.sexe == 'masculin' ? 'Garçon'.tr : 'Fille'.tr,
                    style: AppTextStyles.iosCaption2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(' · ', style: TextStyle(color: AppColors.textHint)),
                ],
                Text(
                  isVisible ? 'Dossier accessible'.tr : 'Dossier masqué'.tr,
                  style: AppTextStyles.iosCaption2.copyWith(
                    color: isVisible
                        ? const Color(0xFF059669)
                        : AppColors.textSecondary,
                    fontWeight: isVisible ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            trailing: controller.isAdmin.value
                ? CupertinoSwitch(
                    value: isVisible,
                    activeTrackColor: const Color(0xFF10B981),
                    onChanged: (_) => controller.togglePatient(pid),
                  )
                : StatusBadge(
                    label: isVisible ? 'Visible'.tr : 'Masqué'.tr,
                    backgroundColor: isVisible
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : Colors.grey.shade100,
                    textColor: isVisible
                        ? const Color(0xFF047857)
                        : Colors.grey.shade600,
                  ),
            onTap: controller.isAdmin.value
                ? () => controller.togglePatient(pid)
                : null,
          ),
        );
      },
    );
  }

  // ─── Dialogue confirmation action globale sur toute l'équipe ────────────────
  void _confirmGlobalAction(BuildContext context, String action) {
    final isGrant = action == 'grant_all';
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isGrant
              ? 'Autoriser tous les patients'.tr
              : 'Masquer tous les patients'.tr,
          style: AppTextStyles.iosHeadline.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Text(
          isGrant
              ? 'Voulez-vous donner la visibilité de TOUS les dossiers patients à TOUS les employés de l\'équipe ?'.tr
              : 'Voulez-vous retirer la visibilité de tous les dossiers patients pour tous les employés (hors administrateurs) ?'.tr,
          style: AppTextStyles.iosSubhead,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isGrant ? const Color(0xFF10B981) : AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Get.back();
              controller.applyToAllTeam(action);
            },
            child: Text(isGrant ? 'Confirmer'.tr : 'Révoquer'.tr),
          ),
        ],
      ),
    );
  }
}
