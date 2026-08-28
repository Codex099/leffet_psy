import 'package:get/get.dart';
import '../models/tache_model.dart';
import '../services/cache_manager.dart';
import '../services/tache_service.dart';

class TachesController extends GetxController {
  final TacheService _tacheService = TacheService();

  final RxList<TacheModel> taches = <TacheModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxBool filterAssignesAMoi = false.obs;

  static const _cacheDuration = Duration(minutes: 3);

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadTaches();
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.tachesList)) {
      loadTaches();
    }
  }

  void _loadFromCache() {
    final cached = AppCacheManager.get<List<TacheModel>>(CacheKeys.tachesList);
    if (cached != null && cached.isNotEmpty && !filterAssignesAMoi.value) {
      taches.value = cached;
      status.value = 'success';
    }
  }

  Future<void> loadTaches({bool forceRefresh = false}) async {
    final isDefaultFilter = !filterAssignesAMoi.value;
    if (isDefaultFilter && AppCacheManager.isFresh(CacheKeys.tachesList) && !forceRefresh && taches.isNotEmpty) {
      return;
    }

    if (taches.isEmpty) {
      status.value = 'loading';
    }

    try {
      final list = await _tacheService.getTaches(
        assigneesAMoi: filterAssignesAMoi.value ? true : null,
      );
      taches.value = list;

      if (isDefaultFilter) {
        AppCacheManager.set<List<TacheModel>>(
          CacheKeys.tachesList,
          list,
          ttl: _cacheDuration,
          tags: {CacheTags.taches},
        );
      }

      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      if (taches.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
    }
  }

  Future<void> refreshData() => loadTaches(forceRefresh: true);

  void toggleFilter(bool val) {
    filterAssignesAMoi.value = val;
    loadTaches(forceRefresh: true);
  }

  List<TacheModel> get tachesAFaire => taches
      .where((t) => t.statut == 'a_faire' || (t.statut != 'en_cours' && t.statut != 'fait' && t.statut != 'terminee'))
      .toList();
  List<TacheModel> get tachesEnCours => taches.where((t) => t.statut == 'en_cours').toList();
  List<TacheModel> get tachesFait =>
      taches.where((t) => t.statut == 'fait' || t.statut == 'terminee' || t.statut == 'cloturee').toList();

  /// Met à jour le statut d'une tâche avec mise à jour optimiste instantanée
  Future<void> updateStatutFromList(dynamic tacheId, String newStatut) async {
    final idx = taches.indexWhere((t) => t.id == tacheId);
    TacheModel? original;
    if (idx >= 0) {
      original = taches[idx];
      taches[idx] = TacheModel(
        id: original.id,
        titre: original.titre,
        description: original.description,
        assigneA: original.assigneA,
        creePar: original.creePar,
        patientId: original.patientId,
        etapePlanId: original.etapePlanId,
        statut: newStatut,
        priorite: original.priorite,
        dateEcheance: original.dateEcheance,
        patient: original.patient,
        assigneEmployee: original.assigneEmployee,
      );
    }

    try {
      await _tacheService.updateTache(tacheId, {'statut': newStatut});
      AppCacheManager.invalidateTag(CacheTags.taches);
    } catch (_) {
      // Rollback en cas d'erreur
      if (idx >= 0 && original != null) {
        taches[idx] = original;
      }
      Get.snackbar('Erreur', 'Impossible de mettre à jour le statut.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}