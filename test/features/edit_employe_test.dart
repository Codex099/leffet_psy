import 'package:flutter_test/flutter_test.dart';
import 'package:leffet_psy/app/models/employee_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Employee Management & Serialization Tests', () {
    test('EmployeeModel fromJson correctly parses patients_assignes_ids and telephone', () {
      final json = {
        'id': 'emp-uuid-1',
        'nom': 'Benali',
        'prenom': 'Sara',
        'telephone': '0555998877',
        'username': 'sara.benali',
        'role': 'psychologue',
        'patients_assignes_ids': ['pat-1', 'pat-2', 'pat-3'],
      };

      final emp = EmployeeModel.fromJson(json);

      expect(emp.id, 'emp-uuid-1');
      expect(emp.nom, 'Benali');
      expect(emp.prenom, 'Sara');
      expect(emp.telephone, '0555998877');
      expect(emp.username, 'sara.benali');
      expect(emp.role, 'psychologue');
      expect(emp.patientsAssignesIds, ['pat-1', 'pat-2', 'pat-3']);
      expect(emp.fullName, 'Sara Benali');
      expect(emp.initials, 'SB');
    });

    test('Telephone sanitizer correctly strips formatting spaces, dots and hyphens', () {
      const raw1 = '05 55 99 88 77';
      const raw2 = '06-12-34-56-78';
      const raw3 = '07.99.11.22.33';

      final clean1 = raw1.replaceAll(RegExp(r'[\s\.\-]'), '').trim();
      final clean2 = raw2.replaceAll(RegExp(r'[\s\.\-]'), '').trim();
      final clean3 = raw3.replaceAll(RegExp(r'[\s\.\-]'), '').trim();

      expect(clean1, '0555998877');
      expect(clean2, '0612345678');
      expect(clean3, '0799112233');
    });

    test('EmployeeModel toJson serializes accurately', () {
      final emp = EmployeeModel(
        id: 'emp-1',
        nom: 'Dupont',
        prenom: 'Jean',
        telephone: '0612345678',
        username: 'j.dupont',
        role: 'educatrice',
        patientsAssignesIds: ['p1'],
      );

      final map = emp.toJson();
      expect(map['nom'], 'Dupont');
      expect(map['prenom'], 'Jean');
      expect(map['telephone'], '0612345678');
      expect(map['username'], 'j.dupont');
      expect(map['role'], 'educatrice');
    });
  });
}
