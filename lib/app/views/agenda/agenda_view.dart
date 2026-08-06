import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/agenda_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_placeholder.dart';

class AgendaView extends GetView<AgendaController> {
  const AgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.creationSeance),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Agenda', style: AppTextStyles.screenTitle),
                      Text('Planification des séances', style: AppTextStyles.screenSubtitle),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => Get.toNamed(AppRoutes.creationSeance),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date & Mode selector card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
                          onPressed: () => controller.previousDay(),
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
                          child: Column(
                            children: [
                              Obx(() => Text(controller.formattedDate, style: AppTextStyles.sectionKicker)),
                              Obx(() => Text(controller.activeMode.value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                          onPressed: () => controller.nextDay(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _buildModeTab('Jour')),
                              Expanded(child: _buildModeTab('Semaine')),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Crénaux Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Créneaux du jour', style: AppTextStyles.sectionTitle),
                  Obx(() => Text(
                        '${controller.seances.length} séances',
                        style: AppTextStyles.bodySmall,
                      )),
                ],
              ),
              const SizedBox(height: 12),

              // Content List or Placeholders
              Expanded(
                child: Obx(() {
                  if (controller.status.value == 'loading') {
                    return StatePlaceholder.loading();
                  }
                  if (controller.status.value == 'error') {
                    return StatePlaceholder.error(
                      message: controller.errorMessage.value,
                      onAction: () => controller.loadAgenda(),
                    );
                  }
                  if (controller.status.value == 'empty') {
                    return StatePlaceholder.empty(
                      title: 'Aucune séance aujourd\'hui',
                      message: 'Consultez un autre jour pour voir les créneaux disponibles.',
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.seances.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final seance = controller.seances[index];
                      return _buildAgendaItemCard(seance);
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

  Widget _buildModeTab(String mode) {
    final isSelected = controller.activeMode.value == mode;
    return InkWell(
      onTap: () => controller.setMode(mode),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            mode,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgendaItemCard(dynamic seance) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.compteRenduSeance, arguments: seance.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(seance.heureDebut, style: AppTextStyles.timeLabel),
                      const SizedBox(width: 8),
                      StatusBadge.pending(label: seance.duree),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seance.patientFullName.isNotEmpty ? seance.patientFullName : 'Patient #${seance.patientId}',
                    style: AppTextStyles.cardName,
                  ),
                  const SizedBox(height: 2),
                  Text('Suivi individuel', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
