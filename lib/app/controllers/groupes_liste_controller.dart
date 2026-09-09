import 'dart:async';
import 'package:get/get.dart';
import '../models/groupe_model.dart';
import '../services/auth_service.dart';
import '../services/cache_manager.dart';
import '../services/groupe_service.dart';
import '../services/seance_groupe_service.dart';

class GroupesListeController extends GetxController {
  final GroupeService _groupeService = GroupeService();
  final SeanceGroupeService _seanceGroupeService = SeanceGroupeService();
  final AuthService _authService = AuthService();

  final RxList<GroupeModel> groupes = <GroupeModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  final RxBool isAdmin = false.obs;
  final RxString currentUserId = ''.obs;

  Timer? _debounceTimer;

  static const _cacheDuration = Duration(minutes: 10);

  String get _userCacheKey =>
      isAdmin.value ? CacheKeys.groupesList : '${CacheKeys.groupesList}_${currentUserId.value}';

  @override
  void onInit() {
    super.onInit();
    _initUserAndLoad();
  }

  Future<void> _initUserAndLoad() async {
    try {
      final me = await _authService.getCachedUser() ?? await _authService.getMe();
      isAdmin.value = me.role.toLowerCase() == 'admin';
      currentUserId.value = me.id.toString();
    } catch (_) {}
    _loadFromCache();
    loadGroupes();
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(_userCacheKey)) {
      loadGroupes();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _loadFromCache() {
    final cached = AppCacheManager.get<List<GroupeModel>>(_userCacheKey);
    if (cached != null && cached.isNotEmpty) {
      groupes.value = cached;
      status.value = 'success';
    }
  }

  Future<void> loadGroupes({bool forceRefresh = false}) async {
    if (AppCacheManager.isFresh(_userCacheKey) &&
        !forceRefresh &&
        searchQuery.value.isEmpty &&
        groupes.isNotEmpty) {
      return;
    }

    if (groupes.isEmpty) {
      status.value = 'loading';
    }

    try {
      if (currentUserId.value.isEmpty) {
        final me = await _authService.getCachedUser() ?? await _authService.getMe();
        isAdmin.value = me.role.toLowerCase() == 'admin';
        currentUserId.value = me.id.toString();
      }

      final list = await _groupeService.getGroupes(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      List<GroupeModel> finalList = list;

      // Pour les employés non-admins, filtrer uniquement les groupes auxquels ils sont assignés
      if (!isAdmin.value && currentUserId.value.isNotEmpty) {
        final Set<String> assignedGroupeIds = {};
        try {
          final mySeances = await _seanceGroupeService.getSeancesGroupe(
            employeId: currentUserId.value,
          );
          for (final s in mySeances) {
            final gid = s.groupeId?.toString();
            if (gid != null) assignedGroupeIds.add(gid);
          }
        } catch (_) {}

        finalList = list.where((g) {
          final gid = g.id?.toString();
          if (gid != null && assignedGroupeIds.contains(gid)) return true;
          return g.isEmployeeAssigned(currentUserId.value);
        }).toList();
      }

      groupes.value = finalList;

      if (searchQuery.value.isEmpty) {
        AppCacheManager.set<List<GroupeModel>>(
          _userCacheKey,
          finalList,
          ttl: _cacheDuration,
          tags: {CacheTags.groupes},
        );
      }

      status.value = finalList.isEmpty ? 'empty' : 'success';
    } catch (e) {
      if (groupes.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
    }
  }

  Future<void> refreshData() => loadGroupes(forceRefresh: true);

  void search(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      loadGroupes(forceRefresh: true);
    });
  }
}