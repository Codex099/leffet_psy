import 'dart:async';
import 'package:get/get.dart';
import '../models/parent_model.dart';
import '../services/cache_manager.dart';
import '../services/parent_service.dart';

class ParentsListeController extends GetxController {
  final ParentService _parentService = ParentService();

  final RxList<ParentModel> allParents = <ParentModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  Timer? _debounceTimer;

  static const _cacheDuration = Duration(minutes: 15);

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadParents();
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.parentsList)) {
      loadParents();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _loadFromCache() {
    final cached = AppCacheManager.get<List<ParentModel>>(CacheKeys.parentsList);
    if (cached != null && cached.isNotEmpty) {
      allParents.value = cached;
      status.value = 'success';
    }
  }

  Future<void> loadParents({bool forceRefresh = false}) async {
    if (AppCacheManager.isFresh(CacheKeys.parentsList) && !forceRefresh && allParents.isNotEmpty) {
      return;
    }

    if (allParents.isEmpty) {
      status.value = 'loading';
    }

    try {
      final list = await _parentService.getParents();
      allParents.value = list;

      AppCacheManager.set<List<ParentModel>>(
        CacheKeys.parentsList,
        list,
        ttl: _cacheDuration,
        tags: {CacheTags.parents},
      );

      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      if (allParents.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
    }
  }

  Future<void> refreshData() => loadParents(forceRefresh: true);

  List<ParentModel> get filteredParents {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return allParents;
    return allParents.where((p) {
      final name = p.fullName.toLowerCase();
      final tel = (p.telephone ?? '').toLowerCase();
      return name.contains(q) || tel.contains(q);
    }).toList();
  }

  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 180), () {
      searchQuery.value = query;
    });
  }
}