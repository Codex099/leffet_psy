import 'package:get/get.dart';
import '../models/patient_statut_historique_model.dart';
import '../services/patient_service.dart';
import '../utils/json_utils.dart';

class StatutHistoriqueController extends GetxController {
  final PatientService _patientService = PatientService();

  final RxList<PatientStatutHistoriqueModel> historique = <PatientStatutHistoriqueModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  int? patientId;

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du patient non spécifié.';
    } else {
      loadHistorique();
    }
  }

  Future<void> loadHistorique() async {
    if (patientId == null) return;
    try {
      status.value = 'loading';
      final list = await _patientService.getStatutHistorique(patientId!);
      historique.value = list;
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> updateNoteDegradation(int itemId, String note) async {
    if (patientId == null) return;
    try {
      await _patientService.updateStatutHistoriqueNote(patientId!, itemId, noteDegradation: note);
      loadHistorique();
      Get.snackbar('Succès', 'Note de dégradation mise à jour');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour la note');
    }
  }

}