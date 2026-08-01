import 'package:get/get.dart';
import '../models/seance_model.dart';
import '../services/seance_service.dart';

class PlanningRecurrentController extends GetxController {
  final PlanningRecurrentService _planningService = PlanningRecurrentService();

  final Rx<PatientPlanningRecurrentModel?> planning = Rx<PatientPlanningRecurrentModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final selectedDays = <String>[].obs;
  final heureDebut = '09:00'.obs;
  final heureFin = '09:45'.obs;

  late int patientId;

  @override
  void onInit() {
    super.onInit();
    patientId = Get.arguments as int? ?? 1;
    loadPlanning();
  }

  Future<void> loadPlanning() async {
    try {
      status.value = 'loading';
      planning.value = await _planningService.getPlanningRecurrent(patientId);
      selectedDays.value = planning.value?.joursSemaine ?? [];
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> savePlanning() async {
    try {
      status.value = 'loading';
      await _planningService.setPlanningRecurrent(patientId, {
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