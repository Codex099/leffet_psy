import 'package:get/get.dart';
import '../controllers/compte_rendu_seance_controller.dart';

class CompteRenduSeanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompteRenduSeanceController>(() => CompteRenduSeanceController());
  }
}
