import 'package:get/get.dart';
import '../models/seance_model.dart';
import '../services/seance_service.dart';

import '../utils/json_utils.dart';

class PlanningRecurrentController extends GetxController {
  final PlanningRecurrentService _planningService = PlanningRecurrentService();

  final Rx<PatientPlanningRecurrentModel?> planning = Rx<PatientPlanningRecurrentModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final selectedDays = <String>[].obs;
  final heureDebut = '09:00'.obs;
  final heureFin = '09:45'.obs;

  dynamic patientId;

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du patient non spécifié.';
    } else {
      loadPlanning();
    }
  }

  Future<void> loadPlanning() async {
    if (patientId == null) return;
    try {
      status.value = 'loading';
      planning.value = await _planningService.getPlanningRecurrent(patientId!);
      selectedDays.value = planning.value?.joursSemaine ?? [];
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> savePlanning() async {
    if (patientId == null) return;
    try {
      status.value = 'loading';
      await _planningService.setPlanningRecurrent(patientId!, {
        'jours_semaine': selectedDays,
        'heure_debut': heureDebut.value,
        'heure_fin': heureFin.value,
      });
      Get.back();
      Get.snackbar('Succès', 'Planning récurrent enregistré');
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }
}