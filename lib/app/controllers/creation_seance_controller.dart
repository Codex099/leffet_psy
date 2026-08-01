import 'package:get/get.dart';
import '../services/seance_service.dart';

class CreationSeanceController extends GetxController {
  final SeanceService _seanceService = SeanceService();

  final patientId = RxnInt();
  final employeId = RxnInt();
  final date = ''.obs;
  final heureDebut = '10:00'.obs;
  final duree = '45 min'.obs;

  final RxString status = 'success'.obs;

  Future<void> createSeance() async {
    if (patientId.value == null || date.value.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs obligatoires');
      return;
    }
    try {
      status.value = 'loading';
      await _seanceService.createSeance({
        'patient_id': patientId.value,
        if (employeId.value != null) 'employe_id': employeId.value,
        'date': date.value,
        'heure_debut': heureDebut.value,
        'duree': duree.value,
        'statut': 'prevue',
      });
      Get.back();
      Get.snackbar('Succès', 'Séance planifiée avec succès');
    } catch (e) {
      status.value = 'error';
      Get.snackbar('Erreur', 'Impossible de planifier la séance');
    }
  }
}
