import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/seance_model.dart';
import '../services/auth_service.dart';
import '../services/cache_manager.dart';
import '../services/patient_service.dart';
import '../services/seance_service.dart';
import 'accueil_controller.dart';
import 'agenda_controller.dart';

/// Regroupement de toutes les séances et créneaux par Patient
class PatientSeancesGroup {
 final dynamic patientId;
  final String patientName;
  final String? photoUrl;
  final String initials;
  final List<SeanceModel> seances;
  final List<String> recurringDays;
  final SeanceModel? prochaineSeance;
  final int totalAVenir;
  final int totalRealisees;

  PatientSeancesGroup({
    required this.patientId,
    required this.patientName,
    this.photoUrl,
    required this.initials,
    required this.seances,
    required this.recurringDays,
    this.prochaineSeance,
    required this.totalAVenir,
    required this.totalRealisees,
  });
}

class SeancesIndividuellesController extends GetxController {
  final SeanceService _seanceService = SeanceService();
  final PatientService _patientService = PatientService();
  final PlanningRecurrentService _planningService = PlanningRecurrentService();
  final AuthService _authService = AuthService();

  final RxList<SeanceModel> allSeances = <SeanceModel>[].obs;
  final RxList<PatientModel> allPatients = <PatientModel>[].obs;
  final RxBool isAdmin = false.obs;

  final RxString status = 'loading'.obs;
 final RxString errorMessage = ''.obs;

 // Tabs: 'a_venir' | 'historique' | 'toutes'
 final RxString activeTab = 'a_venir'.obs;
 final RxString searchQuery = ''.obs;

 // ── Formulaire Créneau Récurrent Patient ──
  final Rx<dynamic> selectedPatientId = Rx<dynamic>(null);
  final RxList<String> selectedDays = <String>['Lun', 'Mer'].obs;
 final RxString modeCreneaux = 'fixe'.obs;
 final RxString heureDebut = '10:00'.obs;
 final RxString heureFin = '10:45'.obs;
 final RxMap<String, Map<String, String>> daySlotsMap = <String, Map<String, String>>{}.obs;
  final RxString patientSearchQuery = ''.obs;

 Timer? _debounceTimer;

  static const _cacheDuration = Duration(minutes: 2);

  static const List<String> allDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
 static const List<String> allDayFullNames = [
    'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
 ];

  static const Map<String, String> dayToFull = {
    'Lun': 'lundi',
   'Mar': 'mardi',
   'Mer': 'mercredi',
   'Jeu': 'jeudi',
   'Ven': 'vendredi',
   'Sam': 'samedi',
   'Dim': 'dimanche',
   'lun': 'lundi',
   'mar': 'mardi',
   'mer': 'mercredi',
   'jeu': 'jeudi',
   'ven': 'vendredi',
   'sam': 'samedi',
   'dim': 'dimanche',
 };

  @override
  void onInit() {
    super.onInit();
    _checkAdmin();
    _loadFromCache();
    loadData();
  }

  Future<void> _checkAdmin() async {
    try {
      final me = await _authService.getCachedUser() ?? await _authService.getMe();
      isAdmin.value = me.role.toLowerCase() == 'admin';
    } catch (_) {}
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.seancesIndivList)) {
      loadData();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _loadFromCache() {
    final cached = AppCacheManager.get<Map<String, dynamic>>(CacheKeys.seancesIndivList);
    if (cached != null) {
      if (cached['seances'] is List<SeanceModel>) {
       allSeances.value = cached['seances'] as List<SeanceModel>;
     }
      if (cached['patients'] is List<PatientModel>) {
       allPatients.value = cached['patients'] as List<PatientModel>;
     }
      if (allPatients.isNotEmpty && selectedPatientId.value == null) {
        selectedPatientId.value = allPatients.first.id;
      }
      status.value = 'success';
   }
  }

  Future<void> loadData({bool forceRefresh = false}) async {
    if (AppCacheManager.isFresh(CacheKeys.seancesIndivList) && !forceRefresh && allSeances.isNotEmpty) {
      return;
    }

    if (allSeances.isEmpty) {
      status.value = 'loading';
   }

    try {
      final results = await Future.wait([
        _seanceService.getSeances(),
        _patientService.getPatients(),
      ]);

      final seancesList = results[0] as List<SeanceModel>;
      final patientsList = results[1] as List<PatientModel>;

      seancesList.sort((a, b) {
        final compDate = b.date.compareTo(a.date);
        if (compDate != 0) return compDate;
        return a.heureDebut.compareTo(b.heureDebut);
      });

      allSeances.value = seancesList;
      allPatients.value = patientsList;

      if (patientsList.isNotEmpty && selectedPatientId.value == null) {
        selectedPatientId.value = patientsList.first.id;
      }

      AppCacheManager.set<Map<String, dynamic>>(
        CacheKeys.seancesIndivList,
        {
          'seances': seancesList,
         'patients': patientsList,
       },
        ttl: _cacheDuration,
        tags: {CacheTags.seances, CacheTags.patients},
      );

      status.value = 'success';
   } catch (e) {
      if (allSeances.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
     }
    }
  }

  Future<void> refreshData() => loadData(forceRefresh: true);

  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 180), () {
      searchQuery.value = query;
    });
  }

  /// Liste regroupée par Patient (1 seule carte par patient dans la liste)
  List<PatientSeancesGroup> get filteredPatientGroups {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
   final Map<String, List<SeanceModel>> byPatient = {};

    for (final s in allSeances) {
      final pid = (s.patientId ?? s.patient?['id'] ?? s.patientFullName).toString();
     byPatient.putIfAbsent(pid, () => []).add(s);
    }

    final groups = <PatientSeancesGroup>[];

    for (final entry in byPatient.entries) {
      final pid = entry.key;
      final seanceList = entry.value;

      seanceList.sort((a, b) {
        final d = a.date.compareTo(b.date);
        if (d != 0) return d;
        return a.heureDebut.compareTo(b.heureDebut);
      });

      final patient = allPatients.firstWhereOrNull(
        (p) =>
            p.id.toString() == pid ||
            p.fullName.toLowerCase() ==
                seanceList.first.patientFullName.toLowerCase(),
      );

      final pName = patient?.fullName ??
          (seanceList.first.patientFullName.isNotEmpty
              ? seanceList.first.patientFullName
              : 'Patient #$pid');
     final pInitials = patient?.initials ?? seanceList.first.initials;
      final pPhoto = patient?.photoUrl ?? seanceList.first.photoUrl;

      final aVenirSeances = seanceList
          .where((s) => s.date.compareTo(todayStr) >= 0 && s.statut != 'faite')
         .toList();
      final realiseesSeances = seanceList
          .where((s) => s.date.compareTo(todayStr) < 0 || s.statut == 'faite')
         .toList();

      final prochaine =
          aVenirSeances.isNotEmpty ? aVenirSeances.first : null;

      final daySet = <String>{};
      for (final s in seanceList) {
        final dt = DateTime.tryParse(s.date);
        if (dt != null) {
          const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
         daySet.add(days[(dt.weekday - 1) % 7]);
        }
      }

      final group = PatientSeancesGroup(
        patientId: patient?.id ?? pid,
        patientName: pName,
        photoUrl: pPhoto,
        initials: pInitials,
        seances: seanceList,
        recurringDays: daySet.toList(),
        prochaineSeance: prochaine,
        totalAVenir: aVenirSeances.length,
        totalRealisees: realiseesSeances.length,
      );

      if (activeTab.value == 'a_venir' && group.totalAVenir == 0) {
       continue;
      }
      if (activeTab.value == 'historique' && group.totalRealisees == 0) {
       continue;
      }

      final q = searchQuery.value.toLowerCase().trim();
      if (q.isNotEmpty) {
        final matchName = pName.toLowerCase().contains(q);
        final matchDates = seanceList.any((s) =>
            s.date.contains(q) ||
            (s.descriptionEtat ?? '').toLowerCase().contains(q));
       if (!matchName && !matchDates) continue;
      }

      groups.add(group);
    }

    groups.sort((a, b) {
      if (a.prochaineSeance != null && b.prochaineSeance != null) {
        final d = a.prochaineSeance!.date.compareTo(b.prochaineSeance!.date);
        if (d != 0) return d;
        return a.prochaineSeance!.heureDebut
            .compareTo(b.prochaineSeance!.heureDebut);
      }
      if (a.prochaineSeance != null) return -1;
      if (b.prochaineSeance != null) return 1;
      return a.patientName.compareTo(b.patientName);
    });

    return groups;
  }

  List<SeanceModel> get filteredSeances {
    var list = allSeances.toList();
    final todayStr = DateTime.now().toIso8601String().split('T').first;

   if (activeTab.value == 'a_venir') {
     list = list.where((s) => s.date.compareTo(todayStr) >= 0 && s.statut != 'faite').toList();
     list.sort((a, b) {
        final d = a.date.compareTo(b.date);
        if (d != 0) return d;
        return a.heureDebut.compareTo(b.heureDebut);
      });
    } else if (activeTab.value == 'historique') {
     list = list.where((s) => s.date.compareTo(todayStr) < 0 || s.statut == 'faite').toList();
   }

    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((s) {
        final pName = s.patientFullName.toLowerCase();
        final date = s.date.toLowerCase();
        final desc = (s.descriptionEtat ?? '').toLowerCase();
       return pName.contains(q) || date.contains(q) || desc.contains(q);
      }).toList();
    }

    return list;
  }

  List<PatientModel> get searchedPatients {
    final q = patientSearchQuery.value.toLowerCase().trim();
    if (q.isEmpty) return allPatients;
    return allPatients.where((p) => p.fullName.toLowerCase().contains(q)).toList();
  }

  String getPatientName(dynamic id) {
    final pat = allPatients.firstWhereOrNull((p) => p.id == id);
    return pat?.fullName ?? 'Patient #$id';
 }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      if (selectedDays.length > 1) {
        selectedDays.remove(day);
      }
    } else {
      selectedDays.add(day);
    }
  }

  void setModeCreneaux(String mode) {
    modeCreneaux.value = mode;
  }

  String getSlotStartForDay(String day) {
    return daySlotsMap[day]?['debut'] ?? heureDebut.value;
 }

  String getSlotEndForDay(String day) {
    return daySlotsMap[day]?['fin'] ?? heureFin.value;
 }

  void updateSlotForDay(String day, {String? debut, String? fin}) {
    final cur = daySlotsMap[day] ?? {'debut': heureDebut.value, 'fin': heureFin.value};
   daySlotsMap[day] = {
      'debut': debut ?? cur['debut'] ?? heureDebut.value,
     'fin': fin ?? cur['fin'] ?? heureFin.value,
   };
    daySlotsMap.refresh();
  }

  bool isDaySelected(String day) => selectedDays.contains(day);

  Future<bool> enregistrerCreneauRecurrent() async {
    if (selectedPatientId.value == null) {
      Get.snackbar('Erreur', 'Veuillez sélectionner un patient.', snackPosition: SnackPosition.BOTTOM);
     return false;
    }
    if (selectedDays.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez sélectionner au moins un jour.', snackPosition: SnackPosition.BOTTOM);
     return false;
    }

    try {
      if (modeCreneaux.value == 'fixe') {
       final fullDays = selectedDays.map((d) => dayToFull[d] ?? d.toLowerCase()).toList();

        await _planningService.setPlanningRecurrent(selectedPatientId.value, {
          'jours_semaine': fullDays,
         'heure_debut': heureDebut.value,
         'heure_fin': heureFin.value,
       });

        try {
          await _planningService.genererSeances(selectedPatientId.value);
        } catch (_) {}
      } else {
        for (final day in selectedDays) {
          final fullDay = dayToFull[day] ?? day.toLowerCase();
          final start = getSlotStartForDay(day);
          final end = getSlotEndForDay(day);

          await _planningService.setPlanningRecurrent(selectedPatientId.value, {
            'jours_semaine': [fullDay],
           'heure_debut': start,
           'heure_fin': end,
         });

          try {
            await _planningService.genererSeances(selectedPatientId.value);
          } catch (_) {}
        }
      }

      AppCacheManager.invalidateTag(CacheTags.seances);
      AppCacheManager.invalidateTag(CacheTags.dashboard);

      await loadData(forceRefresh: true);
      try {
        if (Get.isRegistered<AgendaController>()) {
          Get.find<AgendaController>().loadAgenda(forceRefresh: true);
        }
      } catch (_) {}
      try {
        if (Get.isRegistered<AccueilController>()) {
          Get.find<AccueilController>().loadDashboard(forceRefresh: true);
        }
      } catch (_) {}

      Get.snackbar(
        'Créneau enregistré',
       'Le planning a été configuré et synchronisé sur l\'agenda.',
       snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.85),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'enregistrer le créneau : $e', snackPosition: SnackPosition.BOTTOM);
     return false;
    }
  }

  Future<bool> modifierRendezVous({
    required SeanceModel seance,
    required String newDate,
    required String newHeureDebut,
    required String newHeureFin,
    required String statut,
  }) async {
    try {
      if (newDate == seance.date) {
        await _seanceService.updateSeance(seance.id, {
          'heure_debut': newHeureDebut,
         'heure_fin': newHeureFin,
         'statut': statut,
       });
      } else {
        await _seanceService.deleteSeance(seance.id);
        await _seanceService.createSeance({
          'patient_id': seance.patientId,
         'date': newDate,
         'heure_debut': newHeureDebut,
         'heure_fin': newHeureFin,
         'statut': statut,
         'employe_ids': seance.employeIds,
         if (seance.descriptionEtat != null) 'description_etat': seance.descriptionEtat,
       });
      }

      AppCacheManager.invalidateTag(CacheTags.seances);
      AppCacheManager.invalidateTag(CacheTags.dashboard);

      await loadData(forceRefresh: true);

      try {
        if (Get.isRegistered<AgendaController>()) {
          Get.find<AgendaController>().loadAgenda(forceRefresh: true);
        }
      } catch (_) {}
      try {
        if (Get.isRegistered<AccueilController>()) {
          Get.find<AccueilController>().loadDashboard(forceRefresh: true);
        }
      } catch (_) {}

      Get.snackbar(
        'Rendez-vous mis à jour',
       'La séance a été reprogrammée au $newDate de $newHeureDebut à $newHeureFin.',
       snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier le rendez-vous : $e', snackPosition: SnackPosition.BOTTOM);
     return false;
    }
  }

  Future<bool> supprimerSeance(dynamic seanceId) async {
    try {
      await _seanceService.deleteSeance(seanceId);
      AppCacheManager.invalidateTag(CacheTags.seances);
      AppCacheManager.invalidateTag(CacheTags.dashboard);
      await loadData(forceRefresh: true);

      try {
        if (Get.isRegistered<AgendaController>()) {
          Get.find<AgendaController>().loadAgenda(forceRefresh: true);
        }
      } catch (_) {}
      try {
        if (Get.isRegistered<AccueilController>()) {
          Get.find<AccueilController>().loadDashboard(forceRefresh: true);
        }
      } catch (_) {}

      Get.snackbar('Séance supprimée', 'Le rendez-vous a été retiré du planning.', snackPosition: SnackPosition.BOTTOM);
     return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la séance : $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
