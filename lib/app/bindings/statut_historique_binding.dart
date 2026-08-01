import 'package:get/get.dart';
import '../controllers/statut_historique_controller.dart';

class StatutHistoriqueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatutHistoriqueController>(() => StatutHistoriqueController());
  }
}
