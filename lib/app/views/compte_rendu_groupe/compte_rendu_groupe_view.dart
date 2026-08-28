import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/compte_rendu_groupe_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/media_picker_widget.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/app_section_header.dart';

class CompteRenduGroupeView extends GetView<CompteRenduGroupeController> {
  const CompteRenduGroupeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const CreativeAppBar(
        title: 'Compte-rendu Groupe',
        subtitle: 'Atelier Clinique Collectif',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.status.value == 'loading') {
            return const StatePlaceholder(type: StatePlaceholderType.loading);
          }
          if (controller.status.value == 'error') {
            return StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadSeance(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Group summary banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Groupe', style: AppTextStyles.bodySmall),
                          StatusBadge.active(label: 'Séance du jour'),
                        ],
                      ),
                      SectionHeader(title: 'Atelier compétences sociales', padding: const EdgeInsets.fromLTRB(4, 16, 4, 8)),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Date: Mardi 24 juin 2026', style: AppTextStyles.bodySmall),
                          const SizedBox(width: 12),
                          Text('Horaire: 14:00 - 15:00', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Participants section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SectionHeader(title: 'Liste des participants', padding: const EdgeInsets.fromLTRB(4, 16, 4, 8)),

                    TextButton(
                      onPressed: () {},
                      child: const Text('Présence rapide'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Participant presence list cards
                _buildParticipantPresenceCard('Camille Moreau', isPresent: true, patientId: 1),
                const SizedBox(height: 12),
                _buildParticipantPresenceCard('Lucas Bernard', isPresent: false, patientId: 2),
                const SizedBox(height: 12),
                _buildParticipantPresenceCard('Nina Faure', isPresent: true, patientId: 3),
                const SizedBox(height: 20),

                // Note générale card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Note générale de la séance', padding: const EdgeInsets.fromLTRB(4, 16, 4, 8)),

                      const SizedBox(height: 12),
                      AppTextField(
                        label: '',
                        hintText: 'Décrire le déroulé de la séance, les objectifs travaillés, les réactions du groupe et les points de vigilance...',
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pièces jointes Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.attach_file_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          SectionHeader(title: 'Pièces jointes', padding: const EdgeInsets.fromLTRB(4, 16, 4, 8)),

                        ],
                      ),
                      Text('Ajouter une photo ou une vidéo liée à  la séance', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 14),
                      MediaPickerWidget(
                        initialMediaUrls: controller.medias,
                        onMediasChanged: (urls) => controller.medias.value = urls,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildParticipantPresenceCard(String name, {required bool isPresent, required dynamic patientId}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
                  const CircleAvatar(radius: 18, backgroundColor: AppColors.secondaryLight, child: Icon(Icons.person, size: 18)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text('Remarque individuelle optionnelle', style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  StatusBadge.custom(
                    label: isPresent ? 'Présent' : 'Absent',
                    color: isPresent ? AppColors.primary : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: isPresent,
                    onChanged: (v) => controller.togglePresence(patientId, v),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppTextField(
            label: 'Note',
            hintText: 'Ajouter une remarque sur la participation, l\'attention ou le comportement...',
            maxLines: 2,
            suffixIcon: const Icon(Icons.edit_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}
