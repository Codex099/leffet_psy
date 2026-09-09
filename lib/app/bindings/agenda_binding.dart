import 'package:get/get.dart';
import '../controllers/agenda_controller.dart';

class AgendaBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AgendaController>()) {
      Get.put<AgendaController>(AgendaController(), permanent: true);
    }
  }
}
