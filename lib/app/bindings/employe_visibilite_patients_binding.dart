import 'package:get/get.dart';
import '../controllers/employe_visibilite_patients_controller.dart';

class EmployeVisibilitePatientsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeVisibilitePatientsController>(
      () => EmployeVisibilitePatientsController(),
    );
  }
}
