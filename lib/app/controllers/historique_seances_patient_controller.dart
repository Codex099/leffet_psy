import 'package:get/get.dart';
import '../models/seance_model.dart';
import '../services/cache_manager.dart';
import '../services/seance_service.dart';
import '../services/groupe_service.dart';
import '../utils/json_utils.dart';

class HistoriqueSeancesPatientController extends GetxController {
 final SeanceService _seanceService = SeanceService();
  final GroupeService _groupeService = GroupeService();

  dynamic patientId;
  String filterType = 'tous'; // 'tous' | 'individuel' | 'groupe'

 final RxList<SeanceModel> seancesIndividuelles = <SeanceModel>[].obs;
  final RxList<Map<String, dynamic>> seancesGroupe = <Map<String, dynamic>>[].obs;
  final RxString status = 'loading'.obs;
 final RxString errorMessage = ''.obs;
 final RxString activeFilter = 'tous'.obs;

 static const _cacheDuration = Duration(minutes: 3);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      patientId = parseId(args['id']);
     filterType = args['type'] as String? ?? 'tous';
   } else {
      patientId = extractIdParam(args, Get.parameters);
    }
    activeFilter.value = filterType;

    if (patientId == null) {
      status.value = 'error';
     errorMessage.value = 'Identifiant du patient non spécifié.';
   } else {
      _loadFromCache();
      loadHistorique();
    }
  }

  void _loadFromCache() {
    if (patientId == null) return;
    final cached = AppCacheManager.get<Map<String, dynamic>>(CacheKeys.patientSeances(patientId));
    if (cached != null) {
      if (cached['indiv'] is List<SeanceModel>) {
       seancesIndividuelles.value = cached['indiv'] as List<SeanceModel>;
     }
      if (cached['groupe'] is List<Map<String, dynamic>>) {
       seancesGroupe.value = cached['groupe'] as List<Map<String, dynamic>>;
     }
      status.value = 'success';
   }
  }

  Future<void> loadHistorique({bool forceRefresh = false}) async {
    if (patientId == null) return;
    final cacheKey = CacheKeys.patientSeances(patientId);

    if (AppCacheManager.isFresh(cacheKey) && !forceRefresh && (seancesIndividuelles.isNotEmpty || seancesGroupe.isNotEmpty)) {
      return;
    }

    if (seancesIndividuelles.isEmpty && seancesGroupe.isEmpty) {
      status.value = 'loading';
   }

    try {
      if (activeFilter.value != 'groupe') {
       seancesIndividuelles.value = await _seanceService.getSeances(patientId: patientId);
      }
      if (activeFilter.value != 'individuel') {
       seancesGroupe.value = await _groupeService.getSeancesGroupePatient(patientId!);
      }

      AppCacheManager.set<Map<String, dynamic>>(
        cacheKey,
        {
          'indiv': seancesIndividuelles.toList(),
         'groupe': seancesGroupe.toList(),
       },
        ttl: _cacheDuration,
        tags: {CacheTags.seances, CacheTags.patients},
      );

      status.value = 'success';
   } catch (e) {
      if (seancesIndividuelles.isEmpty && seancesGroupe.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
    }
  }

  Future<void> refreshData() => loadHistorique(forceRefresh: true);

  void setFilter(String type) {
    if (activeFilter.value == type) return;
    activeFilter.value = type;
    loadHistorique();
  }
}
