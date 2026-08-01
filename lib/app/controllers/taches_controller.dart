import 'package:get/get.dart';
import '../models/tache_model.dart';
import '../services/tache_service.dart';

class TachesController extends GetxController {
  final TacheService _tacheService = TacheService();

  final RxList<TacheModel> taches = <TacheModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxBool filterAssignesAMoi = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTaches();
  }

  Future<void> loadTaches() async {
    try {
      status.value = 'loading';
      final list = await _tacheService.getTaches(
        assigneesAMoi: filterAssignesAMoi.value,
      );
      taches.value = list;
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  void toggleFilter(bool val) {
    filterAssignesAMoi.value = val;
    loadTaches();
  }

  List<TacheModel> get tachesAFaire => taches.where((t) => t.statut == 'a_faire').toList();
  List<TacheModel> get tachesEnCours => taches.where((t) => t.statut == 'en_cours').toList();
  List<TacheModel> get tachesFait => taches.where((t) => t.statut == 'fait').toList();
}