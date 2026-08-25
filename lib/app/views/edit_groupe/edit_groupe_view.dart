import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_groupe_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/json_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/searchable_picker.dart';

class EditGroupeView extends StatefulWidget {
  const EditGroupeView({super.key});

  @override
  State<EditGroupeView> createState() => _EditGroupeViewState();
}

class _EditGroupeViewState extends State<EditGroupeView> {
  final controller = Get.find<EditGroupeController>();
  late final TextEditingController _nomCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: controller.nom.value);
    _descCtrl = TextEditingController(text: controller.description.value);

    ever(controller.nom, (v) {
      if (_nomCtrl.text != v) _nomCtrl.text = v;
    });
    ever(controller.description, (v) {
      if (_descCtrl.text != v) _descCtrl.text = v;
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = controller.groupeId != null;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: isEditMode ? 'Modifier le Groupe' : 'Nouveau Groupe',
        subtitle: 'Atelier Thérapeutique',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Infos générales ──
              _card(children: [
                Text('Informations générales', style: AppTextStyles.sectionTitle),
                Text('Nom et description du groupe', style: AppTextStyles.bodySmall),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Nom du groupe *',
                  hintText: 'Ex: Groupe Compétences sociales',
                  controller: _nomCtrl,
                  onChanged: (v) => controller.nom.value = v,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Description',
                  hintText: 'Description du groupe...',
                  maxLines: 3,
                  controller: _descCtrl,
                  onChanged: (v) => controller.description.value = v,
                ),
              ]),
              const SizedBox(height: 16),

              // ── Type de groupe ──
              _card(children: [
                Text('Type de groupe', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 14),
                Obx(() => Row(
                      children: [
                        Expanded(child: _buildTypeTile('fixe', 'Fixe')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTypeTile('ponctuel', 'Ponctuel')),
                      ],
                    )),
              ]),
              const SizedBox(height: 16),

              // ── Planning récurrent multi-créneaux ──
              _card(children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Planning récurrent', style: AppTextStyles.sectionTitle),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Sélectionnez les jours, puis ajustez les créneaux horaires.',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 12),

                // Chips jours de la semaine
                Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        EditGroupeController.allDays.length,
                        (i) => _buildDayChip(
                          EditGroupeController.allDays[i],
                          EditGroupeController.allDayLabels[i],
                        ),
                      ),
                    )),
                const SizedBox(height: 12),

                // Créneaux par jour
                Obx(() {
                  if (controller.daySlots.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  // Grouper par jour dans l'ordre
                  final activeDays = EditGroupeController.allDays
                      .where((d) => controller.isDayActive(d))
                      .toList();
                  return Column(
                    children: activeDays.map((day) {
                      final label = EditGroupeController.allDayLabels[
                          EditGroupeController.allDays.indexOf(day)];
                      final slots = controller.slotsForDay(day);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(label,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(fontWeight: FontWeight.bold)),
                                TextButton.icon(
                                  onPressed: () => controller.addSlotForDay(day),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Créneau'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...slots.map((slot) => _buildSlotRow(context, slot)),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),
              ]),
              const SizedBox(height: 16),

              // ── Employés assignés (SearchablePickerField multi-sélection) ──
              _card(children: [
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Professionnels assignés', style: AppTextStyles.sectionTitle),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Sélectionnez les intervenants avec recherche instantanée',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.employeesStatus.value == 'loading') {
                    return const SizedBox(
                      height: 60,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  if (controller.availableEmployees.isEmpty) {
                    return Text('Aucun professionnel disponible',
                        style: AppTextStyles.bodySmall);
                  }
                  return SearchablePickerField<dynamic>(
                    label: 'Intervenants',
                    hintText: 'Rechercher et assigner des professionnels...',
                    title: 'Intervenants du Groupe',
                    isMultiSelect: true,
                    leadingIcon: Icons.badge_outlined,
                    selectedValues: controller.selectedEmployeeIds.toList(),
                    items: controller.availableEmployees.map((emp) {
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
              ]),
              const SizedBox(height: 16),

              // ── Patients inscrits (US-M22) ──
              _card(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Patients inscrits', style: AppTextStyles.sectionTitle),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => _showPatientPickerSheet(context),
                      icon: const Icon(Icons.person_add_alt_outlined, size: 16),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.groupePatients.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Aucun patient dans ce groupe.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: controller.groupePatients.map((p) {
                      final name =
                          '${p['prenom'] ?? ''} ${p['nom'] ?? ''}'.trim();
                      final id = parseId(p['id'] ?? p['patient_id']);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.secondaryLight,
                                child: Icon(Icons.person, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(name.isEmpty ? 'Patient #$id' : name,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(fontWeight: FontWeight.w600)),
                              ),
                              if (controller.groupeId != null)
                                IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      color: AppColors.error, size: 20),
                                  onPressed: () =>
                                      controller.removePatientFromGroupe(id),
                                  tooltip: 'Retirer du groupe',
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ]),
              const SizedBox(height: 24),

              // ── Bouton Save ──
              Obx(() => AppButton(
                    label: controller.status.value == 'loading'
                        ? 'Enregistrement...'
                        : isEditMode
                            ? 'Mettre à jour le groupe'
                            : 'Créer le groupe',
                    isLoading: controller.status.value == 'loading',
                    onPressed: controller.status.value == 'loading'
                        ? null
                        : () => controller.saveGroupe(),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets helpers ──

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildTypeTile(String value, String label) {
    final isSelected = controller.typePlanning.value == value;
    return InkWell(
      onTap: () => controller.typePlanning.value = value,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(String value, String label) {
    final isSelected = controller.isDayActive(value);
    return InkWell(
      onTap: () => controller.toggleDay(value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.badge.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// Ligne d'un créneau avec heure début, fin, et bouton supprimer
  Widget _buildSlotRow(BuildContext context, DaySlot slot) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: _timePicker(
              context,
              label: 'Début',
              value: slot.heureDebut,
              onPicked: (v) => controller.updateSlotStart(slot, v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _timePicker(
              context,
              label: 'Fin',
              value: slot.heureFin,
              onPicked: (v) => controller.updateSlotEnd(slot, v),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: () => controller.removeSlot(slot),
            tooltip: 'Supprimer ce créneau',
          ),
        ],
      ),
    );
  }

  Widget _timePicker(BuildContext context,
      {required String label,
      required String value,
      required ValueChanged<String> onPicked}) {
    final parts = value.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: initial,
          builder: (ctx, child) =>
              MediaQuery(data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true), child: child!),
        );
        if (picked != null) {
          onPicked(
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.fieldLabel.copyWith(fontSize: 10)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
            const Icon(Icons.access_time_rounded,
                size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _showPatientPickerSheet(BuildContext context) {
    final unassigned = controller.allPatients
        .where((p) => !controller.isPatientInGroupe(p.id))
        .toList();
    if (unassigned.isEmpty) {
      Get.snackbar('Info', 'Tous les patients actifs sont déjà dans ce groupe.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    SearchablePicker.showMulti<dynamic>(
      context: context,
      title: 'Ajouter des patients au groupe',
      items: unassigned.map((p) => SearchableItem<dynamic>(
        value: p.id,
        label: p.fullName,
        subtitle: '${p.age != null ? "${p.age} ans • " : ""}${p.isFille ? "Fille" : "Garçon"}',
        initials: p.initials,
      )).toList(),
      initialSelected: [],
      onConfirm: (selectedPatientIds) {
        if (selectedPatientIds.isNotEmpty) {
          controller.addPatientsToGroupe(selectedPatientIds);
        }
      },
    );
  }
}
