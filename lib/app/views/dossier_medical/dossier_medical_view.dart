import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dossier_medical_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_placeholder.dart';

class DossierMedicalView extends GetView<DossierMedicalController> {
  const DossierMedicalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Obx(() {
          if (controller.status.value == 'loading') {
            return const StatePlaceholder(type: StatePlaceholderType.loading);
          }
          if (controller.status.value == 'error') {
            return StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadDossier(),
            );
          }

          final d = controller.dossier.value;

          return SingleChildScrollView(
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
                        Text('FICHE CLINIQUE', style: AppTextStyles.sectionKicker),
                        Text('Dossier médical', style: AppTextStyles.screenTitleMedium),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Form card with 11 structured fields
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
                      AppTextField(
                        label: 'Antécédents médicaux',
                        hintText: 'Antécédents du patient...',
                        maxLines: 2,
                        onChanged: (v) => controller.antecedents.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Médicaments pris',
                        hintText: 'Traitements en cours...',
                        maxLines: 2,
                        onChanged: (v) => controller.medicaments.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Date du cas',
                        hintText: 'JJ/MM/AAAA',
                        onChanged: (v) => controller.dateCas.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Naissance',
                        hintText: 'Conditions de naissance...',
                        onChanged: (v) => controller.naissance.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Développement psychomoteur',
                        hintText: 'Marche, motricité...',
                        maxLines: 2,
                        onChanged: (v) => controller.devPsychomoteur.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Comportement auditif',
                        hintText: 'Réactions aux sons...',
                        onChanged: (v) => controller.compAuditif.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Développement langagier',
                        hintText: 'Vocabulaire, compréhension...',
                        maxLines: 2,
                        onChanged: (v) => controller.devLangagier.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Adaptation sociale',
                        hintText: 'Relations avec les pairs...',
                        maxLines: 2,
                        onChanged: (v) => controller.adaptationSociale.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Autonomie',
                        hintText: 'Habillage, hygiène...',
                        onChanged: (v) => controller.autonomie.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Aspect sanitaire',
                        hintText: 'État général...',
                        onChanged: (v) => controller.aspectSanitaire.value = v,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Stade de scolarisation',
                        hintText: 'Classe / Établissement...',
                        onChanged: (v) => controller.stadeScolarisation.value = v,
                      ),
                      const SizedBox(height: 16),
                      if (d?.misAJourPar != null)
                        Text(
                          'Mis à jour par ${d!.misAJourPar} le ${d.dateMaj ?? ""}',
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
              ],
            ),
          );
        }),
      ),
    );
  }
}
