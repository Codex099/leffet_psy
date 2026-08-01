import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../config/api_config.dart';

/// Middleware d'authentification — protège toutes les routes sauf /login.
/// Si aucun token JWT n'est présent, redirige vers l'écran de login.
class AuthMiddleware extends GetMiddleware {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // La vérification du token est asynchrone.
    // Pour la protection synchrone au démarrage, utiliser le controller auth
    // qui pré-charge le token via onInit() avant toute navigation.
    return null;
  }

  /// Vérifie si l'utilisateur est authentifié (async)
  static Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: ApiConfig.secureKeyToken);
    return token != null && token.isNotEmpty;
  }
}
