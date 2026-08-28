import 'dart:async';
import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../services/cache_manager.dart';
import '../services/employee_service.dart';

class EmployesListeController extends GetxController {
  final EmployeeService _employeeService = EmployeeService();

  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  Timer? _debounceTimer;

  static const _cacheDuration = Duration(minutes: 15);

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadEmployees();
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.employesList)) {
      loadEmployees();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _loadFromCache() {
    final cached = AppCacheManager.get<List<EmployeeModel>>(CacheKeys.employesList);
    if (cached != null && cached.isNotEmpty) {
      employees.value = cached;
      status.value = 'success';
    }
  }

  Future<void> loadEmployees({bool forceRefresh = false}) async {
    if (AppCacheManager.isFresh(CacheKeys.employesList) && !forceRefresh && searchQuery.value.isEmpty && employees.isNotEmpty) {
      return;
    }

    if (employees.isEmpty) {
      status.value = 'loading';
    }

    try {
      final list = await _employeeService.getEmployees(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      employees.value = list;

      if (searchQuery.value.isEmpty) {
        AppCacheManager.set<List<EmployeeModel>>(
          CacheKeys.employesList,
          list,
          ttl: _cacheDuration,
          tags: {CacheTags.employes},
        );
      }

      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      if (employees.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
    }
  }

  Future<void> refreshData() => loadEmployees(forceRefresh: true);

  void search(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      loadEmployees(forceRefresh: true);
    });
  }
}