import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/patient_model.dart';
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
        if (telephone.value.trim().isNotEmpty) 'telephone': telephone.value.trim(),
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

      // Assign selected patients
      if (selectedPatientIds.isNotEmpty) {
        await _employeeService.assignPatients(saved.id, selectedPatientIds.toList());
      }

      try {
        if (Get.isRegistered<EmployesListeController>()) {
          Get.find<EmployesListeController>().loadEmployees();
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
      errorMessage.value = e.toString();
      status.value = 'error';
      Get.snackbar('Erreur', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    }
  }
}