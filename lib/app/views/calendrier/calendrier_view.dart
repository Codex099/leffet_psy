import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/calendrier_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/ios_segmented_control.dart';
import '../../widgets/state_placeholder.dart';

class CalendrierView extends GetView<CalendrierController> {
  const CalendrierView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      appBar: CreativeAppBar(
        title: 'Calendrier Administratif',
        subtitle: 'Événements & Réunions',
        showBackButton: true,
        actions: [
          BouncyTap(
            onTap: () => _showAddDialog(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Control (Liste / Calendrier)
            Obx(() => IosSegmentedControl<String>(
                  segments: const {
                    'Liste': 'Liste des événements',
                    'Calendrier': 'Vue Calendrier',
                  },
                  selectedValue: controller.activeTab.value,
                  onValueChanged: (tab) => controller.activeTab.value = tab,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                )),

            // Content List or Empty placeholder
            Expanded(
              child: Obx(() {
                if (controller.status.value == 'loading') {
                  return StatePlaceholder.loading();
                }
                if (controller.status.value == 'error') {
                  return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadEvenements(),
                  );
                }
                if (controller.status.value == 'empty') {
                  return StatePlaceholder.empty(
                    title: 'Aucun événement planifié',
                    message: 'Ajoutez un événement pour organiser le calendrier clinique.',
                    actionLabel: '+ Nouvel événement',
                    onAction: () => _showAddDialog(context),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 120),
                  itemCount: controller.evenements.length,
                  itemBuilder: (context, index) {
                    final ev = controller.evenements[index];
                    return IosCard(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      children: [
                        IosCardTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.event_note_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          title: ev.titre,
                          subtitle: "${ev.date}${ev.description != null && ev.description!.isNotEmpty ? ' · ${ev.description}' : ''}",
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                onPressed: () => _showAddDialog(context, ev),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                                onPressed: () => _confirmDelete(context, ev.id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic id) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Supprimer l\'événement'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet événement du calendrier clinique ?'),
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
              controller.deleteEvenement(id);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, [dynamic ev]) {
    controller.resetForm(ev);
    final formKey = GlobalKey<FormState>();
    final titreTextCtrl = TextEditingController(text: controller.titre.value);
    final descTextCtrl = TextEditingController(text: controller.description.value);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.iosSystemGray4,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ev != null ? 'Modifier l\'événement' : 'Nouvel événement',
                  style: AppTextStyles.iosTitle2,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Titre de l\'événement *',
                  hintText: 'Ex: Réunion d\'équipe pluridisciplinaire',
                  controller: titreTextCtrl,
                  onChanged: (v) => controller.titre.value = v,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Le titre est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Description',
                  hintText: 'Détails ou ordre du jour...',
                  controller: descTextCtrl,
                  maxLines: 3,
                  onChanged: (v) => controller.description.value = v,
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text('Date de l\'événement *', style: AppTextStyles.fieldLabel),
                ),
                Obx(() => InkWell(
                      onTap: () async {
                        final initial = DateTime.tryParse(controller.date.value) ?? DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initial,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          controller.date.value =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.date.value.isEmpty
                                  ? 'Sélectionner la date'
                                  : controller.date.value,
                              style: AppTextStyles.fieldValue,
                            ),
                            const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rappel (jours avant)', style: AppTextStyles.fieldLabel),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                          onPressed: () {
                            if (controller.notifierJours.value > 1) {
                              controller.notifierJours.value--;
                            }
                          },
                        ),
                        Obx(() => Text(
                              '${controller.notifierJours.value} j',
                              style: AppTextStyles.iosHeadline,
                            )),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                          onPressed: () => controller.notifierJours.value++,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: ev != null ? 'Mettre à jour' : 'Enregistrer',
                  onPressed: () async {
                    if (formKey.currentState?.validate() == true) {
                      final success = await controller.saveEvenement();
                      if (success) Get.back();
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
