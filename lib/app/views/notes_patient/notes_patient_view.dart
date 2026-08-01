import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notes_patient_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_placeholder.dart';

class NotesPatientView extends GetView<NotesPatientController> {
  const NotesPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Padding(
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
                      Text('NOTES CLINIQUES', style: AppTextStyles.sectionKicker),
                      Text('Notes du patient', style: AppTextStyles.screenTitleMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Add note card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ajouter une note', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: '',
                      hintText: 'Saisir une observation clinique...',
                      maxLines: 3,
                      onChanged: (v) => controller.contenu.value = v,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => controller.addNote(),
                      icon: const Icon(Icons.add),
                      label: const Text('Enregistrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Historique des notes', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 10),
              Expanded(
                child: Obx(() {
                  if (controller.status.value == 'loading') {
                    return StatePlaceholder.loading();
                  }
                  if (controller.status.value == 'error') {
                    return StatePlaceholder.error(
                      message: controller.errorMessage.value,
                      onAction: () => controller.loadNotes(),
                    );
                  }
                  if (controller.notes.isEmpty) {
                    return StatePlaceholder.empty(
                      title: 'Aucune note',
                      message: 'Ajoutez des observations cliniques pour ce patient.',
                    );
                  }
                  return ListView.separated(
                    itemCount: controller.notes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final note = controller.notes[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note['contenu'] as String? ?? '',
                                    style: AppTextStyles.body,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${note['auteur'] ?? 'Auteur'} | ${note['date'] ?? ''}',
                                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                              onPressed: () => controller.deleteNote(note['id'] as int? ?? 0),
                            ),
                          ],
                        ),
                      );
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
}
