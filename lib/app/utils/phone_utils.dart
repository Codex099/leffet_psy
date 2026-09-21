import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

/// Utilitaire d'appel téléphonique direct et sécurisé
class PhoneUtils {
  PhoneUtils._();

  /// Lance l'appel téléphonique vers [rawPhone].
  /// Si l'appareil ne dispose pas de composeur téléphonique (ex. PC sans Phone Link),
  /// copie le numéro dans le presse-papiers et avertit l'utilisateur.
  static Future<void> call(String rawPhone) async {
    final cleanPhone = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) {
      Get.snackbar(
        'Numéro invalide'.tr,
        'Le numéro de téléphone est manquant ou invalide.'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final uri = Uri.parse('tel:$cleanPhone');

    // 1. Essai avec url_launcher (standard mobile & desktop)
    try {
      final launched = await launchUrl(uri);
      if (launched) return;
    } catch (e) {
      debugPrint('[PhoneUtils] launchUrl error: $e');
    }

    // 2. Fallback spécifique Windows
    if (Platform.isWindows) {
      try {
        final res = await Process.run('cmd', ['/c', 'start', 'tel:$cleanPhone']);
        if (res.exitCode == 0) return;
      } catch (e) {
        debugPrint('[PhoneUtils] Windows fallback error: $e');
      }
    }

    // 3. Fallback secours : copier le numéro dans le presse-papiers
    await Clipboard.setData(ClipboardData(text: cleanPhone));
    Get.snackbar(
      'Numéro copié'.tr,
      '${'Impossible de composer directement sur cet appareil. Le numéro'.tr} $cleanPhone ${'a été copié dans le presse-papiers.'.tr}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.copy_rounded, color: Colors.white),
    );
  }

  /// Copie simplement le numéro dans le presse-papiers
  static Future<void> copyToClipboard(String rawPhone) async {
    final cleanPhone = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');
    await Clipboard.setData(ClipboardData(text: cleanPhone.isNotEmpty ? cleanPhone : rawPhone));
    Get.snackbar(
      'Copié'.tr,
      'Numéro de téléphone copié dans le presse-papiers.'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    );
  }
}
