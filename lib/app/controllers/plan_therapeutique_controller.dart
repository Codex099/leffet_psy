import 'package:get/get.dart';
import '../models/plan_therapeutique_model.dart';
import '../services/plan_therapeutique_service.dart';
import '../utils/json_utils.dart';

class PlanTherapeutiqueController extends GetxController {
  final PlanTherapeutiqueService _planService = PlanTherapeutiqueService();

  final Rx<PlanTherapeutiqueModel?> plan = Rx<PlanTherapeutiqueModel?>(null);
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
      loadPlan();
    }
  }

  Future<void> loadPlan() async {
    if (patientId == null) return;
    try {
      status.value = 'loading';
      final plans = await _planService.getPlansPatient(patientId!);
      if (plans.isNotEmpty) {
        plan.value = plans.first;
        status.value = 'success';
      } else {
        status.value = 'empty';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }


  Future<void> convertEtapeToTache(int etapeId) async {
    if (plan.value == null) return;
    try {
      await _planService.creerTacheDepuisEtape(plan.value!.id, etapeId);
      Get.snackbar('Succès', 'Étape convertie en tâche');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de convertir en tâche');
    }
  }
}