import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/creation_seance_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/ios_segmented_control.dart';
import '../../widgets/searchable_picker.dart';
import '../../widgets/state_placeholder.dart';

class CreationSeanceView extends GetView<CreationSeanceController> {
  const CreationSeanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const CreativeAppBar(
        title: 'Planifier une séance',
        subtitle: 'Consultation Clinique',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.status.value == 'loading' && controller.patients.isEmpty) {
            return StatePlaceholder.loading(message: 'Chargement des options de séance...');
          }
          if (controller.status.value == 'error') {
            return StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadOptions(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 12, bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Type de séance (Segmented Control iOS) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text('TYPE DE SÉANCE', style: AppTextStyles.iosCaption2),
                ),
                Obx(() => IosSegmentedControl<String>(
                      segments: const {
                        'individuelle': 'Individuelle',
                        'groupe': 'Collectif (Groupe)',
                      },
                      selectedValue: controller.typeSeance.value,
                      onValueChanged: (t) => controller.typeSeance.value = t,
                    )),
                const SizedBox(height: 12),

                // ── Bénéficiaire (Patient ou Groupe) ──
                Obx(() {
                  final isIndiv = controller.typeSeance.value == 'individuelle';
                  return IosCard(
                    title: isIndiv ? 'Patient' : 'Groupe Clinique',
                    subtitle: isIndiv
                        ? 'Recherchez et sélectionnez le patient suivi'
                        : 'Recherchez et sélectionnez le groupe concerné',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: isIndiv
                            ? _buildPatientPicker()
                            : _buildGroupePicker(),
                      ),
                    ],
                  );
                }),

                // ── Date et Horaires ──
                IosCard(
                  title: 'Date & Horaires',
                  children: [
                    IosCardTile(
                      leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                      title: 'Date de la séance',
                      subtitle: controller.date.value.isEmpty ? 'Sélectionner' : controller.date.value,
                      showChevron: true,
                      onTap: () => _pickDate(context),
                    ),
                    IosCardTile(
                      leading: const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                      title: 'Horaire de début',
                      subtitle: controller.heureDebut.value,
                      showChevron: true,
                      onTap: () => _pickTime(context, isStart: true),
                    ),
                    IosCardTile(
                      leading: const Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                      title: 'Horaire de fin',
                      subtitle: controller.heureFin.value,
                      showChevron: true,
                      onTap: () => _pickTime(context, isStart: false),
                    ),
                  ],
                ),

                // ── Psychologues / Praticiens assignés ──
                IosCard(
                  title: 'Praticiens Responsables',
                  subtitle: 'Sélectionnez un ou plusieurs professionnels avec recherche instantanée',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Obx(() {
                        if (controller.employees.isEmpty) {
                          return Text('Aucun praticien disponible.', style: AppTextStyles.iosFootnote);
                        }
                        return SearchablePickerField<dynamic>(
                          label: 'Praticiens Assignés',
                          hintText: 'Rechercher et sélectionner les praticiens...',
                          title: 'Sélectionner les Praticiens',
                          isMultiSelect: true,
                          leadingIcon: Icons.badge_outlined,
                          selectedValues: controller.selectedEmployeeIds.toList(),
                          items: controller.employees.map((emp) {
                            return SearchableItem<dynamic>(
                              value: emp.id,
                              label: emp.fullName,
                              subtitle: emp.roleLabel,
                              initials: emp.initials,
                            );
                          }).toList(),
                          onMultiChanged: (vals) {
                            controller.selectedEmployeeIds.assignAll(vals);
                          },
                        );
                      }),
                    ),
                  ],
                ),

                // ── Bouton de confirmation ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: AppButton(
                    label: 'Planifier la séance',
                    icon: Icons.event_available_rounded,
                    onPressed: () => controller.createSeance(),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPatientPicker() {
    if (controller.patients.isEmpty) {
      return Text('Aucun patient actif disponible.', style: AppTextStyles.iosFootnote);
    }
    return SearchablePickerField<dynamic>(
      label: 'Patient concerné *',
      hintText: 'Rechercher un patient par nom ou prénom...',
      title: 'Sélectionner un patient',
      leadingIcon: Icons.person_search_rounded,
      selectedValue: controller.selectedPatientId.value,
      items: controller.patients.map((p) {
        return SearchableItem<dynamic>(
          value: p.id,
          label: p.fullName,
          subtitle: '${p.age != null ? "${p.age} ans • " : ""}${p.isFille ? "Fille" : "Garçon"}',
          initials: p.initials,
        );
      }).toList(),
      onSingleChanged: (val) {
        if (val != null) controller.selectedPatientId.value = val;
      },
    );
  }

  Widget _buildGroupePicker() {
    if (controller.groupes.isEmpty) {
      return Text('Aucun groupe disponible.', style: AppTextStyles.iosFootnote);
    }
    return SearchablePickerField<dynamic>(
      label: 'Groupe concerné *',
      hintText: 'Rechercher un groupe thérapeutique...',
      title: 'Sélectionner un groupe',
      leadingIcon: Icons.groups_rounded,
      selectedValue: controller.selectedGroupeId.value,
      items: controller.groupes.map((g) {
        return SearchableItem<dynamic>(
          value: g.id,
          label: g.nom,
          subtitle: '${g.typeLabel} • ${g.membresCount} membre(s)',
          initials: g.initials,
        );
      }).toList(),
      onSingleChanged: (val) {
        if (val != null) controller.selectedGroupeId.value = val;
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final initial = DateTime.tryParse(controller.date.value) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.date.value =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _pickTime(BuildContext context, {required bool isStart}) async {
    final currentStr = isStart ? controller.heureDebut.value : controller.heureFin.value;
    final parts = currentStr.split(':');
    final initialTime = TimeOfDay(
      hour: parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 10) : 10,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      if (isStart) {
        controller.heureDebut.value = formatted;
      } else {
        controller.heureFin.value = formatted;
      }
    }
  }
}
