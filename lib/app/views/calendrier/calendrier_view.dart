import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/calendrier_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/state_placeholder.dart';


class CalendrierView extends GetView<CalendrierController> {
  const CalendrierView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
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
                      Text('GESTION CLINIQUE', style: AppTextStyles.sectionKicker),
                      Text('Calendrier administratif', style: AppTextStyles.screenTitleMedium),
                      Text('Événements de la clinique', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mode tabs (Liste / Calendrier)
              Obx(() => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildTab('Liste')),
                        Expanded(child: _buildTab('Calendrier')),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),

              // Content List or Form or Empty placeholder
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
                      actionLabel: '+ Ajouter un événement',
                      onAction: () => _showAddDialog(context),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.evenements.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ev = controller.evenements[index];
                      return _buildEvenementCard(context, ev);
                    },

                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String tab) {
    final isSelected = controller.activeTab.value == tab;
    return InkWell(
      onTap: () => controller.activeTab.value = tab,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            tab,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEvenementCard(BuildContext context, dynamic ev) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ev.titre, style: AppTextStyles.cardName),
                const SizedBox(height: 4),
                Text(ev.date, style: AppTextStyles.bodySmall),
                if (ev.description != null && ev.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(ev.description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
            onPressed: () => _showAddDialog(context, ev),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
            onPressed: () => controller.deleteEvenement(ev.id),
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
        padding: const EdgeInsets.all(20),
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
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ev != null ? 'Modifier l\'événement' : 'Nouvel événement',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titreTextCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    hintText: 'Ex: Réunion d\'équipe',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => controller.titre.value = v,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Le titre est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descTextCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Détails de la réunion...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (v) => controller.description.value = v,
                ),
                const SizedBox(height: 12),
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.date.value.isEmpty ? 'Sélectionner la date *' : 'Date : ${controller.date.value}',
                              style: AppTextStyles.bodyMedium,
                            ),
                            const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rappel (jours avant)', style: AppTextStyles.fieldLabel),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (controller.notifierJours.value > 1) {
                              controller.notifierJours.value--;
                            }
                          },
                        ),
                        Obx(() => Text('${controller.notifierJours.value}', style: AppTextStyles.bodyMedium)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => controller.notifierJours.value++,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: ev != null ? 'Mettre à jour' : 'Enregistrer',
                  onPressed: () async {
                    if (formKey.currentState?.validate() == true) {
                      final success = await controller.saveEvenement();
                      if (success) Get.back();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

