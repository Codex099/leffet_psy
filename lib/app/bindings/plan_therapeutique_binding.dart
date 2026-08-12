import 'package:get/get.dart';
import '../controllers/plan_therapeutique_controller.dart';

class PlanTherapeutiqueBinding extends Bindings {
  @override
  void dependencies() {
    Get.delete<PlanTherapeutiqueController>(force: true);
    Get.put<PlanTherapeutiqueController>(PlanTherapeutiqueController());
  }
}
