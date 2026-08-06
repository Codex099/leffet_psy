import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/parent_model.dart';
import '../models/plan_therapeutique_model.dart';
import '../services/patient_service.dart';
import '../services/plan_therapeutique_service.dart';
import '../utils/json_utils.dart';

class PatientInfoController extends GetxController {
  final PatientService _patientService = PatientService();
  final PlanTherapeutiqueService _planService = PlanTherapeutiqueService();

  final Rx<PatientModel?> patient = Rx<PatientModel?>(null);
  final RxList<PatientParentModel> parents = <PatientParentModel>[].obs;
  final RxList<PlanTherapeutiqueModel> plans = <PlanTherapeutiqueModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  dynamic patientId;

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null || patientId.toString().isEmpty) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du patient non spécifié.';
    } else {
      loadPatientInfo();
    }
  }


  Future<void> loadPatientInfo() async {
    if (patientId == null) return;
    final id = patientId!;
    try {
      status.value = 'loading';
      patient.value = await _patientService.getPatient(id);
      parents.value = await _patientService.getPatientParents(id);
      plans.value = await _planService.getPlansPatient(id);
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> toggleStatut() async {
    if (patient.value == null || patientId == null) return;
    try {
      final current = patient.value!.estActif;
      await _patientService.updateStatut(patientId!, estActif: !current);
      loadPatientInfo();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier le statut');
    }
  }

  Future<void> deletePatient() async {
    if (patientId == null) return;
    try {
      await _patientService.deletePatient(patientId!);
      Get.back();
      Get.snackbar('Succès', 'Patient supprimé');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer le patient');
    }
  }

}