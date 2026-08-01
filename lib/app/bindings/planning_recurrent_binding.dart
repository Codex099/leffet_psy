import 'package:get/get.dart';
import '../controllers/planning_recurrent_controller.dart';

class PlanningRecurrentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlanningRecurrentController>(() => PlanningRecurrentController());
  }
}
