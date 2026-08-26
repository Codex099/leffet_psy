import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patients_liste_controller.dart';
import '../../models/patient_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/ios_segmented_control.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/status_badge.dart';

class PatientsListeView extends GetView<PatientsListeController> {
  const PatientsListeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      appBar: CreativeAppBar(
        title: 'Dossiers Patients',
        subtitle: 'Cabinet PsyCare',
        actions: [
          BouncyTap(
            onTap: () async {
              final res = await Get.toNamed(AppRoutes.editPatient);
              if (res == true) {
                controller.loadPatients();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Search Bar Simple & Évidente ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 0.9),
                  boxShadow: AppColors.softShadow,
                ),
                child: TextField(
                  onChanged: (val) => controller.search(val),
                  style: AppTextStyles.iosBody,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un patient par nom...',
                    hintStyle: AppTextStyles.iosSubhead.copyWith(color: AppColors.textHint),
                    prefixIcon: const Icon(Icons.search_rounded, size: 22, color: AppColors.secondary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    isDense: true,
                  ),
                ),
              ),
            ),

            // ── Segmented Control Filter (Tous / Actifs / Inactifs) ──
            Obx(() {
              int selectedIndex = 0;
              if (controller.actifFilter.value == true) selectedIndex = 1;
              if (controller.actifFilter.value == false) selectedIndex = 2;

              return IosSegmentedControl<int>(
                segments: const {
                  0: 'Tous',
                  1: 'Suivi Actif',
                  2: 'Inactifs',
                },
                selectedValue: selectedIndex,
                onValueChanged: (idx) {
                  if (idx == 0) controller.setActifFilter(null);
                  if (idx == 1) controller.setActifFilter(true);
                  if (idx == 2) controller.setActifFilter(false);
                },
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              );
            }),

            // ── Compteur de patients ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        '${controller.filteredPatients.length} patient(s) répertorié(s)',
                        style: AppTextStyles.iosCaption2.copyWith(color: AppColors.textSecondary),
                      )),
                ],
              ),
            ),

            // ── Liste Patients Inset Grouped ──
            Expanded(
              child: Obx(() {
                if (controller.status.value == 'loading') {
                  return StatePlaceholder.loading(message: 'Chargement des dossiers...');
                }
                if (controller.status.value == 'error') {
                  return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadPatients(),
                  );
                }

                final list = controller.filteredPatients;
                if (list.isEmpty) {
                  return StatePlaceholder.empty(
                    title: 'Aucun patient trouvé',
                    message: 'Vous pouvez ajouter un nouveau dossier dès maintenant.',
                    actionLabel: '+ Créer un dossier patient',
                    onAction: () async {
                      final res = await Get.toNamed(AppRoutes.editPatient);
                      if (res == true) {
                        controller.loadPatients();
                      }
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => controller.loadPatients(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 2, bottom: 120),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final patient = list[index];
                      return _buildPatientCard(patient);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(PatientModel patient) {
    return IosCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      children: [
        IosCardTile(
          leading: Stack(
            children: [
              PatientAvatar(
                photoUrl: patient.photoUrl,
                initials: patient.initials,
                radius: 22,
              ),
              if (patient.actif)
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: PulseDot(color: AppColors.secondary, size: 8),
                ),
            ],
          ),
          title: patient.fullName,
          subtitle: patient.ageFormatted != null
              ? '${patient.ageFormatted} • ${patient.sexeLabel}'
              : patient.sexeLabel,
          trailing: StatusBadge.active(label: patient.statutLabel),
          showChevron: true,
          onTap: () async {
            await Get.toNamed(AppRoutes.patientInfo, arguments: patient.id);
            controller.loadPatients();
          },
        ),
      ],
    );
  }
}
