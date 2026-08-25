import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/agenda_controller.dart';
import '../../models/seance_model.dart';
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

class AgendaView extends GetView<AgendaController> {
  const AgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      appBar: CreativeAppBar(
        title: 'Planning & Agenda',
        subtitle: 'Consultations Cliniques',
        actions: [
          BouncyTap(
            onTap: () => Get.toNamed(AppRoutes.creationSeance),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_alarm_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Mode Switcher (Jour / Semaine) ──
            Obx(() => IosSegmentedControl<String>(
                  segments: const {
                    'Jour': 'Vue Journée',
                    'Semaine': 'Vue Semaine',
                  },
                  selectedValue: controller.activeMode.value,
                  onValueChanged: (mode) => controller.setMode(mode),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                )),

            // ── Date Navigation Card Simple ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.9),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BouncyTap(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        controller.previousDay();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.chevron_left_rounded, color: AppColors.primary, size: 24),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          controller.selectedDate.value = picked;
                          controller.loadAgenda();
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Column(
                          children: [
                            Obx(() => Text(
                                  controller.formattedDate,
                                  style: AppTextStyles.iosHeadline.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_month_rounded, size: 13, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Changer de date',
                                  style: AppTextStyles.iosCaption2.copyWith(color: AppColors.secondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    BouncyTap(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        controller.nextDay();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content / List of Sessions ──
            Expanded(
              child: Obx(() {
                if (controller.status.value == 'loading') {
                  return StatePlaceholder.loading(message: 'Chargement du planning...');
                }
                if (controller.status.value == 'error') {
                  return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadAgenda(),
                  );
                }
                if (controller.seances.isEmpty) {
                  return StatePlaceholder.empty(
                    title: 'Aucune séance programmée',
                    message: 'Aucun rendez-vous planifié pour cette date.',
                    actionLabel: '+ Planifier un rendez-vous',
                    onAction: () => Get.toNamed(AppRoutes.creationSeance),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => controller.loadAgenda(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 6, bottom: 120),
                    itemCount: controller.seances.length,
                    itemBuilder: (context, index) {
                      final seance = controller.seances[index];
                      return _buildSessionCard(seance);
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

  Widget _buildSessionCard(SeanceModel seance) {
    return IosCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      children: [
        IosCardTile(
          leading: PatientAvatar(
            initials: seance.patientFullName.isNotEmpty ? seance.patientFullName[0] : 'S',
            radius: 20,
          ),
          title: seance.patientFullName.isNotEmpty ? seance.patientFullName : 'Patient #${seance.patientId}',
          subtitle: '${seance.heureDebut} — ${seance.heureFin} (${seance.duree})',
          showChevron: true,
          trailing: StatusBadge.active(label: seance.statutLabel),
          onTap: () => Get.toNamed(AppRoutes.compteRenduSeance, arguments: seance.id),
        ),
      ],
    );
  }
}
