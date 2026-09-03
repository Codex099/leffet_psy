import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/patient_model.dart';
import '../services/auth_service.dart';
import '../services/cache_manager.dart';
import '../services/employee_service.dart';
import '../services/patient_service.dart';
import '../utils/json_utils.dart';
import 'employes_liste_controller.dart';

class EmployeVisibilitePatientsController extends GetxController {
  final EmployeeService _employeeService = EmployeeService();
  final PatientService _patientService = PatientService();
  final AuthService _authService = AuthService();

  dynamic employeeId;
  final Rx<EmployeeModel?> employee = Rx<EmployeeModel?>(null);

  final RxList<PatientModel> allPatients = <PatientModel>[].obs;
  final RxSet<String> visiblePatientIds = <String>{}.obs;

  final RxString status = 'loading'.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString searchQuery = ''.obs;
  final RxString activeFilter = 'all'.obs; // 'all' | 'visible' | 'invisible'
  final RxBool isAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    _resolveEmployeeId();
    _checkAdminAccess();
    loadVisibilityData();
  }

  void _resolveEmployeeId() {
    final args = Get.arguments;
    if (args is EmployeeModel) {
      employee.value = args;
      employeeId = args.id;
    } else if (args is Map && args['id'] != null) {
      employeeId = args['id'];
    } else {
      employeeId = extractIdParam(Get.arguments, Get.parameters);
    }
  }

  Future<void> _checkAdminAccess() async {
    final me = await _authService.getCachedUser() ?? await _authService.getMe();
    isAdmin.value = me.role.toLowerCase() == 'admin';
  }

  Future<void> loadVisibilityData() async {
    status.value = 'loading';
    try {
      final results = await Future.wait([
        _employeeService.getVisibilitePatients(employeeId),
        _patientService.getPatients(actif: true),
      ]);

      final visData = results[0] as Map<String, dynamic>;
      final patientsList = results[1] as List<PatientModel>;

      if (visData['employee'] != null && employee.value == null) {
        employee.value = EmployeeModel.fromJson(
          Map<String, dynamic>.from(visData['employee'] as Map),
        );
      }

      final visibleList = (visData['visible_patients'] as List<dynamic>?) ?? [];
      final Set<String> visIds = visibleList
          .map((p) => parseId((p as Map)['id']).toString())
          .toSet();

      allPatients.value = patientsList;
      visiblePatientIds.assignAll(visIds);

      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  int get visibleCount => visiblePatientIds.length;
  int get invisibleCount => allPatients.where((p) => !visiblePatientIds.contains(p.id.toString())).length;
  int get totalCount => allPatients.length;

  List<PatientModel> get displayedPatients {
    final query = searchQuery.value.trim().toLowerCase();
    return allPatients.where((p) {
      final pid = p.id.toString();
      final isVis = visiblePatientIds.contains(pid);

      if (activeFilter.value == 'visible' && !isVis) return false;
      if (activeFilter.value == 'invisible' && isVis) return false;

      if (query.isNotEmpty) {
        final matchesName = p.fullName.toLowerCase().contains(query);
        if (!matchesName) return false;
      }

      return true;
    }).toList();
  }

  void togglePatient(dynamic patientId) {
    if (!isAdmin.value) {
      if (Get.context != null) {
        Get.snackbar(
          'Accès refusé',
          'Seul un administrateur peut modifier la visibilité des patients.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }

    HapticFeedback.selectionClick();
    final idStr = patientId.toString();
    if (visiblePatientIds.contains(idStr)) {
      visiblePatientIds.remove(idStr);
    } else {
      visiblePatientIds.add(idStr);
    }
  }

  void grantAll() {
    if (!isAdmin.value) return;
    HapticFeedback.mediumImpact();
    visiblePatientIds.addAll(allPatients.map((p) => p.id.toString()));
  }

  void revokeAll() {
    if (!isAdmin.value) return;
    HapticFeedback.mediumImpact();
    visiblePatientIds.clear();
  }

  Future<void> saveVisibility() async {
    if (!isAdmin.value) {
      Get.snackbar(
        'Action restreinte',
        'Seul l\'administrateur peut enregistrer les droits de visibilité.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;
    try {
      await _employeeService.assignPatients(
        employeeId,
        visiblePatientIds.toList(),
      );

      AppCacheManager.invalidateTag(CacheTags.employes);
      AppCacheManager.invalidateTag(CacheTags.patients);
      AppCacheManager.invalidateTag(CacheTags.dashboard);

      try {
        if (Get.isRegistered<EmployesListeController>()) {
          Get.find<EmployesListeController>().loadEmployees(forceRefresh: true);
        }
      } catch (_) {}

      Get.snackbar(
        'Visibilité mise à jour',
        '${visiblePatientIds.length} patient(s) visible(s) pour cet employé.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur d\'enregistrement',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> applyToAllTeam(String action) async {
    if (!isAdmin.value) return;
    isSaving.value = true;
    try {
      final res = await _employeeService.applyGlobalVisibility(action);
      AppCacheManager.invalidateTag(CacheTags.employes);
      AppCacheManager.invalidateTag(CacheTags.patients);
      AppCacheManager.invalidateTag(CacheTags.dashboard);

      await loadVisibilityData();

      try {
        if (Get.isRegistered<EmployesListeController>()) {
          Get.find<EmployesListeController>().loadEmployees(forceRefresh: true);
        }
      } catch (_) {}

      Get.snackbar(
        'Action globale réussie',
        res['message']?.toString() ?? 'Visibilité globale mise à jour.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
