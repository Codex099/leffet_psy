import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
 final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

 @override
  void onInit() {
    super.onInit();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      Get.offAllNamed(AppRoutes.accueil);
    }
  }

  Future<void> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      errorMessage.value = 'Veuillez remplir tous les champs.';
     return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
     await _authService.login(username: username.trim(), password: password.trim());
      Get.offAllNamed(AppRoutes.accueil);
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          errorMessage.value = 'Erreur réseau : impossible de contacter le serveur. Vérifiez votre connexion.';
       } else if (e.response?.statusCode == 401) {
          errorMessage.value = 'Identifiants invalides : nom d\'utilisateur ou mot de passe incorrect.';
       } else {
          errorMessage.value = e.message ?? 'Erreur lors de la connexion.';
       }
      } else {
        errorMessage.value = 'Une erreur inattendue est survenue : $e';
      }
    } finally {
      isLoading.value = false;
    }
  }
}

