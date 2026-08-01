import 'package:get/get.dart';
import '../controllers/edit_patient_controller.dart';

class EditPatientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditPatientController>(() => EditPatientController());
  }
}
