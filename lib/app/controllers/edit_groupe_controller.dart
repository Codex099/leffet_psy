import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/groupe_model.dart';
import '../models/patient_model.dart';
import '../services/auth_service.dart';
import '../services/cache_manager.dart';
import '../services/employee_service.dart';
import '../services/groupe_service.dart';
import '../services/patient_service.dart';
import '../services/seance_groupe_service.dart';
import '../utils/json_utils.dart';
import 'accueil_controller.dart';
import 'agenda_controller.dart';

/// Un créneau horaire pour un jour donné
class DaySlot {
  final String day;
  final String heureDebut;
  final String heureFin;

  DaySlot({required this.day, required this.heureDebut, required this.heureFin});

  DaySlot copyWith({String? heureDebut, String? heureFin}) => DaySlot(
        day: day,
        heureDebut: heureDebut ?? this.heureDebut,
        heureFin: heureFin ?? this.heureFin,
      );
}

class EditGroupeController extends GetxController {
  final GroupeService _groupeService = GroupeService();
  final EmployeeService _employeeService = EmployeeService();
  final PatientService _patientService = PatientService();
  final SeanceGroupeService _seanceGroupeService = SeanceGroupeService();
  final AuthService _authService = AuthService();

  final RxBool isAdmin = false.obs;

  // Current groupe being edited (null = create mode)
  dynamic groupeId;

  // Form fields
  final nom = ''.obs;
 final description = ''.obs;
 final typePlanning = 'fixe'.obs;
 // Planning récurrent : liste de créneaux (un ou plusieurs par jour)
  final RxList<DaySlot> daySlots = <DaySlot>[].obs;

  // Mode des créneaux : 'fixe' (mêmes heures pour tous les jours) ou 'ponctuel' (heure personnalisée par jour)
 final RxString modeCreneaux = 'fixe'.obs;
 final RxString globalHeureDebut = '09:00'.obs;
 final RxString globalHeureFin = '09:45'.obs;

 // Employees — RxSet pour une réactivité correcte des checkboxes
  final RxList<EmployeeModel> availableEmployees = <EmployeeModel>[].obs;
  final RxSet<dynamic> selectedEmployeeIds = <dynamic>{}.obs;
  final RxString employeesStatus = 'loading'.obs;

 // Patients in group (from API)
  final RxList<Map<String, dynamic>> groupePatients = <Map<String, dynamic>>[].obs;

  // All patients for patient picker
  final RxList<PatientModel> allPatients = <PatientModel>[].obs;
  final RxString patientsStatus = 'loading'.obs;

 final RxString status = 'success'.obs;
 final RxString errorMessage = ''.obs;

 // ── Jours de la semaine disponibles ──
  static const List<String> allDays = ['lun', 'mar', 'mer', 'jeu', 'ven', 'sam', 'dim'];
 static const List<String> allDayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

 static const Map<String, String> dayToFull = {
    'lun': 'lundi',
   'mar': 'mardi',
   'mer': 'mercredi',
   'jeu': 'jeudi',
   'ven': 'vendredi',
   'sam': 'samedi',
   'dim': 'dimanche',
   'lundi': 'lundi',
   'mardi': 'mardi',
   'mercredi': 'mercredi',
   'jeudi': 'jeudi',
   'vendredi': 'vendredi',
   'samedi': 'samedi',
   'dimanche': 'dimanche',
 };

  static const Map<String, String> fullToShort = {
    'lundi': 'lun',
   'mardi': 'mar',
   'mercredi': 'mer',
   'jeudi': 'jeu',
   'vendredi': 'ven',
   'samedi': 'sam',
   'dimanche': 'dim',
 };

  @override
  void onInit() {
    super.onInit();
    groupeId = extractIdParam(Get.arguments, Get.parameters);
    _checkAdminAndInit();
  }

  Future<void> _checkAdminAndInit() async {
    try {
      final me = await _authService.getCachedUser() ?? await _authService.getMe();
      isAdmin.value = me.role.toLowerCase() == 'admin';
      if (!isAdmin.value) {
        Get.back();
        Get.snackbar(
          'Accès restreint'.tr,
          'Seul l\'administrateur peut créer ou modifier un groupe thérapeutique.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } catch (_) {}
    _loadEmployees();
    _loadAllPatients();
    if (groupeId != null) {
      _loadGroupe(groupeId!);
    }
  }

  // ──────────────────────────────────────────
  // LOAD
  // ──────────────────────────────────────────

  Future<void> _loadGroupe(dynamic id) async {
    try {
      status.value = 'loading';
     final groupe = await _groupeService.getGroupe(id);
      nom.value = groupe.nom;
      description.value = groupe.description ?? '';
     typePlanning.value = groupe.typePlanning;
      
      // Déduplication stricte par identifiant patient
      final rawPatients = groupe.patients ?? [];
      final seenIds = <String>{};
      final uniquePatients = <Map<String, dynamic>>[];
      for (final p in rawPatients) {
        final pid = parseId(p['id'] ?? p['patient_id'])?.toString();
       if (pid != null && !seenIds.contains(pid)) {
          seenIds.add(pid);
          uniquePatients.add(p);
        }
      }
      groupePatients.value = uniquePatients;

      // Pré-remplir les créneaux récurrents existants
      if (groupe.planningRecurrent != null && groupe.planningRecurrent!.isNotEmpty) {
        daySlots.value = groupe.planningRecurrent!.map((slot) {
          final rawDay = (slot['jour_semaine'] ?? '').toString().toLowerCase();
         final shortDay = fullToShort[rawDay] ?? rawDay;
          return DaySlot(
            day: shortDay,
            heureDebut: slot['heure_debut'] ?? '09:00',
           heureFin: slot['heure_fin'] ?? '09:45',
         );
        }).toList();
      }

      // Pré-remplir les employee ids si l'API les retourne
      if (groupe.employeeIds != null) {
        selectedEmployeeIds.addAll(groupe.employeeIds!);
      }
      status.value = 'success';
   } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
   }
  }

  Future<void> _loadEmployees() async {
    try {
      employeesStatus.value = 'loading';
     final list = await _employeeService.getEmployees();
      availableEmployees.value = list;
      employeesStatus.value = 'success';
   } catch (_) {
      employeesStatus.value = 'error';
   }
  }

  Future<void> _loadAllPatients() async {
    try {
      patientsStatus.value = 'loading';
     final list = await _patientService.getPatients(actif: true);
      allPatients.value = list;
      patientsStatus.value = 'success';
   } catch (_) {
      patientsStatus.value = 'error';
   }
  }

  // ──────────────────────────────────────────
  // EMPLOYEE SELECTION (RxSet — réactivité correcte)
  // ──────────────────────────────────────────

  void toggleEmployee(dynamic employeeId) {
    if (selectedEmployeeIds.contains(employeeId)) {
      selectedEmployeeIds.remove(employeeId);
    } else {
      selectedEmployeeIds.add(employeeId);
    }
    // Force refresh explicite de l'observable
    selectedEmployeeIds.refresh();
  }

  bool isEmployeeSelected(dynamic id) => selectedEmployeeIds.contains(id);

  // ──────────────────────────────────────────
  // PLANNING RÉCURRENT — MULTI-CRÉNEAUX
  // ──────────────────────────────────────────

  bool isDayActive(String day) => daySlots.any((s) => s.day == day);

  List<DaySlot> slotsForDay(String day) => daySlots.where((s) => s.day == day).toList();

  void setModeCreneaux(String mode) {
    modeCreneaux.value = mode;
    if (mode == 'fixe') {
     for (int i = 0; i < daySlots.length; i++) {
        daySlots[i] = daySlots[i].copyWith(
          heureDebut: globalHeureDebut.value,
          heureFin: globalHeureFin.value,
        );
      }
      daySlots.refresh();
    }
  }

  void updateGlobalStart(String val) {
    globalHeureDebut.value = val;
    if (modeCreneaux.value == 'fixe') {
     for (int i = 0; i < daySlots.length; i++) {
        daySlots[i] = daySlots[i].copyWith(heureDebut: val);
      }
      daySlots.refresh();
    }
  }

  void updateGlobalEnd(String val) {
    globalHeureFin.value = val;
    if (modeCreneaux.value == 'fixe') {
     for (int i = 0; i < daySlots.length; i++) {
        daySlots[i] = daySlots[i].copyWith(heureFin: val);
      }
      daySlots.refresh();
    }
  }

  /// Active ou désactive un jour. Si activation → ajoute un créneau par défaut.
  void toggleDay(String day) {
    if (isDayActive(day)) {
      daySlots.removeWhere((s) => s.day == day);
    } else {
      final start = modeCreneaux.value == 'fixe' ? globalHeureDebut.value : '09:00';
     final end = modeCreneaux.value == 'fixe' ? globalHeureFin.value : '09:45';
     daySlots.add(DaySlot(day: day, heureDebut: start, heureFin: end));
    }
    daySlots.refresh();
  }

  void addSlotForDay(String day) {
    daySlots.add(DaySlot(day: day, heureDebut: '09:00', heureFin: '09:45'));
   daySlots.refresh();
  }

  void removeSlot(DaySlot slot) {
    daySlots.remove(slot);
    daySlots.refresh();
  }

  void updateSlotStart(DaySlot slot, String value) {
    final idx = daySlots.indexOf(slot);
    if (idx >= 0) {
      daySlots[idx] = slot.copyWith(heureDebut: value);
      daySlots.refresh();
    }
  }

  void updateSlotEnd(DaySlot slot, String value) {
    final idx = daySlots.indexOf(slot);
    if (idx >= 0) {
      daySlots[idx] = slot.copyWith(heureFin: value);
      daySlots.refresh();
    }
  }

  // ──────────────────────────────────────────
  // PATIENTS
  // ──────────────────────────────────────────

  bool isPatientInGroupe(dynamic patientId) {
    if (patientId == null) return false;
    final targetId = parseId(patientId)?.toString();
    if (targetId == null) return false;
    return groupePatients.any((p) {
      final pid = parseId(p['id'] ?? p['patient_id'])?.toString();
     return pid != null && pid == targetId;
    });
  }

  Future<void> addPatientsToGroupe(List<dynamic> patientIds) async {
    // Filtrer pour ne garder QUE les patients non encore inscrits (zéro doublon)
    final toAdd = patientIds.where((pid) => !isPatientInGroupe(pid)).toSet().toList();
    if (toAdd.isEmpty) {
      Get.snackbar('Information', 'Ce(s) patient(s) font déjà partie de ce groupe.',
         snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (groupeId == null) {
      // Groupe non encore enregistré : ajouter localement à la liste des membres sans doublon
      for (final pid in toAdd) {
        final pat = allPatients.firstWhereOrNull((p) => p.id == pid);
        if (pat != null) {
          groupePatients.add({
            'id': pat.id,
           'nom': pat.nom,
           'prenom': pat.prenom,
         });
        }
      }
      groupePatients.refresh();
      Get.snackbar('Sélection', '${toAdd.length} patient(s) sélectionné(s) pour ce groupe.',
         snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      status.value = 'loading';
     for (final pid in toAdd) {
        try {
          await _groupeService.addPatientToGroupe(groupeId!, pid);
        } catch (_) {}
      }
      await _loadGroupe(groupeId!);
      status.value = 'success';
     Get.snackbar('Succès', '${toAdd.length} patient(s) ajouté(s) au groupe d\'un seul coup.',
         snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      status.value = 'error';
     Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
   }
  }

  Future<void> addPatientToGroupe(dynamic patientId) async {
    await addPatientsToGroupe([patientId]);
  }

  Future<void> removePatientFromGroupe(dynamic patientId) async {
    final targetId = parseId(patientId)?.toString();
    if (groupeId == null) {
      groupePatients.removeWhere((p) => parseId(p['id'] ?? p['patient_id'])?.toString() == targetId);
     groupePatients.refresh();
      return;
    }
    try {
      await _groupeService.removePatientFromGroupe(groupeId!, patientId);
      await _loadGroupe(groupeId!);
      Get.snackbar('Succès', 'Patient retiré du groupe.', snackPosition: SnackPosition.BOTTOM);
   } catch (e) {
      Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
   }
  }

  // ──────────────────────────────────────────
  // SAVE
  // ──────────────────────────────────────────

  Future<void> saveGroupe() async {
    if (nom.value.trim().isEmpty) {
      Get.snackbar('Champ requis', 'Le nom du groupe est obligatoire.',
         snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      status.value = 'loading';
      final data = {
        'nom': nom.value.trim(),
        'description': description.value.trim().isEmpty ? null : description.value.trim(),
        'type_planning': typePlanning.value,
        if (selectedEmployeeIds.isNotEmpty) ...{
          'employee_ids': selectedEmployeeIds.toList(),
          'employe_ids': selectedEmployeeIds.toList(),
        },
      };

      final bool isNewGroup = (groupeId == null);
      GroupeModel saved;
      if (groupeId != null) {
        saved = await _groupeService.updateGroupe(groupeId!, data);
      } else {
        saved = await _groupeService.createGroupe(data);
        groupeId = saved.id;
      }

      // Si nouveau groupe avec des patients présélectionnés
      if (isNewGroup && groupePatients.isNotEmpty && groupeId != null) {
        for (final p in List.from(groupePatients)) {
          final pid = parseId(p['id'] ?? p['patient_id']);
         if (pid != null) {
            try {
              await _groupeService.addPatientToGroupe(groupeId!, pid);
            } catch (_) {}
          }
        }
      }

      // Enregistrement des créneaux récurrents et génération des séances sur l'agenda
      if (daySlots.isNotEmpty && groupeId != null) {
        for (final slot in daySlots) {
          final fullDay = dayToFull[slot.day.toLowerCase()] ?? slot.day;
          try {
            await _groupeService.setPlanningRecurrent(groupeId!, {
              'jour_semaine': fullDay,
             'heure_debut': slot.heureDebut,
             'heure_fin': slot.heureFin,
           });

            // Création de la séance de groupe pour le jour correspondant de la semaine
            final targetDate = _getNextWeekdayDate(slot.day);
            final dateStr = targetDate.toIso8601String().split('T').first;
           await _seanceGroupeService.createSeanceGroupe({
              'groupe_id': groupeId!,
             'date': dateStr,
             'heure_debut': slot.heureDebut,
             'heure_fin': slot.heureFin,
             'statut': 'prevue',
             if (selectedEmployeeIds.isNotEmpty) 'employe_id': selectedEmployeeIds.first,
           });
          } catch (_) {}
        }
      }

      AppCacheManager.invalidateTag(CacheTags.groupes);
      AppCacheManager.invalidateTag(CacheTags.seances);
      AppCacheManager.invalidateTag(CacheTags.dashboard);

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

      status.value = 'success';
     Get.back(result: true);
      Get.snackbar(
        'Succès',
       groupeId != null ? 'Groupe mis à jour et créneaux planifiés.' : 'Groupe créé et créneaux planifiés.',
       snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
     Get.snackbar('Erreur', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
   }
  }

  DateTime _getNextWeekdayDate(String dayStr) {
    final dayMap = {
      'lundi': DateTime.monday,
     'lun': DateTime.monday,
     'mardi': DateTime.tuesday,
     'mar': DateTime.tuesday,
     'mercredi': DateTime.wednesday,
     'mer': DateTime.wednesday,
     'jeudi': DateTime.thursday,
     'jeu': DateTime.thursday,
     'vendredi': DateTime.friday,
     'ven': DateTime.friday,
     'samedi': DateTime.saturday,
     'sam': DateTime.saturday,
     'dimanche': DateTime.sunday,
     'dim': DateTime.sunday,
    };
    final targetWeekday = dayMap[dayStr.toLowerCase()] ?? DateTime.monday;
    final now = DateTime.now();
    int diff = targetWeekday - now.weekday;
    if (diff < 0) diff += 7;
    return now.add(Duration(days: diff));
  }
}