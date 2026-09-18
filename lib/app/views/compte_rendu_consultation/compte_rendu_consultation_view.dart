import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/compte_rendu_specialiste_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/status_badge.dart';

/// Page de consultation (lecture seule) d'un compte-rendu clinique.
/// Distincte de la page d'édition/rédaction, elle présente les données
/// de façon propre, structurée et non modifiable.
class CompteRenduConsultationView
    extends GetView<CompteRenduSpecialisteController> {
  const CompteRenduConsultationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Compte-Rendu Clinique'.tr,
        subtitle: 'Consultation'.tr,
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.status.value == 'loading') {
          return StatePlaceholder.loading(
            message: 'Chargement du compte-rendu...'.tr,
          );
        }

        if (controller.status.value == 'unauthorized') {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.accentCoral.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 38,
                      color: AppColors.accentCoral,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Accès Non Autorisé'.tr,
                    style: AppTextStyles.iosTitle2.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : "Vous n'êtes pas assigné(e) à ce patient.".tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.iosSubhead.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  BouncyTap(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                      decoration: BoxDecoration(
                        gradient: AppColors.oceanGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Retour'.tr,
                        style: AppTextStyles.iosHeadline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.status.value == 'error') {
          return StatePlaceholder.error(
            message: controller.errorMessage.value,
            onAction: () => controller.loadData(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. En-tête Clinique ──
              _buildHeaderCard(),
              const SizedBox(height: 14),

              // ── 2. Présence ──
              if (controller.isGroupe.value)
                _buildGroupParticipantsCard()
              else
                _buildPresenceCard(),
              const SizedBox(height: 14),

              // ── 3. Observations Cliniques ──
              _buildObservationsCard(),
              const SizedBox(height: 14),

              // ── 4. Médias Joints ──
              if (controller.medias.isNotEmpty) ...[
                _buildMediasCard(),
                const SizedBox(height: 14),
              ],

              // ── 5. Rappel de suivi (si actif) ──
              if (controller.activerRappel.value)
                _buildRappelCard(),

              const SizedBox(height: 32),

              // ── 6. Actions ──
              _buildActions(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. En-tête : type, date, praticien, statut
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.secondary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18), width: 1),
        boxShadow: AppColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type badge + statut
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        color: controller.isGroupe.value
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        controller.isGroupe.value
                            ? 'Séance de Groupe'.tr
                            : 'Consultation Individuelle'.tr,
                        style: AppTextStyles.iosCaption1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: controller.isGroupe.value
                              ? AppColors.secondary
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (controller.isAlreadyValidated.value)
                  StatusBadge.active(label: 'Validé'.tr)
                else
                  StatusBadge.pending(label: 'Brouillon'.tr),
              ],
            ),
            const SizedBox(height: 14),

            // Titre de la séance
            Text(
              controller.sessionTitle,
              style: AppTextStyles.iosTitle2.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Date et heure
            _buildInfoRow(
              icon: Icons.schedule_rounded,
              text: controller.sessionDateTimeInfo,
            ),
            const SizedBox(height: 6),

            // Praticien
            _buildInfoRow(
              icon: Icons.badge_outlined,
              text: '${'Spécialiste'.tr} : ${controller.responsableNom}',
            ),

            const SizedBox(height: 14),

            // Bandeau rôle de l'utilisateur courant
            Obx(() {
              final isAuthor = controller.isAuthor.value;
              final isAdmin = controller.isAdmin.value;
              final color = isAuthor ? AppColors.iosGreen : AppColors.primary;
              final icon = isAuthor ? Icons.edit_note_rounded : Icons.visibility_rounded;
              final label = isAuthor
                  ? 'Vous êtes l\'auteur de ce compte-rendu'.tr
                  : isAdmin
                      ? 'Mode consultation administrative (lecture seule)'.tr
                      : 'Mode lecture seule — seul l\'auteur peut modifier'.tr;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.20), width: 0.9),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 17, color: color),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTextStyles.iosCaption1.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2a. Présence individuelle
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildPresenceCard() {
    return Obx(() {
      final p = controller.statutPresence.value;
      final isPresent = p == 'present';
      final isExcuse = p == 'excuse';
      final Color color = isPresent
          ? AppColors.iosGreen
          : (isExcuse ? AppColors.secondary : AppColors.accentCoral);
      final String label = isPresent
          ? 'Présent(e)'.tr
          : (isExcuse ? 'Excusé(e)'.tr : 'Absent(e)'.tr);
      final IconData icon = isPresent
          ? Icons.check_circle_rounded
          : (isExcuse ? Icons.info_rounded : Icons.cancel_rounded);

      return _buildSection(
        title: 'Statut de Présence'.tr,
        icon: Icons.person_pin_rounded,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppTextStyles.iosHeadline.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2b. Participants (groupe)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildGroupParticipantsCard() {
    return _buildSection(
      title: 'Participants de l\'atelier'.tr,
      icon: Icons.groups_rounded,
      trailing: Text(
        '${controller.participants.length} ${'participant(s)'.tr}',
        style: AppTextStyles.iosCaption1.copyWith(color: AppColors.textSecondary),
      ),
      child: Column(
        children: controller.participants.map((p) {
          return Obx(() {
            final isPresent = p.statutPresence.value == 'present';
            final isExcuse = p.statutPresence.value == 'excuse';
            final Color presColor = isPresent
                ? AppColors.iosGreen
                : (isExcuse ? AppColors.secondary : AppColors.accentCoral);
            final String presLabel = isPresent
                ? 'Présent'.tr
                : (isExcuse ? 'Excusé'.tr : 'Absent'.tr);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.fieldBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.8),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: presColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPresent
                                  ? Icons.check_circle_rounded
                                  : (isExcuse ? Icons.info_rounded : Icons.cancel_rounded),
                              size: 13,
                              color: presColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              presLabel,
                              style: AppTextStyles.iosCaption1.copyWith(
                                fontWeight: FontWeight.w700,
                                color: presColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (p.noteController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Note clinique'.tr,
                            style: AppTextStyles.iosCaption2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.noteController.text.trim(),
                            style: AppTextStyles.iosBody.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. Observations cliniques
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildObservationsCard() {
    return Obx(() {
      final text = controller.descriptionEtat.value.trim();
      final hasText = text.isNotEmpty;

      return _buildSection(
        title: 'Observations Cliniques'.tr,
        icon: Icons.medical_information_rounded,
        child: hasText
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.fieldBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    width: 0.9,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Déroulement \u0026 Synthèse clinique'.tr,
                          style: AppTextStyles.iosCaption1.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      text,
                      style: AppTextStyles.iosBody.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.fieldBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Aucune observation clinique enregistrée.'.tr,
                    style: AppTextStyles.iosSubhead.copyWith(
                      color: AppColors.textHint,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. Médias joints
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildMediasCard() {
    return _buildSection(
      title: 'Documents \u0026 Médias Joints'.tr,
      icon: Icons.attach_file_rounded,
      child: Obx(() {
        final medias = controller.medias;
        if (medias.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                'Aucun document joint.'.tr,
                style: AppTextStyles.iosSubhead.copyWith(
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: medias.map((url) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.9),
                color: AppColors.fieldBackground,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, s) => const Icon(
                    Icons.description_rounded,
                    color: AppColors.textSecondary,
                    size: 30,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. Rappel de suivi
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRappelCard() {
    return _buildSection(
      title: 'Rappel de Suivi'.tr,
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.accentCoral,
      child: Obx(() {
        final message = controller.rappelMessage.value.trim();
        final date = controller.rappelDate.value;
        final priorite = controller.rappelPriorite.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isNotEmpty) ...[
              _buildReadField(label: 'Action à rappeler'.tr, value: message),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                if (date.isNotEmpty)
                  Expanded(
                    child: _buildReadField(label: 'Date'.tr, value: date),
                  ),
                if (date.isNotEmpty) const SizedBox(width: 8),
                Expanded(
                  child: _buildReadField(
                    label: 'Priorité'.tr,
                    value: priorite == 'haute' ? 'Haute'.tr : 'Normale'.tr,
                    valueColor: priorite == 'haute'
                        ? AppColors.accentCoral
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 6. Boutons d'action
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildActions() {
    return Obx(() {
      final isAuthor = controller.isAuthor.value;

      return Column(
        children: [
          if (isAuthor) ...[
            BouncyTap(
              onTap: () async {
                final res = await Get.toNamed(
                  AppRoutes.compteRenduSpecialiste,
                  arguments: {
                    'seance_id': controller.seanceId,
                    'is_groupe': controller.isGroupe.value,
                  },
                );
                if (res == true) controller.loadData();
              },
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
                    const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Modifier ce compte-rendu'.tr,
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
          ],
          BouncyTap(
            onTap: () => Get.back(),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.0),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Fermer'.tr,
                    style: AppTextStyles.iosHeadline.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers UI
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    Color? iconColor,
    Widget? trailing,
  }) {
    final color = iconColor ?? AppColors.primary;
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
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.iosHeadline.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const Divider(height: 18, thickness: 0.7),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.iosSubhead.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadField({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.iosCaption2.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTextStyles.iosSubhead.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
