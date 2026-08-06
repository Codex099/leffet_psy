import 'package:get/get.dart';
import '../controllers/taches_controller.dart';

class TachesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TachesController>(() => TachesController(), fenix: true);
  }

}
