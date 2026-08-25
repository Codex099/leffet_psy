import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notes_patient_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/media_picker_widget.dart';
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
                      controller: controller.contenuController,
                    ),
                    const SizedBox(height: 12),
                    // Médias de la note (PRD §7.6) : la clé force la
                    // reconstruction du picker après un enregistrement.
                    Obx(() => MediaPickerWidget(
                          key: ValueKey(controller.formResetToken.value),
                          initialMediaUrls: controller.medias,
                          onMediasChanged: (urls) => controller.medias.value = urls,
                        )),
                    const SizedBox(height: 12),
                    Obx(() => ElevatedButton.icon(
                          onPressed: controller.isSaving.value ? null : () => controller.addNote(),
                          icon: controller.isSaving.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.add),
                          label: Text(controller.isSaving.value ? 'Enregistrement...' : 'Enregistrer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        )),
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
                      final medias = controller.mediasDe(note);
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                    '${controller.auteurDe(note)} | ${controller.dateDe(note)}',
                                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                                  ),
                                  if (medias.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 64,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: medias.length,
                                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                                        itemBuilder: (_, i) => ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            medias[i],
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => Container(
                                              width: 64,
                                              height: 64,
                                              color: AppColors.fieldBackground,
                                              child: const Icon(
                                                Icons.broken_image_outlined,
                                                size: 20,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                              onPressed: () => controller.deleteNote(note['id']),
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
