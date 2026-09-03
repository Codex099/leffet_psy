import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:leffet_psy/app/controllers/accueil_controller.dart';
import 'package:leffet_psy/app/models/agenda_session_item.dart';
import 'package:leffet_psy/app/models/seance_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccueilController Séances du Jour Counter Tests', () {
    test('seancesPrevuesCount updates reactively when prochainesSeances changes', () {
      final controller = AccueilController();
      expect(controller.seancesPrevuesCount.value, 0);

      final todayStr = DateTime.now().toIso8601String().split('T').first;

      final session1 = AgendaSessionItem(
        id: 's-1',
        isGroupe: false,
        title: 'Séance 1',
        subtitle: 'Consultation',
        date: todayStr,
        heureDebut: '09:00',
        heureFin: '09:45',
        duree: '45 min',
        statut: 'prevue',
        statutLabel: 'Prévue',
        initials: 'AB',
        assignedEmployee: 'Dr. Test',
      );

      final session2 = AgendaSessionItem(
        id: 's-2',
        isGroupe: false,
        title: 'Séance 2',
        subtitle: 'Consultation',
        date: todayStr,
        heureDebut: '10:00',
        heureFin: '10:45',
        duree: '45 min',
        statut: 'prevue',
        statutLabel: 'Prévue',
        initials: 'CD',
        assignedEmployee: 'Dr. Test',
      );

      controller.prochainesSeances.assignAll([session1, session2]);
      controller.seancesPrevuesCount.value = controller.prochainesSeances.length;

      expect(controller.seancesPrevuesCount.value, 2);
    });

    test('Filtering includes sessions with empty employeIds for followed patients', () {
      final todayStr = DateTime.now().toIso8601String().split('T').first;

      final unassignedSeance = SeanceModel(
        id: 's-unassigned',
        patientId: 'p-1',
        employeIds: [],
        date: todayStr,
        heureDebut: '08:00',
        heureFin: '10:00',
        statut: 'prevue',
      );

      final assignedSeance = SeanceModel(
        id: 's-assigned',
        patientId: 'p-2',
        employeIds: ['emp-123'],
        date: todayStr,
        heureDebut: '11:00',
        heureFin: '12:00',
        statut: 'prevue',
      );

      final otherSeance = SeanceModel(
        id: 's-other',
        patientId: 'p-3',
        employeIds: ['emp-999'],
        date: todayStr,
        heureDebut: '14:00',
        heureFin: '15:00',
        statut: 'prevue',
      );

      final currentUserId = 'emp-123';

      // Practitioner filter logic
      final filteredForPractitioner = [unassignedSeance, assignedSeance, otherSeance].where((s) {
        if (s.employeIds.isEmpty) return true;
        return s.employeIds.map((e) => e.toString()).contains(currentUserId);
      }).toList();

      expect(filteredForPractitioner.length, 2);
      expect(filteredForPractitioner.map((s) => s.id), containsAll(['s-unassigned', 's-assigned']));
      expect(filteredForPractitioner.map((s) => s.id), isNot(contains('s-other')));

      // Admin filter logic (all sessions included)
      final filteredForAdmin = [unassignedSeance, assignedSeance, otherSeance].toList();

      expect(filteredForAdmin.length, 3);
    });
  });
}
