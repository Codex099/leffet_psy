import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ThemeData premium pour PsyCare — Design iOS 17 Clinique Ultra-Modern.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
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
          tertiary: AppColors.accentCoral,
          onTertiary: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.scaffold,
        fontFamily: GoogleFonts.inter().fontFamily,

        // ─── Transitions de page iOS ──────────────────────────────────────────
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          },
        ),

        // ─── AppBar iOS Translucent ────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface.withValues(alpha: 0.94),
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.primary,
            size: 22,
          ),
          actionsIconTheme: const IconThemeData(
            color: AppColors.primary,
            size: 22,
          ),
        ),

        // ─── Cards Premium ─────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border, width: 0.6),
          ),
          margin: EdgeInsets.zero,
        ),

        // ─── Input Fields iOS ──────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.fieldBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border, width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border, width: 0.8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.8),
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.textHint,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          prefixIconColor: AppColors.secondary,
          suffixIconColor: AppColors.textTertiary,
        ),

        // ─── Bouton Primaire Gradient Pill ─────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),

        // ─── Outlined Button ───────────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),

        // ─── Text Button ───────────────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.iosBlue,
            textStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),

        // ─── Chip ──────────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.fieldBackground,
          selectedColor: AppColors.primary.withValues(alpha: 0.12),
          labelStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          side: const BorderSide(color: AppColors.border, width: 0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),

        // ─── Dividers ──────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.separator,
          thickness: 0.6,
          space: 1,
        ),

        // ─── Dialogs & BottomSheets ───────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          showDragHandle: true,
          dragHandleColor: AppColors.iosSystemGray4,
          dragHandleSize: const Size(36, 4),
        ),

        // ─── Floating Action Button ────────────────────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),

        // ─── ListTile ──────────────────────────────────────────────────────────
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Colors.transparent,
        ),

        // ─── Switch ────────────────────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return AppColors.iosSystemGray3;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.primary;
            return AppColors.iosSystemGray5;
          }),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),

        // ─── Progress Indicator ────────────────────────────────────────────────
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.fieldBackground,
          circularTrackColor: AppColors.fieldBackground,
        ),
      );
}
