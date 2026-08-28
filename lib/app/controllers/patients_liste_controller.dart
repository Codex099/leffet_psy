import 'dart:async';
import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../services/cache_manager.dart';
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

  static const _cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadPatients();
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.patientsList)) {
      loadPatients();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _loadFromCache() {
    final cached = AppCacheManager.get<List<PatientModel>>(CacheKeys.patientsList);
    if (cached != null && cached.isNotEmpty) {
      allPatients.value = cached;
      status.value = 'success';
    }
  }

  Future<void> loadPatients({bool forceRefresh = false}) async {
    if (AppCacheManager.isFresh(CacheKeys.patientsList) && !forceRefresh && allPatients.isNotEmpty) {
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

      allPatients.value = uniquePatients;
      AppCacheManager.set<List<PatientModel>>(
        CacheKeys.patientsList,
        uniquePatients,
        ttl: _cacheDuration,
        tags: {CacheTags.patients},
      );

      status.value = uniquePatients.isEmpty ? 'empty' : 'success';
    } catch (e) {
      if (allPatients.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
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