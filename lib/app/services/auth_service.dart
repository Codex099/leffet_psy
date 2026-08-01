import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../config/api_config.dart';
import '../models/employee_model.dart';
import 'dio_client.dart';

class AuthService {
  final Dio _dio = DioClient.instance;
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// POST /api/auth/login — Authentification par username/password
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConfig.authLogin,
      data: {'username': username, 'password': password},
    );
    final token = response.data['access_token'] as String;
    // Stocke le token de façon sécurisée
    await _storage.write(key: ApiConfig.secureKeyToken, value: token);
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/auth/me — Récupère le profil de l'employé connecté
  Future<EmployeeModel> getMe() async {
    final response = await _dio.get(ApiConfig.authMe);
    final employee = EmployeeModel.fromJson(
      response.data as Map<String, dynamic>,
    );
    // Cache l'utilisateur courant
    await _storage.write(
      key: ApiConfig.secureKeyUser,
      value: jsonEncode(response.data),
    );
    return employee;
  }

  /// Déconnexion — supprime le token et l'utilisateur mis en cache
  Future<void> logout() async {
    await _storage.delete(key: ApiConfig.secureKeyToken);
    await _storage.delete(key: ApiConfig.secureKeyUser);
    DioClient.reset();
  }

  /// Vérifie si un token est présent (synchrone approximatif via cache)
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: ApiConfig.secureKeyToken);
    return token != null && token.isNotEmpty;
  }

  /// Récupère l'utilisateur depuis le cache local (sans appel réseau)
  Future<EmployeeModel?> getCachedUser() async {
    final userJson = await _storage.read(key: ApiConfig.secureKeyUser);
    if (userJson == null) return null;
    try {
      return EmployeeModel.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
