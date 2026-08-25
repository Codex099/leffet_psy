import 'package:get/get.dart';
import '../controllers/historique_seances_patient_controller.dart';

class HistoriqueSeancesPatientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoriqueSeancesPatientController>(() => HistoriqueSeancesPatientController());
  }
}
