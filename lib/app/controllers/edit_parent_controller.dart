import 'package:get/get.dart';
import '../services/parent_service.dart';

class EditParentController extends GetxController {
  final ParentService _parentService = ParentService();

  final nom = ''.obs;
  final prenom = ''.obs;
  final telephone = ''.obs;
  final etatCivil = ''.obs;
  final adresse = ''.obs;

  final RxString status = 'success'.obs;
  final RxString errorMessage = ''.obs;

  Future<void> saveParent() async {
    try {
      status.value = 'loading';
      await _parentService.createParent({
        'nom': nom.value,
        'prenom': prenom.value,
        'telephone': telephone.value,
        'etat_civil': etatCivil.value,
        'adresse': adresse.value,
      });
      Get.back();
      Get.snackbar('Succès', 'Parent enregistré avec succès');
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }
}