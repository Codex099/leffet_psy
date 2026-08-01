import 'package:get/get.dart';
import '../controllers/employes_liste_controller.dart';

class EmployesListeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployesListeController>(() => EmployesListeController());
  }
}
