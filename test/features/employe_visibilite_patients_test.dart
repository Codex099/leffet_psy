import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:leffet_psy/app/controllers/employe_visibilite_patients_controller.dart';
import 'package:leffet_psy/app/models/employee_model.dart';
import 'package:leffet_psy/app/models/patient_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmployeVisibilitePatientsController Unit Tests', () {
    late EmployeVisibilitePatientsController controller;

    setUp(() {
      Get.reset();
      controller = EmployeVisibilitePatientsController();

      controller.employee.value = EmployeeModel(
        id: 'emp-101',
        nom: 'Benali',
        prenom: 'Sara',
        role: 'psychologue',
        telephone: '0555123456',
        username: 'sara',
      );

      final p1 = PatientModel(id: 'p1', nom: 'Amrani', prenom: 'Yacine');
      final p2 = PatientModel(id: 'p2', nom: 'Brahimi', prenom: 'Lina');
      final p3 = PatientModel(id: 'p3', nom: 'Cherif', prenom: 'Adel');
      final p4 = PatientModel(id: 'p4', nom: 'Daoudi', prenom: 'Maya');

      controller.allPatients.assignAll([p1, p2, p3, p4]);
      controller.visiblePatientIds.assignAll({'p1', 'p3'});
      controller.isAdmin.value = true;
    });

    test('Computed counts calculate accurately', () {
      expect(controller.totalCount, 4);
      expect(controller.visibleCount, 2);
      expect(controller.invisibleCount, 2);
    });

    test('Filtering by visible and invisible returns correct subsets', () {
      controller.activeFilter.value = 'all';
      expect(controller.displayedPatients.length, 4);

      controller.activeFilter.value = 'visible';
      final visibleList = controller.displayedPatients;
      expect(visibleList.length, 2);
      expect(visibleList.map((p) => p.id), containsAll(['p1', 'p3']));

      controller.activeFilter.value = 'invisible';
      final invisibleList = controller.displayedPatients;
      expect(invisibleList.length, 2);
      expect(invisibleList.map((p) => p.id), containsAll(['p2', 'p4']));
    });

    test('Search query filters by patient full name', () {
      controller.activeFilter.value = 'all';
      controller.searchQuery.value = 'lina';
      expect(controller.displayedPatients.length, 1);
      expect(controller.displayedPatients.first.nom, 'Brahimi');

      controller.searchQuery.value = 'amr'; // matches Amrani
      expect(controller.displayedPatients.length, 1);
      expect(controller.displayedPatients.first.nom, 'Amrani');
    });

    test('togglePatient correctly toggles visibility when user is admin', () {
      expect(controller.visiblePatientIds.contains('p2'), isFalse);
      controller.togglePatient('p2');
      expect(controller.visiblePatientIds.contains('p2'), isTrue);
      expect(controller.visibleCount, 3);

      controller.togglePatient('p2');
      expect(controller.visiblePatientIds.contains('p2'), isFalse);
      expect(controller.visibleCount, 2);
    });

    test('togglePatient does not toggle visibility if user is NOT admin', () {
      controller.isAdmin.value = false;
      controller.togglePatient('p2');
      expect(controller.visiblePatientIds.contains('p2'), isFalse);
    });

    test('grantAll assigns all patients to visible set when admin', () {
      controller.grantAll();
      expect(controller.visibleCount, 4);
      expect(controller.invisibleCount, 0);
      expect(controller.visiblePatientIds, containsAll(['p1', 'p2', 'p3', 'p4']));
    });

    test('revokeAll clears all patients from visible set when admin', () {
      controller.revokeAll();
      expect(controller.visibleCount, 0);
      expect(controller.invisibleCount, 4);
      expect(controller.visiblePatientIds.isEmpty, isTrue);
    });
  });
}
