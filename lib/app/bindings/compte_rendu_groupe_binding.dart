import 'package:get/get.dart';
import '../controllers/compte_rendu_groupe_controller.dart';

class CompteRenduGroupeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompteRenduGroupeController>(() => CompteRenduGroupeController());
  }
}
