import "package:get/get.dart";
import "../controllers/assistant_ia_controller.dart";

class AssistantIaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssistantIaController>(() => AssistantIaController());
  }
}