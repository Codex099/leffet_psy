import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Hiérarchie typographique centralisée pour PsyCare.
/// Basée sur l'analyse des 18 maquettes fournies.
/// Police : Inter (Google Fonts) — moderne, lisible, style iOS natif.
class AppTextStyles {
  AppTextStyles._();

  // ─── Titres d'écran ──────────────────────────────────────────────────────────
  /// Grand titre d'écran — ex: "Dashbord", "Agenda", "Patients" (bold ~28px)
  static TextStyle get screenTitle => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  /// Titre d'écran moyen — ex: "Détail patient", "Ajout / Édition Patient" (bold ~22px)
  static TextStyle get screenTitleMedium => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  /// Sous-titre sous le titre d'écran — description contextuelle (regular ~13px, atténué)
  static TextStyle get screenSubtitle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  // ─── Titres de section ───────────────────────────────────────────────────────
  /// Titre de carte/section — ex: "Mes séances", "Plan thérapeutique" (semibold ~17px)
  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Titre de section coloré — en bleu primaire (semibold ~17px)
  static TextStyle get sectionTitleColored => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  /// Kicker de section (label uppercase small) — ex: "GESTION CLINIQUE", "COMPTE-RENDU"
  static TextStyle get sectionKicker => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      );

  // ─── Corps de texte ──────────────────────────────────────────────────────────
  /// Corps principal — texte courant (regular 14px)
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// Corps secondaire / sous-titre de carte (regular 13px, atténué)
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  /// Corps medium — texte de valeur importante (medium 14px)
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  // ─── Labels de formulaire ────────────────────────────────────────────────────
  /// Label au-dessus d'un champ (medium 13px, atténué)
  static TextStyle get fieldLabel => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  /// Texte de hint dans un champ (regular 14px, placeholder)
  static TextStyle get fieldHint => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
      );

  /// Valeur dans un champ (regular 14px)
  static TextStyle get fieldValue => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  // ─── Chiffres de dashboard ───────────────────────────────────────────────────
  /// Grand chiffre de dashboard — ex: "248", "12" (bold ~32px)
  static TextStyle get dashboardNumber => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  /// Label sous chiffre de dashboard (regular 12px, atténué)
  static TextStyle get dashboardLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  // ─── Boutons ─────────────────────────────────────────────────────────────────
  /// Texte de bouton principal (semibold 16px, blanc)
  static TextStyle get buttonPrimary => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        letterSpacing: 0.1,
      );

  /// Texte de bouton secondaire (semibold 14px, primaire)
  static TextStyle get buttonSecondary => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  /// Texte de bouton destructif (semibold 16px, rouge)
  static TextStyle get buttonDestructive => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.error,
      );

  // ─── Navigation ──────────────────────────────────────────────────────────────
  /// Label de bottom navigation bar (medium 11px)
  static TextStyle get navLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  // ─── Badges / Chips ──────────────────────────────────────────────────────────
  /// Texte de badge de statut (semibold 12px)
  static TextStyle get badge => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  // ─── Heure / Date ────────────────────────────────────────────────────────────
  /// Heure de séance (bold 16px)
  static TextStyle get timeLabel => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// Date de séance (medium 13px)
  static TextStyle get dateLabel => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // ─── Nom principal dans une carte ────────────────────────────────────────────
  /// Nom patient/employé dans une carte de liste (semibold 16px)
  static TextStyle get cardName => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Nom patient dans le header de fiche (bold 24px, blanc)
  static TextStyle get cardNameHero => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textOnPrimary,
      );

  // ─── États vides/erreur ──────────────────────────────────────────────────────
  /// Titre d'état vide/erreur (semibold 18px)
  static TextStyle get emptyStateTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Description d'état vide/erreur (regular 14px, atténué)
  static TextStyle get emptyStateBody => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );
}
