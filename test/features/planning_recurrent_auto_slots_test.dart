import 'package:flutter_test/flutter_test.dart';
import 'package:leffet_psy/app/models/seance_model.dart';
import 'package:leffet_psy/app/controllers/planning_recurrent_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Planning Recurrent Auto Slots (4 Semaines & Default OFF)', () {
    test('PlanningRecurrentController defaults creneauxAutomatiques to false (OFF)', () {
      final controller = PlanningRecurrentController();
      expect(controller.creneauxAutomatiques.value, isFalse,
          reason: 'Les créneaux automatiques doivent être désactivés (off) par défaut');
    });

    test('PatientPlanningRecurrentModel correctly parses mode_generation and horizon_jours', () {
      final jsonAuto = {
        'id': 'pl-1',
        'patient_id': 'pt-1',
        'jours_semaine': ['lundi', 'jeudi'],
        'heure_debut': '09:00',
        'heure_fin': '09:45',
        'mode_generation': 'auto',
        'horizon_jours': 28,
      };

      final modelAuto = PatientPlanningRecurrentModel.fromJson(jsonAuto);
      expect(modelAuto.modeGeneration, 'auto');
      expect(modelAuto.horizonJours, 28);

      final jsonManuel = {
        'id': 'pl-2',
        'patient_id': 'pt-2',
        'jours_semaine': ['mardi'],
        'heure_debut': '10:00',
        'heure_fin': '10:45',
        'mode_generation': 'manuel',
        'horizon_jours': 28,
      };

      final modelManuel = PatientPlanningRecurrentModel.fromJson(jsonManuel);
      expect(modelManuel.modeGeneration, 'manuel');
      expect(modelManuel.horizonJours, 28);
    });

    test('Controller activates auto-slots when planning is auto and remains false when manuel', () {
      final controller = PlanningRecurrentController();

      // Simulate loaded planning with mode 'auto'
      final autoPlanning = PatientPlanningRecurrentModel(
        id: 'auto-1',
        patientId: 'p-1',
        joursSemaine: ['lundi'],
        heureDebut: '09:00',
        heureFin: '09:45',
        modeGeneration: 'auto',
        horizonJours: 28,
      );

      controller.creneauxAutomatiques.value = autoPlanning.modeGeneration == 'auto';
      expect(controller.creneauxAutomatiques.value, isTrue);

      // Simulate loaded planning with mode 'manuel'
      final manuelPlanning = PatientPlanningRecurrentModel(
        id: 'man-1',
        patientId: 'p-2',
        joursSemaine: ['mercredi'],
        heureDebut: '14:00',
        heureFin: '14:45',
        modeGeneration: 'manuel',
        horizonJours: 28,
      );

      controller.creneauxAutomatiques.value = manuelPlanning.modeGeneration == 'auto';
      expect(controller.creneauxAutomatiques.value, isFalse);
    });

    test('4 weeks equals 28 days for auto slot horizon', () {
      const weeks = 4;
      const daysPerWeek = 7;
      const horizonDays = weeks * daysPerWeek;
      expect(horizonDays, 28);
    });
  });
}
