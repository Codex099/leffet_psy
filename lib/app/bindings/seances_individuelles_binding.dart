import 'package:get/get.dart';
import '../controllers/seances_individuelles_controller.dart';

class SeancesIndividuellesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SeancesIndividuellesController>(() => SeancesIndividuellesController());
  }
}
