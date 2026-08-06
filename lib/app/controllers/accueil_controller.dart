import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/seance_model.dart';
import '../services/auth_service.dart';
import '../services/seance_service.dart';
import '../services/patient_service.dart';

class AccueilController extends GetxController {
  final AuthService _authService = AuthService();
  final SeanceService _seanceService = SeanceService();
  final PatientService _patientService = PatientService();

  final Rx<EmployeeModel?> currentUser = Rx<EmployeeModel?>(null);
  final RxList<SeanceModel> prochainesSeances = <SeanceModel>[].obs;
  final RxInt totalPatients = 0.obs;
  final RxInt seancesPrevuesCount = 0.obs;
  final RxInt alertesCount = 0.obs;

  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  /// Cache TTL : on ne re-fetch pas si les données ont moins de 5 minutes.
  DateTime? _lastLoaded;
  static const _cacheDuration = Duration(minutes: 5);

  bool get _isFresh =>
      _lastLoaded != null &&
      DateTime.now().difference(_lastLoaded!) < _cacheDuration;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  /// Appelée à chaque retour sur l'onglet — ne charge que si cache expiré.
  @override
  void onReady() {
    super.onReady();
    if (!_isFresh) loadDashboard();
  }

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    if (_isFresh && !forceRefresh) return;
    try {
      status.value = 'loading';
      currentUser.value = await _authService.getMe();

      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final seances = await _seanceService.getSeances(date: todayStr);
      prochainesSeances.value = seances;
      seancesPrevuesCount.value = seances.length;

      final patients = await _patientService.getPatients(actif: true);
      totalPatients.value = patients.length;

      alertesCount.value = 0;
      _lastLoaded = DateTime.now();
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  /// Forcer un refresh (ex: pull-to-refresh)
  Future<void> refreshData() => loadDashboard(forceRefresh: true);
}