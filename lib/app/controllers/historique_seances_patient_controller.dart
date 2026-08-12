import 'package:get/get.dart';
import '../models/seance_model.dart';
import '../services/seance_service.dart';
import '../services/groupe_service.dart';
import '../utils/json_utils.dart';

class HistoriqueSeancesPatientController extends GetxController {
  final SeanceService _seanceService = SeanceService();
  final GroupeService _groupeService = GroupeService();

  dynamic patientId;
  String filterType = 'tous'; // 'tous' | 'individuel' | 'groupe'

  final RxList<SeanceModel> seancesIndividuelles = <SeanceModel>[].obs;
  final RxList<Map<String, dynamic>> seancesGroupe = <Map<String, dynamic>>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString activeFilter = 'tous'.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      patientId = parseId(args['id']);
      filterType = args['type'] as String? ?? 'tous';
    } else {
      patientId = extractIdParam(args, Get.parameters);
    }
    activeFilter.value = filterType;

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
      if (activeFilter.value != 'groupe') {
        seancesIndividuelles.value = await _seanceService.getSeances(patientId: patientId);
      }
      if (activeFilter.value != 'individuel') {
        seancesGroupe.value = await _groupeService.getSeancesGroupePatient(patientId!);
      }
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  void setFilter(String type) {
    if (activeFilter.value == type) return;
    activeFilter.value = type;
    loadHistorique();
  }
}
