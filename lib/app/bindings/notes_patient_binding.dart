import 'package:get/get.dart';
import '../controllers/notes_patient_controller.dart';

class NotesPatientBinding extends Bindings {
  @override
  void dependencies() {
    Get.delete<NotesPatientController>(force: true);
    Get.put<NotesPatientController>(NotesPatientController());
  }
}
