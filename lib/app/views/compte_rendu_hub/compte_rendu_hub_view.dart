import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/compte_rendu_hub_controller.dart';
import '../../models/agenda_session_item.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/ios_segmented_control.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';

class CompteRenduHubView extends GetView<CompteRenduHubController> {
  const CompteRenduHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Comptes-Rendus Cliniques'.tr,
        subtitle: 'Suivi Thérapeutique Spécialiste'.tr,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => controller.loadData(forceRefresh: true),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Statistiques Rapides (KPIs) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _buildStatTile(
                        title: 'À Rédiger'.tr,
                        count: '${controller.enAttenteCount}',
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.accentCoral,
                        isSelected:
                            controller.selectedTab.value == 'en_attente',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.selectedTab.value = 'en_attente';
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
                      () => _buildStatTile(
                        title: 'Validés'.tr,
                        count: '${controller.redigesCount}',
                        icon: Icons.task_alt_rounded,
                        color: AppColors.primary,
                        isSelected: controller.selectedTab.value == 'rediges',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.selectedTab.value = 'rediges';
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Onglets de Navigation ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Obx(
                () => IosSegmentedControl<String>(
                  segments: const {
                    'en_attente': 'En attente',
                    'rediges': 'Rédigés',
                    'tous': 'Toutes',
                  },
                  selectedValue: controller.selectedTab.value,
                  onValueChanged: (val) => controller.selectedTab.value = val,
                ),
              ),
            ),

            // ── Barre de Recherche & Filtres Type ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  // Champ de recherche
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        style: AppTextStyles.iosBody.copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Rechercher patient, groupe, date...'.tr,
                          hintStyle: AppTextStyles.iosCaption1.copyWith(
                            color: AppColors.textHint,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Filtre Type (Tous / Indiv / Groupe)
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.filterType.value,
                          icon: const Icon(
                            Icons.filter_list_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'tous',
                              child: Text('Tous types'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'indiv',
                              child: Text('Individuel'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'groupe',
                              child: Text('Groupe'.tr),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.filterType.value = val;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Liste des Séances ──
            Expanded(
              child: Obx(() {
                if (controller.status.value == 'loading') {
                  return StatePlaceholder.loading(
                    message: 'Chargement des comptes-rendus...',
                  );
                }
                if (controller.status.value == 'error') {
                  return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadData(forceRefresh: true),
                  );
                }

                final list = controller.filteredSessions;

                if (list.isEmpty) {
                  return StatePlaceholder.empty(
                    title: 'Aucune séance trouvée'.tr,
                    message: controller.selectedTab.value == 'en_attente'
                        ? 'Tous vos comptes-rendus cliniques sont à  jour !'
                        : 'Aucune séance ne correspond aux critères sélectionnés.',
                    actionLabel: 'Planifier une séance'.tr,
                    onAction: () async {
                      final res = await Get.toNamed(AppRoutes.creationSeance);
                      if (res == true) controller.loadData(forceRefresh: true);
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadData(forceRefresh: true),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 6, bottom: 120),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final session = list[index];
                      return _buildSessionCard(session);
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

  Widget _buildStatTile({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 0.8,
          ),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: AppTextStyles.iosTitle3.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: AppTextStyles.iosCaption2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(AgendaSessionItem session) {
    final bool isDone = session.statut == 'faite';

    return IosCard(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      children: [
        IosCardTile(
          leading: session.isGroupe
              ? Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                )
              : PatientAvatar(
                  photoUrl: session.photoUrl,
                  initials: session.initials,
                  radius: 21,
                ),
          title: session.title,
          subtitle:
              '${session.date} • ${session.heureDebut} - ${session.heureFin}${session.isGroupe ? " • Atelier Collectif" : " • Individuel"}'.tr,
          showChevron: true,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.iosGreen.withValues(alpha: 0.12)
                  : AppColors.accentCoral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDone ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                  size: 13,
                  color: isDone ? AppColors.iosGreen : AppColors.accentCoral,
                ),
                const SizedBox(width: 4),
                Text(
                  isDone ? 'Validé' : 'À rédiger',
                  style: AppTextStyles.iosCaption2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDone ? AppColors.iosGreen : AppColors.accentCoral,
                  ),
                ),
              ],
            ),
          ),
          onTap: () async {
            final res = await Get.toNamed(
              AppRoutes.compteRenduSpecialiste,
              arguments: {
                'seance_id': session.id,
                'is_groupe': session.isGroupe,
              },
            );
            if (res == true) controller.loadData(forceRefresh: true);
          },
        ),
      ],
    );
  }
}
