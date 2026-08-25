import 'package:flutter/material.dart';

/// Palette de couleurs centralisée pour PsyCare basée STRICTEMENT sur la charte officielle :
/// 1. #064973 (Bleu Pétrole / Océan profond)
/// 2. #75AABF (Bleu Acier / Céruléen doux)
/// 3. #ADCCD9 (Bleu Givré / Brume pastel)
/// 4. #D93636 (Rouge Corail éclatant)
/// 5. #A62929 (Bordeaux / Pourpre profond)
class AppColors {
  AppColors._();

  // ─── 5 Couleurs Officielles de la Charte ──────────────────────────────────
  /// #064973 (RGB 6, 73, 115) — Couleur Primaire Maîtresse : Navigation, Titres, Actions
  static const Color primary = Color(0xFF064973);

  /// #75AABF (RGB 117, 170, 191) — Couleur Secondaire : Accents, Icônes, Dégradés
  static const Color secondary = Color(0xFF75AABF);

  /// #ADCCD9 (RGB 173, 204, 217) — Couleur Claire / Givrée : Fonds de cartes, Puces, Séparateurs
  static const Color secondaryLight = Color(0xFFADCCD9);
  static const Color secondaryMuted = Color(0xFFADCCD9);

  /// #D93636 (RGB 217, 54, 54) — Rouge Corail Vif : Badges d'alerte, Accents dynamiques, Boutons urgents
  static const Color accentCoral = Color(0xFFD93636);
  static const Color logoCoral = Color(0xFFD93636);
  static const Color logoCoralLight = Color(0xFFFCEAEA);

  /// #A62929 (RGB 166, 41, 41) — Rouge Bordeaux Profond : Alertes critiques, États pressés, Contrastes
  static const Color accentDeep = Color(0xFFA62929);

  // ─── Déclinaisons Harmoniques & Ergonomie ──────────────────────────────────
  /// Variations primaires
  static const Color primaryLight = Color(0xFF0A5C8F);
  static const Color primaryDark = Color(0xFF032B45);

  /// Fond d'écran général apaisant teinté avec la brume pastel #ADCCD9
  static const Color scaffold = Color(0xFFF2F7F9);
  static const Color background = Color(0xFFF2F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color fieldBackground = Color(0xFFEBF2F6);
  static const Color frostedGlassColor = Color(0xDCFFFFFF);

  // ─── Typographie ──────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF062338);
  static const Color textSecondary = Color(0xFF4A6B7F);
  static const Color textTertiary = Color(0xFF7B98A9);
  static const Color textHint = Color(0xFF9EBDCE);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Bordures & Séparateurs ───────────────────────────────────────────────
  static const Color border = Color(0xFFD3E4EC);
  static const Color borderLight = Color(0xFFE3EDF3);
  static const Color borderFocus = Color(0xFF064973);
  static const Color hairlineDivider = Color(0xFFDBE7EE);
  static const Color separator = Color(0xFFD3E4EC);

  // ─── Statuts Cliniques ───────────────────────────────────────────────────
  static const Color statusPresent = Color(0xFF75AABF);
  static const Color statusPresentLight = Color(0xFFE6F1F5);
  static const Color statusPresentBg = Color(0xFFE6F1F5);

  static const Color statusAbsent = Color(0xFFD93636);
  static const Color statusAbsentLight = Color(0xFFFCEAEA);
  static const Color statusAbsentBg = Color(0xFFFCEAEA);

  static const Color statusPending = Color(0xFF064973);
  static const Color statusPendingLight = Color(0xFFE6EEF3);
  static const Color statusPendingBg = Color(0xFFE6EEF3);

  static const Color statusActive = Color(0xFF064973);
  static const Color statusActiveBg = Color(0xFFE0EDF3);

  static const Color statusInactive = Color(0xFF7B98A9);
  static const Color statusInactiveBg = Color(0xFFEAF1F5);

  // ─── Alertes & Destructif (Palette Rouge #D93636 / #A62929) ────────────────
  static const Color error = Color(0xFFD93636);
  static const Color errorDark = Color(0xFFA62929);
  static const Color errorLight = Color(0xFFFCEAEA);

  // ─── Couleurs Système iOS adaptées à la Charte ─────────────────────────────
  static const Color iosBackground = Color(0xFFF2F7F9);
  static const Color iosSecondaryBackground = Color(0xFFFFFFFF);
  static const Color iosTertiaryBackground = Color(0xFFE0EDF3);

  static const Color iosSystemGray = Color(0xFF7B98A9);
  static const Color iosSystemGray2 = Color(0xFF9EBDCE);
  static const Color iosSystemGray3 = Color(0xFFBED5E1);
  static const Color iosSystemGray4 = Color(0xFFD3E4EC);
  static const Color iosSystemGray5 = Color(0xFFE3EDF3);
  static const Color iosSystemGray6 = Color(0xFFF2F7F9);

  static const Color iosBlue = Color(0xFF064973);
  static const Color iosGreen = Color(0xFF5399A8);
  static const Color iosIndigo = Color(0xFF064973);
  static const Color iosOrange = Color(0xFFD93636);
  static const Color iosPink = Color(0xFFD93636);
  static const Color iosPurple = Color(0xFF064973);
  static const Color iosRed = Color(0xFFD93636);
  static const Color iosTeal = Color(0xFF75AABF);
  static const Color iosYellow = Color(0xFFD93636);

  // ─── Dégradés Artistiques de la Charte ────────────────────────────────────
  /// Dégradé Océan Clinique (#064973 -> #75AABF)
  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF064973),
      Color(0xFF75AABF),
    ],
  );

  /// Dégradé Hero avec les 3 bleus de la charte (#064973 -> #75AABF -> #ADCCD9)
  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF064973),
      Color(0xFF75AABF),
      Color(0xFFADCCD9),
    ],
  );

  /// Dégradé En-tête (#064973 -> #75AABF)
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF064973),
      Color(0xFF75AABF),
    ],
  );

  /// Dégradé Groupe (#75AABF -> #064973)
  static const LinearGradient groupHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF75AABF),
      Color(0xFF064973),
    ],
  );

  /// Dégradé Dynamique Corail (#D93636 -> #A62929)
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD93636),
      Color(0xFFA62929),
    ],
  );

  /// Dégradé Doux Givré (#F2F7F9 -> #E0EDF3)
  static const LinearGradient softIceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF2F7F9),
      Color(0xFFE0EDF3),
    ],
  );

  // ─── Ombres Cliniques Douces ──────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF064973).withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 5),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: const Color(0xFF75AABF).withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF064973).withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: const Color(0xFF064973).withValues(alpha: 0.18),
          blurRadius: 28,
          offset: const Offset(0, 10),
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get accentShadow => [
        BoxShadow(
          color: const Color(0xFFD93636).withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];
}
