import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/calendrier_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/ios_segmented_control.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/app_date_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/evenement_calendrier_model.dart';

class CalendrierView extends GetView<CalendrierController> {
 const CalendrierView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Calendrier Administratif'.tr,
       subtitle: 'Événements & Réunions'.tr,
       showBackButton: true,
        actions: [
          BouncyTap(
            onTap: () => _showAddDialog(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: AppColors.oceanGradient,
                shape: BoxShape.circle,
                boxShadow: AppColors.softShadow,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 19,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Control (Liste / Calendrier)
          Obx(
            () => IosSegmentedControl<String>(
              segments: const {
                'Liste': 'Liste des événements',
                'Calendrier': 'Vue Calendrier',
              },
              selectedValue: controller.activeTab.value,
              onValueChanged: (tab) => controller.activeTab.value = tab,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
          ),

          // ── iOS Search Bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.9),
                boxShadow: AppColors.softShadow,
              ),
              child: TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                style: AppTextStyles.iosBody,
                decoration: InputDecoration(
                  hintText: 'Rechercher un événement...'.tr,
                  hintStyle: AppTextStyles.iosSubhead.copyWith(
                    color: AppColors.textHint,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  isDense: true,
                ),
              ),
            ),
          ),

            // Content List or Empty placeholder
            Expanded(
              child: Obx(() {
                if (controller.status.value == 'loading') {
                  return StatePlaceholder.loading();
                }
                if (controller.status.value == 'error') {
                  return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadEvenements(),
                  );
                }
                if (controller.status.value == 'empty' && controller.activeTab.value == 'Liste') {
                  return StatePlaceholder.empty(
                    title: 'Aucun événement planifié'.tr,
                    message:
                        'Ajoutez un événement pour organiser le calendrier clinique.',
                    actionLabel: 'Nouvel événement',
                    onAction: () => _showAddDialog(context),
                  );
                }

                if (controller.activeTab.value == 'Liste') {
                  return _buildListView(context);
                } else {
                  return _buildCalendarView(context);
                }
              }),
            ),
          ],
        ),
    );
  }

  Widget _buildListView(BuildContext context) {
    final list = controller.filteredEvenements;
    if (list.isEmpty) {
      return StatePlaceholder.empty(
        title: 'Aucun événement planifié'.tr,
        message: 'Ajoutez un événement pour organiser le calendrier clinique.',
        actionLabel: 'Nouvel événement',
        onAction: () => _showAddDialog(context),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final ev = list[index];
        return _buildEventCard(context, ev);
      },
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 0.8),
            boxShadow: AppColors.cardShadow,
          ),
          child: TableCalendar<EvenementCalendrierModel>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: controller.focusedDay.value,
            selectedDayPredicate: (day) =>
                isSameDay(controller.selectedDay.value, day),
            onDaySelected: (selectedDay, focusedDay) {
              controller.selectedDay.value = selectedDay;
              controller.focusedDay.value = focusedDay;
            },
            eventLoader: controller.getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              formatButtonTextStyle: AppTextStyles.iosCaption1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              titleCentered: true,
              titleTextStyle: AppTextStyles.iosSubhead.copyWith(fontWeight: FontWeight.w700),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.accentCoral,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
          ),
        ),
        Expanded(
          child: _buildSelectedDayEvents(context),
        ),
      ],
    );
  }

  Widget _buildSelectedDayEvents(BuildContext context) {
    final selectedDay = controller.selectedDay.value;
    if (selectedDay == null) return const SizedBox.shrink();

    final dayEvents = controller.getEventsForDay(selectedDay);

    if (dayEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Aucun événement pour cette date.'.tr,
            style: AppTextStyles.iosSubhead.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        return _buildEventCard(context, dayEvents[index]);
      },
    );
  }

  Widget _buildEventCard(BuildContext context, EvenementCalendrierModel ev) {
    return IosCard(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      children: [
        IosCardTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          title: ev.titre,
          subtitle:
              "${ev.date}${ev.description != null && ev.description!.isNotEmpty ? ' · ${ev.description}' : ''}".tr,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                onPressed: () => _showAddDialog(context, ev),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.error,
                ),
                onPressed: () => _confirmDelete(context, ev.id),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, dynamic id) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Supprimer l\'événement'.tr),
       content: Text(
          'Êtes-vous sûr de vouloir supprimer cet événement du calendrier clinique ?'.tr,
       ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler'.tr),
         ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteEvenement(id);
            },
            child: Text('Supprimer'.tr),
         ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, [dynamic ev]) {
    controller.resetForm(ev);
    final formKey = GlobalKey<FormState>();
    final titreTextCtrl = TextEditingController(text: controller.titre.value);
    final descTextCtrl = TextEditingController(
      text: controller.description.value,
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.iosSystemGray4,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ev != null ? 'Modifier l\'événement'.tr : 'Nouvel événement'.tr,
                 style: AppTextStyles.iosTitle2,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Titre de l\'événement *'.tr,
                 hintText: 'Ex: Réunion d\'équipe pluridisciplinaire'.tr,
                 controller: titreTextCtrl,
                  onChanged: (v) => controller.titre.value = v,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Le titre est obligatoire';
                   }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Description'.tr,
                 hintText: 'Détails ou ordre du jour...'.tr,
                 controller: descTextCtrl,
                  maxLines: 3,
                  onChanged: (v) => controller.description.value = v,
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'Date de l\'événement *'.tr,
                   style: AppTextStyles.fieldLabel,
                  ),
                ),
                Obx(
                  () => InkWell(
                    onTap: () async {
                      final initial =
                          DateTime.tryParse(controller.date.value) ??
                          DateTime.now();
                      final picked = await AppDatePicker.show(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        controller.date.value =
                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                     }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.fieldBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.date.value.isEmpty
                                ? 'Sélectionner la date'.tr
                               : controller.date.value,
                            style: AppTextStyles.fieldValue,
                          ),
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rappel (jours avant)'.tr,
                     style: AppTextStyles.fieldLabel,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            if (controller.notifierJours.value > 1) {
                              controller.notifierJours.value--;
                            }
                          },
                        ),
                        Obx(
                          () => Text(
                            '${controller.notifierJours.value} j'.tr,
                           style: AppTextStyles.iosHeadline,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                          ),
                          onPressed: () => controller.notifierJours.value++,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: ev != null ? 'Mettre à jour'.tr : 'Enregistrer'.tr,
                  onPressed: () async {
                    if (formKey.currentState?.validate() == true) {
                      final success = await controller.saveEvenement();
                      if (success) Get.back();
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
