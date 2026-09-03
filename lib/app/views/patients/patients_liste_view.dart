import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/patients_liste_controller.dart';
import '../../models/patient_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
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
        title: 'Dossiers Patients'.tr,
        subtitle: controller.isAdmin.value
            ? 'Tous les dossiers du cabinet'.tr
            : 'Dossiers assignés'.tr,
        actions: [
          if (controller.isAdmin.value)
            BouncyTap(
              onTap: () async {
                final res = await Get.toNamed(AppRoutes.editPatient);
                if (res == true) controller.loadPatients();
              },
              child: Container(
                padding: const EdgeInsets.all(9),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  gradient: AppColors.oceanGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.softShadow,
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  size: 19,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: RefreshIndicator(
        onRefresh: () async => controller.loadPatients(),
        color: AppColors.primary,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            // ── Search Bar Premium ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight, width: 0.7),
                  boxShadow: AppColors.softShadow,
                ),
                child: TextField(
                  onChanged: (val) => controller.search(val),
                  style: AppTextStyles.iosBody.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un patient...'.tr,
                    hintStyle: AppTextStyles.iosSubhead.copyWith(
                      color: AppColors.textHint,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: AppColors.secondary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    isDense: true,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
            ),

              // ── Filtres Segmented ──────────────────────────────────────────
              Obx(() {
                int selectedIndex = 0;
                if (controller.actifFilter.value == true) selectedIndex = 1;
                if (controller.actifFilter.value == false) selectedIndex = 2;

                return IosSegmentedControl<int>(
                  segments: const {0: 'Tous', 1: 'Suivi actif', 2: 'Inactifs'},
                 selectedValue: selectedIndex,
                  onValueChanged: (idx) {
                    if (idx == 0) controller.setActifFilter(null);
                    if (idx == 1) controller.setActifFilter(true);
                    if (idx == 2) controller.setActifFilter(false);
                  },
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                );
              }),

              // ── Compteur ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        '${controller.filteredPatients.length} patient(s)'.tr,
                       style: AppTextStyles.iosCaption2.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Liste Patients ─────────────────────────────────────────────
              Obx(() {
                if (controller.status.value == 'loading') {
                 return const ShimmerListLoader(count: 6);
                }
                if (controller.status.value == 'error') {
                 return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadPatients(),
                  );
                }

                final list = controller.filteredPatients;
                if (list.isEmpty) {
                  final isInactive = controller.actifFilter.value == false;
                  final canCreate = controller.isAdmin.value;
                  return StatePlaceholder.empty(
                    title: isInactive
                        ? 'Aucun patient inactif'.tr
                        : 'Aucun patient trouvé'.tr,
                    message: isInactive
                        ? 'Il n\'y a aucun patient inactif dans votre liste.'.tr
                        : (canCreate
                            ? 'Vous pouvez créer un nouveau dossier dès maintenant.'.tr
                            : 'Aucun patient ne vous a été assigné par l\'administrateur.'.tr),
                    actionLabel: (!isInactive && canCreate) ? 'Créer un dossier'.tr : null,
                    onAction: (!isInactive && canCreate)
                        ? () async {
                            final res = await Get.toNamed(
                              AppRoutes.editPatient,
                            );
                            if (res == true) controller.loadPatients();
                          }
                        : null,
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 6),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _buildPatientCard(list[index], index);
                  },
                );
              }),
            ],
          ),
        ),
    );
  }

  Widget _buildPatientCard(PatientModel patient, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child:
          BouncyTap(
                onTap: () async {
                  await Get.toNamed(
                    AppRoutes.patientInfo,
                    arguments: patient.id,
                  );
                  controller.loadPatients();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 0.6,
                    ),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      // Avatar + indicateur statut
                      Stack(
                        children: [
                          PatientAvatar(
                            photoUrl: patient.photoUrl,
                            initials: patient.initials,
                            radius: 24,
                          ),
                          if (patient.actif)
                            const Positioned(
                              right: 0,
                              bottom: 0,
                              child: PulseDot(
                                color: AppColors.secondary,
                                size: 9,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      // Info patient
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.fullName,
                              style: AppTextStyles.iosHeadline.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              patient.ageFormatted != null
                                  ? '${patient.ageFormatted} \u200E•\u200E ${patient.sexeLabel}'
                                  : patient.sexeLabel,
                              style: AppTextStyles.iosFootnote.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Badge + chevron
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusBadge.active(label: patient.statutLabel),
                          const SizedBox(height: 6),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppColors.iosSystemGray3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .animate(delay: Duration(milliseconds: 50 * (index % 10)))
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.05, curve: Curves.easeOut),
    );
  }
}

// Shimmer loader "” imported from app_animations via state_placeholder
class ShimmerListLoader extends StatelessWidget {
  final int count;
  const ShimmerListLoader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 6, bottom: 20),
      itemCount: count,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child:
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Row(
                    children: [
                      _shimmer(48, 48, 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmer(double.infinity, 14, 7),
                            const SizedBox(height: 8),
                            _shimmer(100, 11, 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: Duration(milliseconds: i * 80))
                .fadeIn(duration: 400.ms),
      ),
    );
  }

  Widget _shimmer(double w, double h, double r) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0F5),
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

