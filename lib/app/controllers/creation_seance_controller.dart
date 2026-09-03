import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/groupe_model.dart';
import '../models/employee_model.dart';
import '../services/cache_manager.dart';
import '../services/patient_service.dart';
import '../services/groupe_service.dart';
import '../services/employee_service.dart';
import '../services/seance_service.dart';
import '../services/seance_groupe_service.dart';
import '../services/tache_service.dart';
import '../utils/json_utils.dart';
import 'accueil_controller.dart';
import 'agenda_controller.dart';

class CreationSeanceController extends GetxController {
 final SeanceService _seanceService = SeanceService();
  final SeanceGroupeService _seanceGroupeService = SeanceGroupeService();
  final PatientService _patientService = PatientService();
  final GroupeService _groupeService = GroupeService();
  final EmployeeService _employeeService = EmployeeService();
  final TacheService _tacheService = TacheService();

  final typeSeance = 'individuelle'.obs; // 'individuelle' | 'groupe'
 final patients = <PatientModel>[].obs;
  final groupes = <GroupeModel>[].obs;
  final employees = <EmployeeModel>[].obs;

  final selectedPatientId = Rx<dynamic>(null);
  final selectedGroupeId = Rx<dynamic>(null);
  final selectedEmployeeIds = <dynamic>[].obs;

  final date = ''.obs;
 final heureDebut = '10:00'.obs;
 final heureFin = '10:45'.obs;

 final RxString status = 'loading'.obs;
 final RxString errorMessage = ''.obs;

 @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    date.value = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
   _loadFromCache();
    loadOptions();
  }

  void _loadFromCache() {
    final cachedPatients = AppCacheManager.get<List<PatientModel>>(CacheKeys.patientsList);
    if (cachedPatients != null && cachedPatients.isNotEmpty) {
      patients.value = cachedPatients.where((p) => p.estActif).toList();
      if (selectedPatientId.value == null && patients.isNotEmpty) {
        selectedPatientId.value = patients.first.id;
      }
    }
    final cachedGroupes = AppCacheManager.get<List<GroupeModel>>(CacheKeys.groupesList);
    if (cachedGroupes != null && cachedGroupes.isNotEmpty) {
      groupes.value = cachedGroupes;
      if (selectedGroupeId.value == null && groupes.isNotEmpty) {
        selectedGroupeId.value = groupes.first.id;
      }
    }
    final cachedEmps = AppCacheManager.get<List<EmployeeModel>>(CacheKeys.employesList);
    if (cachedEmps != null && cachedEmps.isNotEmpty) {
      employees.value = cachedEmps;
    }
    if (patients.isNotEmpty || groupes.isNotEmpty) {
      status.value = 'success';
   }
  }

  Future<void> loadOptions() async {
    try {
      if (patients.isEmpty && groupes.isEmpty) {
        status.value = 'loading';
     }
      final fetchedPatients = await _patientService.getPatients(actif: true);
      final fetchedGroupes = await _groupeService.getGroupes();
      final fetchedEmployees = await _employeeService.getEmployees();

      patients.value = fetchedPatients;
      groupes.value = fetchedGroupes;
      employees.value = fetchedEmployees;

      if (patients.isNotEmpty && selectedPatientId.value == null) selectedPatientId.value = patients.first.id;
      if (groupes.isNotEmpty && selectedGroupeId.value == null) selectedGroupeId.value = groupes.first.id;
      status.value = 'success';
   } catch (e) {
      if (patients.isEmpty && groupes.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
     }
    }
  }

  void toggleEmployee(dynamic employeeId) {
    final parsed = parseId(employeeId);
    if (selectedEmployeeIds.contains(parsed)) {
      selectedEmployeeIds.remove(parsed);
    } else {
      selectedEmployeeIds.add(parsed);
    }
  }

  Future<void> createSeance() async {
    if (date.value.isEmpty || heureDebut.value.isEmpty || heureFin.value.isEmpty) {
      Get.snackbar('Champs requis', 'Veuillez renseigner la date et les horaires de la séance.', snackPosition: SnackPosition.BOTTOM);
     return;
    }

    try {
      status.value = 'loading';
     if (typeSeance.value == 'individuelle') {
       if (selectedPatientId.value == null) {
          Get.snackbar('Sélection requise', 'Veuillez sélectionner un patient.', snackPosition: SnackPosition.BOTTOM);
         status.value = 'success';
         return;
        }

        final payload = {
          'patient_id': selectedPatientId.value,
         'date': date.value,
         'heure_debut': heureDebut.value,
         'heure_fin': heureFin.value,
         'statut': 'prevue',
         if (selectedEmployeeIds.isNotEmpty) 'employe_ids': selectedEmployeeIds.toList(),
       };

        await _seanceService.createSeance(payload);
      } else {
        if (selectedGroupeId.value == null) {
          Get.snackbar('Sélection requise', 'Veuillez sélectionner un groupe.', snackPosition: SnackPosition.BOTTOM);
         status.value = 'success';
         return;
        }

        final payload = {
          'groupe_id': selectedGroupeId.value,
         'date': date.value,
         'heure_debut': heureDebut.value,
         'heure_fin': heureFin.value,
         'statut': 'prevue',
         if (selectedEmployeeIds.isNotEmpty) 'employe_id': selectedEmployeeIds.first,
       };

        await _seanceGroupeService.createSeanceGroupe(payload);
      }

      // ─── Création automatique de la tâche pour chaque employé assigné ──────
      if (selectedEmployeeIds.isNotEmpty) {
        final dateStr = date.value;
        final startStr = heureDebut.value;
        final endStr = heureFin.value;

        String taskTitle = '';
        String taskDesc = '';

        if (typeSeance.value == 'individuelle') {
          final patientName = patients
              .firstWhereOrNull((p) => p.id == selectedPatientId.value)
              ?.fullName ?? 'Patient';
          taskTitle = 'Séance : $patientName ($startStr - $endStr)';
          taskDesc = 'Séance individuelle planifiée le $dateStr de $startStr à $endStr avec $patientName.';
        } else {
          final groupeName = groupes
              .firstWhereOrNull((g) => g.id == selectedGroupeId.value)
              ?.nom ?? 'Groupe';
          taskTitle = 'Séance collective : $groupeName ($startStr - $endStr)';
          taskDesc = 'Séance de groupe planifiée le $dateStr de $startStr à $endStr avec le groupe $groupeName.';
        }

        for (final empId in selectedEmployeeIds) {
          try {
            await _tacheService.createTache({
              'titre': taskTitle,
              'description': taskDesc,
              'assigne_a': empId.toString(),
              if (typeSeance.value == 'individuelle' && selectedPatientId.value != null)
                'patient_id': selectedPatientId.value.toString(),
              'statut': 'a_faire',
              'priorite': 'normale',
              'date_echeance': '${dateStr}T${endStr.length == 5 ? "$endStr:00" : endStr}',
            });
          } catch (e) {
            debugPrint('Auto task creation notice: $e');
          }
        }
      }

      AppCacheManager.invalidateTag(CacheTags.taches);
      AppCacheManager.invalidateTag(CacheTags.seances);
      AppCacheManager.invalidateTag(CacheTags.dashboard);

      status.value = 'success';
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

      Get.back(result: true);
      Get.snackbar('Succès', 'Séance planifiée avec succès', snackPosition: SnackPosition.BOTTOM);
   } catch (e) {
      status.value = 'success';
     Get.snackbar('Erreur', 'Impossible de planifier la séance : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
