import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class ProfilController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<EmployeeModel?> currentUser = Rx<EmployeeModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      status.value = 'loading';
      currentUser.value = await _authService.getMe();
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}