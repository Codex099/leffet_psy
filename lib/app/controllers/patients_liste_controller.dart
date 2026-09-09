import 'dart:async';
import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../services/cache_manager.dart';
import '../services/persistent_cache_service.dart';
import '../services/patient_service.dart';
import '../services/tache_service.dart';
import '../services/auth_service.dart';

class PatientsListeController extends GetxController {
  final PatientService _patientService = PatientService();
  final TacheService _tacheService = TacheService();
  final AuthService _authService = AuthService();

  final RxList<PatientModel> allPatients = <PatientModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAdmin = false.obs;
  final RxString currentUserId = ''.obs;

  /// Vrai quand les données affichées viennent du cache persistant (mode offline).
  final RxBool isOfflineData = false.obs;

  /// Label humanisé de l'ancienneté du cache offline (ex: "il y a 2h").
  final RxnString offlineSavedLabel = RxnString();

  // Filters
  final RxString searchQuery = ''.obs;
  final RxnBool actifFilter = RxnBool(true);
  final RxnInt ageMinFilter = RxnInt();
  final RxnInt ageMaxFilter = RxnInt();
  final RxnString sexeFilter = RxnString();

  Timer? _debounceTimer;

  static const _cacheDuration = Duration(minutes: 5);

  String get _cacheKey =>
      currentUserId.value.isNotEmpty ? 'patients_list_${currentUserId.value}' : CacheKeys.patientsList;

  String get _persistentKey =>
      currentUserId.value.isNotEmpty
          ? '${PersistentCacheService.patientsList}_${currentUserId.value}'
          : PersistentCacheService.patientsList;

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
    _loadFromPersistentCache(); // 1. Persistant (disque)
    _loadFromRamCache();        // 2. RAM
    loadPatients();             // 3. Réseau
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(_cacheKey)) {
      loadPatients();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  // ─── Cache disque (hors-ligne) ────────────────────────────────────────────

  void _loadFromPersistentCache() {
    try {
      final raw = PersistentCacheService.get(_persistentKey);
      if (raw == null) return;

      final list = (raw as List)
          .map((e) => PatientModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (list.isNotEmpty) {
        allPatients.value = list;
        status.value = 'success';
        isOfflineData.value = true;
        offlineSavedLabel.value = PersistentCacheService.lastSavedLabel(_persistentKey);
      }
    } catch (_) {
      // Ne jamais bloquer sur une erreur de cache
    }
  }

  // ─── Cache RAM ────────────────────────────────────────────────────────────

  void _loadFromRamCache() {
    final cached = AppCacheManager.get<List<PatientModel>>(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      allPatients.value = cached;
      status.value = 'success';
      isOfflineData.value = false;
    }
  }

  // ─── Chargement réseau ────────────────────────────────────────────────────

  Future<void> loadPatients({bool forceRefresh = false}) async {
    if (AppCacheManager.isFresh(_cacheKey) && !forceRefresh && allPatients.isNotEmpty) {
      return;
    }

    if (allPatients.isEmpty) {
      status.value = 'loading';
    }

    try {
      final list = await _patientService.getPatients(
        actif: null,
        search: null,
      );
      final uniquePatients = <PatientModel>[];
      final seenIds = <String>{};
      for (final p in list) {
        final idStr = p.id.toString();
        if (!seenIds.contains(idStr)) {
          seenIds.add(idStr);
          uniquePatients.add(p);
        }
      }

      // ── Accès patient par tâche assignée (Option 2) ─────────────────────
      // Si l'employé a une tâche assignée liée à un patient, ce patient
      // lui est automatiquement visible avec toutes ses informations.
      if (!isAdmin.value) {
        try {
          final myTasks = await _tacheService.getTaches(assigneesAMoi: true);
          final missingPatientIds = <dynamic>{};
          for (final t in myTasks) {
            if (t.patientId != null && !seenIds.contains(t.patientId.toString())) {
              missingPatientIds.add(t.patientId);
            }
          }
          for (final pid in missingPatientIds) {
            try {
              final p = await _patientService.getPatient(pid);
              final idStr = p.id.toString();
              if (!seenIds.contains(idStr)) {
                seenIds.add(idStr);
                uniquePatients.add(p);
              }
            } catch (_) {
              // Si getPatient échoue, reconstituer depuis t.patient s'il existe
              final tMatch = myTasks.firstWhereOrNull((task) => task.patientId == pid);
              if (tMatch?.patient != null) {
                try {
                  final p = PatientModel.fromJson(tMatch!.patient!);
                  final idStr = p.id.toString();
                  if (!seenIds.contains(idStr)) {
                    seenIds.add(idStr);
                    uniquePatients.add(p);
                  }
                } catch (_) {}
              }
            }
          }
        } catch (_) {}
      }

      uniquePatients.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));

      allPatients.value = uniquePatients;
      isOfflineData.value = false;

      // ── Cache RAM ──────────────────────────────────────────────────────
      AppCacheManager.set<List<PatientModel>>(
        _cacheKey,
        uniquePatients,
        ttl: _cacheDuration,
        tags: {CacheTags.patients},
      );

      // ── Cache persistant (offline) ─────────────────────────────────────
      await PersistentCacheService.set(
        _persistentKey,
        uniquePatients.map((p) => p.toJson()).toList(),
      );

      status.value = uniquePatients.isEmpty ? 'empty' : 'success';
    } catch (e) {
      if (allPatients.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
      // Si on a des données offline, on les garde affichées
    }
  }

  Future<void> refreshData() => loadPatients(forceRefresh: true);

  List<PatientModel> get filteredPatients {
    return allPatients.where((p) {
      // Actif filter
      if (actifFilter.value != null && p.estActif != actifFilter.value) {
        return false;
      }
      // Sexe filter
      if (sexeFilter.value != null && sexeFilter.value!.isNotEmpty) {
        final sf = sexeFilter.value!.toLowerCase();
        if (sf == 'garçon' || sf == 'garcon') {
          if (!p.isGarcon) return false;
        } else if (sf == 'fille') {
          if (!p.isFille) return false;
        } else {
          if ((p.sexe ?? '').toLowerCase() != sf) return false;
        }
      }
      // Age filter
      final pAge = p.age;
      if (ageMinFilter.value != null && (pAge == null || pAge < ageMinFilter.value!)) {
        return false;
      }
      if (ageMaxFilter.value != null && (pAge == null || pAge > ageMaxFilter.value!)) {
        return false;
      }
      // Search query
      final q = searchQuery.value.trim().toLowerCase();
      if (q.isNotEmpty) {
        final matchName = p.fullName.toLowerCase().contains(q);
        final matchParents = p.parents?.any((parent) {
              final nom = (parent['nom'] ?? '').toString().toLowerCase();
              final prenom = (parent['prenom'] ?? '').toString().toLowerCase();
              final tel = (parent['telephone'] ?? '').toString().toLowerCase();
              return nom.contains(q) || prenom.contains(q) || tel.contains(q);
            }) ??
            false;
        if (!matchName && !matchParents) return false;
      }
      return true;
    }).toList();
  }

  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 180), () {
      searchQuery.value = query;
    });
  }

  void setActifFilter(bool? actif) {
    actifFilter.value = actif;
  }

  void setSexeFilter(String? sexe) {
    sexeFilter.value = sexe;
  }

  void setAgeFilter(int? min, int? max) {
    ageMinFilter.value = min;
    ageMaxFilter.value = max;
  }
}