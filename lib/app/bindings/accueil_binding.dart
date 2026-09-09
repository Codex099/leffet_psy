import 'package:get/get.dart';
import '../controllers/accueil_controller.dart';

/// Le controller est déjà enregistré en permanent dans InitialBinding.
/// Ce binding ne fait que s'assurer qu'il est disponible (Get.find).
class AccueilBinding extends Bindings {
  @override
  void dependencies() {
    // lazyPut fenix: true en fallback seulement si le controller n'existe pas déjà
    if (!Get.isRegistered<AccueilController>()) {
      Get.put<AccueilController>(AccueilController(), permanent: true);
    }
  }
}
