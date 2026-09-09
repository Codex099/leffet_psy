import 'package:get/get.dart';
import '../models/groupe_model.dart';
import '../services/auth_service.dart';
import '../services/cache_manager.dart';
import '../services/groupe_service.dart';
import '../services/seance_groupe_service.dart';
import '../utils/json_utils.dart';
import 'groupes_liste_controller.dart';

class GroupeDetailController extends GetxController {
  final GroupeService _groupeService = GroupeService();
  final SeanceGroupeService _seanceGroupeService = SeanceGroupeService();
  final AuthService _authService = AuthService();

  final Rx<GroupeModel?> groupe = Rx<GroupeModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  dynamic groupeId;

  final RxBool isAdmin = false.obs;
  final RxString currentUserId = ''.obs;

  static const _cacheDuration = Duration(minutes: 10);

  @override
  void onInit() {
    super.onInit();
    groupeId = extractIdParam(Get.arguments, Get.parameters);
    if (groupeId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du groupe non spécifié.';
    } else {
      _initUserAndLoad();
    }
  }

  Future<void> _initUserAndLoad() async {
    try {
      final me = await _authService.getCachedUser() ?? await _authService.getMe();
      isAdmin.value = me.role.toLowerCase() == 'admin';
      currentUserId.value = me.id.toString();
    } catch (_) {}
    _loadFromCache();
    loadGroupe();
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
      if (currentUserId.value.isEmpty) {
        final me = await _authService.getCachedUser() ?? await _authService.getMe();
        isAdmin.value = me.role.toLowerCase() == 'admin';
        currentUserId.value = me.id.toString();
      }

      final loaded = await _groupeService.getGroupe(groupeId!);

      // Vérification des droits pour les employés normaux
      if (!isAdmin.value && currentUserId.value.isNotEmpty) {
        bool allowed = loaded.isEmployeeAssigned(currentUserId.value);
        if (!allowed) {
          try {
            final mySeances = await _seanceGroupeService.getSeancesGroupe(
              groupeId: groupeId,
              employeId: currentUserId.value,
            );
            if (mySeances.isNotEmpty) allowed = true;
          } catch (_) {}
        }

        if (!allowed) {
          status.value = 'error';
          errorMessage.value =
              'Accès restreint : vous n\'êtes pas assigné à ce groupe thérapeutique.'.tr;
          Get.snackbar(
            'Accès restreint'.tr,
            'Ce groupe thérapeutique ne vous est pas assigné.'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.back();
          return;
        }
      }

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
    if (!isAdmin.value) {
      Get.snackbar(
        'Action non autorisée'.tr,
        'Seul l\'administrateur peut supprimer un groupe.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
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