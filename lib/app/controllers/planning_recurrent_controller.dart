import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/seance_model.dart';
import '../services/cache_manager.dart';
import '../services/employee_service.dart';
import '../services/seance_service.dart';

import '../services/auth_service.dart';
import '../utils/json_utils.dart';
import 'accueil_controller.dart';
import 'agenda_controller.dart';

class PlanningRecurrentController extends GetxController {
  final PlanningRecurrentService _planningService = PlanningRecurrentService();
  final EmployeeService _employeeService = EmployeeService();
  final AuthService _authService = AuthService();

  final Rx<PatientPlanningRecurrentModel?> planning = Rx<PatientPlanningRecurrentModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAdmin = false.obs;
  final selectedDays = <String>[].obs;
  final RxString modeCreneaux = 'fixe'.obs;
  final heureDebut = '09:00'.obs;
  final heureFin = '09:45'.obs;
  final RxMap<String, Map<String, String>> daySlotsMap = <String, Map<String, String>>{}.obs;

  /// Créneaux automatiques (par défaut OFF = false)
  final RxBool creneauxAutomatiques = false.obs;

  final employees = <EmployeeModel>[].obs;
  final selectedEmployeeIds = <dynamic>[].obs;

  dynamic patientId;

  static const _cacheDuration = Duration(minutes: 5);

  static const Map<String, String> dayToFull = {
    'lun': 'lundi',
    'mar': 'mardi',
    'mer': 'mercredi',
    'jeu': 'jeudi',
    'ven': 'vendredi',
    'sam': 'samedi',
    'dim': 'dimanche',
    'lundi': 'lundi',
    'mardi': 'mardi',
    'mercredi': 'mercredi',
    'jeudi': 'jeudi',
    'vendredi': 'vendredi',
    'samedi': 'samedi',
    'dimanche': 'dimanche',
  };

  static const Map<String, String> fullToShort = {
    'lundi': 'Lun',
    'mardi': 'Mar',
    'mercredi': 'Mer',
    'jeudi': 'Jeu',
    'vendredi': 'Ven',
    'samedi': 'Sam',
    'dimanche': 'Dim',
  };

  @override
  void onInit() {
    super.onInit();
    _checkAdminAndLoad();
  }

  Future<void> _checkAdminAndLoad() async {
    try {
      final me = await _authService.getCachedUser() ?? await _authService.getMe();
      isAdmin.value = me.role.toLowerCase() == 'admin';
      if (!isAdmin.value) {
        Get.back();
        Get.snackbar(
          'Accès restreint'.tr,
          'Seul l\'administrateur peut configurer les créneaux récurrents.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } catch (_) {}

    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du patient non spécifié.';
    } else {
      _loadFromCache();
      loadPlanning();
      loadEmployees();
    }
  }

  void _loadFromCache() {
    if (patientId == null) return;
    final cached = AppCacheManager.get<PatientPlanningRecurrentModel>(CacheKeys.patientPlanning(patientId));
    if (cached != null) {
      planning.value = cached;
      final rawDays = cached.joursSemaine;
      selectedDays.value = rawDays.map((d) {
        final lower = d.toLowerCase();
        return fullToShort[lower] ?? d;
      }).toList();
      if (cached.heureDebut.isNotEmpty) heureDebut.value = cached.heureDebut;
      if (cached.heureFin.isNotEmpty) heureFin.value = cached.heureFin;
      if (cached.employeIds != null) {
        selectedEmployeeIds.assignAll(cached.employeIds!);
      } else if (cached.employeId != null) {
        selectedEmployeeIds.assignAll([cached.employeId]);
      }
      if (cached.modeGeneration != null) {
        creneauxAutomatiques.value = cached.modeGeneration == 'auto';
      } else {
        creneauxAutomatiques.value = false;
      }
      status.value = 'success';
   }
  }

  Future<void> loadEmployees() async {
    try {
      final list = await _employeeService.getEmployees();
      employees.assignAll(list);
    } catch (_) {}
  }

  void setModeCreneaux(String mode) {
    modeCreneaux.value = mode;
  }

  String getSlotStartForDay(String day) {
    return daySlotsMap[day]?['debut'] ?? heureDebut.value;
 }

  String getSlotEndForDay(String day) {
    return daySlotsMap[day]?['fin'] ?? heureFin.value;
 }

  void updateSlotForDay(String day, {String? debut, String? fin}) {
    final cur = daySlotsMap[day] ?? {'debut': heureDebut.value, 'fin': heureFin.value};
   daySlotsMap[day] = {
      'debut': debut ?? cur['debut'] ?? heureDebut.value,
     'fin': fin ?? cur['fin'] ?? heureFin.value,
   };
    daySlotsMap.refresh();
  }

  Future<void> loadPlanning({bool forceRefresh = false}) async {
    if (patientId == null) return;
    final cacheKey = CacheKeys.patientPlanning(patientId);

    if (AppCacheManager.isFresh(cacheKey) && !forceRefresh && planning.value != null) {
      return;
    }

    if (planning.value == null) {
      status.value = 'loading';
   }

    try {
      final loaded = await _planningService.getPlanningRecurrent(patientId!);
      planning.value = loaded;
      final rawDays = loaded?.joursSemaine ?? [];
      selectedDays.value = rawDays.map((d) {
        final lower = d.toLowerCase();
        return fullToShort[lower] ?? d;
      }).toList();
      if (loaded?.heureDebut != null && loaded!.heureDebut.isNotEmpty) {
        heureDebut.value = loaded.heureDebut;
      }
      if (loaded?.heureFin != null && loaded!.heureFin.isNotEmpty) {
        heureFin.value = loaded.heureFin;
      }
      if (loaded?.employeIds != null) {
        selectedEmployeeIds.assignAll(loaded!.employeIds!);
      } else if (loaded?.employeId != null) {
        selectedEmployeeIds.assignAll([loaded!.employeId]);
      }
      if (loaded?.modeGeneration != null) {
        creneauxAutomatiques.value = loaded!.modeGeneration == 'auto';
      } else {
        creneauxAutomatiques.value = false;
      }

      if (loaded != null) {
        AppCacheManager.set<PatientPlanningRecurrentModel>(
          cacheKey,
          loaded,
          ttl: _cacheDuration,
          tags: {CacheTags.patients, CacheTags.seances},
        );
      }

      status.value = 'success';
   } catch (e) {
      if (planning.value == null) {
        errorMessage.value = e.toString();
        status.value = 'error';
     }
    }
  }

  Future<void> refreshData() => loadPlanning(forceRefresh: true);

  Future<void> savePlanning() async {
    if (patientId == null) return;
    try {
      status.value = 'loading';

      final isAuto = creneauxAutomatiques.value;
      final modeGen = isAuto ? 'auto' : 'manuel';
      const horizonDays = 28; // 4 semaines

      if (modeCreneaux.value == 'fixe') {
        final fullDays = selectedDays.map((d) {
          final lower = d.toLowerCase();
          return dayToFull[lower] ?? lower;
        }).toList();
        await _planningService.setPlanningRecurrent(patientId!, {
          'jours_semaine': fullDays,
          'heure_debut': heureDebut.value,
          'heure_fin': heureFin.value,
          'employe_ids': selectedEmployeeIds.toList(),
          'mode_generation': modeGen,
          'horizon_jours': horizonDays,
        });

        if (isAuto) {
          try {
            final now = DateTime.now();
            final todayStr = now.toIso8601String().split('T').first;
            final finStr =
                now.add(const Duration(days: 28)).toIso8601String().split('T').first;
            await _planningService.genererSeances(
              patientId!,
              dateDebut: todayStr,
              dateFin: finStr,
            );
          } catch (_) {}
        }
      } else {
        for (final day in selectedDays) {
          final lower = day.toLowerCase();
          final fullDay = dayToFull[lower] ?? lower;
          final start = getSlotStartForDay(day);
          final end = getSlotEndForDay(day);

          await _planningService.setPlanningRecurrent(patientId!, {
            'jours_semaine': [fullDay],
            'heure_debut': start,
            'heure_fin': end,
            'employe_ids': selectedEmployeeIds.toList(),
            'mode_generation': modeGen,
            'horizon_jours': horizonDays,
          });

          if (isAuto) {
            try {
              final now = DateTime.now();
              final todayStr = now.toIso8601String().split('T').first;
              final finStr =
                  now.add(const Duration(days: 28)).toIso8601String().split('T').first;
              await _planningService.genererSeances(
                patientId!,
                dateDebut: todayStr,
                dateFin: finStr,
              );
            } catch (_) {}
          }
        }
      }

      AppCacheManager.invalidateTag(CacheTags.seances);
      AppCacheManager.invalidateTag(CacheTags.patients);
      AppCacheManager.invalidateTag(CacheTags.dashboard);

      try {
        if (Get.isRegistered<AgendaController>()) {
          Get.find<AgendaController>().loadAgenda(forceRefresh: true);
        }
      } catch (_) {}
      try {
        if (Get.isRegistered<AccueilController>()) {
          Get.find<AccueilController>().loadDashboard(forceRefresh: true);
        }
      } catch (_) {}

      Get.back(result: true);
      Get.snackbar(
        'Succès'.tr,
        isAuto
            ? 'Planning récurrent enregistré. Créneaux automatiques activés pour 4 semaines.'.tr
            : 'Planning récurrent enregistré (créneaux automatiques désactivés).'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }
}