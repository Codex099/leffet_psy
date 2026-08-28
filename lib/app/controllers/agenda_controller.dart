import 'package:get/get.dart';
import '../models/agenda_session_item.dart';
import '../models/seance_model.dart';
import '../models/seance_groupe_model.dart';
import '../services/cache_manager.dart';
import '../services/seance_service.dart';
import '../services/seance_groupe_service.dart';

class AgendaController extends GetxController {
  final SeanceService _seanceService = SeanceService();
  final SeanceGroupeService _seanceGroupeService = SeanceGroupeService();

  /// Toutes les séances chargées
  final RxList<AgendaSessionItem> allSessions = <AgendaSessionItem>[].obs;
  // Compatibilité ascendante
  List<AgendaSessionItem> get items => allSessions;
  List<AgendaSessionItem> get seances => allSessions;

  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString activeMode = 'Jour'.obs; // 'Jour' | 'Semaine'
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  static const _cacheDuration = Duration(minutes: 2);

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadAgenda();
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.agendaAll)) {
      loadAgenda();
    }
  }

  void _loadFromCache() {
    final cached = AppCacheManager.get<List<AgendaSessionItem>>(CacheKeys.agendaAll);
    if (cached != null && cached.isNotEmpty) {
      allSessions.value = cached;
      status.value = 'success';
    }
  }

  Future<void> loadAgenda({bool forceRefresh = false}) async {
    if (AppCacheManager.isFresh(CacheKeys.agendaAll) && !forceRefresh && allSessions.isNotEmpty) {
      return;
    }

    if (allSessions.isEmpty) {
      status.value = 'loading';
    }

    try {
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

      // Tri chronologique par date puis par heure de début
      unified.sort((a, b) {
        final dateComp = a.date.compareTo(b.date);
        if (dateComp != 0) return dateComp;
        return a.heureDebut.compareTo(b.heureDebut);
      });

      allSessions.value = unified;
      AppCacheManager.set<List<AgendaSessionItem>>(
        CacheKeys.agendaAll,
        unified,
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

  Future<void> refreshData() => loadAgenda(forceRefresh: true);

  /// 7 jours de la semaine courante (du Dimanche au Samedi)
  List<DateTime> get currentWeekDays {
    final current = selectedDate.value;
    final daysToSubtract = current.weekday % 7;
    final sunday = DateTime(current.year, current.month, current.day)
        .subtract(Duration(days: daysToSubtract));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  /// Séances du jour sélectionné
  List<AgendaSessionItem> get sessionsForSelectedDate {
    final dateStr = selectedDate.value.toIso8601String().split('T').first;
    return allSessions.where((s) => s.date == dateStr).toList();
  }

  /// Séances pour un jour précis
  List<AgendaSessionItem> sessionsForDate(DateTime d) {
    final dateStr = d.toIso8601String().split('T').first;
    return allSessions.where((s) => s.date == dateStr).toList();
  }

  /// Indique si un jour contient au moins une séance
  bool hasSessionsOn(DateTime d) {
    final dateStr = d.toIso8601String().split('T').first;
    return allSessions.any((s) => s.date == dateStr);
  }

  /// Nombre de séances sur un jour
  int countSessionsOn(DateTime d) {
    final dateStr = d.toIso8601String().split('T').first;
    return allSessions.where((s) => s.date == dateStr).length;
  }

  /// Séances de toute la semaine courante
  List<AgendaSessionItem> get sessionsForCurrentWeek {
    final weekStrs = currentWeekDays.map((d) => d.toIso8601String().split('T').first).toSet();
    return allSessions.where((s) => weekStrs.contains(s.date)).toList();
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void goToToday() {
    selectedDate.value = DateTime.now();
  }

  void setMode(String mode) {
    activeMode.value = mode;
  }

  void previousWeek() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 7));
  }

  void nextWeek() {
    selectedDate.value = selectedDate.value.add(const Duration(days: 7));
  }

  void previousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
  }

  void nextDay() {
    selectedDate.value = selectedDate.value.add(const Duration(days: 1));
  }

  bool get isSelectedDateToday {
    final now = DateTime.now();
    final s = selectedDate.value;
    return s.year == now.year && s.month == now.month && s.day == now.day;
  }

  String get monthYearTitle {
    final d = selectedDate.value;
    final mois = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${mois[d.month - 1]} ${d.year}';
  }

  String get formattedSelectedDate {
    final d = selectedDate.value;
    final jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final mois = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]}';
  }

  String formatDayDate(DateTime d) {
    final jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final mois = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]}';
  }

  String get formattedDate => formattedSelectedDate;
}