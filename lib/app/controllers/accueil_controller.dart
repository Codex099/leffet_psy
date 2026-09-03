import 'package:get/get.dart';
import '../models/agenda_session_item.dart';
import '../models/employee_model.dart';
import '../models/seance_model.dart';
import '../models/seance_groupe_model.dart';
import '../services/auth_service.dart';
import '../services/cache_manager.dart';
import '../services/seance_service.dart';
import '../services/seance_groupe_service.dart';
import '../services/patient_service.dart';

class AccueilController extends GetxController {
 final AuthService _authService = AuthService();
  final SeanceService _seanceService = SeanceService();
  final SeanceGroupeService _seanceGroupeService = SeanceGroupeService();
  final PatientService _patientService = PatientService();

  final Rx<EmployeeModel?> currentUser = Rx<EmployeeModel?>(null);
  final RxList<AgendaSessionItem> prochainesSeances = <AgendaSessionItem>[].obs;
  final RxInt totalPatients = 0.obs;
  final RxInt seancesPrevuesCount = 0.obs;
  final RxInt alertesCount = 0.obs;

  final RxString status = 'loading'.obs;
 final RxString errorMessage = ''.obs;

 static const _cacheDuration = Duration(minutes: 2);

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadDashboard();
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.dashboard)) {
      loadDashboard();
    }
  }

  void _loadFromCache() async {
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
    }
  }

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
      final userFuture = _authService.getMe();
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final results = await Future.wait([
        userFuture,
        _seanceService.getSeances(date: todayStr),
        _seanceGroupeService.getSeancesGroupe(date: todayStr),
        _patientService.getPatients(actif: true),
      ]);

      final user = results[0] as EmployeeModel;
      List<SeanceModel> indList = results[1] as List<SeanceModel>;
      List<SeanceGroupeModel> grpList = results[2] as List<SeanceGroupeModel>;
      final patients = results[3] as List<dynamic>;

      final currentUserId = user.id.toString();
      final role = user.role.toLowerCase();
      final isAdminOrManager = role == 'admin' ||
          role == 'directeur' ||
          role == 'directrice' ||
          role == 'secretaire' ||
          role == 'coordinateur';

      // Pour les admins / direction / secrétariat : vue globale de toutes les séances du jour
      // Pour les praticiens : séances assignées ou séances ouvertes des patients qu'ils suivent
      if (!isAdminOrManager) {
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

      // Filtrer explicitement sur la date du jour
      final todaySessions = unified.where((s) => s.date == todayStr).toList();

      // Tri chronologique par heure de début
      todaySessions.sort((a, b) => a.heureDebut.compareTo(b.heureDebut));

      currentUser.value = user;
      prochainesSeances.value = todaySessions;
      seancesPrevuesCount.value = todaySessions.length;
      totalPatients.value = patients.length;
      alertesCount.value = 0;

      // Sauvegarde dans le cache global
      AppCacheManager.set<Map<String, dynamic>>(
        CacheKeys.dashboard,
        {
          'user': user,
          'seances': todaySessions,
          'totalPatients': patients.length,
        },
        ttl: _cacheDuration,
        tags: {CacheTags.dashboard, CacheTags.seances, CacheTags.patients},
      );

      status.value = 'success';
    } catch (e) {
      // Si on avait déjà des données en cache, on ne bloque pas l'écran
      if (prochainesSeances.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
    }
  }

  /// Forcer un refresh (ex: pull-to-refresh)
  Future<void> refreshData() => loadDashboard(forceRefresh: true);
}