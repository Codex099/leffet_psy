import 'package:flutter/material.dart';

/// Palette de couleurs centralisée pour PsyCare — Design Premium iOS Clinique.
/// Charte officielle : #064973 · #75AABF · #ADCCD9 · #D93636 · #A62929
class AppColors {
  AppColors._();

  // ─── 5 Couleurs Officielles de la Charte ──────────────────────────────────
  static const Color primary = Color(0xFF064973);
  static const Color secondary = Color(0xFF75AABF);
  static const Color secondaryLight = Color(0xFFADCCD9);
  static const Color secondaryMuted = Color(0xFFADCCD9);
  static const Color accentCoral = Color(0xFFD93636);
  static const Color logoCoral = Color(0xFFD93636);
  static const Color logoCoralLight = Color(0xFFFCEAEA);
  static const Color accentDeep = Color(0xFFA62929);

  // ─── Déclinaisons Primaires ────────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF0A5C8F);
  static const Color primaryDark = Color(0xFF032B45);
  static const Color primaryXLight = Color(0xFF1A7CB0);

  // ─── Surfaces & Fonds ──────────────────────────────────────────────────────
  static const Color scaffold = Color(0xFFF0F5F9);
  static const Color background = Color(0xFFF0F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color fieldBackground = Color(0xFFEBF2F6);
  static const Color frostedGlassColor = Color(0xDCFFFFFF);
  static const Color surfaceCard = Color(0xFFFAFCFE);

  /// Surface variante légèrement teintée
  static const Color surfaceVariant = Color(0xFFE8F2F8);

  /// Ultra-light primaire — fond des chips actives, tags sélectionnés
  static const Color primaryUltraLight = Color(0xFFEBF4FA);

  // ─── Shimmer Premium ──────────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE8EFF4);
  static const Color shimmerHighlight = Color(0xFFF5F9FC);

  // ─── Glassmorphism ─────────────────────────────────────────────────────────
  static const Color glassWhite = Color(0xEEFFFFFF);
  static const Color glassWhiteMedium = Color(0xCCFFFFFF);
  static const Color glassWhiteLight = Color(0x99FFFFFF);
  static const Color glassPrimary = Color(0x1A064973);
  static const Color glassBorder = Color(0x40FFFFFF);
  static const Color glassBorderStrong = Color(0x80FFFFFF);

  // ─── Typographie ──────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF062338);
  static const Color textSecondary = Color(0xFF4A6B7F);
  static const Color textTertiary = Color(0xFF7B98A9);
  static const Color textHint = Color(0xFF9EBDCE);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

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

  // ─── Alertes & Destructif ────────────────────────────────────────────────
  static const Color error = Color(0xFFD93636);
  static const Color errorDark = Color(0xFFA62929);
  static const Color errorLight = Color(0xFFFCEAEA);
  static const Color success = Color(0xFF2E7D6B);
  static const Color successLight = Color(0xFFE3F4F0);
  static const Color warning = Color(0xFFB8860B);
  static const Color warningLight = Color(0xFFFFF8E1);

  // ─── iOS System Colors adaptées ──────────────────────────────────────────
  static const Color iosBackground = Color(0xFFF0F5F9);
  static const Color iosSecondaryBackground = Color(0xFFFFFFFF);
  static const Color iosTertiaryBackground = Color(0xFFE0EDF3);
  static const Color iosSystemGray = Color(0xFF7B98A9);
  static const Color iosSystemGray2 = Color(0xFF9EBDCE);
  static const Color iosSystemGray3 = Color(0xFFBED5E1);
  static const Color iosSystemGray4 = Color(0xFFD3E4EC);
  static const Color iosSystemGray5 = Color(0xFFE3EDF3);
  static const Color iosSystemGray6 = Color(0xFFF0F5F9);
  static const Color iosBlue = Color(0xFF064973);
  static const Color iosGreen = Color(0xFF2E7D6B);
  static const Color iosIndigo = Color(0xFF064973);
  static const Color iosOrange = Color(0xFFD93636);
  static const Color iosPink = Color(0xFFD93636);
  static const Color iosPurple = Color(0xFF064973);
  static const Color iosRed = Color(0xFFD93636);
  static const Color iosTeal = Color(0xFF75AABF);
  static const Color iosYellow = Color(0xFFB8860B);

  // ─── Dégradés Premium ────────────────────────────────────────────────────
  /// Gradient principal clinique (#064973 → #0A5C8F → #75AABF)
  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF064973), Color(0xFF0A5C8F), Color(0xFF75AABF)],
    stops: [0.0, 0.5, 1.0],
  );

  /// Gradient hero 3 bleus
  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF064973), Color(0xFF75AABF), Color(0xFFADCCD9)],
  );

  /// Gradient en-tête riche
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF032B45), Color(0xFF064973), Color(0xFF1A7CB0)],
    stops: [0.0, 0.5, 1.0],
  );

  /// Gradient groupe
  static const LinearGradient groupHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF75AABF), Color(0xFF064973)],
  );

  /// Gradient corail dynamique
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD93636), Color(0xFFA62929)],
  );

  /// Gradient fond doux givré
  static const LinearGradient softIceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0F5F9), Color(0xFFE3EDF3)],
  );

  /// Gradient vertical sombre pour overlays
  static const LinearGradient darkOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00032B45), Color(0xCC032B45)],
  );

  /// Aurora gradient animé pour login
  static const LinearGradient auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF032B45),
      Color(0xFF064973),
      Color(0xFF0A5C8F),
      Color(0xFF75AABF),
      Color(0xFFADCCD9),
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  /// Gradient succès vert
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D6B), Color(0xFF48A999)],
  );

  // ─── Gradients Vibrants & Vivants (UI/UX Pro Max) ───────────────────────────
  /// Émeraude / Menthe fraîche (Nouveau Patient, Santé, Croissance)
  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
  );

  /// Violet / Indigo lumineux (Planification, Agenda, Sérénité)
  static const LinearGradient violetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF9333EA)],
  );

  /// Corail Rose éclatant (Tâches, Priorités, Urgences)
  static const LinearGradient coralGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE11D48), Color(0xFFF43F5E), Color(0xFFFB7185)],
  );

  /// Ambre / Or chaleureux (Groupes, Communauté, Ateliers)
  static const LinearGradient amberGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFFBBF24)],
  );

  /// Bleu Azur Électrique (Bilans, Dossiers, Métriques)
  static const LinearGradient azureGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0284C7), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
  );

  /// Indigo / Lilas Céleste (Comptes-Rendus, Bilans Thérapeutiques)
  static const LinearGradient indigoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  /// Fuchsia / Magenta Vif (Équipe, Administration, Paramètres)
  static const LinearGradient fuchsiaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9333EA), Color(0xFFC026D3), Color(0xFFE11D48)],
  );

  // ─── Ombres Premium ───────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF064973).withValues(alpha: 0.07),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF75AABF).withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF064973).withValues(alpha: 0.06),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get heroShadow => [
    BoxShadow(
      color: const Color(0xFF064973).withValues(alpha: 0.22),
      blurRadius: 36,
      offset: const Offset(0, 12),
      spreadRadius: 2,
    ),
    BoxShadow(
      color: const Color(0xFF064973).withValues(alpha: 0.10),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get accentShadow => [
    BoxShadow(
      color: const Color(0xFFD93636).withValues(alpha: 0.28),
      blurRadius: 22,
      offset: const Offset(0, 7),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: const Color(0xFF064973).withValues(alpha: 0.30),
      blurRadius: 40,
      offset: const Offset(0, 16),
      spreadRadius: 4,
    ),
    BoxShadow(
      color: const Color(0xFF75AABF).withValues(alpha: 0.20),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: const Color(0xFF064973).withValues(alpha: 0.16),
      blurRadius: 30,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: const Color(0xFF064973).withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.80),
      blurRadius: 1,
      offset: const Offset(0, -1),
    ),
  ];
}
