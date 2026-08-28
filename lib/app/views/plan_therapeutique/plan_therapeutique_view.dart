import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/plan_therapeutique_controller.dart';
import '../../models/plan_therapeutique_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/app_section_header.dart';

class PlanTherapeutiqueView extends GetView<PlanTherapeutiqueController> {
  const PlanTherapeutiqueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Obx(() {
          if (controller.status.value == 'loading') {
            return const StatePlaceholder(type: StatePlaceholderType.loading);
          }
          if (controller.status.value == 'error') {
            return StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadPlan(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PLAN THÉRAPEUTIQUE', style: AppTextStyles.sectionKicker),
                        Text('Plans thérapeutiques', style: AppTextStyles.screenTitleMedium),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Empty state: propose creating a plan
                if (controller.status.value == 'empty') ...[
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.assignment_outlined, size: 56, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text('Aucun plan thérapeutique.', style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showCreatePlanDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Créer un plan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(200, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Plan selector if multiple plans
                  if (controller.plans.length > 1) ...[
                    SectionHeader(title: 'Sélectionner un plan', padding: const EdgeInsets.fromLTRB(4, 16, 4, 8)),

                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.plans.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final plan = controller.plans[i];
                          final isSelected = controller.selectedPlan.value?.id == plan.id;
                          return ChoiceChip(
                            label: Text(plan.titre, style: AppTextStyles.bodySmall),
                            selected: isSelected,
                            onSelected: (_) => controller.selectPlan(plan),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Selected plan
                  if (controller.selectedPlan.value != null) ...[
                    _buildPlanCard(context, controller.selectedPlan.value!),
                  ],

                  const SizedBox(height: 20),

                  // Create new plan button
                  OutlinedButton.icon(
                    onPressed: () => _showCreatePlanDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Nouveau plan'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, PlanTherapeutiqueModel plan) {
    final etapes = plan.etapes ?? [];
    final Color statutColor = plan.statut == 'actif'
        ? AppColors.statusPresent
        : plan.statut == 'archive'
            ? AppColors.textSecondary
            : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Card
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.titre, style: AppTextStyles.sectionTitle),
                        const SizedBox(height: 4),
                        Text(
                          '${plan.etapesTerminees} / ${plan.totalEtapes} étapes complétées',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) => controller.updatePlanStatut(plan.id, val),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'actif', child: Text('Actif')),
                      const PopupMenuItem(value: 'suspendu', child: Text('Suspendu')),
                      const PopupMenuItem(value: 'archive', child: Text('Archivé')),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge.custom(
                          label: plan.statut == 'actif' ? 'Actif' : plan.statut == 'archive' ? 'Archivé' : 'Suspendu',
                          color: statutColor,
                        ),
                        const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: plan.progression,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 8),
              Text(
                '${(plan.progression * 100).toInt()}% accompli',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Étapes header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionHeader(title: 'Étapes du plan', padding: const EdgeInsets.fromLTRB(4, 16, 4, 8)),

            Text('${etapes.length} étapes', style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 12),

        // Step cards
        if (etapes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text('Aucune étape définie.', style: AppTextStyles.bodySmall),
          )
        else
          ...etapes.map((etape) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildEtapeCard(context, plan, etape),
              )),

        // Add step button
        OutlinedButton.icon(
          onPressed: () => _showAddEtapeDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une étape'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: AppColors.primary),
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEtapeCard(BuildContext context, PlanTherapeutiqueModel plan, EtapePlanTherapeutiqueModel etape) {
    Color statusColor;
    IconData statusIcon;
    switch (etape.statut) {
      case 'fait':
      case 'termine':
        statusColor = AppColors.statusPresent;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'en_cours':
        statusColor = AppColors.primary;
        statusIcon = Icons.sync_rounded;
        break;
      default:
        statusColor = AppColors.textHint;
        statusIcon = Icons.access_time_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: etape.statut == 'en_cours'
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      '${etape.ordre}.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        etape.titre,
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge.custom(label: etape.statutLabel, color: statusColor),
            ],
          ),
          if (etape.description != null && etape.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(etape.description!, style: AppTextStyles.bodySmall),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Change statut dropdown
              PopupMenuButton<String>(
                onSelected: (val) => controller.updateEtapeStatut(plan.id, etape.id, val),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'a_faire', child: Text('À faire')),
                  const PopupMenuItem(value: 'en_cours', child: Text('En cours')),
                  const PopupMenuItem(value: 'fait', child: Text('Terminé')),
                ],
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      'Changer statut',
                      style: AppTextStyles.bodySmall.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => controller.convertEtapeToTache(plan.id, etape.id),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Tâche',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => controller.deleteEtape(plan.id, etape.id),
                    child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreatePlanDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Créer un plan thérapeutique'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.titreController,
              decoration: const InputDecoration(
                labelText: 'Titre du plan *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Statut'),
                  initialValue: controller.statutPlan.value,
                  items: const [
                    DropdownMenuItem(value: 'actif', child: Text('Actif')),
                    DropdownMenuItem(value: 'suspendu', child: Text('Suspendu')),
                    DropdownMenuItem(value: 'archive', child: Text('Archivé')),
                  ],
                  onChanged: (val) {
                    if (val != null) controller.statutPlan.value = val;
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.createPlan();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showAddEtapeDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Ajouter une étape'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.etapeTitreController,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.etapeDescController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Statut'),
                  initialValue: controller.statutEtape.value,
                  items: const [
                    DropdownMenuItem(value: 'a_faire', child: Text('À faire')),
                    DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                    DropdownMenuItem(value: 'fait', child: Text('Terminé')),
                  ],
                  onChanged: (val) {
                    if (val != null) controller.statutEtape.value = val;
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.addEtape();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
