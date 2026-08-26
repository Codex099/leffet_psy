import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/seances_individuelles_controller.dart';
import '../../models/seance_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/creative_app_bar.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/ios_segmented_control.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';

class SeancesIndividuellesView extends GetView<SeancesIndividuellesController> {
  const SeancesIndividuellesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CreativeAppBar(
        title: 'Séances Individuelles',
        subtitle: 'Consultations & Créneaux Récurrents',
        showBackButton: true,
        actions: [
          // Bouton Créer Créneau Récurrent (Style Groupe)
          BouncyTap(
            onTap: () => _openNouveauCreneauModal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.repeat_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '+ Créneau',
                    style: AppTextStyles.iosCaption1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton Planifier Séance Ponctuelle
          BouncyTap(
            onTap: () async {
              final res = await Get.toNamed(AppRoutes.creationSeance);
              if (res == true) controller.loadData(forceRefresh: true);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_alarm_rounded, size: 20, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Onglets de Navigation (À venir / Historique / Toutes) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Obx(() => IosSegmentedControl<String>(
                    segments: const {
                      'a_venir': 'À venir',
                      'historique': 'Historique',
                      'toutes': 'Toutes',
                    },
                    selectedValue: controller.activeTab.value,
                    onValueChanged: (val) => controller.activeTab.value = val,
                  )),
            ),

            // ── Barre de Recherche ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 0.8),
                  boxShadow: AppColors.softShadow,
                ),
                child: TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  style: AppTextStyles.iosBody.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Rechercher patient, date, notes...',
                    hintStyle: AppTextStyles.iosCaption1.copyWith(color: AppColors.textHint),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.secondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    isDense: true,
                  ),
                ),
              ),
            ),

            // ── Liste des Séances Individuelles (1 Carte par Patient) ──
            Expanded(
              child: Obx(() {
                if (controller.status.value == 'loading') {
                  return StatePlaceholder.loading(message: 'Chargement des séances...');
                }
                if (controller.status.value == 'error') {
                  return StatePlaceholder.error(
                    message: controller.errorMessage.value,
                    onAction: () => controller.loadData(forceRefresh: true),
                  );
                }

                final groups = controller.filteredPatientGroups;

                if (groups.isEmpty) {
                  return StatePlaceholder.empty(
                    title: 'Aucune séance individuelle',
                    message: controller.activeTab.value == 'a_venir'
                        ? 'Aucune consultation n\'est programmée pour les prochains jours.'
                        : 'Aucune séance trouvée.',
                    actionLabel: '+ Planifier un créneau',
                    onAction: () => _openNouveauCreneauModal(context),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadData(forceRefresh: true),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 120),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _buildPatientGroupCard(context, group);
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

  Widget _buildPatientGroupCard(BuildContext context, PatientSeancesGroup group) {
    final hasNext = group.prochaineSeance != null;
    final nextTime = hasNext && group.prochaineSeance!.heureDebut.length >= 5
        ? group.prochaineSeance!.heureDebut.substring(0, 5)
        : (group.prochaineSeance?.heureDebut ?? '');
    final nextStr = hasNext
        ? '${group.prochaineSeance!.date} à $nextTime'
        : 'Aucune séance à venir';

    return IosCard(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      children: [
        IosCardTile(
          leading: PatientAvatar(
            initials: group.initials,
            radius: 22,
          ),
          title: group.patientName,
          subtitle: hasNext
              ? 'Prochain RDV : $nextStr · ${group.totalAVenir} séance(s) prévue(s)'
              : '${group.totalRealisees} séance(s) effectuée(s)',
          showChevron: true,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: group.totalAVenir > 0
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.textSecondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              group.totalAVenir > 0
                  ? '${group.totalAVenir} à venir'
                  : 'Historique',
              style: AppTextStyles.iosCaption2.copyWith(
                color: group.totalAVenir > 0
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          onTap: () => _openPatientDetailsModal(context, group),
        ),
      ],
    );
  }

  /// Modal Bottom Sheet listant tous les créneaux et séances d'un patient donné
  void _openPatientDetailsModal(BuildContext context, PatientSeancesGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // En-tête Patient
              Row(
                children: [
                  PatientAvatar(
                    initials: group.initials,
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.patientName,
                          style: AppTextStyles.iosTitle3.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${group.totalAVenir} séance(s) à venir · ${group.totalRealisees} réalisée(s)',
                          style: AppTextStyles.iosCaption1.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bouton Créer un nouveau créneau pour ce patient
              BouncyTap(
                onTap: () {
                  Navigator.pop(ctx);
                  controller.selectedPatientId.value = group.patientId;
                  _openNouveauCreneauModal(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Configurer un nouveau créneau',
                        style: AppTextStyles.iosSubhead.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'RENDEZ-VOUS PROGRAMMÉS (${group.seances.length})',
                style: AppTextStyles.iosCaption2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),

              // Liste des séances de ce patient
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: group.seances.length,
                  itemBuilder: (c, idx) {
                    final s = group.seances[idx];
                    final isDone = s.statut == 'realisee';
                    final isCancelled = s.statut == 'annulee';
                    final typeLabel = (s.descriptionEtat != null && s.descriptionEtat!.isNotEmpty)
                        ? 'Suivi Clinique'
                        : 'Consultation Thérapeutique';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.fieldBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppColors.secondary.withValues(alpha: 0.15)
                                : isCancelled
                                    ? AppColors.error.withValues(alpha: 0.12)
                                    : AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone
                                ? Icons.check_circle_outline_rounded
                                : isCancelled
                                    ? Icons.cancel_outlined
                                    : Icons.event_available_rounded,
                            color: isDone
                                ? AppColors.secondary
                                : isCancelled
                                    ? AppColors.error
                                    : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          '${s.date} · ${s.heureDebut} — ${s.heureFin}',
                          style: AppTextStyles.iosSubhead.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          typeLabel,
                          style: AppTextStyles.iosCaption1.copyWith(color: AppColors.textSecondary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? AppColors.secondary.withValues(alpha: 0.15)
                                    : isCancelled
                                        ? AppColors.error.withValues(alpha: 0.12)
                                        : AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isDone
                                    ? 'Réalisée'
                                    : isCancelled
                                        ? 'Annulée'
                                        : 'Planifiée',
                                style: AppTextStyles.iosCaption2.copyWith(
                                  color: isDone
                                      ? AppColors.primary
                                      : isCancelled
                                          ? AppColors.error
                                          : AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _openModifierSeanceModal(context, s);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Modal Bottom Sheet pour modifier/reporter le rendez-vous d'une séance ou accéder à son compte-rendu
  void _openModifierSeanceModal(BuildContext context, SeanceModel s) {
    final RxString selectedDate = s.date.obs;
    final RxString selectedDebut = s.heureDebut.length >= 5 ? s.heureDebut.substring(0, 5).obs : s.heureDebut.obs;
    final RxString selectedFin = s.heureFin.length >= 5 ? s.heureFin.substring(0, 5).obs : s.heureFin.obs;
    final RxString selectedStatut = s.statut.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poignée
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // En-tête avec Patient
                Row(
                  children: [
                    PatientAvatar(
                      initials: s.initials,
                      radius: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.patientFullName,
                            style: AppTextStyles.iosTitle3.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Consultation Individuelle',
                            style: AppTextStyles.iosCaption1.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Titre section
                Text(
                  'MODIFIER / REPORTER LE RENDEZ-VOUS',
                  style: AppTextStyles.iosCaption2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),

                // 1. Date du rendez-vous
                Text(
                  'Date de la consultation',
                  style: AppTextStyles.iosCaption1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    DateTime initialDate = DateTime.tryParse(selectedDate.value) ?? DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      selectedDate.value = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.fieldBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            final parsed = DateTime.tryParse(selectedDate.value) ?? DateTime.now();
                            final display = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(parsed);
                            return Text(
                              display,
                              style: AppTextStyles.iosSubhead.copyWith(fontWeight: FontWeight.w600),
                            );
                          }),
                        ),
                        const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Horaires Début & Fin
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Heure début',
                            style: AppTextStyles.iosCaption1.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final parts = selectedDebut.value.split(':');
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: int.tryParse(parts[0]) ?? 10,
                                  minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
                                ),
                              );
                              if (picked != null) {
                                selectedDebut.value =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.fieldBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border, width: 0.8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Obx(() => Text(
                                        selectedDebut.value,
                                        style: AppTextStyles.iosSubhead.copyWith(fontWeight: FontWeight.w700),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Heure fin',
                            style: AppTextStyles.iosCaption1.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final parts = selectedFin.value.split(':');
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: int.tryParse(parts[0]) ?? 10,
                                  minute: int.tryParse(parts.length > 1 ? parts[1] : '45') ?? 45,
                                ),
                              );
                              if (picked != null) {
                                selectedFin.value =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.fieldBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border, width: 0.8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 16, color: AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Obx(() => Text(
                                        selectedFin.value,
                                        style: AppTextStyles.iosSubhead.copyWith(fontWeight: FontWeight.w700),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. Statut
                Text(
                  'Statut',
                  style: AppTextStyles.iosCaption1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(() => Row(
                      children: [
                        Expanded(child: _buildStatutOption('planifiee', 'Planifiée', selectedStatut)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatutOption('realisee', 'Réalisée', selectedStatut)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatutOption('annulee', 'Annulée', selectedStatut)),
                      ],
                    )),
                const SizedBox(height: 22),

                // Bouton Valider le Changement
                BouncyTap(
                  onTap: () async {
                    final ok = await controller.modifierRendezVous(
                      seance: s,
                      newDate: selectedDate.value,
                      newHeureDebut: selectedDebut.value,
                      newHeureFin: selectedFin.value,
                      statut: selectedStatut.value,
                    );
                    if (ok) Get.back();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.oceanGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Valider les Changements',
                        style: AppTextStyles.iosHeadline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Bouton Rédiger Compte-Rendu Spécialiste
                BouncyTap(
                  onTap: () async {
                    Get.back();
                    final res = await Get.toNamed(
                      AppRoutes.compteRenduSpecialiste,
                      arguments: {'seance_id': s.id, 'is_groupe': false},
                    );
                    if (res == true) controller.loadData(forceRefresh: true);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment_turned_in_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Rédiger / Consulter Compte-Rendu',
                          style: AppTextStyles.iosSubhead.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Bouton Supprimer la Séance
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    label: Text(
                      'Supprimer cette séance',
                      style: AppTextStyles.iosCaption1.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      final confirm = await Get.dialog<bool>(
                        AlertDialog(
                          title: const Text('Confirmer la suppression'),
                          content: Text('Voulez-vous vraiment supprimer la séance de ${s.patientFullName} ?'),
                          actions: [
                            TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              style: TextButton.styleFrom(foregroundColor: AppColors.error),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        Get.back();
                        await controller.supprimerSeance(s.id);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatutOption(String val, String label, RxString selectedStatut) {
    final isSel = selectedStatut.value == val;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        selectedStatut.value = val;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? AppColors.primary : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.iosCaption1.copyWith(
              color: isSel ? Colors.white : AppColors.textPrimary,
              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Modal Bottom Sheet pour configurer un créneau récurrent (Système identique aux groupes)
  void _openNouveauCreneauModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poignée
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // En-tête
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nouveau Créneau Patient',
                      style: AppTextStyles.iosTitle3.copyWith(fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'Programmez des rendez-vous réguliers (ex: chaque lundi et mercredi à 10h).',
                  style: AppTextStyles.iosCaption1.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // 1. Sélection du Patient
                Text(
                  'Patient concerné',
                  style: AppTextStyles.iosCaption1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Obx(() => DropdownButtonHideUnderline(
                        child: DropdownButton<dynamic>(
                          value: controller.selectedPatientId.value,
                          isExpanded: true,
                          hint: Text('Sélectionner un patient...', style: AppTextStyles.iosSubhead),
                          items: controller.allPatients.map((p) {
                            return DropdownMenuItem<dynamic>(
                              value: p.id,
                              child: Text(
                                p.fullName,
                                style: AppTextStyles.iosSubhead.copyWith(fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            controller.selectedPatientId.value = val;
                          },
                        ),
                      )),
                ),
                const SizedBox(height: 16),

                // 2. Type de Créneau (Fixe vs Ponctuel par jour)
                Text(
                  'Type d\'horaires',
                  style: AppTextStyles.iosCaption1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(() => Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.fieldBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.setModeCreneaux('fixe'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: controller.modeCreneaux.value == 'fixe'
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Horaires Fixes',
                                    style: AppTextStyles.iosCaption1.copyWith(
                                      color: controller.modeCreneaux.value == 'fixe'
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.setModeCreneaux('ponctuel'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: controller.modeCreneaux.value == 'ponctuel'
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Ponctuel / Par Jour',
                                    style: AppTextStyles.iosCaption1.copyWith(
                                      color: controller.modeCreneaux.value == 'ponctuel'
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),

                // 3. Jours de la Semaine
                Text(
                  'Jours de récurrence',
                  style: AppTextStyles.iosCaption1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SeancesIndividuellesController.allDays.map((d) {
                        final isSel = controller.isDaySelected(d);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            controller.toggleDay(d);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : AppColors.fieldBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppColors.primary : AppColors.border,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              d,
                              style: AppTextStyles.iosCaption1.copyWith(
                                color: isSel ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                const SizedBox(height: 16),

                // 4. Horaires (Fixe vs Par Jour)
                Obx(() {
                  if (controller.modeCreneaux.value == 'fixe') {
                    // Mode Fixe : Heure début et fin uniques
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Heure de début (Fixe)',
                                style: AppTextStyles.iosCaption1.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final parts = controller.heureDebut.value.split(':');
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                      hour: int.tryParse(parts[0]) ?? 10,
                                      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
                                    ),
                                  );
                                  if (picked != null) {
                                    controller.heureDebut.value =
                                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.fieldBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Obx(() => Text(
                                            controller.heureDebut.value,
                                            style: AppTextStyles.iosSubhead.copyWith(fontWeight: FontWeight.w700),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Heure de fin (Fixe)',
                                style: AppTextStyles.iosCaption1.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final parts = controller.heureFin.value.split(':');
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                      hour: int.tryParse(parts[0]) ?? 10,
                                      minute: int.tryParse(parts.length > 1 ? parts[1] : '45') ?? 45,
                                    ),
                                  );
                                  if (picked != null) {
                                    controller.heureFin.value =
                                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.fieldBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.secondary),
                                      const SizedBox(width: 8),
                                      Obx(() => Text(
                                            controller.heureFin.value,
                                            style: AppTextStyles.iosSubhead.copyWith(fontWeight: FontWeight.w700),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Mode Ponctuel / Par Jour : Horaires personnalisés par jour
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horaires personnalisés par jour',
                        style: AppTextStyles.iosCaption1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...controller.selectedDays.map((d) {
                        final start = controller.getSlotStartForDay(d);
                        final end = controller.getSlotEndForDay(d);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border, width: 0.8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      d.toUpperCase(),
                                      style: AppTextStyles.iosCaption2.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Horaires pour ce jour',
                                    style: AppTextStyles.iosCaption1.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final parts = start.split(':');
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay(
                                            hour: int.tryParse(parts[0]) ?? 10,
                                            minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
                                          ),
                                        );
                                        if (picked != null) {
                                          final newStart =
                                              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                          controller.updateSlotForDay(d, debut: newStart);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.schedule_rounded, size: 15, color: AppColors.primary),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Début : $start',
                                              style: AppTextStyles.iosCaption1.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final parts = end.split(':');
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay(
                                            hour: int.tryParse(parts[0]) ?? 10,
                                            minute: int.tryParse(parts.length > 1 ? parts[1] : '45') ?? 45,
                                          ),
                                        );
                                        if (picked != null) {
                                          final newEnd =
                                              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                          controller.updateSlotForDay(d, fin: newEnd);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.schedule_rounded, size: 15, color: AppColors.secondary),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Fin : $end',
                                              style: AppTextStyles.iosCaption1.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                }),
                const SizedBox(height: 24),

                // Bouton Enregistrer & Générer
                BouncyTap(
                  onTap: () async {
                    final ok = await controller.enregistrerCreneauRecurrent();
                    if (ok) Get.back();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.oceanGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Enregistrer le Créneau & Générer',
                        style: AppTextStyles.iosHeadline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
