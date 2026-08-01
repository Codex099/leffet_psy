import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/seance_model.dart';
import '../services/auth_service.dart';
import '../services/seance_service.dart';
import '../services/patient_service.dart';

class AccueilController extends GetxController {
  final AuthService _authService = AuthService();
  final SeanceService _seanceService = SeanceService();
  final PatientService _patientService = PatientService();

  final Rx<EmployeeModel?> currentUser = Rx<EmployeeModel?>(null);
  final RxList<SeanceModel> prochainesSeances = <SeanceModel>[].obs;
  final RxInt totalPatients = 0.obs;
  final RxInt seancesPrevuesCount = 0.obs;
  final RxInt alertesCount = 0.obs;

  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      status.value = 'loading';
      currentUser.value = await _authService.getMe();
      
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final seances = await _seanceService.getSeances(date: todayStr);
      prochainesSeances.value = seances;
      seancesPrevuesCount.value = seances.length;

      final patients = await _patientService.getPatients(actif: true);
      totalPatients.value = patients.length;

      alertesCount.value = 3;
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }
}