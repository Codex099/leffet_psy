import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/historique_seances_patient_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/state_placeholder.dart';
import '../../models/seance_model.dart';

class HistoriqueSeancesPatientView extends GetView<HistoriqueSeancesPatientController> {
  const HistoriqueSeancesPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HISTORIQUE', style: AppTextStyles.sectionKicker),
                        Text(
                          'Historique des séances',
                          style: AppTextStyles.screenTitleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter tabs
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('Tous', 'tous'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Individuelles', 'individuel'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Groupe', 'groupe'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Obx(() {
                if (controller.status.value == 'loading') {
                  return const StatePlaceholder(type: StatePlaceholderType.loading);
                }
                if (controller.status.value == 'error') {
                  return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadHistorique(),
                  );
                }

                final showIndividuel = controller.activeFilter.value != 'groupe';
                final showGroupe = controller.activeFilter.value != 'individuel';

                final hasContent = (showIndividuel && controller.seancesIndividuelles.isNotEmpty) ||
                    (showGroupe && controller.seancesGroupe.isNotEmpty);

                if (!hasContent) {
                  return const StatePlaceholder(
                    type: StatePlaceholderType.empty,
                    message: 'Aucune séance dans l\'historique.',
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Individual sessions
                    if (showIndividuel && controller.seancesIndividuelles.isNotEmpty) ...[
                      _buildSectionHeader('Séances individuelles', Icons.calendar_month_rounded),
                      const SizedBox(height: 8),
                      ...controller.seancesIndividuelles.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildIndividuelCard(s),
                          )),
                      const SizedBox(height: 16),
                    ],

                    // Group sessions
                    if (showGroupe && controller.seancesGroupe.isNotEmpty) ...[
                      _buildSectionHeader('Séances de groupe', Icons.groups_rounded),
                      const SizedBox(height: 8),
                      ...controller.seancesGroupe.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildGroupeCard(s),
                          )),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    return Obx(() {
      final isSelected = controller.activeFilter.value == type;
      return GestureDetector(
        onTap: () => controller.setFilter(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.sectionTitle),
      ],
    );
  }

  Widget _buildIndividuelCard(SeanceModel s) {
    final date = s.date;
    final heureDebut = s.heureDebut;
    final heureFin = s.heureFin;
    final statut = s.statut;

    Color statutColor;
    IconData statutIcon;
    String statutLabel;
    switch (statut) {
      case 'realisee':
        statutColor = AppColors.statusPresent;
        statutIcon = Icons.check_circle_rounded;
        statutLabel = 'Réalisée';
        break;
      case 'annulee':
        statutColor = AppColors.error;
        statutIcon = Icons.cancel_rounded;
        statutLabel = 'Annulée';
        break;
      default:
        statutColor = AppColors.primary;
        statutIcon = Icons.schedule_rounded;
        statutLabel = 'Planifiée';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statutColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statutIcon, color: statutColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Séance individuelle',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$date  ·  $heureDebut – $heureFin',
                  style: AppTextStyles.bodySmall,
                ),
                if (s.statutPresence != null)
                  Text(
                    s.statutPresence == 'present' ? '✅ Présent' : '❌ Absent',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: s.statutPresence == 'present' ? AppColors.statusPresent : AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statutColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statutLabel,
              style: AppTextStyles.bodySmall.copyWith(color: statutColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupeCard(Map<String, dynamic> s) {
    final date = s['date'] as String? ?? '';
    final heureDebut = s['heure_debut'] as String? ?? '';
    final heureFin = s['heure_fin'] as String? ?? '';
    final statut = s['statut'] as String? ?? 'planifiee';
    final groupeNom = (s['groupe'] as Map<String, dynamic>?)?['nom'] as String? ?? 'Groupe';

    Color statutColor;
    String statutLabel;
    switch (statut) {
      case 'realisee':
        statutColor = AppColors.statusPresent;
        statutLabel = 'Réalisée';
        break;
      case 'annulee':
        statutColor = AppColors.error;
        statutLabel = 'Annulée';
        break;
      default:
        statutColor = AppColors.primary;
        statutLabel = 'Planifiée';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.groups_rounded, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupeNom,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$date  ·  $heureDebut – $heureFin',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statutColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statutLabel,
              style: AppTextStyles.bodySmall.copyWith(color: statutColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
