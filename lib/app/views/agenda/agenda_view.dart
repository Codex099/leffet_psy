import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/agenda_controller.dart';
import '../../models/agenda_session_item.dart';
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
            onTap: () async {
              final res = await Get.toNamed(AppRoutes.creationSeance);
              if (res == true) controller.loadAgenda(forceRefresh: true);
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
                Icons.add_alarm_rounded,
                size: 19,
                color: Colors.white,
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
            // ── En-tête Mois & Navigation Semaine ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Titre Mois Année
                  Obx(() => InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: controller.selectedDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            controller.selectDate(picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          child: Row(
                            children: [
                              Text(
                                controller.monthYearTitle,
                                style: AppTextStyles.iosTitle3.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 22),
                            ],
                          ),
                        ),
                      )),

                  // Bouton Aujourd'hui & Flèches navigation
                  Row(
                    children: [
                      Obx(() {
                        if (!controller.isSelectedDateToday) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: BouncyTap(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                controller.goToToday();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: AppColors.oceanGradient,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: AppColors.softShadow,
                                ),
                                child: Text(
                                  'Aujourd\'hui',
                                  style: AppTextStyles.iosCaption1.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      BouncyTap(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.previousWeek();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border, width: 0.8),
                          ),
                          child: const Icon(Icons.chevron_left_rounded, size: 20, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      BouncyTap(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.nextWeek();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border, width: 0.8),
                          ),
                          child: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Bandeau Horizontal 7 Jours (Week Strip) ──
            Obx(() {
              final weekDays = controller.currentWeekDays;
              final selected = controller.selectedDate.value;
              final now = DateTime.now();

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 0.8),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekDays.map((day) {
                    final bool isSelected =
                        selected.year == day.year && selected.month == day.month && selected.day == day.day;
                    final bool isToday =
                        now.year == day.year && now.month == day.month && now.day == day.day;
                    final bool hasSessions = controller.hasSessionsOn(day);
                    final dayShorts = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
                    final dayName = dayShorts[day.weekday - 1];

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.selectDate(day);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.oceanGradient : null,
                            color: isSelected
                                ? null
                                : isToday
                                    ? AppColors.primaryLight.withValues(alpha: 0.15)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: isToday && !isSelected
                                ? Border.all(color: AppColors.primary, width: 1.2)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dayName,
                                style: AppTextStyles.iosCaption2.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.90)
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${day.day}',
                                style: AppTextStyles.iosHeadline.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Indicateur de séance
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasSessions
                                      ? (isSelected ? AppColors.accentCoral : AppColors.primary)
                                      : Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),

            // ── Mode Switcher (Jour / Semaine complète) ──
            Obx(() => IosSegmentedControl<String>(
                  segments: const {
                    'Jour': 'Vue Journée',
                    'Semaine': 'Semaine Complète',
                  },
                  selectedValue: controller.activeMode.value,
                  onValueChanged: (mode) => controller.setMode(mode),
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                )),

            // ── Contenu Séances ──
            Expanded(
              child: Obx(() {
                if (controller.status.value == 'loading') {
                  return StatePlaceholder.loading(message: 'Chargement des consultations...');
                }
                if (controller.status.value == 'error') {
                  return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadAgenda(forceRefresh: true),
                  );
                }

                if (controller.activeMode.value == 'Jour') {
                  return _buildDayView(context);
                } else {
                  return _buildWeekView(context);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Vue Journée simple et claire
  Widget _buildDayView(BuildContext context) {
    final daySessions = controller.sessionsForSelectedDate;

    if (daySessions.isEmpty) {
      return StatePlaceholder.empty(
        title: 'Aucune consultation',
        message: 'Aucun rendez-vous prévu pour le ${controller.formattedSelectedDate}.',
        actionLabel: '+ Planifier un rendez-vous',
        onAction: () async {
          final res = await Get.toNamed(AppRoutes.creationSeance);
          if (res == true) controller.loadAgenda(forceRefresh: true);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadAgenda(forceRefresh: true),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.only(top: 6, bottom: 120),
        children: [
          // En-tête du jour sélectionné
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.formattedSelectedDate,
                  style: AppTextStyles.iosSubhead.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.oceanGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Text(
                    '${daySessions.length} séance${daySessions.length > 1 ? "s" : ""}',
                    style: AppTextStyles.iosCaption1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des cartes de séance
          ...daySessions.map((session) => _buildSessionCard(session)),
        ],
      ),
    );
  }

  /// Vue Semaine Complète regroupée par jour
  Widget _buildWeekView(BuildContext context) {
    final weekDays = controller.currentWeekDays;
    final weekSessions = controller.sessionsForCurrentWeek;

    if (weekSessions.isEmpty) {
      return StatePlaceholder.empty(
        title: 'Semaine libre',
        message: 'Aucune consultation programmée pour cette semaine.',
        actionLabel: '+ Planifier un rendez-vous',
        onAction: () async {
          final res = await Get.toNamed(AppRoutes.creationSeance);
          if (res == true) controller.loadAgenda(forceRefresh: true);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadAgenda(forceRefresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 120),
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final day = weekDays[index];
          final sessions = controller.sessionsForDate(day);
          if (sessions.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.formatDayDate(day),
                      style: AppTextStyles.iosSubhead.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${sessions.length})',
                      style: AppTextStyles.iosCaption1.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ...sessions.map((session) => _buildSessionCard(session)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(AgendaSessionItem session) {
    return IosCard(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      children: [
        IosCardTile(
          leading: session.isGroupe
              ? Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 24),
                )
              : PatientAvatar(
                  photoUrl: session.photoUrl,
                  initials: session.initials,
                  radius: 21,
                ),
          title: session.title,
          subtitle: '${session.heureDebut} — ${session.heureFin}${session.isGroupe && session.participants != null ? " • ${session.participants!.length} participant(s)" : ""}',
          showChevron: true,
          trailing: StatusBadge.active(label: session.statutLabel),
          onTap: () async {
            if (session.isGroupe) {
              await Get.toNamed(AppRoutes.compteRenduGroupe, arguments: session.id);
            } else {
              await Get.toNamed(AppRoutes.compteRenduSeance, arguments: session.id);
            }
            controller.loadAgenda(forceRefresh: true);
          },
        ),
      ],
    );
  }
}
