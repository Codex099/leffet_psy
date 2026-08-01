import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ThemeData complet pour PsyCare.
/// Applique le design system (couleurs, typographie, rayons) globalement.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: AppColors.textOnPrimary,
          onSecondary: AppColors.textOnPrimary,
          onSurface: AppColors.textPrimary,
          onError: AppColors.textOnPrimary,
          surfaceContainerHighest: AppColors.fieldBackground,
        ),
        scaffoldBackgroundColor: AppColors.scaffold,
        fontFamily: GoogleFonts.inter().fontFamily,

        // ─── AppBar ────────────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.scaffold,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),

        // ─── Cards ─────────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),

        // ─── Input Fields ──────────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.fieldBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textHint,
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),

        // ─── Elevated Button ───────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        // ─── Outlined Button ───────────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ─── Text Button ───────────────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ─── Chip ──────────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.secondaryLight,
          selectedColor: AppColors.primary,
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // ─── ListTile ──────────────────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),

        // ─── Divider ───────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 0,
        ),

        // ─── BottomNavigationBar ───────────────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),

        // ─── FloatingActionButton ──────────────────────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),

        // ─── Switch ────────────────────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.textOnPrimary;
            }
            return AppColors.textSecondary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.border;
          }),
        ),

        // ─── Progress Indicator ────────────────────────────────────────────────
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.secondaryLight,
        ),

        // ─── SnackBar ──────────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: GoogleFonts.inter(
            color: AppColors.textOnPrimary,
            fontSize: 14,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),

        // ─── Bottom Sheet ──────────────────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),

        // ─── Dialog ────────────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      );
}
