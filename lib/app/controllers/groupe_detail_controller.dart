import 'package:get/get.dart';
import '../models/groupe_model.dart';
import '../services/groupe_service.dart';
import '../utils/json_utils.dart';

class GroupeDetailController extends GetxController {
  final GroupeService _groupeService = GroupeService();

  final Rx<GroupeModel?> groupe = Rx<GroupeModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  dynamic groupeId;

  @override
  void onInit() {
    super.onInit();
    groupeId = extractIdParam(Get.arguments, Get.parameters);
    if (groupeId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du groupe non spécifié.';
    } else {
      loadGroupe();
    }
  }

  Future<void> loadGroupe() async {
    if (groupeId == null) return;
    try {
      status.value = 'loading';
      groupe.value = await _groupeService.getGroupe(groupeId!);
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> deleteGroupe() async {
    if (groupeId == null) return;
    try {
      await _groupeService.deleteGroupe(groupeId!);
      Get.back();
      Get.snackbar('Succès', 'Groupe supprimé');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer le groupe');
    }
  }

}