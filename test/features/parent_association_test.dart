import 'package:flutter_test/flutter_test.dart';
import 'package:leffet_psy/app/controllers/edit_patient_controller.dart';
import 'package:leffet_psy/app/models/parent_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Parent Association & Multi-Parent Logic Tests', () {
    test('PatientParentSelection correctly stores parent, role and ID', () {
      final parent1 = ParentModel(
        id: 'parent-father-1',
        nom: 'Benali',
        prenom: 'Karim',
        telephone: '0550112233',
        etatCivil: 'marie',
      );

      final selection = PatientParentSelection(
        parentId: parent1.id,
        role: 'pere',
        parent: parent1,
      );

      expect(selection.parentId, 'parent-father-1');
      expect(selection.role, 'pere');
      expect(selection.parent.fullName, 'Karim Benali');
      expect(selection.parent.telephone, '0550112233');
    });

    test('EditPatientController supports multiple parents (Père ET Mère)', () {
      final controller = EditPatientController();

      final father = ParentModel(
        id: 'parent-101',
        nom: 'Mansouri',
        prenom: 'Rachid',
        telephone: '0661123456',
        etatCivil: 'marie',
      );

      final mother = ParentModel(
        id: 'parent-102',
        nom: 'Mansouri',
        prenom: 'Samira',
        telephone: '0661987654',
        etatCivil: 'marie',
      );

      controller.availableParents.addAll([father, mother]);

      // 1. Add father
      controller.addSelectedParent(father, 'pere');
      expect(controller.selectedParents.length, 1);
      expect(controller.selectedParents.first.role, 'pere');
      expect(controller.selectedParents.first.parent.fullName, 'Rachid Mansouri');

      // 2. Add mother
      controller.addSelectedParent(mother, 'mere');
      expect(controller.selectedParents.length, 2);
      expect(controller.selectedParents[1].role, 'mere');
      expect(controller.selectedParents[1].parent.fullName, 'Samira Mansouri');

      // 3. Update father role to tuteur
      controller.addSelectedParent(father, 'tuteur');
      expect(controller.selectedParents.length, 2); // Still 2, not duplicated
      expect(controller.selectedParents.first.role, 'tuteur');

      // 4. Remove mother
      controller.removeSelectedParent(mother.id);
      expect(controller.selectedParents.length, 1);
      expect(controller.selectedParents.first.parentId, father.id);
    });

    test('EditPatientController reuses existing parent by phone without duplicating', () async {
      final controller = EditPatientController();

      final existingFather = ParentModel(
        id: 'parent-existing-99',
        nom: 'Dahmani',
        prenom: 'Omar',
        telephone: '0770554433',
        etatCivil: 'marie',
      );

      controller.availableParents.add(existingFather);

      // Attempt inline creation with the SAME phone number
      final res = await controller.createParentInline({
        'nom': 'Dahmani',
        'prenom': 'Omar',
        'telephone': '0770554433',
        'role': 'pere',
      });

      expect(res, isNotNull);
      expect(res!.id, 'parent-existing-99');
      expect(controller.selectedParents.length, 1);
      expect(controller.selectedParents.first.parentId, 'parent-existing-99');
      expect(controller.selectedParents.first.role, 'pere');
    });
  });
}
