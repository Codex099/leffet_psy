import 'package:flutter_test/flutter_test.dart';
import 'package:leffet_psy/app/controllers/agenda_controller.dart';
import 'package:leffet_psy/app/controllers/patients_liste_controller.dart';
import 'package:leffet_psy/app/controllers/taches_controller.dart';
import 'package:leffet_psy/app/models/agenda_session_item.dart';
import 'package:leffet_psy/app/models/patient_model.dart';
import 'package:leffet_psy/app/models/tache_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AgendaController Date Logic Tests', () {
    late AgendaController controller;

    setUp(() {
      controller = AgendaController();
    });

    test('currentWeekDays returns exactly 7 days starting from Monday', () {
      controller.selectedDate.value = DateTime(2026, 8, 26); // Wednesday
      final week = controller.currentWeekDays;
      expect(week.length, 7);
      expect(week.first.weekday, DateTime.monday);
      expect(week.last.weekday, DateTime.sunday);
    });

    test('previousDay and nextDay updates selectedDate correctly', () {
      controller.selectedDate.value = DateTime(2026, 8, 26);
      controller.nextDay();
      expect(controller.selectedDate.value.day, 27);
      controller.previousDay();
      expect(controller.selectedDate.value.day, 26);
    });

    test('previousWeek and nextWeek shifts selectedDate by 7 days', () {
      controller.selectedDate.value = DateTime(2026, 8, 26);
      controller.nextWeek();
      expect(controller.selectedDate.value.day, 2);
      expect(controller.selectedDate.value.month, 9);
      controller.previousWeek();
      expect(controller.selectedDate.value.day, 26);
      expect(controller.selectedDate.value.month, 8);
    });

    test('monthYearTitle and formattedSelectedDate formats correctly in French', () {
      controller.selectedDate.value = DateTime(2026, 8, 26);
      expect(controller.monthYearTitle, 'Août 2026');
      expect(controller.formattedSelectedDate, contains('Mercredi'));
      expect(controller.formattedSelectedDate, contains('26'));
      expect(controller.formattedSelectedDate, contains('Août'));
    });

    test('sessionsForSelectedDate filters allSessions by date', () {
      controller.allSessions.value = [
        AgendaSessionItem(
          id: 1,
          isGroupe: false,
          title: 'Patient 1',
          subtitle: '10:00',
          date: '2026-08-26',
          heureDebut: '10:00',
          heureFin: '10:45',
          duree: '45 min',
          statut: 'planifiee',
          statutLabel: 'Planifiée',
          initials: 'P1',
        ),
        AgendaSessionItem(
          id: 2,
          isGroupe: false,
          title: 'Patient 2',
          subtitle: '11:00',
          date: '2026-08-27',
          heureDebut: '11:00',
          heureFin: '11:45',
          duree: '45 min',
          statut: 'planifiee',
          statutLabel: 'Planifiée',
          initials: 'P2',
        ),
      ];

      controller.selectedDate.value = DateTime(2026, 8, 26);
      final sessions = controller.sessionsForSelectedDate;
      expect(sessions.length, 1);
      expect(sessions.first.title, 'Patient 1');
      expect(controller.hasSessionsOn(DateTime(2026, 8, 26)), isTrue);
      expect(controller.hasSessionsOn(DateTime(2026, 8, 28)), isFalse);
    });
  });

  group('PatientsListeController Filter Logic Tests', () {
    late PatientsListeController controller;

    setUp(() {
      controller = PatientsListeController();
      controller.allPatients.value = [
        PatientModel(
          id: 1,
          nom: 'Dupont',
          prenom: 'Jean',
          estActif: true,
          sexe: 'masculin',
          dateNaissance: '2015-01-01',
        ),
        PatientModel(
          id: 2,
          nom: 'Martin',
          prenom: 'Claire',
          estActif: true,
          sexe: 'feminin',
          dateNaissance: '2018-05-10',
        ),
        PatientModel(
          id: 3,
          nom: 'Benali',
          prenom: 'Adam',
          estActif: false,
          sexe: 'garçon',
          dateNaissance: '2020-03-20',
        ),
      ];
    });

    test('Filters by active status', () {
      controller.setActifFilter(true);
      expect(controller.filteredPatients.length, 2);

      controller.setActifFilter(false);
      expect(controller.filteredPatients.length, 1);
      expect(controller.filteredPatients.first.nom, 'Benali');

      controller.setActifFilter(null);
      expect(controller.filteredPatients.length, 3);
    });

    test('Filters by sex', () {
      controller.setActifFilter(null);
      controller.setSexeFilter('garçon');
      expect(controller.filteredPatients.length, 2);

      controller.setSexeFilter('fille');
      expect(controller.filteredPatients.length, 1);
      expect(controller.filteredPatients.first.prenom, 'Claire');
    });

    test('Filters by search query', () {
      controller.setActifFilter(null);
      controller.setSexeFilter(null);
      controller.searchQuery.value = 'adam';
      expect(controller.filteredPatients.length, 1);
      expect(controller.filteredPatients.first.prenom, 'Adam');
    });
  });

  group('TachesController Filter Logic Tests', () {
    late TachesController controller;

    setUp(() {
      controller = TachesController();
      controller.taches.value = [
        TacheModel(id: 1, titre: 'Tâche 1', statut: 'a_faire', priorite: 'haute'),
        TacheModel(id: 2, titre: 'Tâche 2', statut: 'en_cours', priorite: 'normale'),
        TacheModel(id: 3, titre: 'Tâche 3', statut: 'fait', priorite: 'basse'),
        TacheModel(id: 4, titre: 'Tâche 4', statut: 'terminee', priorite: 'normale'),
      ];
    });

    test('Splits tasks by status groups accurately', () {
      expect(controller.tachesAFaire.length, 1);
      expect(controller.tachesAFaire.first.id, 1);

      expect(controller.tachesEnCours.length, 1);
      expect(controller.tachesEnCours.first.id, 2);

      expect(controller.tachesFait.length, 2);
    });
  });
}
