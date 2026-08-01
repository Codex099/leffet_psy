import 'package:get/get.dart';
import '../services/patient_service.dart';

class EditPatientController extends GetxController {
  final PatientService _patientService = PatientService();

  final RxInt currentStep = 1.obs;

  final nom = ''.obs;
  final prenom = ''.obs;
  final dateNaissance = ''.obs;
  final sexe = 'Garçon'.obs;

  final RxString status = 'success'.obs;
  final RxString errorMessage = ''.obs;

  void nextStep() {
    if (currentStep.value < 4) {
      currentStep.value++;
    } else {
      savePatient();
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  Future<void> savePatient() async {
    try {
      status.value = 'loading';
      await _patientService.createPatient({
        'nom': nom.value,
        'prenom': prenom.value,
        'date_naissance': dateNaissance.value,
        'sexe': sexe.value,
      });
      Get.back();
      Get.snackbar('Succès', 'Patient créé avec succès');
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }
}