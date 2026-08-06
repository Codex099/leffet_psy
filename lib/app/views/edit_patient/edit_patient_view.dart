import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_patient_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class EditPatientView extends GetView<EditPatientController> {
  const EditPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ADMIN', style: AppTextStyles.sectionKicker),
                      Text(
                        controller.patientId == null
                            ? 'Nouveau patient'
                            : 'Édition patient',
                        style: AppTextStyles.screenTitleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Step Tabs ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Row(
                      children: [
                        _buildStepTab('Perso', 1),
                        _buildStepTab('Médical', 2),
                        _buildStepTab('Tuteur', 3),
                        _buildStepTab('Fin', 4),
                      ],
                    ),
                  )),
            ),
            const SizedBox(height: 16),

            // ── Step Content ──
            Expanded(
              child: Obx(() {
                switch (controller.currentStep.value) {
                  case 1:
                    return _buildStep1(context);
                  case 2:
                    return _buildStep2(context);
                  case 3:
                    return _buildStep3(context);
                  case 4:
                    return _buildStep4();
                  default:
                    return _buildStep1(context);
                }
              }),
            ),


            // ── Nav Buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Obx(() => Row(
                    children: [
                      if (controller.currentStep.value > 1) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => controller.previousStep(),
                            child: const Text('Précédent'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          label: controller.status.value == 'loading'
                              ? 'En cours...'
                              : controller.currentStep.value == 4
                                  ? 'Terminer'
                                  : 'Suivant',
                          isLoading: controller.status.value == 'loading',
                          onPressed: controller.status.value == 'loading'
                              ? null
                              : () => controller.nextStep(),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 1 — Informations personnelles ──
  Widget _buildStep1(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo section
          Center(
            child: Obx(() => Stack(
                  children: [
                    controller.pickedPhoto.value != null
                        ? CircleAvatar(
                            radius: 48,
                            backgroundImage:
                                FileImage(controller.pickedPhoto.value!),
                          )
                        : controller.photoUrl.value.isNotEmpty
                            ? CircleAvatar(
                                radius: 48,
                                backgroundImage:
                                    NetworkImage(controller.photoUrl.value),
                              )
                            : const CircleAvatar(
                                radius: 48,
                                backgroundColor: AppColors.secondaryLight,
                                child: Icon(Icons.person_rounded,
                                    size: 48, color: AppColors.primary),
                              ),
                    if (controller.photoUploading.value)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => _showPhotoOptions(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          const SizedBox(height: 20),

          _sectionCard(children: [
            Text('Identité', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Prénom *',
              hintText: 'Ex. Léa',
              initialValue: controller.prenom.value,
              onChanged: (v) => controller.prenom.value = v,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Nom *',
              hintText: 'Ex. Dupont',
              initialValue: controller.nom.value,
              onChanged: (v) => controller.nom.value = v,
            ),
            const SizedBox(height: 14),
            Text('Date de naissance', style: AppTextStyles.fieldLabel),
            const SizedBox(height: 8),
            Obx(() => InkWell(
                  onTap: () async {
                    final initial = DateTime.tryParse(controller.dateNaissance.value) ?? DateTime(2018, 1, 1);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      controller.dateNaissance.value =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
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
                        Text(
                          controller.dateNaissance.value.isEmpty
                              ? 'Sélectionner la date de naissance'
                              : controller.dateNaissance.value,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 14),
            Text('Sexe', style: AppTextStyles.fieldLabel),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: [
                    Expanded(child: _buildGenderTile('Garçon')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildGenderTile('Fille')),
                  ],
                )),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Nombre de frères/sœurs',
              hintText: '0',
              keyboardType: TextInputType.number,
              initialValue: controller.nombreFreresSoeurs.value,
              onChanged: (v) => controller.nombreFreresSoeurs.value = v,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Rang dans la fratrie',
              hintText: '1',
              keyboardType: TextInputType.number,
              initialValue: controller.ordreNaissance.value,
              onChanged: (v) => controller.ordreNaissance.value = v,
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── STEP 2 — Dossier médical (Informations médicales complètes) ──
  Widget _buildStep2(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card 1 : Antécédents & Traitements ──
          _sectionCard(children: [
            Row(
              children: [
                const Icon(Icons.medical_information_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Antécédents & Traitements',
                    style: AppTextStyles.sectionTitle),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Informations médicales de base et traitements actuels.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Antécédents médicaux (السوابق المرضية)',
              hintText: 'Ex. Pathologies, chirurgies, hospitalisations...',
              maxLines: 3,
              initialValue: controller.antecedentsMedicaux.value,
              onChanged: (v) => controller.antecedentsMedicaux.value = v,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Médicaments pris (الأدوية المتناولة)',
              hintText: 'Ex. Liste des traitements actuels et posologie...',
              maxLines: 3,
              initialValue: controller.medicamentsPris.value,
              onChanged: (v) => controller.medicamentsPris.value = v,
            ),
          ]),
          const SizedBox(height: 16),

          // ── Card 2 : Historique du cas ──
          _sectionCard(children: [
            Row(
              children: [
                const Icon(Icons.history_edu_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Historique du cas', style: AppTextStyles.sectionTitle),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Historique du développement, autonomie et scolarisation.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),

            // Date de la cas / historique (tاريخ الحالة)
            Text('Date du cas (تاريخ الحالة)', style: AppTextStyles.fieldLabel),
            const SizedBox(height: 6),
            Obx(() => InkWell(
                  onTap: () async {
                    final initial = controller.dateCas.value.isNotEmpty
                        ? DateTime.tryParse(controller.dateCas.value) ?? DateTime.now()
                        : DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      controller.dateCas.value =
                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.fieldBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.dateCas.value.isEmpty
                              ? 'Sélectionner la date du cas'
                              : controller.dateCas.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: controller.dateCas.value.isEmpty
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 14),

            AppTextField(
              label: 'Naissance (الولادة)',
              hintText: 'Conditions de naissance, déroulement...',
              maxLines: 2,
              initialValue: controller.naissance.value,
              onChanged: (v) => controller.naissance.value = v,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Développement psychomoteur (النمو النفسي الحركي)',
              hintText: 'Marche, motricité fine et globale...',
              maxLines: 2,
              initialValue: controller.developpementPsychomoteur.value,
              onChanged: (v) => controller.developpementPsychomoteur.value = v,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Comportement auditif (السلوك السمعي)',
              hintText: 'Réaction aux sons, écoute...',
              maxLines: 2,
              initialValue: controller.comportementAuditif.value,
              onChanged: (v) => controller.comportementAuditif.value = v,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Développement langagier (النمو اللغوي)',
              hintText: 'Premiers mots, niveau de langage...',
              maxLines: 2,
              initialValue: controller.developpementLangagier.value,
              onChanged: (v) => controller.developpementLangagier.value = v,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Adaptation sociale (التكيف الاجتماعي)',
              hintText: 'Relations sociales, comportements en groupe...',
              maxLines: 2,
              initialValue: controller.adaptationSociale.value,
              onChanged: (v) => controller.adaptationSociale.value = v,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Autonomie (الاستقلالية)',
              hintText: 'Habillage, hygiène, alimentation...',
              maxLines: 2,
              initialValue: controller.autonomie.value,
              onChanged: (v) => controller.autonomie.value = v,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Aspect sanitaire / médical (الجانب الصحي)',
              hintText: 'Bilan de santé général...',
              maxLines: 2,
              initialValue: controller.aspectSanitaire.value,
              onChanged: (v) => controller.aspectSanitaire.value = v,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Stade de scolarisation (مرحلة التمدرس)',
              hintText: 'Niveau d\'études, intégration scolaire...',
              maxLines: 2,
              initialValue: controller.stadeScolarisation.value,
              onChanged: (v) => controller.stadeScolarisation.value = v,
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── STEP 3 — Tuteur / Parent ──
  Widget _buildStep3(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tuteur légal / Parent', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 4),
                    Text('Associez un parent à ce patient.', style: AppTextStyles.bodySmall),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _showInlineParentDialog(context),
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('+ Nouveau'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Parent dropdown
            Obx(() {
              if (controller.parentsStatus.value == 'loading') {
                return const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choisir un parent', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.fieldBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: controller.selectedParentId.value,
                        isExpanded: true,
                        hint: Text('Sélectionner un parent', style: AppTextStyles.fieldHint),
                        dropdownColor: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('-- Aucun parent sélectionné --'),
                          ),
                          ...controller.availableParents.map(
                            (p) => DropdownMenuItem<int?>(
                              value: p.id,
                              child: Text(p.fullName),
                            ),
                          ),
                        ],
                        onChanged: (val) => controller.selectedParentId.value = val,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  Text('Rôle familial', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.fieldBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.roleParent.value,
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        items: EditPatientController.roleChoices
                            .map((item) => DropdownMenuItem<String>(
                                  value: item['value'],
                                  child: Text(item['label']!),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) controller.roleParent.value = val;
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── STEP 4 — Finalisation ──
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(children: [
            Text('Récapitulatif', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _recapRow('Prénom', controller.prenom.value.isNotEmpty
                        ? controller.prenom.value : '—'),
                    const Divider(),
                    _recapRow('Nom', controller.nom.value.isNotEmpty
                        ? controller.nom.value : '—'),
                    const Divider(),
                    _recapRow('Date de naissance',
                        controller.dateNaissance.value.isNotEmpty
                            ? controller.dateNaissance.value : '—'),
                    const Divider(),
                    _recapRow('Sexe', controller.sexe.value),
                    const Divider(),
                    _recapRow('Photo',
                        controller.photoUrl.value.isNotEmpty ? '✓ Ajoutée' : '—'),
                    const Divider(),
                    _recapRow('Dossier médical',
                        controller.antecedentsMedicaux.value.isNotEmpty || controller.dateCas.value.isNotEmpty ? '✓ Renseigné' : '—'),
                    const Divider(),
                    _recapRow('Parent lié',
                        controller.selectedParentId.value != null
                            ? controller.availableParents
                                .firstWhereOrNull(
                                    (p) => p.id == controller.selectedParentId.value)
                                ?.fullName ?? '—'
                            : '—'),
                  ],
                )),
          ]),
          const SizedBox(height: 16),
          _sectionCard(children: [
            Text('Plan thérapeutique', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Text('Souhaitez-vous créer un plan thérapeutique pour ce patient après l\'enregistrement ?',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),
            Obx(() => SwitchListTile(
                  value: controller.addPlanTherapeutique.value,
                  onChanged: (v) => controller.addPlanTherapeutique.value = v,
                  title: Text('Créer un plan thérapeutique',
                      style: AppTextStyles.bodyMedium),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                )),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper: step tab chip
  Widget _buildStepTab(String label, int step) {
    final isActive = controller.currentStep.value == step;
    final isDone = controller.currentStep.value > step;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : isDone
                  ? AppColors.secondary
                  : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.badge.copyWith(
              color: (isActive || isDone) ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderTile(String value) {
    final isSelected = controller.sexe.value == value;
    return InkWell(
      onTap: () => controller.sexe.value = value,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.fieldBackground,
          border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _recapRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondary)),
        ],
      ),
    );
  }

  void _showPhotoOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ajouter une photo', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Prendre une photo'),
              onTap: () {
                Get.back();
                controller.pickPhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Get.back();
                controller.pickPhoto(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInlineParentDialog(BuildContext context) {

    final formKey = GlobalKey<FormState>();
    String nom = '';
    String prenom = '';
    String tel = '';
    String role = 'pere';

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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Créer un nouveau parent', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 14),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Prénom *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Prénom requis' : null,
                  onChanged: (v) => prenom = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nom *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                  onChanged: (v) => nom = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => tel = v,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Créer et associer',
                  onPressed: () async {
                    if (formKey.currentState?.validate() == true) {
                      Get.back();
                      await controller.createParentInline({
                        'nom': nom.trim(),
                        'prenom': prenom.trim(),
                        if (tel.trim().isNotEmpty) 'telephone': tel.trim(),
                        'role': role,
                      });
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

