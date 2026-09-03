import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leffet_psy/app/widgets/app_date_picker.dart';

void main() {
  group('AppDatePicker Parser & Digit Normalizer Tests', () {
    test('Normalizes Eastern Arabic & Persian digits and removes unicode markers', () {
      expect(normalizeArabicDigitsAndSeparators('١٢٣٤٥٦٧٨٩٠'), '1234567890');
      expect(normalizeArabicDigitsAndSeparators('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
      // With invisible Unicode RLM \u200F
      expect(normalizeArabicDigitsAndSeparators('١٢\u200F/\u200F٠٥\u200F/\u200F٢٠١٨'), '12/05/2018');
    });

    test('parseFlexibleDate parses various date formats cleanly', () {
      expect(parseFlexibleDate('12/05/2018'), DateTime(2018, 5, 12));
      expect(parseFlexibleDate('2018/05/12'), DateTime(2018, 5, 12));
      expect(parseFlexibleDate('2018-05-12'), DateTime(2018, 5, 12));
      expect(parseFlexibleDate('12-05-2018'), DateTime(2018, 5, 12));
      expect(parseFlexibleDate('12.05.2018'), DateTime(2018, 5, 12));
      expect(parseFlexibleDate('5/5/2018'), DateTime(2018, 5, 5));
      expect(parseFlexibleDate('01/01/2020'), DateTime(2020, 1, 1));
      expect(parseFlexibleDate('١٢/٠٥/٢٠١٨'), DateTime(2018, 5, 12));
      expect(parseFlexibleDate('٢٠١٨/٠٥/١٢'), DateTime(2018, 5, 12));
      expect(parseFlexibleDate('٢٠١٨-٠٥-١٢'), DateTime(2018, 5, 12));
    });

    test('parseFlexibleDate returns null for invalid inputs', () {
      expect(parseFlexibleDate(null), null);
      expect(parseFlexibleDate(''), null);
      expect(parseFlexibleDate('not a date'), null);
      expect(parseFlexibleDate('32/01/2020'), null);
      expect(parseFlexibleDate('15/15/2020'), null);
      expect(parseFlexibleDate('2020/02/30'), null);
    });
  });

  group('AppDatePicker Widget Tests (Arabic Locale Keyboard Entry)', () {
    testWidgets('AppDatePicker keyboard input accepts standard dd/MM/yyyy in Arabic', (tester) async {
      DateTime? selectedDate;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar', 'DZ'),
          supportedLocales: const [Locale('fr', 'FR'), Locale('ar', 'DZ')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    selectedDate = await AppDatePicker.show(
                      context: context,
                      initialDate: DateTime(2018, 1, 1),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      initialEntryMode: DatePickerEntryMode.input,
                    );
                  },
                  child: const Text('Open Picker'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Enter standard French/Algerian date format dd/MM/yyyy: 15/08/2015
      await tester.enterText(find.byType(TextField), '15/08/2015');
      await tester.pumpAndSettle();

      // Tap confirmation button "حسنًا"
      await tester.tap(find.text('حسنًا'));
      await tester.pumpAndSettle();

      expect(selectedDate, DateTime(2015, 8, 15));
    });

    testWidgets('AppDatePicker keyboard input accepts yyyy-MM-dd in Arabic', (tester) async {
      DateTime? selectedDate;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar', 'DZ'),
          supportedLocales: const [Locale('fr', 'FR'), Locale('ar', 'DZ')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    selectedDate = await AppDatePicker.show(
                      context: context,
                      initialDate: DateTime(2018, 1, 1),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      initialEntryMode: DatePickerEntryMode.input,
                    );
                  },
                  child: const Text('Open Picker'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '2016-04-20');
      await tester.pumpAndSettle();

      await tester.tap(find.text('حسنًا'));
      await tester.pumpAndSettle();

      expect(selectedDate, DateTime(2016, 4, 20));
    });

    testWidgets('AppDatePicker keyboard input accepts Arabic numerals in Arabic', (tester) async {
      DateTime? selectedDate;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar', 'DZ'),
          supportedLocales: const [Locale('fr', 'FR'), Locale('ar', 'DZ')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    selectedDate = await AppDatePicker.show(
                      context: context,
                      initialDate: DateTime(2018, 1, 1),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      initialEntryMode: DatePickerEntryMode.input,
                    );
                  },
                  child: const Text('Open Picker'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '١٠/٠٣/٢٠١٧');
      await tester.pumpAndSettle();

      await tester.tap(find.text('حسنًا'));
      await tester.pumpAndSettle();

      expect(selectedDate, DateTime(2017, 3, 10));
    });
  });
}
