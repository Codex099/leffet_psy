import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patient_info_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';

class PatientInfoView extends GetView<PatientInfoController> {
  const PatientInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: Obx(() {
        if (controller.status.value == 'loading') {
          return const Scaffold(body: StatePlaceholder(type: StatePlaceholderType.loading));
        }
        if (controller.status.value == 'error') {
          return Scaffold(
            body: StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadPatientInfo(),
            ),
          );
        }

        final p = controller.patient.value;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Hero Blue Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 24),
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                        Text('Détail patient', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.white),
                              onPressed: () => Get.toNamed(AppRoutes.editPatient, arguments: controller.patientId),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
                              onPressed: () => Get.toNamed(AppRoutes.dossierMedical, arguments: controller.patientId),
                            ),
                          ],
                        ),

                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        PatientAvatar(
                          initials: p?.initials ?? 'LM',
                          photoUrl: p?.photo,
                          radius: 36,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p?.fullName ?? 'Lucas Martin', style: AppTextStyles.cardNameHero),
                            const SizedBox(height: 4),
                            Text(
                              '${p?.age ?? 7} ans · Né le ${p?.dateNaissance ?? "14/06/2017"}',
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                            ),
                            const SizedBox(height: 6),
                            StatusBadge.active(label: p?.estActif == true ? 'Suivi actif' : 'Inactif'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content Sections
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Parent lié card
                    _buildSectionCard(
                      title: 'Parent lié',
                      icon: Icons.phone_outlined,
                      actionLabel: 'Modifier',
                      onActionTap: () => Get.toNamed(AppRoutes.editParent),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const PatientAvatar(initials: 'SM', radius: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sophie Martin (Mère)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                  Text('+21366665846', style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Plan Thérapeutique preview card
                    _buildSectionCard(
                      title: 'Plan thérapeutique',
                      subtitle: 'Vue Admin · progression complète',
                      actionLabel: 'Modifier',
                      onActionTap: () => Get.toNamed(AppRoutes.planTherapeutique, arguments: controller.patientId),
                      child: Column(
                        children: [
                          _buildStepTile(
                            number: '1',
                            title: 'Évaluation initiale',
                            subtitle: 'Entretien, contexte familial, objectifs.',
                            statusLabel: 'Terminé',
                            statusColor: AppColors.statusPresent,
                            progress: 1.0,
                          ),
                          const SizedBox(height: 10),
                          _buildStepTile(
                            number: '2',
                            title: 'Suivi émotionnel',
                            subtitle: 'Régulation, repérage des déclencheurs.',
                            statusLabel: 'En cours',
                            statusColor: AppColors.primary,
                            progress: 0.5,
                          ),
                          const SizedBox(height: 10),
                          _buildStepTile(
                            number: '3',
                            title: 'Consolidation',
                            subtitle: 'Autonomie, prévention des rechutes.',
                            statusLabel: 'À venir',
                            statusColor: AppColors.textSecondary,
                            progress: 0.1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Historique des séances card
                    _buildSectionCard(
                      title: 'Historique des séances',
                      icon: Icons.access_time_rounded,
                      actionLabel: 'Tout voir',
                      onActionTap: () => Get.toNamed(AppRoutes.agenda),
                      child: Column(
                        children: [
                          _buildSeanceTypeItem(
                            icon: Icons.calendar_month_rounded,
                            label: 'Séances individuelles',
                            onTap: () => Get.toNamed(AppRoutes.agenda),
                          ),
                          const SizedBox(height: 8),
                          _buildSeanceTypeItem(
                            icon: Icons.groups_rounded,
                            label: 'Séances groupe',
                            onTap: () => Get.toNamed(AppRoutes.groupesListe),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes section
                    _buildSectionCard(
                      title: 'Notes',
                      icon: Icons.note_alt_outlined,
                      headerWidget: ElevatedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.notesPatient, arguments: controller.patientId),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Note'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(80, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildNoteCard('Bonne progression sur les exercices de motricité fine.', '12 mars 2025'),
                          const SizedBox(height: 8),
                          _buildNoteCard('Séance annulée par le parent, à reprogrammer.', '12 mars 2025'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Planning récurrent toggle section
                    _buildSectionCard(
                      title: 'Planning récurrent',
                      icon: Icons.sync_rounded,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Créneaux automatiques', style: AppTextStyles.bodyMedium),
                                  Text('Planification de séances individuelles', style: AppTextStyles.bodySmall),
                                ],
                              ),
                              Switch(value: true, onChanged: (v) {}),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => Get.toNamed(AppRoutes.planningRecurrent, arguments: controller.patientId),
                            icon: const Icon(Icons.tune_rounded),
                            label: const Text('Définir les créneaux'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 44),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Supprimer le patient Action Button
                    TextButton.icon(
                      onPressed: () => controller.deletePatient(),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      label: Text('Supprimer le patient', style: AppTextStyles.buttonDestructive),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onActionTap,
    Widget? headerWidget,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.sectionTitle),
                      if (subtitle != null) Text(subtitle, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
              if (actionLabel != null && onActionTap != null)
                TextButton(
                  onPressed: onActionTap,
                  child: Text(actionLabel, style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                ),
              if (headerWidget != null) headerWidget,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStepTile({
    required String number,
    required String title,
    required String subtitle,
    required String statusLabel,
    required Color statusColor,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$number. $title', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              StatusBadge.custom(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            color: statusColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSeanceTypeItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(String content, String date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content, style: AppTextStyles.body),
                const SizedBox(height: 4),
                Text('nom_d\'auteur | $date', style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
        ],
      ),
    );
  }
}
