import 'package:get/get.dart';
import '../models/seance_groupe_model.dart';
import '../services/seance_groupe_service.dart';

import '../utils/json_utils.dart';

class CompteRenduGroupeController extends GetxController {
  final SeanceGroupeService _seanceService = SeanceGroupeService();

  final Rx<SeanceGroupeModel?> seance = Rx<SeanceGroupeModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final medias = <String>[].obs;

  dynamic seanceId;

  @override
  void onInit() {
    super.onInit();
    seanceId = extractIdParam(Get.arguments, Get.parameters);
    if (seanceId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant de séance de groupe non spécifié.';
    } else {
      loadSeance();
    }
  }

  Future<void> loadSeance() async {
    if (seanceId == null) return;
    try {
      status.value = 'loading';
      seance.value = await _seanceService.getSeanceGroupe(seanceId!);
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> togglePresence(dynamic patientId, bool isPresent) async {
    if (seanceId == null) return;
    try {
      await _seanceService.updateParticipant(seanceId!, patientId, {
        'statut_presence': isPresent ? 'present' : 'absent',
      });
      loadSeance();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier la présence');
    }
  }
}