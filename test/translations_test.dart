import 'package:flutter_test/flutter_test.dart';
import 'package:leffet_psy/app/translations/app_translations.dart';

void main() {
  test('AppTranslations contains French and Arabic dictionaries', () {
    final trans = AppTranslations();
    final keys = trans.keys;

    expect(keys.containsKey('ar_DZ'), isTrue);
    expect(keys.containsKey('ar'), isTrue);
    expect(keys.containsKey('fr_FR'), isTrue);
    expect(keys.containsKey('fr'), isTrue);

    // Verify Arabic translation
    expect(keys['ar_DZ']!['Accueil'], equals('الرئيسية'));
    expect(keys['ar']!['Accueil'], equals('الرئيسية'));

    // Verify French translation returns original French string
    expect(keys['fr_FR']!['Accueil'], equals('Accueil'));
    expect(keys['fr']!['Accueil'], equals('Accueil'));
    expect(keys['fr_FR']!['Patients'], equals('Patients'));
  });
}
