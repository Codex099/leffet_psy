import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

/// Convertit les chiffres arabes/persans orientaux (٠-٩) en chiffres occidentaux (0-9)
/// et supprime les caractères de contrôle de direction Unicode (RLM \u200F, LRM \u200E, etc.).
String normalizeArabicDigitsAndSeparators(String input) {
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  var res = input;
  for (int i = 0; i < 10; i++) {
    res = res.replaceAll(eastern[i], i.toString());
    res = res.replaceAll(persian[i], i.toString());
  }
  // Nettoyage des marqueurs invisibles Unicode RTL/LTR
  res = res.replaceAll(RegExp(r'[\u200e\u200f\u202a-\u202e\u2066-\u2069]'), '');
  return res.trim();
}

/// Analyseur universel et tolérant de dates (supporte dd/MM/yyyy, yyyy/MM/dd, yyyy-MM-dd, dd-MM-yyyy).
DateTime? parseFlexibleDate(String? input) {
  if (input == null || input.trim().isEmpty) return null;
  final clean = normalizeArabicDigitsAndSeparators(input);
  final parts = clean.split(RegExp(r'[\/\-\.\s]')).where((s) => s.isNotEmpty).toList();
  if (parts.length != 3) return null;

  int? y, m, d;
  if (parts[0].length == 4) {
    // Format yyyy/MM/dd ou yyyy-MM-dd
    y = int.tryParse(parts[0]);
    m = int.tryParse(parts[1]);
    d = int.tryParse(parts[2]);
  } else if (parts[2].length == 4) {
    // Format dd/MM/yyyy ou MM/dd/yyyy
    final p0 = int.tryParse(parts[0]);
    final p1 = int.tryParse(parts[1]);
    y = int.tryParse(parts[2]);
    if (p0 == null || p1 == null || y == null) return null;

    if (p0 > 12 && p1 <= 12) {
      d = p0;
      m = p1;
    } else if (p1 > 12 && p0 <= 12) {
      m = p0;
      d = p1;
    } else {
      // Par défaut en contexte francophone/arabe : jour/mois/année (dd/MM/yyyy)
      d = p0;
      m = p1;
    }
  } else {
    return null;
  }

  if (y == null || m == null || d == null) return null;
  if (m < 1 || m > 12) return null;
  if (d < 1 || d > 31) return null;

  try {
    final dt = DateTime(y, m, d);
    if (dt.year == y && dt.month == m && dt.day == d) {
      return dt;
    }
  } catch (_) {}
  return null;
}

/// Délégué de calendrier personnalisé résolvant le bug Flutter de saisie clavier en langue arabe.
class FlexibleCalendarDelegate extends GregorianCalendarDelegate {
  const FlexibleCalendarDelegate();

  @override
  DateTime? parseCompactDate(String? inputString, MaterialLocalizations localizations) {
    final flexible = parseFlexibleDate(inputString);
    if (flexible != null) return flexible;
    return super.parseCompactDate(inputString, localizations);
  }

  @override
  String dateHelpText(MaterialLocalizations localizations) {
    return 'dd/mm/yyyy';
  }
}

/// Helper universel pour afficher un sélecteur de date (calendrier ou saisie clavier)
/// compatible avec toutes les langues (français, arabe, anglais).
class AppDatePicker {
  AppDatePicker._();

  static const CalendarDelegate<DateTime> calendarDelegate = FlexibleCalendarDelegate();

  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? fieldHintText,
    String? fieldLabelText,
  }) {
    final isArabic = (Get.locale?.languageCode == 'ar') ||
        (Localizations.maybeLocaleOf(context)?.languageCode == 'ar');
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialEntryMode: initialEntryMode,
      calendarDelegate: calendarDelegate,
      helpText: helpText ?? (isArabic ? 'اختيار التاريخ' : 'Sélectionner la date'.tr),
      cancelText: cancelText ?? (isArabic ? 'الإلغاء' : 'Annuler'.tr),
      confirmText: confirmText ?? (isArabic ? 'حسنًا' : 'Confirmer'.tr),
      fieldHintText: fieldHintText ?? 'dd/mm/yyyy',
      fieldLabelText: fieldLabelText ?? (isArabic ? 'التاريخ' : 'Date'.tr),
      errorFormatText: isArabic
          ? 'تنسيق غير صالح (يوم/شهر/سنة)'
          : 'Format de date invalide (jj/mm/aaaa)'.tr,
      errorInvalidText: isArabic
          ? 'التاريخ خارج النطاق المسموح'
          : 'Date hors limites'.tr,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
