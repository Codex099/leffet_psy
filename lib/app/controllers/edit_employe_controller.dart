import 'package:get/get.dart';
import '../services/employee_service.dart';

class EditEmployeController extends GetxController {
  final EmployeeService _employeeService = EmployeeService();

  final nom = ''.obs;
  final prenom = ''.obs;
  final telephone = ''.obs;
  final username = ''.obs;
  final role = 'Psychologue'.obs;
  final selectedPatients = <int>[].obs;

  final RxString status = 'success'.obs;
  final RxString errorMessage = ''.obs;

  void togglePatient(int patientId) {
    if (selectedPatients.contains(patientId)) {
      selectedPatients.remove(patientId);
    } else {
      selectedPatients.add(patientId);
    }
  }

  Future<void> saveEmployee() async {
    try {
      status.value = 'loading';
      await _employeeService.createEmployee({
        'nom': nom.value,
        'prenom': prenom.value,
        'telephone': telephone.value,
        'username': username.value,
        'role': role.value.toLowerCase(),
      });
      Get.back();
      Get.snackbar('Succès', 'Employé enregistré avec succès');
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }
}