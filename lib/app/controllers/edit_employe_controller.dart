import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/patient_model.dart';
import '../services/cache_manager.dart';
import '../services/employee_service.dart';
import '../services/patient_service.dart';
import '../utils/json_utils.dart';
import 'employes_liste_controller.dart';

class EditEmployeController extends GetxController {
 final EmployeeService _employeeService = EmployeeService();
  final PatientService _patientService = PatientService();

  // Edit mode: non-null means edit an existing employee
  dynamic employeId;

  // Form fields
  final nom = ''.obs;
 final prenom = ''.obs;
 final telephone = ''.obs;
 final username = ''.obs;
 final password = ''.obs; // Required for creation
 final role = 'psychologue'.obs;
  /// Permission accordée par l'admin pour créer et assigner des tâches
  final peutCreerTaches = false.obs;

 // Patient assignment
  final RxList<PatientModel> allPatients = <PatientModel>[].obs;
  final RxList<dynamic> selectedPatientIds = <dynamic>[].obs;
  final RxString patientsStatus = 'loading'.obs;
 final RxString patientSearch = ''.obs;

 final RxString status = 'success'.obs;
 final RxString errorMessage = ''.obs;

 // Valid backend roles
  static const List<String> validRoles = ['admin', 'psychologue', 'educatrice'];

 @override
  void onInit() {
    super.onInit();
    employeId = extractIdParam(Get.arguments, Get.parameters);
    _loadAllPatients();
    if (employeId != null) {
      _loadEmployee(employeId!);
    }
  }


  Future<void> _loadEmployee(dynamic id) async {
    try {
      status.value = 'loading';
     final emp = await _employeeService.getEmployee(id);
      nom.value = emp.nom;
      prenom.value = emp.prenom;
      telephone.value = emp.telephone ?? '';
     username.value = emp.username;
      role.value = emp.role;
      peutCreerTaches.value = emp.peutCreerTaches;
      if (emp.patientsAssignesIds != null) {
        selectedPatientIds.value = List<dynamic>.from(emp.patientsAssignesIds!);
      }
      status.value = 'success';
   } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
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

  List<PatientModel> get filteredPatients {
    final q = patientSearch.value.toLowerCase();
    if (q.isEmpty) return allPatients;
    return allPatients.where((p) => p.fullName.toLowerCase().contains(q)).toList();
  }

  void togglePatient(dynamic patientId) {
    if (selectedPatientIds.contains(patientId)) {
      selectedPatientIds.remove(patientId);
    } else {
      selectedPatientIds.add(patientId);
    }
  }

  Future<void> saveEmployee() async {
    if (nom.value.trim().isEmpty || prenom.value.trim().isEmpty) {
      Get.snackbar('Champs requis', 'Prénom et nom sont obligatoires.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (username.value.trim().isEmpty) {
      Get.snackbar('Champ requis', 'Le nom d\'utilisateur est obligatoire.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final cleanTel = telephone.value.replaceAll(RegExp(r'[\s\.\-]'), '').trim();
    if (cleanTel.isEmpty) {
      Get.snackbar('Champ requis', 'Le numéro de téléphone est obligatoire.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (employeId == null && password.value.trim().isEmpty) {
      Get.snackbar('Champ requis', 'Un mot de passe est requis pour la création.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      status.value = 'loading';

      final data = <String, dynamic>{
        'nom': nom.value.trim(),
        'prenom': prenom.value.trim(),
        'username': username.value.trim(),
        'role': role.value,
        'telephone': cleanTel,
        'peut_creer_taches': peutCreerTaches.value,
        // Password: only sent on create, or on update if non-empty
        if (employeId == null) 'password': password.value.trim(),
        if (employeId != null && password.value.trim().isNotEmpty)
          'password': password.value.trim(),
      };

      EmployeeModel saved;
      if (employeId != null) {
        saved = await _employeeService.updateEmployee(employeId!, data);
      } else {
        saved = await _employeeService.createEmployee(data);
        employeId = saved.id;
      }

      // Synchroniser les patients assignés (y compris si liste modifiée ou vidée)
      await _employeeService.assignPatients(
        saved.id,
        selectedPatientIds.map((e) => e.toString()).toList(),
      );

      AppCacheManager.invalidateTag(CacheTags.employes);

      try {
        if (Get.isRegistered<EmployesListeController>()) {
          Get.find<EmployesListeController>().loadEmployees(forceRefresh: true);
        }
      } catch (_) {}

      status.value = 'success';
      Get.back(result: true);
      Get.snackbar(
        'Succès',
        employeId != null ? 'Employé mis à jour.' : 'Employé créé avec succès.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      String msg = e.toString();
      if (e is DioException && e.response?.data != null) {
        final d = e.response!.data;
        if (d is Map && d['detail'] != null) {
          final detail = d['detail'];
          if (detail is String) {
            msg = detail;
          } else if (detail is List && detail.isNotEmpty) {
            final first = detail.first;
            if (first is Map && first['msg'] != null) {
              msg = '${first['loc']?.last ?? ""}: ${first['msg']}';
            }
          }
        }
      }
      errorMessage.value = msg;
      status.value = 'error';
      Get.snackbar('Erreur', msg, snackPosition: SnackPosition.BOTTOM);
    }
  }
}