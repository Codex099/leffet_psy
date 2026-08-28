import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Hiérarchie typographique centralisée pour PsyCare (Apple Human Interface Guidelines).
/// Police : Inter avec calibrage SF Pro (tracking précis, haute lisibilité et hiérarchie naturelle).
class AppTextStyles {
  AppTextStyles._();

  // ─── Échelle Typographique iOS (Apple HIG) ──────────────────────────────────
  /// Large Title (32px bold, letter-spacing -0.6)
  static TextStyle get iosLargeTitle => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.2,
  );

  /// Title 1 (26px bold, letter-spacing -0.4)
  static TextStyle get iosTitle1 => GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.25,
  );

  /// Title 2 (20px semi-bold, letter-spacing -0.3)
  static TextStyle get iosTitle2 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  /// Title 3 (18px semi-bold, letter-spacing -0.2)
  static TextStyle get iosTitle3 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  /// Headline (16px semi-bold, letter-spacing -0.2)
  static TextStyle get iosHeadline => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  /// Body (15px regular, line-height 1.45)
  static TextStyle get iosBody => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// Callout (15px medium)
  static TextStyle get iosCallout => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Subhead (14px regular / medium)
  static TextStyle get iosSubhead => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Footnote (13px regular / medium)
  static TextStyle get iosFootnote => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Caption 1 (12px regular)
  static TextStyle get iosCaption1 => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Caption 2 (11px medium uppercase)
  static TextStyle get iosCaption2 => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  /// Display Hero (40px ultra-bold)
  static TextStyle get displayHero => GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.2,
    height: 1.0,
  );

  /// Large Title Hero (36px ultra-bold)
  static TextStyle get iosLargeTitleHero => GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.1,
  );

  /// Label Overline (10px bold tracké)
  static TextStyle get labelOverline => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textTertiary,
    letterSpacing: 1.5,
    height: 1.2,
  );

  // ─── Compatibilité avec les composants existants ───────────────────────────
  static TextStyle get screenTitle => iosLargeTitle;
  static TextStyle get screenTitleMedium => iosTitle2;
  static TextStyle get screenSubtitle => iosSubhead;

  static TextStyle get sectionTitle => iosHeadline;
  static TextStyle get sectionTitleColored => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  static TextStyle get sectionKicker => iosCaption2;

  static TextStyle get body => iosBody;
  static TextStyle get bodySmall => iosFootnote;
  static TextStyle get bodyMedium => iosCallout;

  static TextStyle get fieldLabel => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get fieldHint => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  static TextStyle get fieldValue => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get cardName => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle get cardNameHero => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -0.3,
  );

  static TextStyle get cardAge => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get cardParentLabel => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  static TextStyle get cardParentValue => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get chipText => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get chipTextActive => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get buttonPrimary => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle get buttonSecondary => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: -0.2,
  );

  static TextStyle get emptyStateTitle => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle get emptyStateBody => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle get emptyStateMessage => emptyStateBody;

  static TextStyle get dashboardNumber => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get dashboardLabel => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get timeLabel => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get buttonDestructive => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
  );

  static TextStyle get badge => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static TextStyle get navLabel =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500);
}
