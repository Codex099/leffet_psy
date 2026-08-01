import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';

class PatientsListeController extends GetxController {
  final PatientService _patientService = PatientService();

  final RxList<PatientModel> patients = <PatientModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPatients();
  }

  Future<void> loadPatients() async {
    try {
      status.value = 'loading';
      final list = await _patientService.getPatients(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      patients.value = list;
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  void search(String query) {
    searchQuery.value = query;
    loadPatients();
  }
}