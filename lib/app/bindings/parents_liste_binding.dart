import 'package:get/get.dart';
import '../controllers/parents_liste_controller.dart';

class ParentsListeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentsListeController>(() => ParentsListeController());
  }
}
