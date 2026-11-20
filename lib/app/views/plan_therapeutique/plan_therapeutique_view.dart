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
        if (controller.status.value == 'error') {
          return StatePlaceholder.error(
            message: controller.errorMessage.value,
            onAction: () => controller.loadPlan(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Empty state: propose creating a plan
                if (controller.status.value == 'empty') ...[
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            size: 56,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun plan thérapeutique.'.tr,
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Définissez les objectifs, étapes et séances du patient.'.tr,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        if (controller.isAdmin.value)
                          ElevatedButton.icon(
                            onPressed: () => _showCreatePlanDialog(context),
                            icon: const Icon(Icons.add),
                            label: Text('Créer un plan'.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    ),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.plans.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final plan = controller.plans[i];
                          final isSelected = controller.selectedPlan.value?.id == plan.id;
                          return ChoiceChip(
                            label: Text(
                              plan.titre,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) => controller.selectPlan(plan),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Selected plan card
                  if (controller.selectedPlan.value != null) ...[
                    _buildPlanCard(context, controller.selectedPlan.value!),
                  ],

                  const SizedBox(height: 20),

                  // Create new plan button (for admin)
                  if (controller.isAdmin.value)
                    OutlinedButton.icon(
                      onPressed: () => _showCreatePlanDialog(context),
                      icon: const Icon(Icons.add),
                      label: Text('Nouveau plan thérapeutique'.tr),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── Plan Card ─────────────────────────────────────────────────────────────

  Widget _buildPlanCard(BuildContext context, PlanTherapeutiqueModel plan) {
    final etapes = plan.etapes ?? [];
    final Color statutColor = plan.statut == 'actif'
        ? AppColors.statusPresent
        : plan.statut == 'archive'
            ? AppColors.textSecondary
            : AppColors.primary;

    final hasSousEtapes = plan.totalSousEtapes > 0;
    final progressLabel = hasSousEtapes
        ? '\u202A${plan.sousEtapesTerminees} / ${plan.totalSousEtapes}\u202C ${'séances complétées'.tr}'
        : '\u202A${plan.etapesTerminees} / ${plan.totalEtapes}\u202C ${'étapes complétées'.tr}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Card: Progress & Referent
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.titre, style: AppTextStyles.sectionTitle),
                        const SizedBox(height: 4),
                        Text(
                          progressLabel,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'supprimer') {
                        _confirmDeletePlan(context, plan);
                      } else {
                        controller.updatePlanStatut(plan.id, val);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'actif', child: Text('Actif'.tr)),
                      PopupMenuItem(value: 'suspendu', child: Text('Suspendu'.tr)),
                      PopupMenuItem(value: 'archive', child: Text('Archivé'.tr)),
                      if (controller.isAdmin.value) const PopupMenuDivider(),
                      if (controller.isAdmin.value)
                        PopupMenuItem(
                          value: 'supprimer',
                          child: Text(
                            'Supprimer le plan'.tr,
                            style: const TextStyle(color: AppColors.error),
                          ),
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

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: plan.progression,
                  minHeight: 8,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\u200E${(plan.progression * 100).toInt()}%\u200E ${'accompli'.tr}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasSousEtapes)
                    Text(
                      '${'séances au total'.tr} : \u200E${plan.totalSousEtapes}\u200E',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                ],
              ),
              const Divider(height: 24),

              // Plan Referent Employee Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Référent du plan :'.tr,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  _buildEmployeeBadge(
                    name: plan.assigneNom,
                    role: plan.assigneRole,
                    emptyLabel: 'Assigner référent'.tr,
                    onTap: () => _showAssignDialog(
                      context,
                      level: 'plan',
                      planId: plan.id,
                      targetTitle: plan.titre,
                      currentAssigneeId: plan.assigneA,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section Header for Steps & Sessions
        SectionHeader(
          title: 'Étapes & Séances du plan'.tr,
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          trailing: Text(
            '\u200E${etapes.length}\u200E ${'étapes'.tr}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 8),

        // Step cards list
        if (etapes.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.alt_route_rounded, size: 40, color: AppColors.textHint),
                  const SizedBox(height: 8),
                  Text(
                    'Aucune étape définie dans ce plan.'.tr,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          ...etapes.map(
            (etape) => Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: _buildEtapeCard(context, plan, etape),
            ),
          ),

        const SizedBox(height: 6),

        // Add step button
        OutlinedButton.icon(
          onPressed: () => _showAddEtapeDialog(context, plan),
          icon: const Icon(Icons.add, size: 18),
          label: Text('Ajouter une étape'.tr),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 46),
            side: const BorderSide(color: AppColors.primary),
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // ─── Étape Card ────────────────────────────────────────────────────────────

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
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'en_cours':
        statusColor = AppColors.primary;
        statusIcon = Icons.sync_rounded;
        break;
      default:
        statusColor = AppColors.textHint;
        statusIcon = Icons.access_time_rounded;
    }

    final isExpanded = controller.expandedEtapeIds.contains(etape.id);
    final sousEtapes = etape.sousEtapes ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: etape.isEnCours
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5)
            : Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header (Tap to expand/collapse)
          InkWell(
            onTap: () => controller.toggleEtapeExpanded(etape.id),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: isExpanded ? Radius.zero : const Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${'Étape'.tr} ${etape.ordre}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
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
                      const SizedBox(width: 6),
                      StatusBadge.custom(label: etape.statutLabel, color: statusColor),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                    ],
                  ),
                  if (etape.description != null && etape.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      etape.description!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 10),

                  // Step meta row: sessions counter & assigned employee
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.event_note_rounded, size: 15, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text(
                            '\u202A${etape.sousEtapesTerminees} / ${etape.totalSousEtapes}\u202C ${'séances'.tr}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: _buildEmployeeBadge(
                          name: etape.assigneNom ?? plan.assigneNom,
                          role: etape.assigneRole ?? plan.assigneRole,
                          emptyLabel: 'Assigner étape'.tr,
                          isInherited: etape.assigneNom == null && plan.assigneNom != null,
                          onTap: () => _showAssignDialog(
                            context,
                            level: 'etape',
                            planId: plan.id,
                            etapeId: etape.id,
                            targetTitle: '${'Étape'.tr} ${etape.ordre} : ${etape.titre}',
                            currentAssigneeId: etape.assigneA,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Divider before action row or sessions
          const Divider(height: 1),

          // Step action bar: Change status, Add session, Task, Delete
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                // Change status dropdown
                PopupMenuButton<String>(
                  onSelected: (val) => controller.updateEtapeStatut(plan.id, etape.id, val),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'a_faire', child: Text('À faire'.tr)),
                    PopupMenuItem(value: 'en_cours', child: Text('En cours'.tr)),
                    PopupMenuItem(value: 'fait', child: Text('Terminé'.tr)),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        'Statut'.tr,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),

                const Spacer(),

                // Add session quick button
                TextButton.icon(
                  onPressed: () => _showAddSousEtapeDialog(context, plan, etape),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 14),
                  label: Text('Séance'.tr),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 6),

                // Convert to Task button
                Tooltip(
                  message: 'Créer une tâche'.tr,
                  child: InkWell(
                    onTap: () => _showAssignTaskDialog(context, plan, etape),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.assignment_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Text(
                            'Tâche'.tr,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Delete step button
                Tooltip(
                  message: 'Supprimer l\'étape'.tr,
                  child: InkWell(
                    onTap: () => controller.deleteEtape(plan.id, etape.id),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expanded Sub-steps (Séances)
          if (isExpanded) ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.scaffold.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'SÉANCES & ACTIONS'.tr,
                          style: AppTextStyles.labelOverline.copyWith(
                            color: AppColors.textTertiary,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _showAddSousEtapeDialog(context, plan, etape),
                        icon: const Icon(Icons.add_rounded, size: 15),
                        label: Text('Nouvelle séance'.tr),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (sousEtapes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Aucune séance définie pour cette étape.'.tr,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                        ),
                      ),
                    )
                  else
                    ...sousEtapes.map(
                      (sousEtape) => _buildSousEtapeTile(context, plan, etape, sousEtape),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Sous-Étape (Séance) Tile ──────────────────────────────────────────────

  Widget _buildSousEtapeTile(
    BuildContext context,
    PlanTherapeutiqueModel plan,
    EtapePlanTherapeutiqueModel etape,
    SousEtapePlanTherapeutiqueModel sousEtape,
  ) {
    Color checkColor;
    IconData checkIcon;
    if (sousEtape.isFait) {
      checkColor = AppColors.statusPresent;
      checkIcon = Icons.check_circle_rounded;
    } else if (sousEtape.isEnCours) {
      checkColor = AppColors.primary;
      checkIcon = Icons.radio_button_checked_rounded;
    } else {
      checkColor = AppColors.textHint;
      checkIcon = Icons.radio_button_unchecked_rounded;
    }

    final effectiveAssigneeName = sousEtape.assigneNom ?? etape.assigneNom ?? plan.assigneNom;
    final effectiveAssigneeRole = sousEtape.assigneRole ?? etape.assigneRole ?? plan.assigneRole;
    final isInherited = sousEtape.assigneNom == null && (etape.assigneNom != null || plan.assigneNom != null);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sousEtape.isEnCours
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Check/toggle + Title + Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tap icon to toggle status quickly
              InkWell(
                onTap: () {
                  final nextStatut = sousEtape.isFait
                      ? 'a_faire'
                      : (sousEtape.isAFaire ? 'en_cours' : 'fait');
                  controller.updateSousEtapeStatut(plan.id, etape.id, sousEtape.id, nextStatut);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 1),
                  child: Icon(checkIcon, size: 20, color: checkColor),
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sousEtape.titre,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: sousEtape.isFait ? TextDecoration.lineThrough : null,
                        color: sousEtape.isFait ? AppColors.textHint : AppColors.textPrimary,
                      ),
                    ),
                    if (sousEtape.datePrevue != null && sousEtape.datePrevue!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            sousEtape.datePrevue!,
                            style: AppTextStyles.iosCaption2.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Menu actions for session
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 18,
                onSelected: (val) {
                  if (val == 'modifier') {
                    _showAddSousEtapeDialog(context, plan, etape, sousEtape);
                  } else if (val == 'supprimer') {
                    controller.deleteSousEtape(plan.id, etape.id, sousEtape.id);
                  } else {
                    controller.updateSousEtapeStatut(plan.id, etape.id, sousEtape.id, val);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'a_faire', child: Text('Marquer : À faire'.tr)),
                  PopupMenuItem(value: 'en_cours', child: Text('Marquer : En cours'.tr)),
                  PopupMenuItem(value: 'fait', child: Text('Marquer : Terminé'.tr)),
                  const PopupMenuDivider(),
                  PopupMenuItem(value: 'modifier', child: Text('Modifier description'.tr)),
                  PopupMenuItem(
                    value: 'supprimer',
                    child: Text('Supprimer la séance'.tr, style: const TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ],
          ),

          // Description box ("Ce qu'on doit faire dans chaque séance")
          if (sousEtape.description != null && sousEtape.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.scaffold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
              ),
              child: Text(
                sousEtape.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Bottom Session Row: Employee Badge & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: _buildEmployeeBadge(
                  name: effectiveAssigneeName,
                  role: effectiveAssigneeRole,
                  emptyLabel: 'Assigner séance'.tr,
                  isInherited: isInherited,
                  onTap: () => _showAssignDialog(
                    context,
                    level: 'sous_etape',
                    planId: plan.id,
                    etapeId: etape.id,
                    sousEtapeId: sousEtape.id,
                    targetTitle: sousEtape.titre,
                    currentAssigneeId: sousEtape.assigneA,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.custom(label: sousEtape.statutLabel, color: checkColor),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Employee Badge Component ──────────────────────────────────────────────

  Widget _buildEmployeeBadge({
    required String? name,
    required String? role,
    required String emptyLabel,
    bool isInherited = false,
    required VoidCallback onTap,
  }) {
    if (name == null || name.isEmpty) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add_alt_1_rounded, size: 13, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                emptyLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isInherited
              ? AppColors.textHint.withValues(alpha: 0.1)
              : AppColors.primaryUltraLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isInherited
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 9,
              backgroundColor: isInherited ? AppColors.textSecondary : AppColors.primary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                role != null && role.isNotEmpty ? '$name (${role.tr})' : name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isInherited ? AppColors.textSecondary : AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isInherited) ...[
              const SizedBox(width: 4),
              Text(
                '(hérité)'.tr,
                style: const TextStyle(fontSize: 9, color: AppColors.textHint, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Dialogs ───────────────────────────────────────────────────────────────

  void _showCreatePlanDialog(BuildContext context) {
    controller.titreController.clear();
    controller.statutPlan.value = 'actif';
    controller.assignePlanEmployeeId.value = null;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Créer un plan thérapeutique'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.titreController,
                decoration: InputDecoration(
                  labelText: 'Titre du plan *'.tr,
                  hintText: 'ex: Plan Orthophonie, Remédiation...'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              Obx(() => DropdownButtonFormField<dynamic>(
                    isExpanded: true,
                    initialValue: controller.assignePlanEmployeeId.value,
                    decoration: InputDecoration(
                      labelText: 'Employé référent (optionnel)'.tr,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('Aucun référent pour le moment'.tr),
                      ),
                      ...controller.availableEmployees.map((emp) {
                        return DropdownMenuItem<dynamic>(
                          value: emp.id,
                          child: Text('${emp.fullName} (${emp.role.tr})', overflow: TextOverflow.ellipsis),
                        );
                      }),
                    ],
                    onChanged: (val) => controller.assignePlanEmployeeId.value = val,
                  )),
            ],
          ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Créer'.tr),
          ),
        ],
      ),
    );
  }

  void _showAddEtapeDialog(BuildContext context, PlanTherapeutiqueModel plan) {
    controller.etapeTitreController.clear();
    controller.etapeDescController.clear();
    controller.statutEtape.value = 'a_faire';
    controller.assigneEtapeEmployeeId.value = plan.assigneA;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Ajouter une étape'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.etapeTitreController,
                decoration: InputDecoration(
                  labelText: 'Titre de l\'étape *'.tr,
                  hintText: 'ex: Phase 1 : Attention sélective'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.etapeDescController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description / Objectif'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<dynamic>(
                    isExpanded: true,
                    initialValue: controller.assigneEtapeEmployeeId.value,
                    decoration: InputDecoration(
                      labelText: 'Employé assigné'.tr,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(plan.assigneNom != null
                            ? '${'Hériter du plan :'.tr} ${plan.assigneNom}'
                            : 'Non assigné'.tr),
                      ),
                      ...controller.availableEmployees.map((emp) {
                        return DropdownMenuItem<dynamic>(
                          value: emp.id,
                          child: Text('${emp.fullName} (${emp.role.tr})', overflow: TextOverflow.ellipsis),
                        );
                      }),
                    ],
                    onChanged: (val) => controller.assigneEtapeEmployeeId.value = val,
                  )),
            ],
          ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Ajouter'.tr),
          ),
        ],
      ),
    );
  }

  void _showAddSousEtapeDialog(
    BuildContext context,
    PlanTherapeutiqueModel plan,
    EtapePlanTherapeutiqueModel etape, [
    SousEtapePlanTherapeutiqueModel? existing,
  ]) {
    final nextOrdre = (etape.sousEtapes?.length ?? 0) + 1;
    controller.sousEtapeTitreController.text = existing?.titre ?? 'Séance $nextOrdre'.tr;
    controller.sousEtapeDescController.text = existing?.description ?? '';
    controller.statutSousEtape.value = existing?.statut ?? 'a_faire';
    controller.assigneSousEtapeEmployeeId.value = existing?.assigneA ?? etape.assigneA ?? plan.assigneA;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Ajouter une séance'.tr : 'Modifier la séance'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'Étape :'.tr} ${etape.titre}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.sousEtapeTitreController,
                decoration: InputDecoration(
                  labelText: 'Titre de la séance *'.tr,
                  hintText: 'ex: Séance 1 : Exercices attentionnels'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller.sousEtapeDescController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Déroulement de la séance (ce qu\'on doit faire) *'.tr,
                  hintText: 'Détaillez les activités, consignes, exercices à réaliser lors de cette séance...'.tr,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              Obx(() => DropdownButtonFormField<dynamic>(
                    isExpanded: true,
                    initialValue: controller.assigneSousEtapeEmployeeId.value,
                    decoration: InputDecoration(
                      labelText: 'Employé en charge de la séance'.tr,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(etape.assigneNom != null
                            ? '${'Hériter de l\'étape :'.tr} ${etape.assigneNom}'
                            : 'Non assigné'.tr),
                      ),
                      ...controller.availableEmployees.map((emp) {
                        return DropdownMenuItem<dynamic>(
                          value: emp.id,
                          child: Text('${emp.fullName} (${emp.role.tr})', overflow: TextOverflow.ellipsis),
                        );
                      }),
                    ],
                    onChanged: (val) => controller.assigneSousEtapeEmployeeId.value = val,
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Annuler'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (existing == null) {
                controller.addSousEtape(plan.id, etape.id);
              } else {
                controller.updateSousEtapeDetails(
                  plan.id,
                  etape.id,
                  existing.id,
                  titre: controller.sousEtapeTitreController.text.trim(),
                  description: controller.sousEtapeDescController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(existing == null ? 'Ajouter la séance'.tr : 'Enregistrer'.tr),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(
    BuildContext context, {
    required String level, // 'plan' | 'etape' | 'sous_etape'
    required dynamic planId,
    dynamic etapeId,
    dynamic sousEtapeId,
    required String targetTitle,
    dynamic currentAssigneeId,
  }) {
    dynamic selectedId = currentAssigneeId;
    final propager = true.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.person_pin_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                level == 'plan'
                    ? 'Assigner le plan complet'.tr
                    : (level == 'etape' ? 'Assigner l\'étape'.tr : 'Assigner la séance'.tr),
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  targetTitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sélectionnez le spécialiste en charge :'.tr,
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<dynamic>(
                isExpanded: true,
                initialValue: selectedId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('— Retirer l\'assignation —'.tr, style: const TextStyle(color: AppColors.textHint)),
                  ),
                  ...controller.availableEmployees.map((emp) {
                    return DropdownMenuItem<dynamic>(
                      value: emp.id,
                      child: Text(
                        '${emp.fullName} (${emp.role.tr})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (val) => selectedId = val,
              ),

              if (level == 'plan' || level == 'etape') ...[
                const SizedBox(height: 14),
                Obx(
                  () => CheckboxListTile(
                    value: propager.value,
                    onChanged: (val) => propager.value = val ?? false,
                    title: Text(
                      level == 'plan'
                          ? 'Appliquer également à toutes les étapes et séances du plan'.tr
                          : 'Appliquer également à toutes les séances de cette étape'.tr,
                      style: const TextStyle(fontSize: 12),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Annuler'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (level == 'plan') {
                controller.assignPlan(planId, selectedId, propager: propager.value);
              } else if (level == 'etape') {
                controller.assignEtape(planId, etapeId, selectedId, propager: propager.value);
              } else if (level == 'sous_etape') {
                controller.assignSousEtape(planId, etapeId, sousEtapeId, selectedId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Confirmer l\'assignation'.tr),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePlan(BuildContext context, PlanTherapeutiqueModel plan) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Supprimer le plan ?'.tr),
        content: Text(
          'Voulez-vous vraiment supprimer "${plan.titre}" ainsi que toutes ses étapes et séances associées ? Cette action est irréversible.'.tr,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Annuler'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deletePlan(plan.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Supprimer définitivement'.tr),
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
