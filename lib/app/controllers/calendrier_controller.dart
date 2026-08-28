import 'package:get/get.dart';
import '../models/evenement_calendrier_model.dart';
import '../services/cache_manager.dart';
import '../services/calendrier_service.dart';

class CalendrierController extends GetxController {
  final CalendrierService _calendrierService = CalendrierService();

  final RxList<EvenementCalendrierModel> evenements = <EvenementCalendrierModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString activeTab = 'Liste'.obs;

  dynamic editingEventId;
  final titre = ''.obs;
  final description = ''.obs;
  final date = ''.obs;
  final notifierJours = 3.obs;

  static const _cacheDuration = Duration(minutes: 10);

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadEvenements();
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.calendrierEvents)) {
      loadEvenements();
    }
  }

  void _loadFromCache() {
    final cached = AppCacheManager.get<List<EvenementCalendrierModel>>(CacheKeys.calendrierEvents);
    if (cached != null && cached.isNotEmpty) {
      evenements.value = cached;
      status.value = 'success';
    }
  }

  void resetForm([EvenementCalendrierModel? ev]) {
    if (ev != null) {
      editingEventId = ev.id;
      titre.value = ev.titre;
      description.value = ev.description ?? '';
      date.value = ev.date;
      notifierJours.value = ev.notifierAvantJours ?? 3;
    } else {
      editingEventId = null;
      titre.value = '';
      description.value = '';
      final now = DateTime.now();
      date.value = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      notifierJours.value = 3;
    }
  }

  Future<void> loadEvenements({bool forceRefresh = false}) async {
    if (AppCacheManager.isFresh(CacheKeys.calendrierEvents) && !forceRefresh && evenements.isNotEmpty) {
      return;
    }

    if (evenements.isEmpty) {
      status.value = 'loading';
    }

    try {
      final list = await _calendrierService.getEvenements();
      evenements.value = list;

      AppCacheManager.set<List<EvenementCalendrierModel>>(
        CacheKeys.calendrierEvents,
        list,
        ttl: _cacheDuration,
        tags: {CacheTags.calendrier},
      );

      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      if (evenements.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
    }
  }

  Future<void> refreshData() => loadEvenements(forceRefresh: true);

  Future<bool> saveEvenement() async {
    if (titre.value.trim().isEmpty) {
      Get.snackbar('Champ requis', 'Le titre de l\'événement est obligatoire.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (date.value.trim().isEmpty) {
      Get.snackbar('Champ requis', 'La date de l\'événement est obligatoire.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    try {
      final payload = {
        'titre': titre.value.trim(),
        'description': description.value.trim().isEmpty ? null : description.value.trim(),
        'date': date.value.trim(),
        'notifier_avant_jours': notifierJours.value,
      };

      if (editingEventId != null) {
        await _calendrierService.updateEvenement(editingEventId!, payload);
        Get.snackbar('Succès', 'Événement mis à jour', snackPosition: SnackPosition.BOTTOM);
      } else {
        await _calendrierService.createEvenement(payload);
        Get.snackbar('Succès', 'Événement créé', snackPosition: SnackPosition.BOTTOM);
      }

      AppCacheManager.invalidateTag(CacheTags.calendrier);
      loadEvenements(forceRefresh: true);
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'enregistrer l\'événement : $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<void> deleteEvenement(dynamic id) async {
    try {
      await _calendrierService.deleteEvenement(id);
      AppCacheManager.invalidateTag(CacheTags.calendrier);
      loadEvenements(forceRefresh: true);
      Get.snackbar('Succès', 'Événement supprimé', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer l\'événement', snackPosition: SnackPosition.BOTTOM);
    }
  }
}