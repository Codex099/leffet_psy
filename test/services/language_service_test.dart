import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:leffet_psy/app/services/language_service.dart';
import 'package:leffet_psy/app/translations/app_translations.dart';

void main() {
  setUp(() {
    Get.clearTranslations();
    Get.addTranslations(AppTranslations().keys);
  });

  group('LanguageService & Translations Tests', () {
    test('LanguageService initial state is valid', () {
      expect(LanguageService.currentLocale.value, isNotNull);
    });

    test('All required Arabic translations exist and are not French', () {
      Get.updateLocale(const Locale('ar', 'DZ'));

      // 1. Présences
      expect('Présent'.tr, 'حاضر');
      expect('Absent'.tr, 'غائب');
      expect('Excusé'.tr, 'معذور');
      expect('Statut de Présence'.tr, 'حالة الحضور');

      // 2. Agenda
      expect('Non assigné'.tr, 'غير معيّن'); // Was previously French "غير asigné"
      expect('Assigné à'.tr, 'معيّن لـ');
      expect('Vue Journée'.tr, 'عرض اليوم');
      expect('Semaine Complète'.tr, 'أسبوع كامل');

      // 3. Programmer séance
      expect('Individuelle'.tr, 'فردية');
      expect('Collectif (Groupe)'.tr, 'جماعية (مجموعة)');
      expect('Désélectionner'.tr, 'إلغاء التحديد');

      // 4. Tâches
      expect('Terminée'.tr, 'منتهية');
      expect('Basse'.tr, 'منخفضة');
      expect('À faire'.tr, 'للقيام');
      expect('En cours'.tr, 'قيد التقدم');

      // 5. Comptes-rendus Hub
      expect('En attente'.tr, 'قيد الانتظار');
      expect('Rédigés'.tr, 'محررة');
      expect('Validé'.tr, 'معتمد');
      expect('À rédiger'.tr, 'للتحرير');
      expect('Atelier Collectif'.tr, 'ورشة جماعية');

      // 6. Séances Individuelles
      expect('À venir'.tr, 'القادمة');
      expect('Historique'.tr, 'السجل');
      expect('Prochain RDV'.tr, 'الموعد القادم');
    });
  });
}
