import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      errorMessage.value = 'Veuillez remplir tous les champs';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authService.login(username: username, password: password);
      Get.offAllNamed(AppRoutes.accueil);
    } catch (e) {
      errorMessage.value = 'Nom d\'utilisateur ou mot de passe incorrect';
    } finally {
      isLoading.value = false;
    }
  }
}
