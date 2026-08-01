import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/creation_seance_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class CreationSeanceView extends GetView<CreationSeanceController> {
  const CreationSeanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Text('PLANIFICATION', style: AppTextStyles.sectionKicker),
                      Text('Nouvelle séance', style: AppTextStyles.screenTitleMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                      label: 'Patient ID',
                      hintText: 'Ex: 12',
                      keyboardType: TextInputType.number,
                      onChanged: (v) => controller.patientId.value = int.tryParse(v),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Date de la séance',
                      hintText: 'AAAA-MM-JJ',
                      onChanged: (v) => controller.date.value = v,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Heure de début',
                            hintText: '10:00',
                            onChanged: (v) => controller.heureDebut.value = v,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Durée',
                            hintText: '45 min',
                            onChanged: (v) => controller.duree.value = v,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => AppButton(
                    label: 'Planifier la séance',
                    isLoading: controller.status.value == 'loading',
                    onPressed: () => controller.createSeance(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
