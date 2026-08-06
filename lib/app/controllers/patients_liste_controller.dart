import 'dart:async';
import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';

class PatientsListeController extends GetxController {
  final PatientService _patientService = PatientService();

  final RxList<PatientModel> allPatients = <PatientModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxnBool actifFilter = RxnBool(true);
  final RxnInt ageMinFilter = RxnInt();
  final RxnInt ageMaxFilter = RxnInt();
  final RxnString sexeFilter = RxnString();

  Timer? _debounceTimer;

  /// Cache TTL — 5 minutes
  DateTime? _lastLoaded;
  static const _cacheDuration = Duration(minutes: 5);
  bool get _isFresh =>
      _lastLoaded != null &&
      DateTime.now().difference(_lastLoaded!) < _cacheDuration;

  @override
  void onInit() {
    super.onInit();
    loadPatients();
  }

  @override
  void onReady() {
    super.onReady();
    if (!_isFresh) loadPatients();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  Future<void> loadPatients({bool forceRefresh = false}) async {
    if (_isFresh && !forceRefresh) return;
    try {
      status.value = 'loading';
      final list = await _patientService.getPatients(
        actif: null,
        search: null,
      );
      allPatients.value = list;
      _lastLoaded = DateTime.now();
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
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
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
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