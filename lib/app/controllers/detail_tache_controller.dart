import 'package:get/get.dart';
import '../models/tache_model.dart';
import '../services/tache_service.dart';
import '../utils/json_utils.dart';

class DetailTacheController extends GetxController {
  final TacheService _tacheService = TacheService();

  final Rx<TacheModel?> tache = Rx<TacheModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  final titre = ''.obs;
  final description = ''.obs;
  final assigneA = RxnInt();
  final patientId = RxnInt();
  final etapePlanId = RxnInt();
  final priorite = 'normale'.obs;
  final dateEcheance = ''.obs;
  final statut = 'a_faire'.obs;

  bool get isNew => tache.value == null;

  @override
  void onInit() {
    super.onInit();
    final id = parseNullableInt(Get.arguments);
    if (id != null) {
      loadTache(id);
    } else {
      status.value = 'success';
    }
  }

  Future<void> loadTache(int id) async {
    try {
      status.value = 'loading';
      tache.value = await _tacheService.getTache(id);
      titre.value = tache.value?.titre ?? '';
      description.value = tache.value?.description ?? '';
      priorite.value = tache.value?.priorite ?? 'normale';
      statut.value = tache.value?.statut ?? 'a_faire';
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> saveTache() async {
    try {
      final data = {
        'titre': titre.value,
        'description': description.value,
        'priorite': priorite.value,
        'statut': statut.value,
      };
      if (isNew) {
        await _tacheService.createTache(data);
        Get.snackbar('Succès', 'Tâche créée');
      } else {
        await _tacheService.updateTache(tache.value!.id, data);
        Get.snackbar('Succès', 'Tâche mise à jour');
      }
      Get.back();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'enregistrer la tâche');
    }
  }

  Future<void> deleteTache() async {
    if (tache.value == null) return;
    try {
      await _tacheService.deleteTache(tache.value!.id);
      Get.back();
      Get.snackbar('Succès', 'Tâche supprimée');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la tâche');
    }
  }
}
