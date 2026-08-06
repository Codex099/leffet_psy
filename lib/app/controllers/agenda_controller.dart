import 'package:get/get.dart';
import '../models/seance_model.dart';
import '../services/seance_service.dart';

class AgendaController extends GetxController {
  final SeanceService _seanceService = SeanceService();

  final RxList<SeanceModel> seances = <SeanceModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString activeMode = 'Jour'.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  /// Cache TTL — 3 minutes (si la date sélectionnée n'a pas changé)
  DateTime? _lastLoaded;
  String? _lastLoadedDateStr;
  static const _cacheDuration = Duration(minutes: 3);

  bool _isFresh(String dateStr) =>
      _lastLoaded != null &&
      _lastLoadedDateStr == dateStr &&
      DateTime.now().difference(_lastLoaded!) < _cacheDuration;

  @override
  void onInit() {
    super.onInit();
    loadAgenda();
  }

  @override
  void onReady() {
    super.onReady();
    final dateStr = selectedDate.value.toIso8601String().split('T').first;
    if (!_isFresh(dateStr)) loadAgenda();
  }

  Future<void> loadAgenda({bool forceRefresh = false}) async {
    final dateStr = selectedDate.value.toIso8601String().split('T').first;
    if (_isFresh(dateStr) && !forceRefresh) return;

    try {
      status.value = 'loading';
      final list = await _seanceService.getSeances(date: dateStr);
      seances.value = list;
      _lastLoaded = DateTime.now();
      _lastLoadedDateStr = dateStr;
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> refreshData() => loadAgenda(forceRefresh: true);

  void setMode(String mode) {
    activeMode.value = mode;
    loadAgenda();
  }

  void previousDay() {
    if (activeMode.value == 'Jour') {
      selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    } else {
      selectedDate.value = selectedDate.value.subtract(const Duration(days: 7));
    }
    loadAgenda();
  }

  void nextDay() {
    if (activeMode.value == 'Jour') {
      selectedDate.value = selectedDate.value.add(const Duration(days: 1));
    } else {
      selectedDate.value = selectedDate.value.add(const Duration(days: 7));
    }
    loadAgenda();
  }

  String get formattedDate {
    final d = selectedDate.value;
    final jours = ['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'];
    final mois = [
      'JANVIER', 'FÉVRIER', 'MARS', 'AVRIL', 'MAI', 'JUIN',
      'JUILLET', 'AOÛT', 'SEPTEMBRE', 'OCTOBRE', 'NOVEMBRE', 'DÉCEMBRE'
    ];
    final jourNom = jours[d.weekday - 1];
    final moisNom = mois[d.month - 1];
    return '$jourNom ${d.day} $moisNom';
  }
}