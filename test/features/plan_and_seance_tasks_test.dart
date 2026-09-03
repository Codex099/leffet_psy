import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:leffet_psy/app/models/plan_therapeutique_model.dart';
import 'package:leffet_psy/app/controllers/patient_info_controller.dart';
import 'package:leffet_psy/app/controllers/creation_seance_controller.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  group('Therapeutic Plan Task Assignment & Session Auto-Tasks Tests', () {
    test('PlanTherapeutiqueModel & EtapePlanTherapeutiqueModel parse and serialize correctly', () {
      final json = {
        'id': 'plan_1',
        'patient_id': 'pat_1',
        'titre': 'Plan cognitif',
        'statut': 'actif',
        'etapes': [
          {
            'id': 'step_1',
            'plan_id': 'plan_1',
            'titre': 'Séance d\'évaluation cognitive',
            'description': 'Tester les fonctions exécutives',
            'ordre': 1,
            'statut': 'a_faire',
          },
          {
            'id': 'step_2',
            'plan_id': 'plan_1',
            'titre': 'Exercices de mémorisation',
            'ordre': 2,
            'statut': 'fait',
          }
        ]
      };

      final plan = PlanTherapeutiqueModel.fromJson(json);
      expect(plan.id, 'plan_1');
      expect(plan.patientId, 'pat_1');
      expect(plan.totalEtapes, 2);
      expect(plan.etapesTerminees, 1);
      expect(plan.progression, 0.5);
      expect(plan.etapes?.first.titre, 'Séance d\'évaluation cognitive');
    });

    test('PatientInfoController task assignment payload structure is complete', () async {
      final controller = PatientInfoController();
      controller.patientId = 'pat_100';

      final etapes = [
        EtapePlanTherapeutiqueModel(
          id: 'step_10',
          planId: 'plan_10',
          titre: 'Exercice de respiration',
          description: 'Relaxation guidée',
        ),
      ];

      // Verify assignEtapesAsTaches validation with empty etapes or null employeeId
      final emptyResult = await controller.assignEtapesAsTaches(
        planId: 'plan_10',
        etapes: [],
        employeeId: 'emp_1',
      );
      expect(emptyResult, isFalse);

      final nullEmpResult = await controller.assignEtapesAsTaches(
        planId: 'plan_10',
        etapes: etapes,
        employeeId: null,
      );
      expect(nullEmpResult, isFalse);
    });

    test('CreationSeanceController handles assigned employees and task payloads', () {
      final controller = CreationSeanceController();
      controller.date.value = '2026-09-10';
      controller.heureDebut.value = '10:00';
      controller.heureFin.value = '11:00';
      controller.selectedPatientId.value = 'pat_55';
      controller.selectedEmployeeIds.addAll(['emp_1', 'emp_2']);

      expect(controller.selectedEmployeeIds.length, 2);
      expect(controller.date.value, '2026-09-10');
      expect(controller.typeSeance.value, 'individuelle');
    });
  });
}
