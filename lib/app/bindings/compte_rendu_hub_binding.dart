import 'package:get/get.dart';
import '../controllers/compte_rendu_hub_controller.dart';

class CompteRenduHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompteRenduHubController>(() => CompteRenduHubController());
  }
}
