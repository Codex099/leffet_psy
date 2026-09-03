import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patient_info_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/searchable_picker.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/app_media_viewer.dart';
import '../../models/plan_therapeutique_model.dart';

class PatientInfoView extends GetView<PatientInfoController> {
 const PatientInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Obx(() {
        if (controller.status.value == 'loading') {
         return const Scaffold(
            body: StatePlaceholder(type: StatePlaceholderType.loading),
          );
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
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              // Hero Zen Wave Header (#064973 -> #75AABF)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.oceanGradient,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                  boxShadow: AppColors.heroShadow,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ZenWavePainter(
                            waveColor: AppColors.secondary.withValues(
                              alpha: 0.25,
                            ),
                            accentColor: AppColors.secondaryLight.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 50,
                          left: 16,
                          right: 16,
                          bottom: 24,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: () => Get.back(),
                                ),
                                Text(
                                  'Dossier Patient'.tr,
                                 style: AppTextStyles.iosHeadline.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      onPressed: () async {
                                        final res = await Get.toNamed(
                                          AppRoutes.editPatient,
                                          arguments: controller.patientId,
                                        );
                                        if (res == true)
                                          controller.loadPatientInfo();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.medical_services_outlined,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      onPressed: () async {
                                        await Get.toNamed(
                                          AppRoutes.dossierMedical,
                                          arguments: controller.patientId,
                                        );
                                        controller.loadPatientInfo();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.18,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      GestureDetector(
                                        onTap: () => _showPhotoOptions(context, controller),
                                        child: PatientAvatar(
                                          initials: p?.initials ?? 'P',
                                          photoUrl: p?.photo,
                                          radius: 34,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -2,
                                        right: -2,
                                        child: GestureDetector(
                                          onTap: () => _showPhotoOptions(context, controller),
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.25),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt_rounded,
                                              size: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Obx(
                                        () => controller.photoUploading.value
                                            ? Positioned.fill(
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.black45,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Center(
                                                    child: SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p?.fullName ?? 'Patient',
                                       style: AppTextStyles.iosTitle1.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        p?.ageFormatted != null
                                            ? '${p!.ageFormatted} \u200E•\u200E ${'Né(e) le'.tr} ${p.dateNaissance ?? ""}'
                                           : '${'Né(e) le'.tr} ${p?.dateNaissance ?? ""}',
                                       style: AppTextStyles.iosFootnote
                                            .copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () => _showStatusDialog(
                                          context,
                                          p?.estActif ?? true,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.20,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.35,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              PulseDot(
                                                color: p?.estActif == true
                                                    ? Colors.white
                                                    : AppColors.accentCoral,
                                                size: 7,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                p?.estActif == true
                                                    ? 'Suivi Actif'.tr
                                                   : 'Inactif'.tr,
                                               style: AppTextStyles.iosCaption2
                                                    .copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.expand_more_rounded,
                                                size: 14,
                                                color: Colors.white70,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Sections
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Parent lié card
                    _buildSectionCard(
                      title: 'Parent lié'.tr,
                     icon: Icons.phone_outlined,
                      actionLabel: 'Créer nouveau'.tr,
                     onActionTap: () => Get.toNamed(AppRoutes.editParent),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller.parents.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Aucun parent associé à ce patient.'.tr,
                               style: AppTextStyles.bodySmall,
                              ),
                            )
                          else
                            ...controller.parents.map((pParent) {
                              final parent = pParent.parent;
                              final name = parent != null
                                  ? parent.fullName
                                  : 'Parent inconnu'.tr;
                             final phone = parent != null
                                  ? (parent.telephone ?? 'Pas de numéro'.tr)
                                 : 'Pas de numéro'.tr;
                             final initials = parent != null
                                  ? parent.initials
                                  : 'P';
                             final role = pParent.roleLabel;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.fieldBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () => Get.toNamed(
                                    AppRoutes.editParent,
                                    arguments: pParent.parentId,
                                  ),
                                  child: Row(
                                    children: [
                                      PatientAvatar(
                                        initials: initials,
                                        radius: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$name ($role)'.tr,
                                             style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Text(
                                              phone,
                                              style: AppTextStyles.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.edit_rounded,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _showAssociateParentDialog(context),
                            icon: const Icon(Icons.link_rounded, size: 16),
                            label: Text('Associer un parent existant'.tr),
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

                    if (controller.isAdmin.value) ...[
                      // Plan Thérapeutique preview card (Admin uniquement)
                      _buildSectionCard(
                        title: 'Plan thérapeutique'.tr,
                        icon: Icons.assignment_rounded,
                        actionLabel: 'Voir tout',
                        onActionTap: () async {
                          await Get.toNamed(
                            AppRoutes.planTherapeutique,
                            arguments: controller.patientId,
                          );
                          controller.loadPatientInfo();
                        },
                        child: controller.plans.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Aucun plan thérapeutique.'.tr,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        await Get.toNamed(
                                          AppRoutes.planTherapeutique,
                                          arguments: controller.patientId,
                                        );
                                        controller.loadPatientInfo();
                                      },
                                      icon: const Icon(Icons.add, size: 14),
                                      label: Text('Créer un plan'.tr),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          36,
                                        ),
                                        foregroundColor: AppColors.primary,
                                        side: const BorderSide(
                                          color: AppColors.primary,
                                        ),
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
                                      subtitle:
                                          '${plan.etapesTerminees}/${plan.totalEtapes} étapes'.tr,
                                      statusLabel: plan.statut == 'actif'
                                          ? 'Actif'.tr
                                          : plan.statut == 'termine'
                                          ? 'Terminé'.tr
                                          : 'Archivé'.tr,
                                      statusColor: statColor,
                                      progress: plan.progression,
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Historique des séances card
                    _buildSectionCard(
                      title: 'Historique des séances'.tr,
                     icon: Icons.access_time_rounded,
                      actionLabel: 'Tout voir',
                     onActionTap: () async {
                        await Get.toNamed(
                          AppRoutes.historiqueSeancesPatient,
                          arguments: controller.patientId,
                        );
                        controller.loadPatientInfo();
                      },
                      child: Column(
                        children: [
                          _buildSeanceTypeItem(
                            icon: Icons.calendar_month_rounded,
                            label: 'Séances individuelles'.tr,
                           onTap: () async {
                              await Get.toNamed(
                                AppRoutes.historiqueSeancesPatient,
                                arguments: {
                                  'id': controller.patientId,
                                 'type': 'individuel',
                               },
                              );
                              controller.loadPatientInfo();
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildSeanceTypeItem(
                            icon: Icons.groups_rounded,
                            label: 'Séances groupe'.tr,
                           onTap: () async {
                              await Get.toNamed(
                                AppRoutes.historiqueSeancesPatient,
                                arguments: {
                                  'id': controller.patientId,
                                 'type': 'groupe',
                               },
                              );
                              controller.loadPatientInfo();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Historique des Statuts & Réactivations ──
                    _buildSectionCard(
                      title: 'Historique des Statuts'.tr,
                     subtitle: 'Suivi des activations et notes'.tr,
                     icon: Icons.history_rounded,
                      actionLabel: 'Gérer',
                     onActionTap: () async {
                        await Get.toNamed(
                          AppRoutes.statutHistorique,
                          arguments: controller.patientId,
                        );
                        controller.loadPatientInfo();
                      },
                      child: controller.statutHistorique.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Aucun changement de statut enregistré.'.tr,
                               style: AppTextStyles.bodySmall,
                              ),
                            )
                          : Column(
                              children: controller.statutHistorique.take(3).map(
                                (hist) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.fieldBackground,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            StatusBadge.active(
                                              label: hist.isActif
                                                  ? 'Actif (Réactivé)'.tr
                                                 : 'Inactif (Désactivé)'.tr,
                                           ),
                                            Text(
                                              hist.dateChangement.length >= 10
                                                  ? hist.dateChangement
                                                        .substring(0, 10)
                                                  : hist.dateChangement,
                                              style: AppTextStyles.iosCaption2
                                                  .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        if (hist.noteDegradation != null &&
                                            hist
                                                .noteDegradation!
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: AppColors.surface,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppColors.borderLight,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.sticky_note_2_outlined,
                                                  size: 16,
                                                  color: AppColors.secondary,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    hist.noteDegradation!,
                                                    style: AppTextStyles
                                                        .bodySmall
                                                        .copyWith(
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Notes section
                    _buildSectionCard(
                      title: 'Notes & Observations'.tr,
                     icon: Icons.note_alt_outlined,
                      headerWidget: ElevatedButton.icon(
                        onPressed: () async {
                          await Get.toNamed(
                            AppRoutes.notesPatient,
                            arguments: controller.patientId,
                          );
                          controller.loadPatientInfo();
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: Text('Note'.tr),
                       style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(80, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      child: controller.notes.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Aucune note pour ce patient.'.tr,
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
                      title: 'Planning récurrent'.tr,
                     icon: Icons.sync_rounded,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Créneaux automatiques'.tr,
                                   style: AppTextStyles.bodyMedium,
                                  ),
                                  Text(
                                    'Planification de séances individuelles'.tr,
                                   style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                              Switch(value: true, onChanged: (v) {}),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Get.toNamed(
                                AppRoutes.planningRecurrent,
                                arguments: controller.patientId,
                              );
                              controller.loadPatientInfo();
                            },
                            icon: const Icon(Icons.tune_rounded),
                            label: Text('Définir les créneaux'.tr),
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
                      onPressed: () => _confirmDeletePatient(context),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      label: Text(
                        'Supprimer le patient'.tr,
                       style: AppTextStyles.buttonDestructive,
                      ),
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
                      if (subtitle != null)
                        Text(subtitle, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
              if (actionLabel != null && onActionTap != null)
                TextButton(
                  onPressed: onActionTap,
                  child: Text(
                    actionLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ?headerWidget,
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
              Text(
                '$number. $title'.tr,
               style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
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
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(NotePatientModel note) {
    final noteMedias = note.medias ?? const [];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.contenu, style: AppTextStyles.body),
                const SizedBox(height: 4),
                Text(
                  '${note.auteurNom} | ${note.dateCreation ?? ""}'.tr,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
                if (noteMedias.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: noteMedias.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 6),
                      itemBuilder: (_, i) => AppMediaThumbnail(
                        url: noteMedias[i],
                        width: 60,
                        height: 60,
                        borderRadius: 8,
                        allUrls: noteMedias,
                        index: i,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: () => controller.deleteNote(note.id),
          ),
        ],
      ),
    );
  }

  void _showAssociateParentDialog(BuildContext context) {
    if (controller.availableParents.isEmpty) {
      Get.snackbar(
        'Info'.tr,
       'Aucun parent enregistré sur le système.'.tr,
       snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    String selectedRole = 'tuteur';

   SearchablePicker.showSingle<dynamic>(
      context: context,
      title: 'Associer un parent / tuteur'.tr,
     items: controller.availableParents
          .map(
            (p) => SearchableItem<dynamic>(
              value: p.id,
              label: '${p.prenom} ${p.nom}'.tr,
             subtitle: p.telephone != null && p.telephone!.isNotEmpty
                  ? p.telephone
                  : 'Parent / Tuteur',
             initials:
                  '${p.prenom.isNotEmpty ? p.prenom[0] : ""}${p.nom.isNotEmpty ? p.nom[0] : ""}'
                     .toUpperCase(),
            ),
          )
          .toList(),
      onSelected: (parentId) {
        if (parentId == null) return;
        // Prompt for family role
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Rôle familial'.tr, style: AppTextStyles.iosTitle2),
           content: StatefulBuilder(
              builder: (ctx, setDialogState) => DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Lien de parenté'.tr),
               initialValue: selectedRole,
                items: [
                  DropdownMenuItem(value: 'pere', child: Text('Père'.tr)),
                 DropdownMenuItem(value: 'mere', child: Text('Mère'.tr)),
                 DropdownMenuItem(
                    value: 'tuteur',
                   child: Text('Tuteur légal'.tr),
                 ),
                  DropdownMenuItem(
                    value: 'grand_pere',
                   child: Text('Grand-père'.tr),
                 ),
                  DropdownMenuItem(
                    value: 'grand_mere',
                   child: Text('Grand-mère'.tr),
                 ),
                  DropdownMenuItem(value: 'oncle', child: Text('Oncle'.tr)),
                 DropdownMenuItem(value: 'tante', child: Text('Tante'.tr)),
                 DropdownMenuItem(value: 'autre', child: Text('Autre'.tr)),
               ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedRole = val);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Annuler'.tr),
             ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  controller.associateParent(parentId, selectedRole);
                },
                child: Text('Confirmer l\'association'.tr),
             ),
            ],
          ),
        );
      },
    );
  }

  void _showStatusDialog(BuildContext context, bool isCurrentlyActive) {
    final noteCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isCurrentlyActive
              ? 'Désactiver le patient ?'.tr
             : 'Réactiver le patient ?'.tr,
         style: AppTextStyles.iosTitle2,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCurrentlyActive
                  ? 'Le statut du patient passera à Inactif. Une entrée sera ajoutée dans l\'historique des statuts.'.tr
                 : 'Le statut du patient repassera à Actif. Vous pouvez consigner une observation ou note clinique pour cette réactivation.'.tr,
             style: AppTextStyles.bodySmall,
            ),
            if (!isCurrentlyActive) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Note clinique / Dégradation'.tr,
                 hintText: 'Préciser les motifs ou observations cliniques...'.tr,
               ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Annuler'.tr)),
         ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyActive
                  ? AppColors.error
                  : AppColors.primary,
            ),
            onPressed: () {
              final note = noteCtrl.text.trim();
              Get.back();
              controller.toggleStatut(
                noteDegradation: note.isNotEmpty ? note : null,
              );
            },
            child: Text(isCurrentlyActive ? 'Désactiver'.tr : 'Réactiver'.tr),
         ),
        ],
      ),
    );
  }

  void _confirmDeletePatient(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Supprimer le patient'.tr,
           style: AppTextStyles.iosHeadline
                .copyWith(fontWeight: FontWeight.w800)),
        content: Text(
          'Voulez-vous vraiment supprimer ce patient ? Cette action est irréversible et supprimera toutes ses données.'.tr,
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
              controller.deletePatient();
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

  void _showPhotoOptions(BuildContext context, PatientInfoController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Photo du patient'.tr,
                style: AppTextStyles.iosTitle3.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: Text('Prendre une photo'.tr, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                onTap: () {
                  Get.back();
                  controller.pickAndUploadPhoto(fromCamera: true);
                },
              ),
              const SizedBox(height: 6),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                ),
                title: Text('Choisir depuis la galerie'.tr, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                onTap: () {
                  Get.back();
                  controller.pickAndUploadPhoto(fromCamera: false);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

