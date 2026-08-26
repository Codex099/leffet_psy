import 'package:get/get.dart';
import '../controllers/compte_rendu_specialiste_controller.dart';

class CompteRenduSpecialisteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompteRenduSpecialisteController>(() => CompteRenduSpecialisteController());
  }
}
