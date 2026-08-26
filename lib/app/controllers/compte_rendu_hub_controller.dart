import 'package:get/get.dart';
import '../models/agenda_session_item.dart';
import '../models/employee_model.dart';
import '../models/seance_model.dart';
import '../models/seance_groupe_model.dart';
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

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData({bool forceRefresh = false}) async {
    try {
      status.value = 'loading';

      // 1. Charger praticiens
      try {
        praticiens.value = await _employeeService.getEmployees();
      } catch (_) {}

      // 2. Charger séances individuelles et groupe
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
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  /// Liste filtrée selon l'onglet et les critères
  List<AgendaSessionItem> get filteredSessions {
    var list = allSessions.toList();

    // 1. Filtrage par onglet de statut
    if (selectedTab.value == 'en_attente') {
      list = list.where((s) => s.statut != 'realisee').toList();
    } else if (selectedTab.value == 'rediges') {
      list = list.where((s) => s.statut == 'realisee').toList();
    }

    // 2. Filtrage par type
    if (filterType.value == 'indiv') {
      list = list.where((s) => !s.isGroupe).toList();
    } else if (filterType.value == 'groupe') {
      list = list.where((s) => s.isGroupe).toList();
    }

    // 3. Filtrage par praticien
    if (filterPraticienId.value != null) {
      // Vérifier si praticien assigné correspond
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

  int get enAttenteCount => allSessions.where((s) => s.statut != 'realisee').length;
  int get redigesCount => allSessions.where((s) => s.statut == 'realisee').length;
}
