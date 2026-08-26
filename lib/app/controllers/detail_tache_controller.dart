import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/patient_model.dart';
import '../models/tache_model.dart';
import '../services/employee_service.dart';
import '../services/patient_service.dart';
import '../services/tache_service.dart';
import '../utils/json_utils.dart';
import 'taches_controller.dart';

class DetailTacheController extends GetxController {
  final TacheService _tacheService = TacheService();
  final EmployeeService _employeeService = EmployeeService();
  final PatientService _patientService = PatientService();

  final Rx<TacheModel?> tache = Rx<TacheModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  // Form fields
  final titre = ''.obs;
  final description = ''.obs;
  final priorite = 'normale'.obs;
  final statut = 'a_faire'.obs;
  final dateEcheance = ''.obs;

  // Assignee & Patient
  final Rx<dynamic> assigneA = Rx<dynamic>(null);
  final RxList<EmployeeModel> availableEmployees = <EmployeeModel>[].obs;
  final RxString employeesStatus = 'loading'.obs;

  final Rx<dynamic> patientId = Rx<dynamic>(null);
  final RxList<PatientModel> availablePatients = <PatientModel>[].obs;

  bool get isNew => tache.value == null;

  @override
  void onInit() {
    super.onInit();
    _loadEmployees();
    _loadPatients();
    final id = extractIdParam(Get.arguments, Get.parameters);
    if (id != null) {
      loadTache(id);
    } else {
      status.value = 'success';
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

  Future<void> _loadPatients() async {
    try {
      final list = await _patientService.getPatients(actif: true);
      availablePatients.value = list;
    } catch (_) {}
  }

  Future<void> loadTache(dynamic id) async {
    try {
      status.value = 'loading';
      final t = await _tacheService.getTache(id);
      tache.value = t;
      titre.value = t.titre;
      description.value = t.description ?? '';
      priorite.value = t.priorite;
      statut.value = t.statut;
      assigneA.value = t.assigneA;
      patientId.value = t.patientId;
      dateEcheance.value = t.dateEcheance ?? '';
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  // Quick status cycle
  static const _statutOrder = ['a_faire', 'en_cours', 'fait'];

  Future<void> cycleStatut() async {
    if (tache.value == null) return;
    final idx = _statutOrder.indexOf(statut.value);
    final next = _statutOrder[(idx + 1) % _statutOrder.length];
    statut.value = next;
    await _patchStatut(tache.value!.id, next);
  }

  Future<void> setStatut(String newStatut) async {
    if (tache.value == null) return;
    statut.value = newStatut;
    await _patchStatut(tache.value!.id, newStatut);
  }

  Future<void> _patchStatut(dynamic id, String newStatut) async {
    try {
      final updated = await _tacheService.updateTache(id, {'statut': newStatut});
      tache.value = updated;
      Get.snackbar('Statut mis à jour', _statutLabel(newStatut),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le statut.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _statutLabel(String s) {
    switch (s) {
      case 'a_faire': return 'À faire';
      case 'en_cours': return 'En cours';
      case 'fait': return 'Fait';
      default: return s;
    }
  }

  Future<void> saveTache() async {
    if (titre.value.trim().isEmpty) {
      Get.snackbar('Champ requis', 'Le titre de la tâche est obligatoire.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final data = <String, dynamic>{
        'titre': titre.value.trim(),
        if (description.value.trim().isNotEmpty) 'description': description.value.trim(),
        'priorite': priorite.value,
        'statut': statut.value,
        if (assigneA.value != null) 'assigne_a': assigneA.value,
        if (patientId.value != null) 'patient_id': patientId.value,
        if (dateEcheance.value.isNotEmpty) 'date_echeance': dateEcheance.value,
      };
      if (isNew) {
        await _tacheService.createTache(data);
        Get.snackbar('Succès', 'Tâche créée.', snackPosition: SnackPosition.BOTTOM);
      } else {
        await _tacheService.updateTache(tache.value!.id, data);
        Get.snackbar('Succès', 'Tâche mise à jour.', snackPosition: SnackPosition.BOTTOM);
      }

      try {
        if (Get.isRegistered<TachesController>()) {
          Get.find<TachesController>().loadTaches(forceRefresh: true);
        }
      } catch (_) {}

      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'enregistrer la tâche: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteTache() async {
    if (tache.value == null) return;
    try {
      await _tacheService.deleteTache(tache.value!.id);
      try {
        if (Get.isRegistered<TachesController>()) {
          Get.find<TachesController>().loadTaches(forceRefresh: true);
        }
      } catch (_) {}
      Get.back(result: true);
      Get.snackbar('Supprimée', 'Tâche supprimée.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la tâche.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  String get employeeName {
    if (assigneA.value == null) return 'Non assignée';
    return availableEmployees
            .firstWhereOrNull((e) => e.id == assigneA.value)
            ?.fullName ??
        'Non assignée';
  }
}
