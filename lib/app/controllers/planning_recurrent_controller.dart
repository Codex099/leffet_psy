import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/seance_model.dart';
import '../services/cache_manager.dart';
import '../services/employee_service.dart';
import '../services/seance_service.dart';

import '../services/auth_service.dart';
import 'package:dio/dio.dart';
import '../utils/conflict_dialog.dart';
import '../utils/json_utils.dart';
import '../utils/time_utils.dart';
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

  void updateHeureDebut(String v) {
    heureDebut.value = v;
    heureFin.value = TimeUtils.ajusterHeureFin(v, heureFin.value);
  }

  void updateHeureFin(String v) {
    heureFin.value = v;
    if (v.length >= 4 && !TimeUtils.isHeureApres(heureDebut.value, v)) {
      Get.snackbar(
        'Horaire non valide'.tr,
        'L\'heure de fin doit être strictement après l\'heure de début.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      heureFin.value = TimeUtils.ajouterMinutes(heureDebut.value, minutesAAjouter: 45);
    }
  }

  void updateSlotForDay(String day, {String? debut, String? fin}) {
    final cur =
        daySlotsMap[day] ?? {'debut': heureDebut.value, 'fin': heureFin.value};
    final d = debut ?? cur['debut'] ?? heureDebut.value;
    var f = fin ?? cur['fin'] ?? heureFin.value;
    if (debut != null && fin == null) {
      f = TimeUtils.ajusterHeureFin(d, f);
    } else if (fin != null && debut == null && fin.length >= 4) {
      if (!TimeUtils.isHeureApres(d, f)) {
        Get.snackbar(
          'Horaire non valide'.tr,
          'L\'heure de fin doit être après l\'heure de début pour $day.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        f = TimeUtils.ajouterMinutes(d, minutesAAjouter: 45);
      }
    }
    daySlotsMap[day] = {
      'debut': d,
      'fin': f,
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

    if (modeCreneaux.value == 'fixe') {
      final valErr =
          TimeUtils.validerHoraires(heureDebut.value, heureFin.value);
      if (valErr != null) {
        Get.snackbar('Horaires non valides'.tr, valErr.tr,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
    } else {
      for (final day in selectedDays) {
        final start = getSlotStartForDay(day);
        final end = getSlotEndForDay(day);
        final valErr = TimeUtils.validerHoraires(start, end);
        if (valErr != null) {
          Get.snackbar('Horaires non valides ($day)'.tr, valErr.tr,
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }
    }

    try {
      status.value = 'loading';

      final isAuto = creneauxAutomatiques.value;
      final modeGen = isAuto ? 'auto' : 'manuel';
      const horizonDays = 28; // 4 semaines
      final List<dynamic> allConflicts = [];
      int totalCreated = 0;

      final primaryEmpId =
          selectedEmployeeIds.isNotEmpty ? selectedEmployeeIds.first : null;

      if (modeCreneaux.value == 'fixe') {
        final fullDays = selectedDays.map((d) {
          final lower = d.toLowerCase();
          return dayToFull[lower] ?? lower;
        }).toList();
        await _planningService.setPlanningRecurrent(patientId!, {
          'jours_semaine': fullDays,
          'heure_debut': heureDebut.value,
          'heure_fin': heureFin.value,
          'employe_id': primaryEmpId,
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
            final res = await _planningService.genererSeances(
              patientId!,
              dateDebut: todayStr,
              dateFin: finStr,
            );
            totalCreated += (res['created'] as int? ?? 0);
            final conf = res['conflicts'] as List<dynamic>?;
            if (conf != null && conf.isNotEmpty) {
              allConflicts.addAll(conf);
            }
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
            'employe_id': primaryEmpId,
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
              final res = await _planningService.genererSeances(
                patientId!,
                dateDebut: todayStr,
                dateFin: finStr,
              );
              totalCreated += (res['created'] as int? ?? 0);
              final conf = res['conflicts'] as List<dynamic>?;
              if (conf != null && conf.isNotEmpty) {
                allConflicts.addAll(conf);
              }
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

      status.value = 'success';
      Get.back(result: true);

      if (allConflicts.isNotEmpty) {
        ConflictDialog.showBatchConflicts(
          createdCount: totalCreated,
          conflicts: allConflicts,
        );
      } else {
        Get.snackbar(
          'Succès'.tr,
          isAuto
              ? 'Planning récurrent enregistré. Créneaux automatiques activés pour 4 semaines.'.tr
              : 'Planning récurrent enregistré (créneaux automatiques désactivés).'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (e is DioException) {
        final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
        if (detail is String) {
          errorMsg = detail;
        } else if (e.message != null && e.message!.isNotEmpty) {
          errorMsg = e.message!;
        }
      }
      status.value = 'success';
      if (errorMsg.contains('Conflit d\'horaires')) {
        ConflictDialog.show(
          title: 'Créneau indisponible'.tr,
          message: errorMsg,
        );
      } else {
        errorMessage.value = errorMsg;
        Get.snackbar('Erreur'.tr, 'Impossible d\'enregistrer le planning : $errorMsg',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }
}