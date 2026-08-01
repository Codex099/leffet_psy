import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_groupe_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_text_field.dart';

class EditGroupeView extends GetView<EditGroupeController> {
  const EditGroupeView({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      Text('DÉTAIL DU GROUPE', style: AppTextStyles.sectionKicker),
                      Text('Ajout / Édition Groupe', style: AppTextStyles.screenTitleMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Groupe info card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nom du groupe', style: AppTextStyles.sectionTitle),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Admin', style: AppTextStyles.badge.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    Text('Description du groupe et paramètres de planification', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nom du groupe',
                      hintText: 'Ex: Groupe Compétences sociales',
                      onChanged: (v) => controller.nom.value = v,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Description',
                      hintText: 'Zone de texte pour la description...',
                      maxLines: 3,
                      onChanged: (v) => controller.description.value = v,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Type de groupe Selector Card
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
                    Text('Type de groupe', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 14),
                    Obx(() => Row(
                          children: [
                            Expanded(child: _buildTypeTile('Fixe')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTypeTile('Ponctuel')),
                          ],
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Planning récurrent Card
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
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Planning récurrent', style: AppTextStyles.sectionTitle),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Jour de la semaine', style: AppTextStyles.fieldLabel),
                    const SizedBox(height: 8),
                    Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: days.map((d) => _buildDayChip(d)).toList(),
                        )),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Heure de début',
                            hintText: '09:00',
                            onChanged: (v) => controller.heureDebut.value = v,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Heure de fin',
                            hintText: '09:45',
                            onChanged: (v) => controller.heureFin.value = v,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Patients inscrits Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people_outline, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text('Patients inscrits', style: AppTextStyles.sectionTitle),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.person_add_alt_outlined, size: 16),
                          label: const Text('Ajouter un patient'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPatientMemberTile('Camille Moreau', '8 ans'),
                    const SizedBox(height: 8),
                    _buildPatientMemberTile('Lucas Bernard', '10 ans'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Supprimer le groupe action button
              ElevatedButton(
                onPressed: () => controller.saveGroupe(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Supprimer le groupe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTile(String type) {
    final isSelected = controller.typePlanning.value == type;
    return InkWell(
      onTap: () => controller.typePlanning.value = type,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            type,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(String day) {
    final isSelected = controller.selectedDays.contains(day);
    return InkWell(
      onTap: () => controller.toggleDay(day),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          day,
          style: AppTextStyles.badge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPatientMemberTile(String name, String age) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, backgroundColor: AppColors.secondaryLight, child: Icon(Icons.person, size: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                Text(age, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
        ],
      ),
    );
  }
}
