import 'package:flutter_test/flutter_test.dart';
import 'package:leffet_psy/app/models/agenda_session_item.dart';
import 'package:leffet_psy/app/models/dossier_medical_model.dart';
import 'package:leffet_psy/app/models/employee_model.dart';
import 'package:leffet_psy/app/models/evenement_calendrier_model.dart';
import 'package:leffet_psy/app/models/groupe_model.dart';
import 'package:leffet_psy/app/models/parent_model.dart';
import 'package:leffet_psy/app/models/patient_model.dart';
import 'package:leffet_psy/app/models/patient_statut_historique_model.dart';
import 'package:leffet_psy/app/models/plan_therapeutique_model.dart';
import 'package:leffet_psy/app/models/seance_groupe_model.dart';
import 'package:leffet_psy/app/models/seance_model.dart';
import 'package:leffet_psy/app/models/tache_model.dart';
import 'package:leffet_psy/app/utils/json_utils.dart';

void main() {
  group('JsonUtils Tests', () {
    test('parseInt handles null, numbers, and strings safely', () {
      expect(parseInt(null, 5), 5);
      expect(parseInt(42), 42);
      expect(parseInt(42.8), 42);
      expect(parseInt('123'), 123);
      expect(parseInt('abc', 10), 10);
    });

    test('parseNullableInt handles null and invalid inputs', () {
      expect(parseNullableInt(null), isNull);
      expect(parseNullableInt(10), 10);
      expect(parseNullableInt('25'), 25);
      expect(parseNullableInt('invalid'), isNull);
    });

    test('parseId parses int or string ID', () {
      expect(parseId(12), 12);
      expect(parseId('34'), 34);
      expect(parseId('uuid-abc-123'), 'uuid-abc-123');
      expect(parseId(null), isNull);
    });

    test('parseDouble handles various numeric and string inputs', () {
      expect(parseDouble(null, 1.5), 1.5);
      expect(parseDouble(3.14), 3.14);
      expect(parseDouble(5), 5.0);
      expect(parseDouble('2.718'), 2.718);
      expect(parseDouble('invalid', 0.0), 0.0);
    });

    test('extractIdParam extracts from map, scalar or parameters', () {
      expect(extractIdParam({'id': 42}), 42);
      expect(extractIdParam(99), 99);
      expect(extractIdParam(null, {'id': '50'}), 50);
      expect(extractIdParam(null, null), isNull);
    });
  });

  group('PatientModel Tests', () {
    test('fromJson and toJson with complete data', () {
      final json = {
        'id': 1,
        'nom': 'Dupont',
        'prenom': 'Jean',
        'date_naissance': '2015-06-15',
        'photo': 'https://example.com/photo.jpg',
        'nombre_freres_soeurs': 2,
        'ordre_naissance': 1,
        'est_actif': true,
        'sexe': 'garçon',
        'parents': [
          {'id': 10, 'nom': 'Dupont', 'prenom': 'Pierre'}
        ],
        'employes_assignes': [
          {'id': 20, 'nom': 'Martin', 'prenom': 'Sophie'}
        ],
      };

      final patient = PatientModel.fromJson(json);
      expect(patient.id, 1);
      expect(patient.nom, 'Dupont');
      expect(patient.prenom, 'Jean');
      expect(patient.fullName, 'Jean Dupont');
      expect(patient.initials, 'JD');
      expect(patient.isGarcon, isTrue);
      expect(patient.isFille, isFalse);
      expect(patient.sexeLabel, 'Garçon');
      expect(patient.backendSexe, 'masculin');
      expect(patient.statutLabel, 'Actif');
      expect(patient.age, isNotNull);
      expect(patient.ageFormatted, contains('ans'));

      final outJson = patient.toJson();
      expect(outJson['nom'], 'Dupont');
      expect(outJson['prenom'], 'Jean');
      expect(outJson['est_actif'], true);
    });

    test('PatientModel handles female sex and null fields gracefully', () {
      final json = {
        'id': 'uuid-2',
        'nom': 'Martin',
        'prenom': 'Claire',
        'sexe': 'Féminin',
      };

      final patient = PatientModel.fromJson(json);
      expect(patient.id, 'uuid-2');
      expect(patient.isFille, isTrue);
      expect(patient.isGarcon, isFalse);
      expect(patient.sexeLabel, 'Fille');
      expect(patient.backendSexe, 'feminin');
      expect(patient.age, isNull);
      expect(patient.ageFormatted, isNull);
    });

    test('PatientModel copyWith updates fields properly', () {
      final patient = PatientModel(
        id: 1,
        nom: 'Alami',
        prenom: 'Youssef',
        estActif: true,
      );

      final updated = patient.copyWith(nom: 'Bennani', estActif: false);
      expect(updated.id, 1);
      expect(updated.prenom, 'Youssef');
      expect(updated.nom, 'Bennani');
      expect(updated.estActif, isFalse);
    });
  });

  group('SeanceModel & AgendaSessionItem Tests', () {
    test('SeanceModel parses and calculates duration properly', () {
      final json = {
        'id': 101,
        'patient_id': 1,
        'employe_ids': [2, 3],
        'date': '2026-08-26',
        'heure_debut': '10:00',
        'heure_fin': '10:45',
        'statut': 'planifiee',
        'statut_presence': 'present',
        'patient': {'nom': 'Dupont', 'prenom': 'Jean'},
      };

      final seance = SeanceModel.fromJson(json);
      expect(seance.id, 101);
      expect(seance.patientFullName, 'Jean Dupont');
      expect(seance.duree, '45 min');
      expect(seance.isPresent, isTrue);
      expect(seance.isPlanifiee, isTrue);
      expect(seance.statutLabel, 'Planifiée');

      final agendaItem = AgendaSessionItem.fromIndividuelle(seance);
      expect(agendaItem.id, 101);
      expect(agendaItem.isGroupe, isFalse);
      expect(agendaItem.title, 'Jean Dupont');
      expect(agendaItem.duree, '45 min');
    });

    test('SeanceGroupeModel and AgendaSessionItem.fromGroupe', () {
      final json = {
        'id': 201,
        'groupe_id': 5,
        'date': '2026-08-26',
        'heure_debut': '14:00',
        'heure_fin': '15:00',
        'statut': 'realisee',
        'groupe': {'nom': 'Groupe Habiletés Sociales'},
        'participants': [
          {
            'seance_groupe_id': 201,
            'patient_id': 1,
            'statut_presence': 'present',
            'patient': {'nom': 'Dupont', 'prenom': 'Jean'}
          }
        ],
      };

      final seanceGrp = SeanceGroupeModel.fromJson(json);
      expect(seanceGrp.id, 201);
      expect(seanceGrp.groupeName, 'Groupe Habiletés Sociales');
      expect(seanceGrp.isRealisee, isTrue);
      expect(seanceGrp.participants?.length, 1);
      expect(seanceGrp.participants!.first.patientFullName, 'Jean Dupont');

      final agendaItem = AgendaSessionItem.fromGroupe(seanceGrp);
      expect(agendaItem.isGroupe, isTrue);
      expect(agendaItem.title, 'Groupe : Groupe Habiletés Sociales');
      expect(agendaItem.statutLabel, 'Groupe');
    });
  });

  group('GroupeModel Tests', () {
    test('GroupeModel parses correctly with patients and recurrence', () {
      final json = {
        'id': 1,
        'nom': 'Atelier Autonomie',
        'type_planning': 'fixe',
        'description': 'Atelier hebdomadaire',
        'patients': [
          {'id': 1, 'nom': 'A'},
          {'id': 2, 'nom': 'B'}
        ],
        'planning_recurrent': [
          {'jour_semaine': 'lundi', 'heure_debut': '10:00', 'heure_fin': '11:00'}
        ],
      };

      final groupe = GroupeModel.fromJson(json);
      expect(groupe.id, 1);
      expect(groupe.nom, 'Atelier Autonomie');
      expect(groupe.isFixe, isTrue);
      expect(groupe.membresCount, 2);
      expect(groupe.initials, 'AA');
      expect(groupe.typeLabel, 'Fixe');
    });
  });

  group('EmployeeModel & ParentModel Tests', () {
    test('EmployeeModel role checks and labels', () {
      final admin = EmployeeModel(
        id: 1,
        nom: 'Directeur',
        prenom: 'Alain',
        username: 'admin',
        role: 'admin',
      );
      expect(admin.isAdmin, isTrue);
      expect(admin.roleLabel, 'Admin');
      expect(admin.fullName, 'Alain Directeur');

      final psy = EmployeeModel(
        id: 2,
        nom: 'Martin',
        prenom: 'Lucie',
        username: 'lmartin',
        role: 'psychologue',
      );
      expect(psy.isPsychologue, isTrue);
      expect(psy.roleLabel, 'Psychologue');

      final educ = EmployeeModel(
        id: 3,
        nom: 'Benali',
        prenom: 'Sara',
        username: 'sbenali',
        role: 'educatrice',
      );
      expect(educ.isEducatrice, isTrue);
      expect(educ.roleLabel, 'Éducatrice');
    });

    test('ParentModel parses and formats', () {
      final json = {
        'id': 10,
        'nom': 'Alami',
        'prenom': 'Karim',
        'telephone': '0612345678',
        'etat_civil': 'Marié',
      };
      final parent = ParentModel.fromJson(json);
      expect(parent.fullName, 'Karim Alami');
      expect(parent.initials, 'KA');
      expect(parent.telephone, '0612345678');
    });
  });

  group('TacheModel & PlanTherapeutiqueModel Tests', () {
    test('TacheModel parses and returns labels', () {
      final json = {
        'id': 1,
        'titre': 'Préparer compte-rendu',
        'statut': 'a_faire',
        'priorite': 'haute',
        'date_echeance': '2026-08-30',
      };
      final tache = TacheModel.fromJson(json);
      expect(tache.titre, 'Préparer compte-rendu');
      expect(tache.statutLabel, 'À faire');
      expect(tache.prioriteLabel, 'Haute');
    });

    test('PlanTherapeutiqueModel calculates progression accurately', () {
      final json = {
        'id': 1,
        'patient_id': 1,
        'titre': 'Plan Développement Cognitif',
        'statut': 'actif',
        'etapes': [
          {'id': 1, 'plan_id': 1, 'titre': 'Étape 1', 'statut': 'fait', 'ordre': 1},
          {'id': 2, 'plan_id': 1, 'titre': 'Étape 2', 'statut': 'en_cours', 'ordre': 2},
          {'id': 3, 'plan_id': 1, 'titre': 'Étape 3', 'statut': 'a_faire', 'ordre': 3},
          {'id': 4, 'plan_id': 1, 'titre': 'Étape 4', 'statut': 'termine', 'ordre': 4},
        ],
      };

      final plan = PlanTherapeutiqueModel.fromJson(json);
      expect(plan.isActif, isTrue);
      expect(plan.totalEtapes, 4);
      expect(plan.etapesTerminees, 2); // 1 'fait' + 1 'termine'
      expect(plan.progression, 0.5); // 2/4 = 50%
    });

    test('PlanTherapeutiqueModel with empty steps progression is 0.0', () {
      final plan = PlanTherapeutiqueModel(
        id: 2,
        patientId: 1,
        titre: 'Nouveau plan',
        statut: 'actif',
        etapes: [],
      );
      expect(plan.totalEtapes, 0);
      expect(plan.progression, 0.0);
    });
  });

  group('DossierMedicalModel & PatientStatutHistoriqueModel Tests', () {
    test('DossierMedicalModel serialization and null safety', () {
      final json = {
        'id': 50,
        'patient_id': 1,
        'antecedents_medicaux': 'Aucun antécédent particulier',
        'nombre_freres_soeurs': '3',
        'rang_fratrie': 2,
      };
      final dossier = DossierMedicalModel.fromJson(json);
      expect(dossier.id, 50);
      expect(dossier.antecedentsMedicaux, 'Aucun antécédent particulier');
      expect(dossier.nombreFreresSoeurs, 3);
      expect(dossier.rangFratrie, 2);
    });

    test('PatientStatutHistoriqueModel parsing', () {
      final json = {
        'id': 1,
        'patient_id': 1,
        'statut': 'inactif',
        'date_changement': '2026-08-01',
        'note_degradation': 'Baisse de motivation constatée',
      };
      final statut = PatientStatutHistoriqueModel.fromJson(json);
      expect(statut.statut, 'inactif');
      expect(statut.noteDegradation, 'Baisse de motivation constatée');
    });

    test('EvenementCalendrierModel parsing', () {
      final json = {
        'id': 100,
        'titre': 'Réunion d\'équipe clinique',
        'date': '2026-09-01T09:00:00',
        'notifier_avant_jours': 2,
      };
      final ev = EvenementCalendrierModel.fromJson(json);
      expect(ev.titre, 'Réunion d\'équipe clinique');
      expect(ev.notifierAvantJours, 2);
    });
  });
}
