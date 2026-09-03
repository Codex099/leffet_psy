import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/plan_therapeutique_controller.dart';
import '../../models/plan_therapeutique_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/app_section_header.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/app_date_picker.dart';

class PlanTherapeutiqueView extends GetView<PlanTherapeutiqueController> {
 const PlanTherapeutiqueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Plan Thérapeutique'.tr,
        subtitle: 'Objectifs & Suivi Clinique'.tr,
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.status.value == 'loading') {
          return const StatePlaceholder(type: StatePlaceholderType.loading);
        }
        if (!controller.isAdmin.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Accès réservé'.tr,
                    style: AppTextStyles.iosHeadline.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seul l\'administrateur est autorisé à consulter et gérer les plans thérapeutiques.'.tr,
                    style: AppTextStyles.iosSubhead.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        if (controller.status.value == 'error') {
          return StatePlaceholder.error(
            message: controller.errorMessage.value,
            onAction: () => controller.loadPlan(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Empty state: propose creating a plan
              if (controller.status.value == 'empty') ...[
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        size: 56,
                        color: AppColors.textHint,
                      ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun plan thérapeutique.'.tr,
                         style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showCreatePlanDialog(context),
                          icon: const Icon(Icons.add),
                          label: Text('Créer un plan'.tr),
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
                    SectionHeader(
                      title: 'Sélectionner un plan'.tr,
                     padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.plans.length,
                        separatorBuilder: (ctx, idx) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final plan = controller.plans[i];
                          final isSelected =
                              controller.selectedPlan.value?.id == plan.id;
                          return ChoiceChip(
                            label: Text(
                              plan.titre,
                              style: AppTextStyles.bodySmall,
                            ),
                            selected: isSelected,
                            onSelected: (_) => controller.selectPlan(plan),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
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
                    label: Text('Nouveau plan'.tr),
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
                          '${plan.etapesTerminees} / ${plan.totalEtapes} étapes complétées'.tr,
                         style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) =>
                        controller.updatePlanStatut(plan.id, val),
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'actif', child: Text('Actif'.tr)),
                     PopupMenuItem(
                        value: 'suspendu',
                       child: Text('Suspendu'.tr),
                     ),
                      PopupMenuItem(
                        value: 'archive',
                       child: Text('Archivé'.tr),
                     ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge.custom(
                          label: plan.statut == 'actif'
                             ? 'Actif'.tr
                             : plan.statut == 'archive'
                             ? 'Archivé'.tr
                             : 'Suspendu'.tr,
                         color: statutColor,
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
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
                '${(plan.progression * 100).toInt()}% accompli'.tr,
               style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Étapes header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionHeader(
              title: 'Étapes du plan'.tr,
             padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            ),

            Text('${etapes.length} étapes'.tr, style: AppTextStyles.bodySmall),
         ],
        ),
        const SizedBox(height: 12),

        // Step cards
        if (etapes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'Aucune étape définie.'.tr,
             style: AppTextStyles.bodySmall,
            ),
          )
        else
          ...etapes.map(
            (etape) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildEtapeCard(context, plan, etape),
            ),
          ),

        // Add step button
        OutlinedButton.icon(
          onPressed: () => _showAddEtapeDialog(context),
          icon: const Icon(Icons.add),
          label: Text('Ajouter une étape'.tr),
         style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: AppColors.primary),
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEtapeCard(
    BuildContext context,
    PlanTherapeutiqueModel plan,
    EtapePlanTherapeutiqueModel etape,
  ) {
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
           ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              )
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
                      '${etape.ordre}.'.tr,
                     style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        etape.titre,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                onSelected: (val) =>
                    controller.updateEtapeStatut(plan.id, etape.id, val),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'a_faire', child: Text('À faire'.tr)),
                 PopupMenuItem(
                    value: 'en_cours',
                   child: Text('En cours'.tr),
                 ),
                  PopupMenuItem(value: 'fait', child: Text('Terminé'.tr)),
               ],
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      'Changer statut'.tr,
                     style: AppTextStyles.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () =>
                        _showAssignTaskDialog(context, plan, etape),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tâche'.tr,
                         style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => controller.deleteEtape(plan.id, etape.id),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
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
        title: Text('Créer un plan thérapeutique'.tr),
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
            Obx(
              () => DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Statut'.tr),
               initialValue: controller.statutPlan.value,
                items: [
                  DropdownMenuItem(value: 'actif', child: Text('Actif'.tr)),
                 DropdownMenuItem(value: 'suspendu', child: Text('Suspendu'.tr)),
                 DropdownMenuItem(value: 'archive', child: Text('Archivé'.tr)),
               ],
                onChanged: (val) {
                  if (val != null) controller.statutPlan.value = val;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Annuler'.tr)),
         ElevatedButton(
            onPressed: () {
              Get.back();
              controller.createPlan();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Créer'.tr),
         ),
        ],
      ),
    );
  }

  void _showAddEtapeDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Ajouter une étape'.tr),
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
              decoration: InputDecoration(
                labelText: 'Description'.tr,
               border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Statut'.tr),
               initialValue: controller.statutEtape.value,
                items: [
                  DropdownMenuItem(value: 'a_faire', child: Text('À faire'.tr)),
                 DropdownMenuItem(value: 'en_cours', child: Text('En cours'.tr)),
                 DropdownMenuItem(value: 'fait', child: Text('Terminé'.tr)),
               ],
                onChanged: (val) {
                  if (val != null) controller.statutEtape.value = val;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Annuler'.tr)),
         ElevatedButton(
            onPressed: () {
              Get.back();
              controller.addEtape();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Ajouter'.tr),
          ),
        ],
      ),
    );
  }

  void _showAssignTaskDialog(
    BuildContext context,
    PlanTherapeutiqueModel plan,
    EtapePlanTherapeutiqueModel etape,
  ) {
    dynamic selectedEmployeeId = controller.availableEmployees.isNotEmpty
        ? controller.availableEmployees.first.id
        : null;
    final selectedPriority = 'normale'.obs;
    final dateEcheance = ''.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Assigner l\'étape en tâche'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etape.titre,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              if (etape.description != null && etape.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(etape.description!, style: AppTextStyles.bodySmall),
              ],
              const SizedBox(height: 16),
              // Employé
              Text(
                'Employé assigné'.tr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Obx(() {
                if (controller.availableEmployees.isEmpty) {
                  return Text(
                    'Aucun employé disponible'.tr,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  );
                }
                return DropdownButtonFormField<dynamic>(
                  isExpanded: true,
                  initialValue: selectedEmployeeId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: controller.availableEmployees.map((emp) {
                    return DropdownMenuItem<dynamic>(
                      value: emp.id,
                      child: Text(
                        '${emp.fullName} (${emp.role.tr})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => selectedEmployeeId = val,
                );
              }),
              const SizedBox(height: 14),
              // Priorité
              Text(
                'Priorité'.tr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: selectedPriority.value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: [
                    DropdownMenuItem(value: 'normale', child: Text('Normale'.tr)),
                    DropdownMenuItem(value: 'haute', child: Text('Haute'.tr)),
                    DropdownMenuItem(value: 'basse', child: Text('Basse'.tr)),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedPriority.value = val;
                  },
                ),
              ),
              const SizedBox(height: 14),
              // Date d'échéance
              Text(
                'Date d\'échéance'.tr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Obx(
                () => InkWell(
                  onTap: () async {
                    final picked = await AppDatePicker.show(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      dateEcheance.value =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateEcheance.value.isEmpty
                              ? 'Sélectionner une date'.tr
                              : dateEcheance.value,
                          style: TextStyle(
                            color: dateEcheance.value.isEmpty
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                          ),
                        ),
                        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Annuler'.tr)),
          ElevatedButton(
            onPressed: () {
              if (selectedEmployeeId == null) {
                Get.snackbar('Sélection requise'.tr, 'Veuillez sélectionner un employé.'.tr);
                return;
              }
              Get.back();
              controller.convertEtapeToTache(
                plan.id,
                etape.id,
                assigneA: selectedEmployeeId.toString(),
                priorite: selectedPriority.value,
                dateEcheance: dateEcheance.value.isNotEmpty ? dateEcheance.value : null,
                titre: etape.titre,
                description: etape.description,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Assigner la tâche'.tr),
          ),
        ],
      ),
    );
  }
}
