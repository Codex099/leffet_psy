import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

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
      final rememberMeStr = await _storage.read(key: 'remember_me');
      final rememberMe = rememberMeStr != 'false';
      if (rememberMe) {
        Get.offAllNamed(AppRoutes.accueil);
      } else {
        await _authService.logout();
      }
    }
  }

  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      errorMessage.value = 'Veuillez remplir tous les champs.'.tr;
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authService.login(username: username.trim(), password: password.trim());
      Get.offAllNamed(AppRoutes.accueil);
      return true;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          errorMessage.value =
              'Erreur réseau : impossible de contacter le serveur. Vérifiez votre connexion.'.tr;
        } else if (e.response?.statusCode == 401) {
          errorMessage.value =
              'Identifiants invalides : nom d\'utilisateur ou mot de passe incorrect.'.tr;
        } else {
          errorMessage.value = e.message ?? 'Erreur lors de la connexion.'.tr;
        }
      } else {
        errorMessage.value = 'Une erreur inattendue est survenue : $e'.tr;
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
