import 'package:get/get.dart';
import '../models/evenement_calendrier_model.dart';
import '../services/tache_service.dart';

class CalendrierController extends GetxController {
  final CalendrierService _calendrierService = CalendrierService();

  final RxList<EvenementCalendrierModel> evenements = <EvenementCalendrierModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString activeTab = 'Liste'.obs;

  final titre = ''.obs;
  final description = ''.obs;
  final date = ''.obs;
  final notifierJours = 3.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvenements();
  }

  Future<void> loadEvenements() async {
    try {
      status.value = 'loading';
      final list = await _calendrierService.getEvenements();
      evenements.value = list;
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> saveEvenement() async {
    try {
      await _calendrierService.createEvenement({
        'titre': titre.value,
        'description': description.value,
        'date': date.value,
        'notifier_avant_jours': notifierJours.value,
      });
      loadEvenements();
      Get.snackbar('Succès', 'Événement créé');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer l\'événement');
    }
  }
}