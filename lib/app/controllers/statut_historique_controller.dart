import 'package:get/get.dart';
import '../models/patient_statut_historique_model.dart';
import '../services/patient_service.dart';
import '../utils/json_utils.dart';

class StatutHistoriqueController extends GetxController {
  final PatientService _patientService = PatientService();

  final RxList<PatientStatutHistoriqueModel> historique = <PatientStatutHistoriqueModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  late int patientId;

  @override
  void onInit() {
    super.onInit();
    patientId = parseInt(Get.arguments, 1);
    loadHistorique();
  }

  Future<void> loadHistorique() async {
    try {
      status.value = 'loading';
      final list = await _patientService.getStatutHistorique(patientId);
      historique.value = list;
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> updateNoteDegradation(int itemId, String note) async {
    try {
      await _patientService.updateStatutHistoriqueNote(patientId, itemId, noteDegradation: note);
      loadHistorique();
      Get.snackbar('Succès', 'Note de dégradation mise à jour');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour la note');
    }
  }
}