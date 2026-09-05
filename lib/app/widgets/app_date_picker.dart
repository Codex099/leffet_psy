import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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

/// Helper universel pour afficher un sélecteur de date (rouleaux Cupertino ou calendrier Material)
/// 100% compatible avec la langue arabe et française sans bugs de format ni de direction RTL.
class AppDatePicker {
  AppDatePicker._();

  static const CalendarDelegate<DateTime> calendarDelegate = FlexibleCalendarDelegate();

  /// Sélecteur de date moderne par rouleaux (Cupertino Wheel Picker) en BottomSheet.
  /// Idéal pour la saisie rapide et sans erreur des dates de naissance et consultations :
  /// - 0 saisie clavier obligatoire, aucun bug de slash inversé en RTL
  /// - 3 rouleaux fluides : [Jour] [Mois en arabe ou français] [Année]
  /// - Badge d'aperçu dynamique de la date en direct
  static Future<DateTime?> showWheelPicker({
    required BuildContext context,
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? title,
    String? cancelText,
    String? confirmText,
  }) async {
    final isArabic = (Get.locale?.languageCode == 'ar') ||
        (Localizations.maybeLocaleOf(context)?.languageCode == 'ar');

    DateTime tempDate = initialDate ?? DateTime.now();
    if (tempDate.isAfter(lastDate)) tempDate = lastDate;
    if (tempDate.isBefore(firstDate)) tempDate = firstDate;
    // Normaliser l'heure pour éviter les faux dépassements
    tempDate = DateTime(tempDate.year, tempDate.month, tempDate.day);
    final minDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    final maxDate = DateTime(lastDate.year, lastDate.month, lastDate.day, 23, 59, 59);

    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        DateTime selected = tempDate;
        return StatefulBuilder(
          builder: (bottomSheetContext, setState) {
            final moisAr = [
              'جانفي', 'فيفري', 'مارس', 'أفريل', 'ماي', 'جوان',
              'جويلية', 'أوت', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
            ];
            final moisFr = [
              'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
              'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
            ];
            final dateLabel = isArabic
                ? '${selected.day} ${moisAr[selected.month - 1]} ${selected.year}'
                : '${selected.day} ${moisFr[selected.month - 1]} ${selected.year}';

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: AppColors.heroShadow,
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle de glissement
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Barre d'actions supérieure
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(null),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            cancelText ?? (isArabic ? 'إلغاء' : 'Annuler'.tr),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          title ?? (isArabic ? 'اختيار التاريخ' : 'Sélectionner la date'.tr),
                          style: AppTextStyles.iosHeadline.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(selected),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text(
                            confirmText ?? (isArabic ? 'تأكيد' : 'Confirmer'.tr),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Badge d'aperçu de la date sélectionnée
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateLabel,
                            style: AppTextStyles.iosSubhead.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Rouleaux Cupertino (Jour, Mois, Année)
                    SizedBox(
                      height: 200,
                      child: CupertinoTheme(
                        data: CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: AppTextStyles.iosTitle3.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: selected,
                          minimumDate: minDate,
                          maximumDate: maxDate,
                          dateOrder: DatePickerDateOrder.dmy,
                          onDateTimeChanged: (DateTime newDate) {
                            setState(() {
                              selected = newDate;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Sélecteur de date principal (dialogue Material ou calendrier).
  /// Résout les problèmes de directionnalité RTL et de saisie clavier en arabe.
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
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
      initialDatePickerMode: initialDatePickerMode,
      calendarDelegate: calendarDelegate,
      helpText: helpText ?? (isArabic ? 'اختيار التاريخ' : 'Sélectionner la date'.tr),
      cancelText: cancelText ?? (isArabic ? 'الإلغاء' : 'Annuler'.tr),
      confirmText: confirmText ?? (isArabic ? 'حسنًا' : 'Confirmer'.tr),
      fieldHintText: fieldHintText ?? (isArabic ? 'يوم/شهر/سنة' : 'dd/mm/yyyy'),
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
          child: Directionality(
            textDirection: isArabic ? TextDirection.ltr : Directionality.of(context),
            child: child!,
          ),
        );
      },
    );
  }
}
