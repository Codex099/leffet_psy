import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notes_patient_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/media_picker_widget.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/app_section_header.dart';

class NotesPatientView extends GetView<NotesPatientController> {
  const NotesPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Notes Cliniques'.tr,
        subtitle: 'Suivi et Évolutions'.tr,
        showBackButton: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          Text(
                            'Ajouter une note'.tr,
                            style: AppTextStyles.sectionTitle,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: '',
                            hintText: 'Saisir une observation clinique...'.tr,
                            maxLines: 3,
                            controller: controller.contenuController,
                          ),
                          const SizedBox(height: 12),
                          Obx(
                            () => MediaPickerWidget(
                              key: ValueKey(controller.formResetToken.value),
                              initialMediaUrls: controller.medias,
                              onMediasChanged: (urls) =>
                                  controller.medias.value = urls,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(
                            () => ElevatedButton.icon(
                              onPressed: controller.isSaving.value
                                  ? null
                                  : () => controller.addNote(),
                              icon: controller.isSaving.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.add),
                              label: Text(
                                controller.isSaving.value
                                    ? 'Enregistrement...'
                                    : 'Enregistrer'.tr,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(double.infinity, 44),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SectionHeader(
                      title: 'Historique des notes'.tr,
                      icon: Icons.note_alt_rounded,
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (controller.status.value == 'loading') {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: StatePlaceholder.loading(),
                  ),
                );
              }
              if (controller.status.value == 'error') {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: StatePlaceholder.error(
                      message: controller.errorMessage.value,
                      onAction: () => controller.loadNotes(),
                    ),
                  ),
                );
              }
              if (controller.notes.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: StatePlaceholder.empty(
                      title: 'Aucune note'.tr,
                      message:
                          'Ajoutez des observations cliniques pour ce patient.',
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final note = controller.notes[index];
                    final medias = controller.mediasDe(note);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Container(
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
                                    '${controller.auteurDe(note)} | ${controller.dateDe(note)}'.tr,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (medias.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 64,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: medias.length,
                                        separatorBuilder: (_, _) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (_, i) => ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.network(
                                            medias[i],
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                Container(
                                                  width: 64,
                                                  height: 64,
                                                  color:
                                                      AppColors.fieldBackground,
                                                  child: const Icon(
                                                    Icons.broken_image_outlined,
                                                    size: 20,
                                                    color:
                                                        AppColors.textSecondary,
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
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                              ),
                              onPressed: () =>
                                  controller.deleteNote(note['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: controller.notes.length),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
