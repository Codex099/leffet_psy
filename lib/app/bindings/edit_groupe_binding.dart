import 'package:get/get.dart';
import '../controllers/edit_groupe_controller.dart';

class EditGroupeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditGroupeController>(() => EditGroupeController());
  }
}
