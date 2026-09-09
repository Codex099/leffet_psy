import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/detail_tache_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_date_picker.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/ios_segmented_control.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/searchable_picker.dart';
import '../../widgets/state_placeholder.dart';

class DetailTacheView extends StatefulWidget {
  const DetailTacheView({super.key});

  @override
  State<DetailTacheView> createState() => _DetailTacheViewState();
}

class _DetailTacheViewState extends State<DetailTacheView> {
  final controller = Get.find<DetailTacheController>();
  late final TextEditingController _titreCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _titreCtrl = TextEditingController(text: controller.titre.value);
    _descCtrl = TextEditingController(text: controller.description.value);

    ever(controller.titre, (v) {
      if (_titreCtrl.text != v) _titreCtrl.text = v;
    });
    ever(controller.description, (v) {
      if (_descCtrl.text != v) _descCtrl.text = v;
    });
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = controller.isEditing.value;
      final isNew = controller.isNew;

      return Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: CreativeAppBar(
          title: isNew
              ? 'Nouvelle Tâche'.tr
              : (isEditing ? 'Modifier la Tâche'.tr : 'Détail de la Tâche'.tr),
          subtitle: 'Suivi Clinique'.tr,
          showBackButton: true,
          actions: [
            if (!isNew && controller.canEdit)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  icon: Icon(
                    isEditing ? Icons.visibility_outlined : Icons.edit_outlined,
                    size: 18,
                  ),
                  label: Text(
                    isEditing ? 'Consulter'.tr : 'Modifier'.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => controller.toggleEditMode(),
                ),
              ),
          ],
        ),
        body: Obx(() {
          if (controller.status.value == 'loading' &&
              !isNew &&
              controller.titre.value.isEmpty) {
            return StatePlaceholder.loading(
              message: 'Chargement de la tâche...'.tr,
            );
          }
          if (controller.status.value == 'error') {
            return StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () {
                final id = controller.tache.value?.id;
                if (id != null) controller.loadTache(id, forceRefresh: true);
              },
            );
          }

          if (!isEditing) {
            return _buildReadOnlyView(context);
          }
          return _buildEditView(context);
        }),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MODE LECTURE (DÉTAILS DE LA TÂCHE)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildReadOnlyView(BuildContext context) {
    final t = controller.tache.value;
    final Color prioColor = controller.priorite.value == 'haute'
        ? AppColors.accentCoral
        : controller.priorite.value == 'normale'
            ? AppColors.primary
            : AppColors.secondary;

    final String prioLabel = controller.priorite.value == 'haute'
        ? 'Haute'.tr
        : controller.priorite.value == 'normale'
            ? 'Normale'.tr
            : 'Basse'.tr;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Statut interactif ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('STATUT DE LA TÂCHE'.tr, style: AppTextStyles.iosCaption2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: prioColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag_rounded, size: 14, color: prioColor),
                      const SizedBox(width: 4),
                      Text(
                        '${'Priorité'.tr} $prioLabel',
                        style: AppTextStyles.iosCaption1.copyWith(
                          color: prioColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => IosSegmentedControl<String>(
              segments: {
                'a_faire': 'À faire'.tr,
                'en_cours': 'En cours'.tr,
                'fait': 'Terminée'.tr,
              },
              selectedValue: controller.statut.value,
              onValueChanged: (s) => controller.setStatut(s),
            ),
          ),
          const SizedBox(height: 14),

          // ── Titre & Description ──
          IosCard(
            title: 'Tâche'.tr,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.titre.value.isEmpty ? 'Sans titre'.tr : controller.titre.value,
                      style: AppTextStyles.iosTitle3.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (controller.description.value.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          controller.description.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // ── Assignation du professionnel ──
          IosCard(
            title: 'Assigné à'.tr,
            children: [
              IosCardTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary),
                ),
                title: controller.employeeName,
                subtitle: controller.employeeRole ??
                    (controller.isAssignedToMe
                        ? 'Assignée à vous-même'.tr
                        : 'Membre de l\'équipe'.tr),
              ),
            ],
          ),

          // ── Patient concerné (avec navigation directe) ──
          if (controller.patientId.value != null || t?.patient != null)
            IosCard(
              title: 'Patient Concerné'.tr,
              children: [
                Builder(
                  builder: (context) {
                    final p = controller.linkedPatient;
                    final ptMap = t?.patient;
                    final patId = controller.patientId.value ?? ptMap?['id'];
                    final fullName = p?.fullName ??
                        '${ptMap?['prenom'] ?? ''} ${ptMap?['nom'] ?? ''}'.trim();
                    final subtitle = p != null
                        ? '${p.age != null ? "${p.age} ${'ans'.tr} • " : ""}${p.isFille ? "Fille".tr : "Garçon".tr}'
                        : 'Voir le dossier du patient'.tr;

                    final String initials;
                    if (p != null) {
                      initials = p.initials;
                    } else {
                      final pr = (ptMap?['prenom'] ?? 'P').toString();
                      final nm = (ptMap?['nom'] ?? '').toString();
                      initials = '${pr.isNotEmpty ? pr[0] : "P"}${nm.isNotEmpty ? nm[0] : ""}'.toUpperCase();
                    }

                    return IosCardTile(
                      leading: PatientAvatar(
                        initials: initials,
                        radius: 20,
                      ),
                      title: fullName.isNotEmpty ? fullName : 'Patient associé'.tr,
                      subtitle: subtitle,
                      showChevron: true,
                      onTap: patId != null
                          ? () {
                              Get.toNamed(AppRoutes.patientInfo, arguments: patId);
                            }
                          : null,
                    );
                  },
                ),
              ],
            ),

          // ── Échéance ──
          IosCard(
            title: 'Échéance'.tr,
            children: [
              IosCardTile(
                leading: const Icon(
                  Icons.event_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                title: controller.dateEcheance.value.isEmpty
                    ? 'Aucune date fixée'.tr
                    : controller.dateEcheance.value,
                subtitle: controller.dateEcheance.value.isNotEmpty
                    ? 'Date limite de réalisation'.tr
                    : null,
              ),
            ],
          ),

          // ── Bouton action rapide Modifier / Supprimer ──
          if (controller.canEdit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  AppButton(
                    label: 'Modifier la tâche'.tr,
                    icon: Icons.edit_outlined,
                    onPressed: () => controller.toggleEditMode(),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    label: Text(
                      'Supprimer cette tâche'.tr,
                      style: AppTextStyles.buttonDestructive,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MODE ÉDITION (MODIFICATION OU NOUVELLE TÂCHE)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildEditView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Statut de la tâche ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'STATUT DE LA TÂCHE'.tr,
              style: AppTextStyles.iosCaption2,
            ),
          ),
          Obx(
            () => IosSegmentedControl<String>(
              segments: {
                'a_faire': 'À faire'.tr,
                'en_cours': 'En cours'.tr,
                'fait': 'Terminée'.tr,
              },
              selectedValue: controller.statut.value,
              onValueChanged: (s) => controller.statut.value = s,
            ),
          ),
          const SizedBox(height: 12),

          // ── Priorité Segmented Control iOS ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('PRIORITÉ'.tr, style: AppTextStyles.iosCaption2),
          ),
          Obx(
            () => IosSegmentedControl<String>(
              segments: {
                'haute': 'Haute'.tr,
                'normale': 'Normale'.tr,
                'basse': 'Basse'.tr,
              },
              selectedValue: controller.priorite.value,
              onValueChanged: (p) => controller.priorite.value = p,
            ),
          ),
          const SizedBox(height: 12),

          // ── Détails principaux ──
          IosCard(
            title: 'Informations'.tr,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Titre de la tâche *'.tr,
                      hintText: 'Ex: Rédiger le bilan psychologique'.tr,
                      controller: _titreCtrl,
                      onChanged: (v) => controller.titre.value = v,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Description'.tr,
                      hintText: 'Préciser les consignes ou observations...'.tr,
                      maxLines: 4,
                      controller: _descCtrl,
                      onChanged: (v) => controller.description.value = v,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Assignation Employé ──
          Obx(
            () => IosCard(
              title: 'Assignation'.tr,
              subtitle: controller.hasAssignPermission
                  ? 'Professionnel en charge de cette action'.tr
                  : 'Tâche personnelle assignée à vous-même'.tr,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Builder(
                    builder: (_) {
                      if (!controller.hasAssignPermission) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assignée à vous-même'.tr,
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Cette tâche fonctionne comme votre todo-list personnelle.'.tr,
                                      style: AppTextStyles.bodySmall
                                          .copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (controller.employeesStatus.value == 'loading') {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      return SearchablePickerField<dynamic>(
                        label: 'Assigner à'.tr,
                        hintText: 'Sélectionner un praticien...'.tr,
                        title: 'Assigner la tâche à'.tr,
                        leadingIcon: Icons.badge_outlined,
                        selectedValue: controller.assigneA.value,
                        items: controller.availableEmployees.map((emp) {
                          return SearchableItem<dynamic>(
                            value: emp.id,
                            label: emp.fullName,
                            subtitle: emp.roleLabel,
                            initials: emp.initials,
                          );
                        }).toList(),
                        onSingleChanged: (val) => controller.assigneA.value = val,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Lien Patient Optionnel ──
          IosCard(
            title: 'Patient Lié (Optionnel)'.tr,
            subtitle: 'Associer cette tâche à un suivi clinique'.tr,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  return SearchablePickerField<dynamic>(
                    label: 'Patient concerné'.tr,
                    hintText: 'Rechercher et associer un patient...'.tr,
                    title: 'Associer un patient'.tr,
                    leadingIcon: Icons.person_search_rounded,
                    selectedValue: controller.patientId.value,
                    items: controller.availablePatients.map((p) {
                      return SearchableItem<dynamic>(
                        value: p.id,
                        label: p.fullName,
                        subtitle:
                            '${p.age != null ? "${p.age} ${'ans'.tr} \u200E•\u200E " : ""}${p.isFille ? "Fille".tr : "Garçon".tr}',
                        initials: p.initials,
                      );
                    }).toList(),
                    onSingleChanged: (val) => controller.patientId.value = val,
                  );
                }),
              ),
            ],
          ),

          // ── Échéance ──
          IosCard(
            title: 'Échéance'.tr,
            children: [
              IosCardTile(
                leading: const Icon(
                  Icons.event_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                title: 'Date d\'échéance'.tr,
                subtitle: controller.dateEcheance.value.isEmpty
                    ? 'Aucune date fixée'.tr
                    : controller.dateEcheance.value,
                showChevron: true,
                onTap: () => _pickDate(context),
              ),
            ],
          ),

          // ── Bouton Enregistrer & Supprimer ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                AppButton(
                  label: controller.isNew
                      ? 'Créer la tâche'.tr
                      : 'Mettre à jour la tâche'.tr,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () => controller.saveTache(),
                ),
                if (!controller.isNew) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => controller.toggleEditMode(),
                    child: Text(
                      'Annuler l\'édition'.tr,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    label: Text(
                      'Supprimer cette tâche'.tr,
                      style: AppTextStyles.buttonDestructive,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final initial = controller.dateEcheance.value.isNotEmpty
        ? DateTime.tryParse(controller.dateEcheance.value) ?? DateTime.now()
        : DateTime.now().add(const Duration(days: 7));
    final picked = await AppDatePicker.show(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      controller.dateEcheance.value =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _confirmDelete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Supprimer la tâche'.tr),
        content: Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'.tr),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler'.tr),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteTache();
            },
            child: Text('Supprimer'.tr),
          ),
        ],
      ),
    );
  }
}
