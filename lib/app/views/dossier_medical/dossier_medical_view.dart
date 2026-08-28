import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dossier_medical_controller.dart';
import '../../models/dossier_medical_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_placeholder.dart';

class DossierMedicalView extends GetView<DossierMedicalController> {
  const DossierMedicalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Obx(() {
        if (controller.status.value == 'loading') {
          return const SafeArea(child: StatePlaceholder(type: StatePlaceholderType.loading));
        }
        if (controller.status.value == 'error') {
          return SafeArea(
            child: StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadDossier(),
            ),
          );
        }

        final d = controller.dossier.value;

        return controller.isEditing.value
            ? _buildEditView(context, d)
            : _buildReadView(context, d);
      }),
    );
  }

  // ─── READ VIEW ────────────────────────────────────────────────────────────────

  Widget _buildReadView(BuildContext context, DossierMedicalModel? d) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Column(
                      children: [
                        Text(
                          'FICHE CLINIQUE',
                          style: AppTextStyles.sectionKicker.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          'Dossier médical',
                          style: AppTextStyles.screenTitleMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.white),
                      tooltip: 'Modifier',
                      onPressed: () => controller.isEditing.value = true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.medical_information_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations médicales complètes',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                            ),
                            if (d?.dateMaj != null)
                              Text(
                                'Mis à  jour le ${d!.dateMaj}${d.misAJourPar != null ? " par ${d.misAJourPar}" : ""}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              )
                            else
                              Text(
                                'Aucune mise à  jour enregistrée',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sections de contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Section 1 : Antécédents & Traitements
                _buildInfoSection(
                  icon: Icons.history_edu_rounded,
                  title: 'Antécédents & Traitements',
                  color: const Color(0xFF1565C0),
                  colorBg: const Color(0xFFE3F2FD),
                  items: [
                    _InfoItem(
                      label: 'Antécédents médicaux',
                      value: d?.antecedentsMedicaux,
                      icon: Icons.medical_services_outlined,
                    ),
                    _InfoItem(
                      label: 'Médicaments pris',
                      value: d?.medicamentsPris,
                      icon: Icons.medication_outlined,
                    ),
                    _InfoItem(
                      label: 'Date du cas',
                      value: d?.dateCas,
                      icon: Icons.calendar_today_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Section 2 : Développement
                _buildInfoSection(
                  icon: Icons.child_care_rounded,
                  title: 'Développement',
                  color: const Color(0xFF2E7D32),
                  colorBg: const Color(0xFFE8F5E9),
                  items: [
                    _InfoItem(
                      label: 'Date de naissance',
                      value: d?.dateNaissance,
                      icon: Icons.cake_outlined,
                    ),
                    _InfoItem(
                      label: 'Naissance',
                      value: d?.naissance,
                      icon: Icons.pregnant_woman_outlined,
                    ),
                    _InfoItem(
                      label: 'Nombre de frères/sÅ“urs',
                      value: d?.nombreFreresSoeurs?.toString(),
                      icon: Icons.people_alt_outlined,
                    ),
                    _InfoItem(
                      label: 'Rang dans la fratrie',
                      value: d?.rangFratrie?.toString(),
                      icon: Icons.format_list_numbered_rounded,
                    ),
                    _InfoItem(
                      label: 'Développement psychomoteur',
                      value: d?.developpementPsychomoteur,
                      icon: Icons.directions_run_rounded,
                    ),
                    _InfoItem(
                      label: 'Développement langagier',
                      value: d?.developpementLangagier,
                      icon: Icons.record_voice_over_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Section 3 : Comportement & Social
                _buildInfoSection(
                  icon: Icons.people_outline_rounded,
                  title: 'Comportement & Social',
                  color: const Color(0xFF6A1B9A),
                  colorBg: const Color(0xFFF3E5F5),
                  items: [
                    _InfoItem(
                      label: 'Comportement auditif',
                      value: d?.comportementAuditif,
                      icon: Icons.hearing_outlined,
                    ),
                    _InfoItem(
                      label: 'Adaptation sociale',
                      value: d?.adaptationSociale,
                      icon: Icons.group_outlined,
                    ),
                    _InfoItem(
                      label: 'Autonomie',
                      value: d?.autonomie,
                      icon: Icons.self_improvement_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Section 4 : Santé & Scolarisation
                _buildInfoSection(
                  icon: Icons.school_rounded,
                  title: 'Santé & Scolarisation',
                  color: const Color(0xFFE65100),
                  colorBg: const Color(0xFFFBE9E7),
                  items: [
                    _InfoItem(
                      label: 'Aspect sanitaire',
                      value: d?.aspectSanitaire,
                      icon: Icons.health_and_safety_outlined,
                    ),
                    _InfoItem(
                      label: 'Stade de scolarisation',
                      value: d?.stadeScolarisation,
                      icon: Icons.menu_book_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required Color color,
    required Color colorBg,
    required List<_InfoItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: AppTextStyles.sectionTitle.copyWith(color: color)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildInfoRow(item, color),
                    if (i < items.length - 1) ...[
                      const SizedBox(height: 4),
                      Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 4),
                    ],
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item, Color accentColor) {
    final bool hasValue = item.value != null && item.value!.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 16, color: accentColor.withValues(alpha: 0.7)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: AppTextStyles.fieldLabel),
                const SizedBox(height: 3),
                hasValue
                    ? Text(item.value!, style: AppTextStyles.body.copyWith(height: 1.5))
                    : Text(
                        'Non renseigné',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── EDIT VIEW ────────────────────────────────────────────────────────────────

  Widget _buildEditView(BuildContext context, DossierMedicalModel? d) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header édition
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () {
                    controller.isEditing.value = false;
                    controller.loadDossier();
                  },
                ),
                Column(
                  children: [
                    Text(
                      'MODIFICATION',
                      style: AppTextStyles.sectionKicker.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'Dossier médical',
                      style: AppTextStyles.screenTitleMedium.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Formulaire
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      // ── Antécédents & Traitements ──
                      _buildEditSectionHeader(
                        icon: Icons.history_edu_rounded,
                        label: 'Antécédents & Traitements',
                      ),
                      AppTextField(
                        label: 'Antécédents médicaux',
                        hintText: 'Antécédents du patient...',
                        controller: controller.antecedentsController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Médicaments pris',
                        hintText: 'Traitements en cours...',
                        controller: controller.medicamentsController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      // ── Date du cas (DatePicker) ──
                      _buildDatePickerField(
                        context: context,
                        label: 'Date du cas',
                        controller: controller.dateCasController,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      ),
                      const SizedBox(height: 24),

                      // ── Développement ──
                      _buildEditSectionHeader(
                        icon: Icons.child_care_rounded,
                        label: 'Développement',
                      ),
                      // ── Date de naissance (DatePicker) ──
                      _buildDatePickerField(
                        context: context,
                        label: 'Date de naissance',
                        controller: controller.dateNaissanceController,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Naissance',
                        hintText: 'Conditions de naissance...',
                        controller: controller.naissanceController,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Nb frères/sÅ“urs',
                              hintText: 'Ex: 2',
                              controller: controller.nombreFreresSoeursController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Rang dans la fratrie',
                              hintText: 'Ex: 1',
                              controller: controller.rangFratrieController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Développement psychomoteur',
                        hintText: 'Marche, motricité...',
                        controller: controller.devPsychomoteurController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Développement langagier',
                        hintText: 'Vocabulaire, compréhension...',
                        controller: controller.devLangagierController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // ── Comportement & Social ──
                      _buildEditSectionHeader(
                        icon: Icons.people_outline_rounded,
                        label: 'Comportement & Social',
                      ),
                      AppTextField(
                        label: 'Comportement auditif',
                        hintText: 'Réactions aux sons...',
                        controller: controller.compAuditifController,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Adaptation sociale',
                        hintText: 'Relations avec les pairs...',
                        controller: controller.adaptationSocialeController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Autonomie',
                        hintText: 'Habillage, hygiène...',
                        controller: controller.autonomieController,
                      ),
                      const SizedBox(height: 24),

                      // ── Santé & Scolarisation ──
                      _buildEditSectionHeader(
                        icon: Icons.school_rounded,
                        label: 'Santé & Scolarisation',
                      ),
                      AppTextField(
                        label: 'Aspect sanitaire',
                        hintText: 'État général...',
                        controller: controller.aspectSanitaireController,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Stade de scolarisation',
                        hintText: 'Classe / Établissement...',
                        controller: controller.stadeScolarisationController,
                      ),
                      const SizedBox(height: 16),
                      if (d?.misAJourPar != null)
                        Text(
                          'Mis à  jour par ${d!.misAJourPar} le ${d.dateMaj ?? ""}',
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Enregistrer le dossier',
                  onPressed: () => controller.saveDossier(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditSectionHeader({required IconData icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.sectionTitle),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // Parse la valeur actuelle pour pré-sélectionner la date dans le picker
            DateTime initialDate;
            try {
              initialDate = controller.text.isNotEmpty
                  ? DateTime.parse(controller.text)
                  : DateTime.now();
              if (initialDate.isBefore(firstDate)) initialDate = firstDate;
              if (initialDate.isAfter(lastDate)) initialDate = lastDate;
            } catch (_) {
              initialDate = DateTime.now();
            }

            final picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              locale: const Locale('fr', 'FR'),
            );
            if (picked != null) {
              controller.text =
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.fieldBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListenableBuilder(
                    listenable: controller,
                    builder: (_, _) => Text(
                      controller.text.isNotEmpty
                          ? controller.text
                          : 'Sélectionner une date',
                      style: AppTextStyles.body.copyWith(
                        color: controller.text.isNotEmpty
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                ),
                Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Helper model interne pour un champ d'info en lecture
class _InfoItem {
  final String label;
  final String? value;
  final IconData icon;
  const _InfoItem({required this.label, required this.value, required this.icon});
}
