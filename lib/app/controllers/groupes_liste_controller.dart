import 'dart:async';
import 'package:get/get.dart';
import '../models/groupe_model.dart';
import '../services/cache_manager.dart';
import '../services/groupe_service.dart';

class GroupesListeController extends GetxController {
  final GroupeService _groupeService = GroupeService();

  final RxList<GroupeModel> groupes = <GroupeModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  Timer? _debounceTimer;

  static const _cacheDuration = Duration(minutes: 10);

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadGroupes();
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.groupesList)) {
      loadGroupes();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _loadFromCache() {
    final cached = AppCacheManager.get<List<GroupeModel>>(CacheKeys.groupesList);
    if (cached != null && cached.isNotEmpty) {
      groupes.value = cached;
      status.value = 'success';
    }
  }

  Future<void> loadGroupes({bool forceRefresh = false}) async {
    if (AppCacheManager.isFresh(CacheKeys.groupesList) && !forceRefresh && searchQuery.value.isEmpty && groupes.isNotEmpty) {
      return;
    }

    if (groupes.isEmpty) {
      status.value = 'loading';
    }

    try {
      final list = await _groupeService.getGroupes(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      groupes.value = list;

      if (searchQuery.value.isEmpty) {
        AppCacheManager.set<List<GroupeModel>>(
          CacheKeys.groupesList,
          list,
          ttl: _cacheDuration,
          tags: {CacheTags.groupes},
        );
      }

      status.value = list.isEmpty ? 'empty' : 'success';
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