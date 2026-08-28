import 'package:get/get.dart';
import '../models/patient_statut_historique_model.dart';
import '../services/cache_manager.dart';
import '../services/patient_service.dart';
import '../utils/json_utils.dart';

class StatutHistoriqueController extends GetxController {
  final PatientService _patientService = PatientService();

  final RxList<PatientStatutHistoriqueModel> historique = <PatientStatutHistoriqueModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  dynamic patientId;

  static const _cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du patient non spécifié.';
    } else {
      _loadFromCache();
      loadHistorique();
    }
  }

  void _loadFromCache() {
    if (patientId == null) return;
    final cached = AppCacheManager.get<List<PatientStatutHistoriqueModel>>(CacheKeys.patientStatut(patientId));
    if (cached != null && cached.isNotEmpty) {
      historique.value = cached;
      status.value = 'success';
    }
  }

  Future<void> loadHistorique({bool forceRefresh = false}) async {
    if (patientId == null) return;
    final cacheKey = CacheKeys.patientStatut(patientId);

    if (AppCacheManager.isFresh(cacheKey) && !forceRefresh && historique.isNotEmpty) {
      return;
    }

    if (historique.isEmpty) {
      status.value = 'loading';
    }

    try {
      final list = await _patientService.getStatutHistorique(patientId!);
      historique.value = list;

      AppCacheManager.set<List<PatientStatutHistoriqueModel>>(
        cacheKey,
        list,
        ttl: _cacheDuration,
        tags: {CacheTags.patients},
      );

      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      if (historique.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
    }
  }

  Future<void> refreshData() => loadHistorique(forceRefresh: true);

  Future<void> updateNoteDegradation(dynamic itemId, String note) async {
    if (patientId == null) return;
    try {
      await _patientService.updateStatutHistoriqueNote(patientId!, itemId, noteDegradation: note);
      AppCacheManager.invalidateTag(CacheTags.patients);
      await loadHistorique(forceRefresh: true);
      Get.snackbar('Succès', 'Note de dégradation mise à jour');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour la note');
    }
  }
}