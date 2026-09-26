import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// Traducteur et formateur centralisé de tous les codes d'erreur et messages backend/réseau.
/// Permet un affichage 100% propre, compréhensible et traduit en Arabe et en Français.
class ErrorTranslator {
  ErrorTranslator._();

  /// Traduit et nettoie n'importe quelle erreur brute (Exception, DioException, String, etc.)
  static String translate(dynamic error) {
    if (error == null) {
      return 'Une erreur inattendue est survenue.'.tr;
    }

    String raw = '';

    if (error is DioException) {
      // 1. Erreurs réseau Dio (Timeouts, connexion)
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Délai d\'attente dépassé. Vérifiez votre connexion.'.tr;
        case DioExceptionType.connectionError:
          return 'Impossible de se connecter au serveur.'.tr;
        case DioExceptionType.cancel:
          return 'La requête a été annulée.'.tr;
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode;
          final detail = error.response?.data is Map ? error.response?.data['detail'] : null;

          // Si le backend a fourni un détail texte précis
          if (detail is String && detail.trim().isNotEmpty) {
            return translateMessage(detail);
          } else if (detail is List && detail.isNotEmpty) {
            final firstMsg = detail.first is Map ? detail.first['msg']?.toString() : detail.first.toString();
            if (firstMsg != null && firstMsg.isNotEmpty) {
              return translateMessage(firstMsg);
            }
          }

          // Fallback par code statut HTTP
          if (status != null) {
            return translateHttpCode(status);
          }
          break;
        default:
          break;
      }

      if (error.message != null && error.message!.isNotEmpty) {
        raw = error.message!;
      }
    } else {
      raw = error.toString();
    }

    return translateMessage(raw);
  }

  /// Traduit les codes de statut HTTP standard
  static String translateHttpCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Requête invalide.'.tr;
      case 401:
        return 'Session expirée ou identifiants incorrects.'.tr;
      case 403:
        return 'Accès refusé pour cette action.'.tr;
      case 404:
        return 'Ressource introuvable.'.tr;
      case 409:
        return 'Conflit détecté avec des données existantes.'.tr;
      case 422:
        return 'Données non valides. Vérifiez les champs saisis.'.tr;
      case 500:
        return 'Erreur interne du serveur. Veuillez réessayer.'.tr;
      case 502:
      case 503:
        return 'Service temporairement indisponible.'.tr;
      default:
        return '${'Une erreur est survenue'.tr} (Code $statusCode).';
    }
  }

  /// Traduit les messages textuels spécifiques du backend ou des exceptions locales
  static String translateMessage(String message) {
    var clean = message
        .replaceAll(RegExp(r'^Exception:\s*'), '')
        .replaceAll(RegExp(r'^DioException\s*\[.*?\]:\s*'), '')
        .trim();

    // ── Patterns dynamiques ──
    if (clean.contains('Un parent avec ce numéro de téléphone existe déjà')) {
      return 'Un parent avec ce numéro de téléphone existe déjà.'.tr;
    }
    if (clean.contains('Conflit d\'horaires') || clean.contains('Ce praticien a déjà une séance')) {
      return 'Ce praticien a déjà une séance programmée sur ce créneau.'.tr;
    }
    if (clean.contains('L\'heure de fin doit être strictement postérieure') ||
        clean.contains('L\'heure de fin doit être postérieure')) {
      return 'L\'heure de fin doit être postérieure à l\'heure de début.'.tr;
    }
    if (clean.contains('Fichier trop volumineux')) {
      return 'Fichier trop volumineux (max 15 Mo).'.tr;
    }
    if (clean.contains('Extension non autorisee') || clean.contains('Extension non autorisée')) {
      return 'Extension de fichier non autorisée.'.tr;
    }
    if (clean.contains('connection error') || clean.contains('SocketException')) {
      return 'Impossible de joindre le serveur clinique. Vérifiez votre accès réseau.'.tr;
    }
    if (clean.contains('timeout') || clean.contains('Délai d\'attente')) {
      return 'Délai d\'attente dépassé. Vérifiez votre connexion.'.tr;
    }

    // ── Dictionnaire direct via GetX .tr ──
    final translated = clean.tr;
    if (translated != clean) {
      return translated;
    }

    // Si pas de traduction directe exacte, vérifier les fragments connus
    if (clean.toLowerCase().contains('unauthorized') || clean.toLowerCase().contains('401')) {
      return 'Session expirée ou identifiants incorrects.'.tr;
    }
    if (clean.toLowerCase().contains('forbidden') || clean.toLowerCase().contains('403')) {
      return 'Accès refusé pour cette action.'.tr;
    }
    if (clean.toLowerCase().contains('not found') || clean.toLowerCase().contains('404')) {
      return 'Ressource introuvable.'.tr;
    }

    return clean;
  }
}
