import 'dart:async';
import 'package:flutter/material.dart';
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

  Future<void> deleteEmployee(dynamic id) async {
    try {
      await _employeeService.deleteEmployee(id);
      employees.removeWhere((e) => e.id.toString() == id.toString());
      AppCacheManager.invalidate(CacheKeys.employesList);
      Get.snackbar(
        'Supprimé',
        'Le compte a été supprimé avec succès.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer : ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
      );
    }
  }

  void search(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      loadEmployees(forceRefresh: true);
    });
  }
}