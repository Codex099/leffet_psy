import 'package:get/get.dart';
import '../models/seance_model.dart';
import '../services/seance_service.dart';

class AgendaController extends GetxController {
  final SeanceService _seanceService = SeanceService();

  final RxList<SeanceModel> seances = <SeanceModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString activeMode = 'Jour'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAgenda();
  }

  Future<void> loadAgenda() async {
    try {
      status.value = 'loading';
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final list = await _seanceService.getSeances(date: todayStr);
      seances.value = list;
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  void setMode(String mode) {
    activeMode.value = mode;
    loadAgenda();
  }
}