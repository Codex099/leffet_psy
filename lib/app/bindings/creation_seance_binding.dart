import 'package:get/get.dart';
import '../controllers/creation_seance_controller.dart';

class CreationSeanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreationSeanceController>(() => CreationSeanceController());
  }
}
