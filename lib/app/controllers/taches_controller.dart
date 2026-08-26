import 'package:get/get.dart';
import '../models/tache_model.dart';
import '../services/tache_service.dart';

class TachesController extends GetxController {
  final TacheService _tacheService = TacheService();

  final RxList<TacheModel> taches = <TacheModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxBool filterAssignesAMoi = false.obs;

  /// Cache TTL — 3 minutes (les tâches changent plus vite)
  DateTime? _lastLoaded;
  static const _cacheDuration = Duration(minutes: 3);
  bool get _isFresh =>
      _lastLoaded != null &&
      DateTime.now().difference(_lastLoaded!) < _cacheDuration;

  @override
  void onInit() {
    super.onInit();
    loadTaches();
  }

  @override
  void onReady() {
    super.onReady();
    if (!_isFresh) loadTaches();
  }

  Future<void> loadTaches({bool forceRefresh = false}) async {
    if (_isFresh && !forceRefresh) return;
    try {
      status.value = 'loading';
      final list = await _tacheService.getTaches(
        assigneesAMoi: filterAssignesAMoi.value ? true : null,
      );
      taches.value = list;
      _lastLoaded = DateTime.now();
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> refreshData() => loadTaches(forceRefresh: true);

  void toggleFilter(bool val) {
    filterAssignesAMoi.value = val;
    loadTaches(forceRefresh: true); // filtre change → force refresh
  }

  List<TacheModel> get tachesAFaire => taches
      .where((t) => t.statut == 'a_faire' || (t.statut != 'en_cours' && t.statut != 'fait' && t.statut != 'terminee'))
      .toList();
  List<TacheModel> get tachesEnCours => taches.where((t) => t.statut == 'en_cours').toList();
  List<TacheModel> get tachesFait =>
      taches.where((t) => t.statut == 'fait' || t.statut == 'terminee' || t.statut == 'cloturee').toList();

  /// Met à jour le statut d'une tâche depuis la liste (US-M38)
  Future<void> updateStatutFromList(dynamic tacheId, String newStatut) async {
    try {
      await _tacheService.updateTache(tacheId, {'statut': newStatut});
      // Mettre à jour localement pour éviter un reload complet
      final idx = taches.indexWhere((t) => t.id == tacheId);
      if (idx >= 0) {
        final t = taches[idx];
        taches[idx] = TacheModel(
          id: t.id,
          titre: t.titre,
          description: t.description,
          assigneA: t.assigneA,
          creePar: t.creePar,
          patientId: t.patientId,
          etapePlanId: t.etapePlanId,
          statut: newStatut,
          priorite: t.priorite,
          dateEcheance: t.dateEcheance,
          patient: t.patient,
          assigneEmployee: t.assigneEmployee,
        );
      }
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le statut.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}