import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/compte_rendu_specialiste_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/ios_segmented_control.dart';
import '../../widgets/media_picker_widget.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_date_picker.dart';

class CompteRenduSpecialisteView
   extends GetView<CompteRenduSpecialisteController> {
  const CompteRenduSpecialisteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Compte-Rendu Clinique'.tr,
       subtitle: 'Espace Spécialiste'.tr,
       showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => controller.loadData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.status.value == 'loading') {
          return StatePlaceholder.loading(
            message: 'Chargement de la séance...',
          );
        }
        if (controller.status.value == 'error') {
          return StatePlaceholder.error(
            message: controller.errorMessage.value,
            onAction: () => controller.loadData(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Bandeau Contexte & Responsable ──
              _buildHeaderCard(context),
              const SizedBox(height: 14),

              // ── 2. Présences & Suivi des Participants ──
              if (controller.isGroupe.value)
                _buildGroupParticipantsSection(context)
              else
                _buildIndividualPresenceCard(context),
                const SizedBox(height: 14),

                // ── 3. Observations Cliniques & Déroulement ──
                _buildClinicalNotesCard(context),
                const SizedBox(height: 14),

                // ── 4. Médias & Documents joints ──
                _buildMediaSection(context),
                const SizedBox(height: 14),

                // ── 5. Rappels & Notifications de Suivi ──
                _buildFollowUpReminderCard(context),
                const SizedBox(height: 24),

                // ── 6. Boutons d'Action ──
                _buildActionButtons(context),
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
    );
  }

  /// 1. En-tête Contexte & Praticien Responsable
  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.9),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: controller.isGroupe.value
                      ? AppColors.secondary.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.isGroupe.value
                          ? Icons.groups_rounded
                          : Icons.person_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      controller.isGroupe.value
                          ? 'Séance de Groupe'
                         : 'Consultation Individuelle'.tr,
                     style: AppTextStyles.iosCaption1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge.active(label: 'À valider'.tr),
           ],
          ),
          const SizedBox(height: 10),
          Text(
            controller.sessionTitle,
            style: AppTextStyles.iosTitle3.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                controller.sessionDateTimeInfo,
                style: AppTextStyles.iosSubhead.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Divider(height: 22, thickness: 0.8),

          // Praticien Responsable Dropdown
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.oceanGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.softShadow,
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  size: 17,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spécialiste Responsable'.tr,
                     style: AppTextStyles.iosCaption2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Obx(() {
                      final currentId = controller.selectedResponsableId.value;
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<dynamic>(
                          value: currentId,
                          isDense: true,
                          isExpanded: true,
                          hint: Text(
                            'Sélectionner un praticien...'.tr,
                           style: AppTextStyles.iosSubhead,
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: AppColors.primary,
                          ),
                          items: controller.praticiens.map((emp) {
                            return DropdownMenuItem<dynamic>(
                              value: emp.id,
                              child: Text(
                                '${emp.fullName} (${emp.roleLabel})'.tr,
                               style: AppTextStyles.iosSubhead.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            controller.selectedResponsableId.value = val;
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Présence Individuelle
  Widget _buildIndividualPresenceCard(BuildContext context) {
    return IosCard(
      title: 'Statut de Présence'.tr,
     children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Obx(
            () => IosSegmentedControl<String>(
              segments: {
                'present': 'Présent'.tr,
                'excuse': 'Excusé'.tr,
                'absent': 'Absent'.tr,
              },
              selectedValue: controller.statutPresence.value,
              onValueChanged: (val) => controller.statutPresence.value = val,
            ),
          ),
        ),
      ],
    );
  }

  /// 2. Présences & Observations Collectives (Groupe)
  Widget _buildGroupParticipantsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Participants de l\'atelier'.tr + ' (${controller.participants.length})',
               style: AppTextStyles.iosHeadline.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Présence & Bilan individuel'.tr,
               style: AppTextStyles.iosCaption1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ...controller.participants.map((p) => _buildParticipantTile(p)),
      ],
    );
  }

  Widget _buildParticipantTile(ParticipantPresenceNote p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PatientAvatar(
                photoUrl: p.photoUrl,
                initials: p.initials,
                radius: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  p.fullName,
                  style: AppTextStyles.iosSubhead.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Obx(() {
                final isPresent = p.statutPresence.value == 'present';
               return BouncyTap(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    p.statutPresence.value = isPresent ? 'absent' : 'present';
                 },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isPresent
                          ? AppColors.iosGreen.withValues(alpha: 0.15)
                          : AppColors.accentCoral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPresent
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 15,
                          color: isPresent
                              ? AppColors.iosGreen
                              : AppColors.accentCoral,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPresent ? 'Présent'.tr : 'Absent'.tr,
                          style: AppTextStyles.iosCaption1.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isPresent
                                ? AppColors.iosGreen
                                : AppColors.accentCoral,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: p.noteIndividuelle.value)
              ..selection = TextSelection.collapsed(
                offset: p.noteIndividuelle.value.length,
              ),
            onChanged: (val) => p.noteIndividuelle.value = val,
            style: AppTextStyles.iosBody.copyWith(fontSize: 13),
            decoration: InputDecoration(
              hintText:
                  'Note clinique pour ${p.patientPrenom} (comportement, participation, progrès)...'.tr,
             hintStyle: AppTextStyles.iosCaption1.copyWith(
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: AppColors.fieldBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              isDense: true,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  /// 3. Observations Cliniques & Plan Thérapeutique
  Widget _buildClinicalNotesCard(BuildContext context) {
    return IosCard(
      title: 'Observations Cliniques & Déroulement'.tr,
     children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller:
                    TextEditingController(
                        text: controller.descriptionEtat.value,
                      )
                      ..selection = TextSelection.collapsed(
                        offset: controller.descriptionEtat.value.length,
                      ),
                onChanged: (val) => controller.descriptionEtat.value = val,
                style: AppTextStyles.iosBody,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText:
                      'Décrivez les observations cliniques, exercices thérapeutiques réalisés, réactions et synthèses du suivi...'.tr,
                 hintStyle: AppTextStyles.iosSubhead.copyWith(
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: AppColors.fieldBackground,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              // Lien avec le plan thérapeutique
              if (controller.etapesDisponibles.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Étape du Plan Thérapeutique Associée'.tr,
                 style: AppTextStyles.iosCaption1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        value: controller.etapePlanId.value,
                        isExpanded: true,
                        hint: Text(
                          'Associer une étape (optionnel)'.tr,
                         style: AppTextStyles.iosSubhead,
                        ),
                        items: [
                          DropdownMenuItem<dynamic>(
                            value: null,
                            child: Text('-- Aucune étape associée --'.tr),
                         ),
                          ...controller.etapesDisponibles.map((et) {
                            return DropdownMenuItem<dynamic>(
                              value: et.id,
                              child: Text(
                                et.titre,
                                style: AppTextStyles.iosSubhead.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) => controller.etapePlanId.value = val,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 4. Pièces Jointes & Médias
  Widget _buildMediaSection(BuildContext context) {
    return IosCard(
      title: 'Pièces Jointes & Médias Cliniques'.tr,
     children: [
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter des dessins d\'évaluation, photos de fiches ou supports de séance'.tr,
               style: AppTextStyles.iosCaption1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MediaPickerWidget(
                  initialMediaUrls: controller.medias.toList(),
                  onMediasChanged: (urls) => controller.medias.value = urls,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 5. Section Rappels & Notifications de Suivi (Clinique)
  Widget _buildFollowUpReminderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: controller.activerRappel.value
              ? AppColors.accentCoral.withValues(alpha: 0.6)
              : AppColors.border,
          width: 1.1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accentCoral.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  size: 18,
                  color: AppColors.accentCoral,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rappel & Notification de Suivi'.tr,
                     style: AppTextStyles.iosHeadline.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Programmer une alerte clinique post-séance'.tr,
                     style: AppTextStyles.iosCaption2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Switch.adaptive(
                  value: controller.activerRappel.value,
                  activeTrackColor: AppColors.accentCoral,
                  onChanged: (val) => controller.activerRappel.value = val,
                ),
              ),
            ],
          ),

          Obx(() {
            if (!controller.activerRappel.value) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 20, thickness: 0.8),

                // Message du rappel
                Text(
                  'Action de suivi à rappeler'.tr,
                 style: AppTextStyles.iosCaption1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  onChanged: (val) => controller.rappelMessage.value = val,
                  style: AppTextStyles.iosBody,
                  decoration: InputDecoration(
                    hintText:
                        'Ex: Relance parents pour compte-rendu bilan, point d\'.trétape...',
                   hintStyle: AppTextStyles.iosSubhead.copyWith(
                      color: AppColors.textHint,
                    ),
                    filled: true,
                    fillColor: AppColors.fieldBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),

                // Date de l'échéance / rappel
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date du rappel'.tr,
                           style: AppTextStyles.iosCaption1.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await AppDatePicker.show(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 7),
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                controller.rappelDate.value = picked
                                    .toIso8601String()
                                    .split('T')
                                   .first;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.fieldBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_rounded,
                                    size: 16,
                                    color: AppColors.accentCoral,
                                  ),
                                  const SizedBox(width: 8),
                                  Obx(
                                    () => Text(
                                      controller.rappelDate.value.isNotEmpty
                                          ? controller.rappelDate.value
                                          : 'Sélectionner date',
                                     style: AppTextStyles.iosBody.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priorité'.tr,
                           style: AppTextStyles.iosCaption1.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.fieldBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Obx(
                              () => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller.rappelPriorite.value,
                                  isExpanded: true,
                                  items: [
                                    DropdownMenuItem(
                                      value: 'normale',
                                     child: Text('Normale'.tr),
                                   ),
                                    DropdownMenuItem(
                                      value: 'haute',
                                     child: Text('Haute'.tr),
                                   ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null)
                                      controller.rappelPriorite.value = val;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 6. Boutons de Validation
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        BouncyTap(
          onTap: () => controller.saveRapport(cloturer: true),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.oceanGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Valider & Enregistrer le Compte-Rendu'.tr,
                 style: AppTextStyles.iosHeadline.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        BouncyTap(
          onTap: () => controller.saveRapport(cloturer: false),
          child: Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Center(
              child: Text(
                'Sauvegarder en brouillon'.tr,
                style: AppTextStyles.iosSubhead.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

