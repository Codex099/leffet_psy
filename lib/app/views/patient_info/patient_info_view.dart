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
import '../../models/plan_therapeutique_model.dart';

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
                      actionLabel: 'Créer nouveau',
                      onActionTap: () => Get.toNamed(AppRoutes.editParent),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller.parents.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Aucun parent associé à ce patient.',
                                style: AppTextStyles.bodySmall,
                              ),
                            )
                          else
                            ...controller.parents.map((pParent) {
                              final parent = pParent.parent;
                              final name = parent != null ? parent.fullName : 'Parent inconnu';
                              final phone = parent != null ? (parent.telephone ?? 'Pas de numéro') : 'Pas de numéro';
                              final initials = parent != null ? parent.initials : 'P';
                              final role = pParent.roleLabel;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.fieldBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () => Get.toNamed(AppRoutes.editParent, arguments: pParent.parentId),
                                  child: Row(
                                    children: [
                                      PatientAvatar(
                                        initials: initials,
                                        radius: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$name ($role)',
                                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                            Text(phone, style: AppTextStyles.bodySmall),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.edit_rounded, color: AppColors.primary, size: 16),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => _showAssociateParentDialog(context),
                            icon: const Icon(Icons.link_rounded, size: 16),
                            label: const Text('Associer un parent existant'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 38),
                              side: const BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Plan Thérapeutique preview card
                    _buildSectionCard(
                      title: 'Plan thérapeutique',
                      icon: Icons.assignment_rounded,
                      actionLabel: 'Voir tout',
                      onActionTap: () => Get.toNamed(AppRoutes.planTherapeutique, arguments: controller.patientId),
                      child: controller.plans.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Text('Aucun plan thérapeutique.', style: AppTextStyles.bodySmall),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => Get.toNamed(AppRoutes.planTherapeutique, arguments: controller.patientId),
                                    icon: const Icon(Icons.add, size: 14),
                                    label: const Text('Créer un plan'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 36),
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: controller.plans.map((plan) {
                                final Color statColor = plan.statut == 'actif'
                                    ? AppColors.statusPresent
                                    : plan.statut == 'termine'
                                        ? AppColors.primary
                                        : AppColors.textSecondary;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: _buildStepTile(
                                    number: plan.statut == 'actif' ? '▶' : '✓',
                                    title: plan.titre,
                                    subtitle: '${plan.etapesTerminees}/${plan.totalEtapes} étapes',
                                    statusLabel: plan.statut == 'actif' ? 'Actif' : plan.statut == 'termine' ? 'Terminé' : 'Archivé',
                                    statusColor: statColor,
                                    progress: plan.progression,
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Historique des séances card
                    _buildSectionCard(
                      title: 'Historique des séances',
                      icon: Icons.access_time_rounded,
                      actionLabel: 'Tout voir',
                      onActionTap: () => Get.toNamed(AppRoutes.historiqueSeancesPatient, arguments: controller.patientId),
                      child: Column(
                        children: [
                          _buildSeanceTypeItem(
                            icon: Icons.calendar_month_rounded,
                            label: 'Séances individuelles',
                            onTap: () => Get.toNamed(
                              AppRoutes.historiqueSeancesPatient,
                              arguments: {'id': controller.patientId, 'type': 'individuel'},
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSeanceTypeItem(
                            icon: Icons.groups_rounded,
                            label: 'Séances groupe',
                            onTap: () => Get.toNamed(
                              AppRoutes.historiqueSeancesPatient,
                              arguments: {'id': controller.patientId, 'type': 'groupe'},
                            ),
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
                      child: controller.notes.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Aucune note pour ce patient.',
                                style: AppTextStyles.bodySmall,
                              ),
                            )
                          : Column(
                              children: controller.notes.map((note) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _buildNoteCard(note),
                                );
                              }).toList(),
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

  Widget _buildNoteCard(NotePatientModel note) {
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
                Text(note.contenu, style: AppTextStyles.body),
                const SizedBox(height: 4),
                Text(
                  '${note.auteurNom} | ${note.dateCreation ?? ""}',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
            onPressed: () => controller.deleteNote(note.id),
          ),
        ],
      ),
    );
  }

  void _showAssociateParentDialog(BuildContext context) {
    dynamic selectedParentIdValue;
    String selectedRole = 'tuteur';

    Get.dialog(
      AlertDialog(
        title: const Text('Associer un parent existant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if (controller.availableParents.isEmpty) {
                return const Text('Aucun parent enregistré sur le système.');
              }
              return DropdownButtonFormField<dynamic>(
                decoration: const InputDecoration(labelText: 'Sélectionner le parent'),
                value: selectedParentIdValue,
                items: controller.availableParents.map((p) {
                  return DropdownMenuItem<dynamic>(
                    value: p.id,
                    child: Text('${p.prenom} ${p.nom}'),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedParentIdValue = val;
                },
              );
            }),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Rôle familial'),
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: 'pere', child: Text('Père')),
                DropdownMenuItem(value: 'mere', child: Text('Mère')),
                DropdownMenuItem(value: 'tuteur', child: Text('Tuteur légal')),
                DropdownMenuItem(value: 'grand_pere', child: Text('Grand-père')),
                DropdownMenuItem(value: 'grand_mere', child: Text('Grand-mère')),
                DropdownMenuItem(value: 'oncle', child: Text('Oncle')),
                DropdownMenuItem(value: 'tante', child: Text('Tante')),
                DropdownMenuItem(value: 'autre', child: Text('Autre')),
              ],
              onChanged: (val) {
                if (val != null) selectedRole = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedParentIdValue != null) {
                Get.back();
                controller.associateParent(selectedParentIdValue, selectedRole);
              } else {
                Get.snackbar('Erreur', 'Veuillez sélectionner un parent', snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text('Associer'),
          ),
        ],
      ),
    );
  }
}
