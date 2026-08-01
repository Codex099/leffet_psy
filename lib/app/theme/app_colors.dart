import 'package:flutter/material.dart';

/// Palette de couleurs centralisée pour PsyCare.
/// Extraite de palette_couleur.jpeg et validée sur les 18 maquettes fournies.
/// AUCUNE couleur ne doit être définie en dehors de ce fichier.
class AppColors {
  AppColors._();

  // ─── Primaire ───────────────────────────────────────────────────────────────
  /// Bleu marine profond — headers, bottom nav actif, boutons principaux, titres
  static const Color primary = Color(0xFF064973);

  /// Bleu marine légèrement plus clair — états hover/pressed du primaire
  static const Color primaryLight = Color(0xFF0A5A8A);

  /// Bleu marine très sombre — état pressed appuyé
  static const Color primaryDark = Color(0xFF043355);

  // ─── Secondaire ─────────────────────────────────────────────────────────────
  /// Bleu moyen — icônes secondaires, accents décoratifs, dégradés
  static const Color secondary = Color(0xFF76AABF);

  /// Bleu très pâle — fonds de cartes, chips de statut neutres, arrière-plans de section
  static const Color secondaryLight = Color(0xFFACCCD9);

  /// Bleu très très pâle — fond d'écran général (légèrement teinté)
  static const Color background = Color(0xFFF0F6F9);

  // ─── Alertes / Destructif ───────────────────────────────────────────────────
  /// Corail/rouge — boutons destructifs, statut "inactif", badges d'alerte
  static const Color error = Color(0xFFD93735);

  /// Rouge foncé — variante pressed/hover du rouge
  static const Color errorDark = Color(0xFFA52929);

  /// Rouge très pâle — fond de badge d'alerte
  static const Color errorLight = Color(0xFFFFF0F0);

  // ─── Surfaces ───────────────────────────────────────────────────────────────
  /// Fond de carte principale
  static const Color surface = Color(0xFFFFFFFF);

  /// Fond général de l'écran
  static const Color scaffold = Color(0xFFF7F7F7);

  /// Fond de champ de formulaire
  static const Color fieldBackground = Color(0xFFF2F5F8);

  // ─── Texte ──────────────────────────────────────────────────────────────────
  /// Texte principal (quasi-noir, jamais de noir pur #000)
  static const Color textPrimary = Color(0xFF2C2C2C);

  /// Texte secondaire / labels atténués
  static const Color textSecondary = Color(0xFF6B7B8D);

  /// Texte désactivé / placeholder
  static const Color textHint = Color(0xFFB0BFCA);

  /// Texte sur fond primaire (blanc)
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Bordures ───────────────────────────────────────────────────────────────
  /// Bordure légère des cartes et champs
  static const Color border = Color(0xFFE0EAEF);

  /// Bordure des champs de formulaire au focus
  static const Color borderFocus = Color(0xFF064973);

  // ─── Statuts de présence ────────────────────────────────────────────────────
  /// Statut "Assisté" / "Présent" — vert doux
  static const Color statusPresent = Color(0xFF2D8A5F);
  static const Color statusPresentBg = Color(0xFFE8F7F0);

  /// Statut "Absent"
  static const Color statusAbsent = Color(0xFFD93735);
  static const Color statusAbsentBg = Color(0xFFFFF0F0);

  /// Statut "En attente"
  static const Color statusPending = Color(0xFF76AABF);
  static const Color statusPendingBg = Color(0xFFEAF4F8);

  /// Statut "Actif"
  static const Color statusActive = Color(0xFF064973);
  static const Color statusActiveBg = Color(0xFFE0EEF6);

  /// Statut "Inactif"
  static const Color statusInactive = Color(0xFFD93735);
  static const Color statusInactiveBg = Color(0xFFFFF0F0);

  // ─── Priorités de tâche ─────────────────────────────────────────────────────
  /// Haute priorité
  static const Color priorityHigh = Color(0xFFD93735);

  /// Priorité normale
  static const Color priorityMedium = Color(0xFFF09C2A);

  /// Basse priorité
  static const Color priorityLow = Color(0xFF2D8A5F);

  // ─── Statuts de plan thérapeutique ──────────────────────────────────────────
  static const Color stepDone = Color(0xFF2D8A5F);
  static const Color stepDoneBg = Color(0xFFE8F7F0);
  static const Color stepInProgress = Color(0xFF064973);
  static const Color stepInProgressBg = Color(0xFFE0EEF6);
  static const Color stepTodo = Color(0xFFD93735);
  static const Color stepTodoBg = Color(0xFFFFF0F0);

  // ─── Ombre ──────────────────────────────────────────────────────────────────
  /// Ombre douce et diffuse pour les cartes (style iOS)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF064973).withValues(alpha: 0.07),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  // ─── Dégradés ───────────────────────────────────────────────────────────────
  /// Dégradé de header bleu marine (visible sur patient_info.png)
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF064973), Color(0xFF0A6E9A)],
  );

  /// Dégradé de section groupe (visible sur groupe_detail.png)
  static const LinearGradient groupHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF076B9E), Color(0xFF064973)],
  );
}
