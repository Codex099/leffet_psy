// Cle API Gemini - chargee via --dart-define=GEMINI_API_KEY=<votre_cle>
// IMPORTANT : Ne jamais commiter la cle directement dans le code !
// Pour lancer : flutter run --dart-define=GEMINI_API_KEY=votre_cle_ici
class GeminiConfig {
  GeminiConfig._();

  /// Cle chargee depuis la variable de compilation --dart-define=GEMINI_API_KEY
  /// Ne jamais ecrire la cle en dur ici !
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Modele actif, rapide et disponible sans saturation 503
  static const String model = 'gemini-3.1-flash-lite';

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