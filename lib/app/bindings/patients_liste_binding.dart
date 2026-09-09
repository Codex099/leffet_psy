import 'package:get/get.dart';
import '../controllers/patients_liste_controller.dart';

class PatientsListeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PatientsListeController>()) {
      Get.put<PatientsListeController>(PatientsListeController(), permanent: true);
    }
  }
}
