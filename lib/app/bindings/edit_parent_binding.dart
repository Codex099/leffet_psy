import 'package:get/get.dart';
import '../controllers/edit_parent_controller.dart';

class EditParentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditParentController>(() => EditParentController());
  }
}
