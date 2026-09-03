import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class LanguageService {
  LanguageService._();

  static const String keyLanguage = 'app_language';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const FlutterSecureStorage _fallbackStorage = FlutterSecureStorage();

  static final Rx<Locale> currentLocale = const Locale('fr', 'FR').obs;

  /// Récupère la langue enregistrée avec double sécurité et fallback gracieux.
  static Future<Locale> getSavedLocale() async {
    String? code;
    try {
      code = await _secureStorage.read(key: keyLanguage);
    } catch (_) {}

    if (code == null || code.isEmpty) {
      try {
        code = await _fallbackStorage.read(key: keyLanguage);
      } catch (_) {}
    }

    final locale = code == 'ar'
        ? const Locale('ar', 'DZ')
        : const Locale('fr', 'FR');
    currentLocale.value = locale;
    return locale;
  }

  /// Sauvegarde la langue dans les deux modes de stockage pour une persistance maximale.
  static Future<void> saveLocale(Locale locale) async {
    final code = locale.languageCode;
    currentLocale.value = locale;

    try {
      await _secureStorage.write(key: keyLanguage, value: code);
    } catch (_) {}

    try {
      await _fallbackStorage.write(key: keyLanguage, value: code);
    } catch (_) {}
  }

  /// Bascule instantanément entre Arabe et Français, met à jour GetX et persiste le choix.
  static Future<void> toggleLanguage() async {
    final isArabic = (Get.locale?.languageCode ?? currentLocale.value.languageCode) == 'ar';
    final targetLocale = isArabic
        ? const Locale('fr', 'FR')
        : const Locale('ar', 'DZ');

    await saveLocale(targetLocale);
    Get.updateLocale(targetLocale);
  }

  /// Définit une langue spécifique, met à jour GetX et persiste le choix.
  static Future<void> setLocale(Locale targetLocale) async {
    await saveLocale(targetLocale);
    Get.updateLocale(targetLocale);
  }

  static bool get isArabic =>
      (Get.locale?.languageCode ?? currentLocale.value.languageCode) == 'ar';
}
