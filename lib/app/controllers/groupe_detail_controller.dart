import 'package:get/get.dart';
import '../models/groupe_model.dart';
import '../services/cache_manager.dart';
import '../services/groupe_service.dart';
import '../utils/json_utils.dart';
import 'groupes_liste_controller.dart';

class GroupeDetailController extends GetxController {
 final GroupeService _groupeService = GroupeService();

  final Rx<GroupeModel?> groupe = Rx<GroupeModel?>(null);
  final RxString status = 'loading'.obs;
 final RxString errorMessage = ''.obs;
 dynamic groupeId;

  static const _cacheDuration = Duration(minutes: 10);

  @override
  void onInit() {
    super.onInit();
    groupeId = extractIdParam(Get.arguments, Get.parameters);
    if (groupeId == null) {
      status.value = 'error';
     errorMessage.value = 'Identifiant du groupe non spécifié.';
   } else {
      _loadFromCache();
      loadGroupe();
    }
  }

  void _loadFromCache() {
    if (groupeId == null) return;
    final cached = AppCacheManager.get<GroupeModel>(CacheKeys.groupeDetail(groupeId));
    if (cached != null) {
      groupe.value = cached;
      status.value = 'success';
   }
  }

  Future<void> loadGroupe({bool forceRefresh = false}) async {
    if (groupeId == null) return;
    final cacheKey = CacheKeys.groupeDetail(groupeId);

    if (AppCacheManager.isFresh(cacheKey) && !forceRefresh && groupe.value != null) {
      return;
    }

    if (groupe.value == null) {
      status.value = 'loading';
   }

    try {
      final loaded = await _groupeService.getGroupe(groupeId!);
      groupe.value = loaded;
      AppCacheManager.set<GroupeModel>(
        cacheKey,
        loaded,
        ttl: _cacheDuration,
        tags: {CacheTags.groupes},
      );
      status.value = 'success';
   } catch (e) {
      if (groupe.value == null) {
        errorMessage.value = e.toString();
        status.value = 'error';
     }
    }
  }

  Future<void> refreshData() => loadGroupe(forceRefresh: true);

  Future<void> deleteGroupe() async {
    if (groupeId == null) return;
    try {
      await _groupeService.deleteGroupe(groupeId!);
      AppCacheManager.invalidateTag(CacheTags.groupes);
      try {
        if (Get.isRegistered<GroupesListeController>()) {
          Get.find<GroupesListeController>().loadGroupes(forceRefresh: true);
        }
      } catch (_) {}
      Get.back();
      Get.snackbar('Succès', 'Groupe supprimé', snackPosition: SnackPosition.BOTTOM);
   } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer le groupe : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}