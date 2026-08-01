import 'package:get/get.dart';
import '../controllers/edit_employe_controller.dart';

class EditEmployeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditEmployeController>(() => EditEmployeController());
  }
}
