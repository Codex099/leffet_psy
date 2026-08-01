import 'package:get/get.dart';
import '../services/groupe_service.dart';

class EditGroupeController extends GetxController {
  final GroupeService _groupeService = GroupeService();

  final nom = ''.obs;
  final description = ''.obs;
  final typePlanning = 'Fixe'.obs;
  final selectedDays = <String>[].obs;
  final heureDebut = '09:00'.obs;
  final heureFin = '09:45'.obs;

  final RxString status = 'success'.obs;
  final RxString errorMessage = ''.obs;

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  Future<void> saveGroupe() async {
    try {
      status.value = 'loading';
      await _groupeService.createGroupe({
        'nom': nom.value,
        'description': description.value,
        'type_planning': typePlanning.value.toLowerCase(),
      });
      Get.back();
      Get.snackbar('Succès', 'Groupe créé avec succès');
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }
}