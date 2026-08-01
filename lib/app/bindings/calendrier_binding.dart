import 'package:get/get.dart';
import '../controllers/calendrier_controller.dart';

class CalendrierBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalendrierController>(() => CalendrierController());
  }
}
