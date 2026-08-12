import 'package:get/get.dart';
import '../controllers/historique_seances_patient_controller.dart';

class HistoriqueSeancesPatientBinding extends Bindings {
  @override
  void dependencies() {
    Get.delete<HistoriqueSeancesPatientController>(force: true);
    Get.put<HistoriqueSeancesPatientController>(
      HistoriqueSeancesPatientController(),
    );
  }
}
