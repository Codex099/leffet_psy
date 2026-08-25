import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/groupe_model.dart';
import '../models/patient_model.dart';
import '../services/employee_service.dart';
import '../services/groupe_service.dart';
import '../services/patient_service.dart';
import '../utils/json_utils.dart';

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

  // Current groupe being edited (null = create mode)
  dynamic groupeId;

  // Form fields
  final nom = ''.obs;
  final description = ''.obs;
  final typePlanning = 'fixe'.obs;

  // Planning récurrent : liste de créneaux (un ou plusieurs par jour)
  final RxList<DaySlot> daySlots = <DaySlot>[].obs;

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

  @override
  void onInit() {
    super.onInit();
    groupeId = extractIdParam(Get.arguments, Get.parameters);
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
      groupePatients.value = groupe.patients ?? [];
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

  /// Active ou désactive un jour. Si activation → ajoute un créneau par défaut.
  void toggleDay(String day) {
    if (isDayActive(day)) {
      daySlots.removeWhere((s) => s.day == day);
    } else {
      daySlots.add(DaySlot(day: day, heureDebut: '09:00', heureFin: '09:45'));
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
    return groupePatients.any((p) => parseId(p['id'] ?? p['patient_id']) == patientId);
  }

  Future<void> addPatientToGroupe(dynamic patientId) async {
    if (groupeId == null) {
      Get.snackbar('Info', 'Enregistrez le groupe d\'abord avant d\'ajouter des patients.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      await _groupeService.addPatientToGroupe(groupeId!, patientId);
      await _loadGroupe(groupeId!);
      Get.snackbar('Succès', 'Patient ajouté au groupe.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> removePatientFromGroupe(dynamic patientId) async {
    if (groupeId == null) return;
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
        if (selectedEmployeeIds.isNotEmpty) 'employee_ids': selectedEmployeeIds.toList(),
      };

      GroupeModel saved;
      if (groupeId != null) {
        saved = await _groupeService.updateGroupe(groupeId!, data);
      } else {
        saved = await _groupeService.createGroupe(data);
        groupeId = saved.id;
      }

      // Enregistrement des créneaux récurrents
      if (daySlots.isNotEmpty && groupeId != null) {
        for (final slot in daySlots) {
          await _groupeService.setPlanningRecurrent(groupeId!, {
            'jour_semaine': slot.day,
            'heure_debut': slot.heureDebut,
            'heure_fin': slot.heureFin,
          });
        }
      }

      status.value = 'success';
      Get.back(result: true);
      Get.snackbar(
        'Succès',
        groupeId != null ? 'Groupe mis à jour.' : 'Groupe créé.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
      Get.snackbar('Erreur', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    }
  }
}