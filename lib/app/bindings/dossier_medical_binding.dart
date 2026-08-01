import 'package:get/get.dart';
import '../controllers/dossier_medical_controller.dart';

class DossierMedicalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DossierMedicalController>(() => DossierMedicalController());
  }
}
