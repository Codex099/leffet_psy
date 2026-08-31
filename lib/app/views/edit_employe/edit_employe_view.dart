import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_employe_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/ios_segmented_control.dart';
import '../../widgets/state_placeholder.dart';

class EditEmployeView extends StatefulWidget {
 const EditEmployeView({super.key});

  @override
  State<EditEmployeView> createState() => _EditEmployeViewState();
}

class _EditEmployeViewState extends State<EditEmployeView> {
  final controller = Get.find<EditEmployeController>();

  late final TextEditingController _prenomCtrl;
  late final TextEditingController _nomCtrl;
  late final TextEditingController _telCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;

  @override
  void initState() {
    super.initState();
    _prenomCtrl = TextEditingController(text: controller.prenom.value);
    _nomCtrl = TextEditingController(text: controller.nom.value);
    _telCtrl = TextEditingController(text: controller.telephone.value);
    _usernameCtrl = TextEditingController(text: controller.username.value);
    _passwordCtrl = TextEditingController(text: controller.password.value);

    // Écouter les mises à jour asynchrones du contrôleur
    ever(controller.prenom, (v) {
      if (_prenomCtrl.text != v) _prenomCtrl.text = v;
    });
    ever(controller.nom, (v) {
      if (_nomCtrl.text != v) _nomCtrl.text = v;
    });
    ever(controller.telephone, (v) {
      if (_telCtrl.text != v) _telCtrl.text = v;
    });
    ever(controller.username, (v) {
      if (_usernameCtrl.text != v) _usernameCtrl.text = v;
    });
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = controller.employeId != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: isEditMode ? 'Modifier l\'employé'.tr : 'Nouvel employé'.tr,
       subtitle: 'Équipe Clinique'.tr,
       showBackButton: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.status.value == 'loading' &&
             isEditMode &&
              controller.nom.value.isEmpty) {
            return StatePlaceholder.loading(
              message: 'Chargement des données de l\'employé...'.tr,
           );
          }
          if (controller.status.value == 'error') {
           return StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.onInit(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const SizedBox(height: 90),
                // ── Rôle Segmented Control iOS ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Text(
                    'RÔLE DE L\'EMPLOYÉ'.tr,
                   style: AppTextStyles.iosCaption2,
                  ),
                ),
                Obx(
                  () => IosSegmentedControl<String>(
                    segments: const {
                      'psychologue': 'Psychologue',
                     'educatrice': 'Éducatrice',
                     'admin': 'Admin',
                   },
                    selectedValue: controller.role.value,
                    onValueChanged: (r) => controller.role.value = r,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Informations personnelles ──
                IosCard(
                  title: 'Identité & Contact'.tr,
                 children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          AppTextField(
                            label: 'Prénom *'.tr,
                           hintText: 'Ex. Camille'.tr,
                           controller: _prenomCtrl,
                            onChanged: (v) => controller.prenom.value = v,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Nom *'.tr,
                           hintText: 'Ex. Moreau'.tr,
                           controller: _nomCtrl,
                            onChanged: (v) => controller.nom.value = v,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Téléphone'.tr,
                           hintText: '06 12 34 56 78',
                           keyboardType: TextInputType.phone,
                            controller: _telCtrl,
                            onChanged: (v) => controller.telephone.value = v,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Identifiants de connexion ──
                IosCard(
                  title: 'Identifiants de connexion'.tr,
                 subtitle: isEditMode
                      ? 'Laissez le mot de passe vide pour ne pas le changer.'.tr
                     : 'Mot de passe initial requis'.tr,
                 children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          AppTextField(
                            label: 'Nom d\'utilisateur (login) *'.tr,
                           hintText: 'c.moreau'.tr,
                           controller: _usernameCtrl,
                            onChanged: (v) => controller.username.value = v,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: isEditMode
                                ? 'Nouveau mot de passe (optionnel)'.tr
                               : 'Mot de passe initial *'.tr,
                           hintText: '••••••••',
                           obscureText: true,
                            controller: _passwordCtrl,
                            onChanged: (v) => controller.password.value = v,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Patients Assignés ──
                IosCard(
                  title: 'Patients Assignés'.tr,
                 subtitle:
                      'Sélectionnez les patients que cet employé peut suivre'.tr,
                 children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller.allPatients.isEmpty)
                            Text(
                              'Aucun patient disponible.'.tr,
                             style: AppTextStyles.iosFootnote,
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: controller.allPatients.map((p) {
                                final isSelected = controller.selectedPatientIds
                                    .contains(p.id);
                                return FilterChip(
                                  selected: isSelected,
                                  label: Text('${p.prenom} ${p.nom}'.tr),
                                 selectedColor: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  onSelected: (_) =>
                                      controller.togglePatient(p.id),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Bouton Enregistrer ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: AppButton(
                    label: isEditMode
                        ? 'Enregistrer les modifications'.tr
                       : 'Créer l\'employé'.tr,
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: () => controller.saveEmployee(),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

