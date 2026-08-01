import 'package:get/get.dart';
import '../controllers/groupes_liste_controller.dart';

class GroupesListeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupesListeController>(() => GroupesListeController());
  }
}
