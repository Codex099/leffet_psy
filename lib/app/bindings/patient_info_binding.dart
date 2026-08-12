import 'package:get/get.dart';
import '../controllers/patient_info_controller.dart';

class PatientInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.delete<PatientInfoController>(force: true);
    Get.put<PatientInfoController>(PatientInfoController());
  }
}
