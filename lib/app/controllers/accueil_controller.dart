import 'package:get/get.dart';
import '../models/agenda_session_item.dart';
import '../models/employee_model.dart';
import '../models/patient_model.dart';
import '../models/seance_model.dart';
import '../models/seance_groupe_model.dart';
import '../services/auth_service.dart';
import '../services/cache_manager.dart';
import '../services/persistent_cache_service.dart';
import '../services/seance_service.dart';
import '../services/seance_groupe_service.dart';
import '../services/patient_service.dart';
import '../services/tache_service.dart';

class AccueilController extends GetxController {
  final AuthService _authService = AuthService();
  final SeanceService _seanceService = SeanceService();
  final SeanceGroupeService _seanceGroupeService = SeanceGroupeService();
  final PatientService _patientService = PatientService();
  final TacheService _tacheService = TacheService();

  final Rx<EmployeeModel?> currentUser = Rx<EmployeeModel?>(null);
  final RxList<AgendaSessionItem> prochainesSeances = <AgendaSessionItem>[].obs;
  final RxInt totalPatients = 0.obs;
  final RxInt seancesPrevuesCount = 0.obs;
  final RxInt alertesCount = 0.obs;

  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  /// Vrai quand les données affichées viennent du cache persistant (mode offline).
  final RxBool isOfflineData = false.obs;

  /// Label humanisé de l'ancienneté du cache offline (ex: "il y a 2h").
  final RxnString offlineSavedLabel = RxnString();

  static const _cacheDuration = Duration(minutes: 2);

  @override
  void onInit() {
    super.onInit();
    _loadFromPersistentCache(); // 1. Persistant (disque) — instantané
    _loadFromRamCache();        // 2. RAM cache — instantané
    loadDashboard();            // 3. Réseau en arrière-plan
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.dashboard)) {
      loadDashboard();
    }
  }

  // ─── Cache disque (hors-ligne) ────────────────────────────────────────────

  void _loadFromPersistentCache() {
    try {
      final raw = PersistentCacheService.get(PersistentCacheService.dashboard);
      if (raw == null) return;

      final map = raw as Map<String, dynamic>;

      if (map['user'] != null) {
        currentUser.value = EmployeeModel.fromJson(
          Map<String, dynamic>.from(map['user'] as Map),
        );
      }
      if (map['seances'] != null) {
        final list = (map['seances'] as List)
            .map((e) => AgendaSessionItem.fromJsonCache(Map<String, dynamic>.from(e as Map)))
            .toList();
        prochainesSeances.value = list;
        seancesPrevuesCount.value = list.length;
      }
      if (map['totalPatients'] != null) {
        totalPatients.value = map['totalPatients'] as int? ?? 0;
      }

      if (prochainesSeances.isNotEmpty || currentUser.value != null) {
        status.value = 'success';
        isOfflineData.value = true;
        offlineSavedLabel.value = PersistentCacheService.lastSavedLabel(
          PersistentCacheService.dashboard,
        );
      }
    } catch (_) {
      // Ne jamais bloquer sur une erreur de cache
    }
  }

  // ─── Cache RAM ────────────────────────────────────────────────────────────

  void _loadFromRamCache() async {
    final secureUser = await _authService.getCachedUser();
    if (secureUser != null && currentUser.value == null) {
      currentUser.value = secureUser;
    }
    final cached = AppCacheManager.get<Map<String, dynamic>>(CacheKeys.dashboard);
    if (cached != null) {
      if (cached['user'] is EmployeeModel) {
        currentUser.value = cached['user'] as EmployeeModel;
      }
      if (cached['seances'] is List) {
        final todayStr = DateTime.now().toIso8601String().split('T').first;
        final list = (cached['seances'] as List)
            .whereType<AgendaSessionItem>()
            .where((s) => s.date == todayStr)
            .toList();
        prochainesSeances.value = list;
        seancesPrevuesCount.value = list.length;
      }
      if (cached['totalPatients'] is int) {
        totalPatients.value = cached['totalPatients'] as int;
      }
      status.value = 'success';
      isOfflineData.value = false; // Données RAM = OK (session en cours)
    }
  }

  // ─── Chargement réseau ────────────────────────────────────────────────────

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    // Si la donnée est fraîche et qu'on ne force pas, pas besoin d'appel réseau
    if (AppCacheManager.isFresh(CacheKeys.dashboard) && !forceRefresh && prochainesSeances.isNotEmpty) {
      return;
    }

    // N'affiche le loader plein écran que si on n'a absolument rien en mémoire
    if (prochainesSeances.isEmpty && currentUser.value == null) {
      status.value = 'loading';
    }

    try {
      final todayStr = DateTime.now().toIso8601String().split('T').first;

      // 1. Récupération de l'utilisateur (avec fallback cache)
      EmployeeModel? user;
      try {
        user = await _authService.getMe();
      } catch (_) {
        user = await _authService.getCachedUser() ?? currentUser.value;
      }
      if (user != null) {
        currentUser.value = user;
      }

      final currentUserId = (user ?? currentUser.value)?.id?.toString() ?? '';
      final role = (user ?? currentUser.value)?.role.toLowerCase() ?? 'admin';
      final isAdminOrManager = role == 'admin' ||
          role == 'directeur' ||
          role == 'directrice' ||
          role == 'secretaire' ||
          role == 'coordinateur';

      // 2. Séances individuelles et de groupe (appels résilients et indépendants)
      List<SeanceModel> indList = [];
      try {
        indList = await _seanceService.getSeances(date: todayStr);
      } catch (_) {}

      List<SeanceGroupeModel> grpList = [];
      try {
        grpList = await _seanceGroupeService.getSeancesGroupe(date: todayStr);
      } catch (_) {}

      // 3. Patients (avec fallback cache en cas de cold-start Vercel)
      List<dynamic> patients = [];
      try {
        patients = await _patientService.getPatients(actif: true);
      } catch (_) {
        final cached = AppCacheManager.get<List<PatientModel>>(CacheKeys.patientsList);
        if (cached != null) {
          patients = cached;
        }
      }

      if (!isAdminOrManager && currentUserId.isNotEmpty) {
        indList = indList.where((s) {
          if (s.employeIds.isEmpty) return true;
          return s.employeIds.map((e) => e.toString()).contains(currentUserId);
        }).toList();

        grpList = grpList.where((s) {
          if (s.employeId == null) return true;
          return s.employeId.toString() == currentUserId;
        }).toList();
      }

      final unified = <AgendaSessionItem>[
        ...indList.map(AgendaSessionItem.fromIndividuelle),
        ...grpList.map(AgendaSessionItem.fromGroupe),
      ];

      final todaySessions = unified.where((s) => s.date == todayStr).toList();
      todaySessions.sort((a, b) => a.heureDebut.compareTo(b.heureDebut));

      int patientCount = patients.length;
      if (!isAdminOrManager && currentUserId.isNotEmpty) {
        try {
          final myTasks = await _tacheService.getTaches(assigneesAMoi: true);
          final knownIds = patients
              .map((p) => p is PatientModel
                  ? p.id.toString()
                  : (p is Map ? p['id']?.toString() : p.toString()))
              .toSet();
          for (final t in myTasks) {
            if (t.patientId != null && !knownIds.contains(t.patientId.toString())) {
              knownIds.add(t.patientId.toString());
              patientCount++;
            }
          }
        } catch (_) {}
      }

      prochainesSeances.value = todaySessions;
      seancesPrevuesCount.value = todaySessions.length;
      totalPatients.value = patientCount;
      alertesCount.value = 0;
      isOfflineData.value = false;

      // ── Sauvegarder dans le cache RAM ──────────────────────────────────
      if (user != null) {
        AppCacheManager.set<Map<String, dynamic>>(
          CacheKeys.dashboard,
          {
            'user': user,
            'seances': todaySessions,
            'totalPatients': patientCount,
          },
          ttl: _cacheDuration,
          tags: {CacheTags.dashboard, CacheTags.seances, CacheTags.patients},
        );

        // ── Sauvegarder dans le cache persistant (offline) ─────────────────
        await PersistentCacheService.set(PersistentCacheService.dashboard, {
          'user': user.toJson(),
          'seances': todaySessions.map((s) => s.toJson()).toList(),
          'totalPatients': patientCount,
        });
      }

      status.value = 'success';
    } catch (e) {
      if (currentUser.value == null && prochainesSeances.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      } else {
        status.value = 'success';
      }
    }
  }

  /// Forcer un refresh (ex: pull-to-refresh)
  Future<void> refreshData() => loadDashboard(forceRefresh: true);
}