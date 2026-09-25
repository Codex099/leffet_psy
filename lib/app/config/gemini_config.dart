import 'package:flutter_dotenv/flutter_dotenv.dart';

// Clé API Gemini - chargée automatiquement depuis .env ou --dart-define=GEMINI_API_KEY=<votre_cle>
// IMPORTANT : Ne jamais commiter la clé directement dans le code !
class GeminiConfig {
  GeminiConfig._();

  /// Clé chargée depuis .env (flutter_dotenv) ou --dart-define=GEMINI_API_KEY
  static String get apiKey {
    // 1. Priorité au fichier .env
    try {
      final envKey = dotenv.maybeGet('GEMINI_API_KEY');
      if (envKey != null && envKey.trim().isNotEmpty) {
        return envKey.trim();
      }
    } catch (_) {}

    // 2. Repli sur --dart-define ou --dart-define-from-file=.env
    const defineKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (defineKey.isNotEmpty) {
      return defineKey.trim();
    }

    return '';
  }

  /// Vérifie si une clé API est présente
  static bool get isConfigured => apiKey.isNotEmpty && apiKey != 'VOTRE_CLE_API_ICI';

  /// Modele actif, rapide et supportant nativement le Function Calling
  static const String model = 'gemini-3.6-flash';

  /// Prompt systeme pour PsyCare
  static const String systemPrompt =
      'Tu es un assistant IA specialise pour les professionnels de sante mentale de PsyCare. '
      'Tes roles : analyser les dossiers medicaux, suggerer des approches therapeutiques, '
      'aider a rediger des comptes-rendus cliniques structures. '
      'Regles : ton professionnel et bienveillant, jamais de diagnostic definitif, '
      'respecte la confidentialite, '
      'detecte automatiquement la langue du message de l utilisateur et reponds TOUJOURS dans la meme langue : '
      'si le message est en francais reponds en francais, si le message est en arabe reponds en arabe, '
      'structure tes analyses en : Observations / Points cles / Suggestions therapeutiques.';
}