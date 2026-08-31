import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/detail_tache_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/ios_segmented_control.dart';
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
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: controller.isNew ? 'Nouvelle Tâche'.tr : 'Détail de la Tâche',
       subtitle: 'Action Clinique'.tr,
       showBackButton: true,
      ),
      body: Obx(() {
        if (controller.status.value == 'loading' &&
           !controller.isNew &&
            controller.titre.value.isEmpty) {
          return StatePlaceholder.loading(
            message: 'Chargement de la tâche...',
         );
        }
        if (controller.status.value == 'error') {
         return StatePlaceholder.error(
            message: controller.errorMessage.value,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // ── Statut de la tâche (Segmented Control iOS) ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
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
                     'fait': 'Terminée',
                   },
                    selectedValue: controller.statut.value,
                    onValueChanged: (s) => controller.statut.value = s,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Priorité Segmented Control iOS ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Text('PRIORITÉ'.tr, style: AppTextStyles.iosCaption2),
               ),
                Obx(
                  () => IosSegmentedControl<String>(
                    segments: {
                      'haute': 'Haute'.tr,
                     'normale': 'Normale'.tr,
                     'basse': 'Basse',
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
                           hintText:
                                'Préciser les consignes ou observations...'.tr,
                           maxLines: 4,
                            controller: _descCtrl,
                            onChanged: (v) => controller.description.value = v,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Assignation Employé (US-M37) ──
                IosCard(
                  title: 'Assignation'.tr,
                 subtitle: 'Professionnel en charge de cette action'.tr,
                 children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Obx(() {
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
                          onSingleChanged: (val) =>
                              controller.assigneA.value = val,
                        );
                      }),
                    ),
                  ],
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
                          onSingleChanged: (val) =>
                              controller.patientId.value = val,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
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
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final initial = controller.dateEcheance.value.isNotEmpty
        ? DateTime.tryParse(controller.dateEcheance.value) ?? DateTime.now()
        : DateTime.now().add(const Duration(days: 7));
    final picked = await showDatePicker(
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
