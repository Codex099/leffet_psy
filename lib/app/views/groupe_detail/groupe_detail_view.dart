import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/groupe_detail_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/json_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/status_badge.dart';

class GroupeDetailView extends GetView<GroupeDetailController> {
  const GroupeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Détail du Groupe',
        subtitle: 'Atelier Clinique Collectif',
        showBackButton: true,
        actions: [
          BouncyTap(
            onTap: () async {
              final res = await Get.toNamed(AppRoutes.editGroupe, arguments: controller.groupeId);
              if (res == true) {
                controller.loadGroupe();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(9),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: AppColors.oceanGradient,
                shape: BoxShape.circle,
                boxShadow: AppColors.softShadow,
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 19,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.status.value == 'loading') {
          return const StatePlaceholder(type: StatePlaceholderType.loading);
        }
        if (controller.status.value == 'error') {
          return StatePlaceholder.error(
            message: controller.errorMessage.value,
            onAction: () => controller.loadGroupe(),
          );
        }

        final g = controller.groupe.value;
        final rawPatients = g?.patients ?? [];
        final seenPatIds = <String>{};
        final patientsList = <Map<String, dynamic>>[];
        for (final p in rawPatients) {
          final pid = parseId(p['id'] ?? p['patient_id'])?.toString();
          if (pid != null && !seenPatIds.contains(pid)) {
            seenPatIds.add(pid);
            patientsList.add(p);
          }
        }
        final planningList = g?.planningRecurrent ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── En-tête Groupe iOS ──
              IosCard(
                title: 'Groupe',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.headerGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              g?.initials ?? 'G',
                              style: AppTextStyles.iosTitle2.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g?.nom ?? 'Sans nom', style: AppTextStyles.iosTitle2),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  StatusBadge.active(label: 'Atelier Clinique'),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${patientsList.length} membre${patientsList.length > 1 ? 's' : ''}',
                                    style: AppTextStyles.iosFootnote,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (g?.description != null && g!.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
                      child: Text(
                        g.description!,
                        style: AppTextStyles.iosBody.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),

              // ── Horaires & Planning Récurrent ──
              IosCard(
                title: 'Horaires Récurrents',
                children: [
                  if (planningList.isEmpty)
                    const IosCardTile(
                      leading: Icon(Icons.schedule_rounded, color: AppColors.iosSystemGray),
                      title: 'Aucun créneau configuré',
                      subtitle: 'Définissez les jours et heures dans l\'édition du groupe.',
                    )
                  else
                    ...planningList.map((slot) {
                      final jour = slot['jour_semaine'] ?? '';
                      final debut = slot['heure_debut'] ?? '';
                      final fin = slot['heure_fin'] ?? '';
                      return IosCardTile(
                        leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                        title: 'Tous les ${jour.toUpperCase()}',
                        subtitle: '$debut "” $fin',
                      );
                    }),
                ],
              ),

              // ── Membres & Participants ──
              IosCard(
                title: 'Membres Inscrits (${patientsList.length})',
                subtitle: 'Patients associés à  ce groupe clinique',
                children: [
                  if (patientsList.isEmpty)
                    const IosCardTile(
                      leading: Icon(Icons.person_add_disabled_rounded, color: AppColors.iosSystemGray),
                      title: 'Aucun patient dans ce groupe',
                      subtitle: 'Ajoutez des membres en modifiant le groupe.',
                    )
                  else
                    ...patientsList.map((p) {
                      final pNom = p['nom'] ?? '';
                      final pPrenom = p['prenom'] ?? '';
                      final pFullName = '$pPrenom $pNom'.trim();
                      final initials = pFullName.isNotEmpty ? pFullName[0] : 'P';
                      final pId = p['id'] ?? p['patient_id'];

                      return IosCardTile(
                        leading: PatientAvatar(initials: initials, radius: 18),
                        title: pFullName.isNotEmpty ? pFullName : 'Patient',
                        subtitle: p['telephone'] ?? '',
                        showChevron: true,
                        onTap: pId != null ? () => Get.toNamed(AppRoutes.patientInfo, arguments: pId) : null,
                      );
                    }),
                ],
              ),

              // ── Actions ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    AppButton(
                      label: 'Gérer les membres et créneaux',
                      icon: Icons.edit_rounded,
                      isSecondary: true,
                      onPressed: () => Get.toNamed(AppRoutes.editGroupe, arguments: controller.groupeId),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Compte-rendu de séance collective',
                      icon: Icons.assignment_outlined,
                      onPressed: () => Get.toNamed(AppRoutes.compteRenduGroupe, arguments: controller.groupeId),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => _confirmDeleteGroup(context),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                      label: Text('Supprimer ce groupe', style: AppTextStyles.buttonDestructive),
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

  void _confirmDeleteGroup(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Supprimer le groupe'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce groupe ? Cette action est irréversible.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteGroupe();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
