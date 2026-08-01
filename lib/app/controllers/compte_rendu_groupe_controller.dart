import 'package:get/get.dart';
import '../models/seance_groupe_model.dart';
import '../services/seance_groupe_service.dart';

class CompteRenduGroupeController extends GetxController {
  final SeanceGroupeService _seanceService = SeanceGroupeService();

  final Rx<SeanceGroupeModel?> seance = Rx<SeanceGroupeModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final medias = <String>[].obs;

  late int seanceId;

  @override
  void onInit() {
    super.onInit();
    seanceId = Get.arguments as int? ?? 1;
    loadSeance();
  }

  Future<void> loadSeance() async {
    try {
      status.value = 'loading';
      seance.value = await _seanceService.getSeanceGroupe(seanceId);
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> togglePresence(int patientId, bool isPresent) async {
    try {
      await _seanceService.updateParticipant(seanceId, patientId, {
        'statut_presence': isPresent ? 'present' : 'absent',
      });
      loadSeance();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier la présence');
    }
  }
}