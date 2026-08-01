import 'package:get/get.dart';
import '../models/seance_model.dart';
import '../services/seance_service.dart';
import '../utils/json_utils.dart';

class CompteRenduSeanceController extends GetxController {
  final SeanceService _seanceService = SeanceService();

  final Rx<SeanceModel?> seance = Rx<SeanceModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  final descriptionEtat = ''.obs;
  final etapePlanId = RxnInt();
  final medias = <String>[].obs;

  late int seanceId;

  @override
  void onInit() {
    super.onInit();
    seanceId = parseInt(Get.arguments, 1);
    loadSeance();
  }

  Future<void> loadSeance() async {
    try {
      status.value = 'loading';
      seance.value = await _seanceService.getSeance(seanceId);
      descriptionEtat.value = seance.value?.descriptionEtat ?? '';
      medias.value = seance.value?.medias ?? [];
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> saveRapport() async {
    try {
      status.value = 'loading';
      await _seanceService.updateSeance(seanceId, {
        'description_etat': descriptionEtat.value,
        if (etapePlanId.value != null) 'etape_plan_id': etapePlanId.value,
        'medias': medias,
        'statut': 'realisee',
      });
      Get.back();
      Get.snackbar('Succès', 'Rapport enregistré');
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }
}