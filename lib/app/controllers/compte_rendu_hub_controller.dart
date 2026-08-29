import 'dart:async';
import 'package:get/get.dart';
import '../models/agenda_session_item.dart';
import '../models/employee_model.dart';
import '../models/seance_model.dart';
import '../models/seance_groupe_model.dart';
import '../services/cache_manager.dart';
import '../services/employee_service.dart';
import '../services/seance_service.dart';
import '../services/seance_groupe_service.dart';

class CompteRenduHubController extends GetxController {
  final SeanceService _seanceService = SeanceService();
  final SeanceGroupeService _seanceGroupeService = SeanceGroupeService();
  final EmployeeService _employeeService = EmployeeService();

  final RxList<AgendaSessionItem> allSessions = <AgendaSessionItem>[].obs;
  final RxList<EmployeeModel> praticiens = <EmployeeModel>[].obs;

  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  // Filters
  final RxString selectedTab = 'en_attente'.obs; // 'en_attente' | 'rediges' | 'tous'
  final RxString filterType = 'tous'.obs; // 'tous' | 'indiv' | 'groupe'
  final Rx<dynamic> filterPraticienId = Rx<dynamic>(null);
  final RxString searchQuery = ''.obs;

  Timer? _debounceTimer;

  static const _cacheDuration = Duration(minutes: 3);

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadData();
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.compteRenduHub)) {
      loadData();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _loadFromCache() {
    final cached = AppCacheManager.get<Map<String, dynamic>>(CacheKeys.compteRenduHub);
    if (cached != null) {
      if (cached['sessions'] is List<AgendaSessionItem>) {
        allSessions.value = cached['sessions'] as List<AgendaSessionItem>;
      }
      if (cached['praticiens'] is List<EmployeeModel>) {
        praticiens.value = cached['praticiens'] as List<EmployeeModel>;
      }
      status.value = 'success';
    }
  }

  Future<void> loadData({bool forceRefresh = false}) async {
    if (AppCacheManager.isFresh(CacheKeys.compteRenduHub) && !forceRefresh && allSessions.isNotEmpty) {
      return;
    }

    if (allSessions.isEmpty) {
      status.value = 'loading';
    }

    try {
      // 1. Praticiens
      try {
        final emps = await _employeeService.getEmployees();
        praticiens.value = emps;
      } catch (_) {}

      // 2. Séances individuelles et groupe
      final results = await Future.wait([
        _seanceService.getSeances(),
        _seanceGroupeService.getSeancesGroupe(),
      ]);

      final indList = results[0] as List<SeanceModel>;
      final grpList = results[1] as List<SeanceGroupeModel>;

      final unified = <AgendaSessionItem>[
        ...indList.map(AgendaSessionItem.fromIndividuelle),
        ...grpList.map(AgendaSessionItem.fromGroupe),
      ];

      // Tri chronologique décroissant (les plus récentes en premier)
      unified.sort((a, b) {
        final dateComp = b.date.compareTo(a.date);
        if (dateComp != 0) return dateComp;
        return b.heureDebut.compareTo(a.heureDebut);
      });

      allSessions.value = unified;

      AppCacheManager.set<Map<String, dynamic>>(
        CacheKeys.compteRenduHub,
        {
          'sessions': unified,
          'praticiens': praticiens.toList(),
        },
        ttl: _cacheDuration,
        tags: {CacheTags.seances, CacheTags.dashboard},
      );

      status.value = 'success';
    } catch (e) {
      if (allSessions.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
    }
  }

  Future<void> refreshData() => loadData(forceRefresh: true);

  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 180), () {
      searchQuery.value = query;
    });
  }

  /// Liste filtrée selon l'onglet et les critères
  List<AgendaSessionItem> get filteredSessions {
    var list = allSessions.toList();

    // 1. Filtrage par onglet de statut
    if (selectedTab.value == 'en_attente') {
      list = list.where((s) => s.statut != 'faite').toList();
    } else if (selectedTab.value == 'rediges') {
      list = list.where((s) => s.statut == 'faite').toList();
    }

    // 2. Filtrage par type
    if (filterType.value == 'indiv') {
      list = list.where((s) => !s.isGroupe).toList();
    } else if (filterType.value == 'groupe') {
      list = list.where((s) => s.isGroupe).toList();
    }

    // 3. Filtrage par praticien
    if (filterPraticienId.value != null) {
      // Filtrer praticien si assigné
    }

    // 4. Recherche textuelle
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((s) {
        return s.title.toLowerCase().contains(q) ||
            s.subtitle.toLowerCase().contains(q) ||
            s.date.contains(q);
      }).toList();
    }

    return list;
  }

  int get enAttenteCount => allSessions.where((s) => s.statut != 'faite').length;
  int get redigesCount => allSessions.where((s) => s.statut == 'faite').length;
}
