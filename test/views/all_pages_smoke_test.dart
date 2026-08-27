import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:leffet_psy/app/controllers/accueil_controller.dart';
import 'package:leffet_psy/app/controllers/agenda_controller.dart';
import 'package:leffet_psy/app/controllers/auth_controller.dart';
import 'package:leffet_psy/app/controllers/calendrier_controller.dart';
import 'package:leffet_psy/app/controllers/compte_rendu_groupe_controller.dart';
import 'package:leffet_psy/app/controllers/compte_rendu_hub_controller.dart';
import 'package:leffet_psy/app/controllers/compte_rendu_seance_controller.dart';
import 'package:leffet_psy/app/controllers/compte_rendu_specialiste_controller.dart';
import 'package:leffet_psy/app/controllers/creation_seance_controller.dart';
import 'package:leffet_psy/app/controllers/detail_tache_controller.dart';
import 'package:leffet_psy/app/controllers/dossier_medical_controller.dart';
import 'package:leffet_psy/app/controllers/edit_employe_controller.dart';
import 'package:leffet_psy/app/controllers/edit_groupe_controller.dart';
import 'package:leffet_psy/app/controllers/edit_parent_controller.dart';
import 'package:leffet_psy/app/controllers/edit_patient_controller.dart';
import 'package:leffet_psy/app/controllers/employes_liste_controller.dart';
import 'package:leffet_psy/app/controllers/groupe_detail_controller.dart';
import 'package:leffet_psy/app/controllers/groupes_liste_controller.dart';
import 'package:leffet_psy/app/controllers/historique_seances_patient_controller.dart';
import 'package:leffet_psy/app/controllers/notes_patient_controller.dart';
import 'package:leffet_psy/app/controllers/parents_liste_controller.dart';
import 'package:leffet_psy/app/controllers/patient_info_controller.dart';
import 'package:leffet_psy/app/controllers/patients_liste_controller.dart';
import 'package:leffet_psy/app/controllers/plan_therapeutique_controller.dart';
import 'package:leffet_psy/app/controllers/planning_recurrent_controller.dart';
import 'package:leffet_psy/app/controllers/profil_controller.dart';
import 'package:leffet_psy/app/controllers/seances_individuelles_controller.dart';
import 'package:leffet_psy/app/controllers/statut_historique_controller.dart';
import 'package:leffet_psy/app/controllers/taches_controller.dart';
import 'package:leffet_psy/app/services/dio_client.dart';
import 'package:leffet_psy/app/views/accueil/accueil_view.dart';
import 'package:leffet_psy/app/views/agenda/agenda_view.dart';
import 'package:leffet_psy/app/views/calendrier/calendrier_view.dart';
import 'package:leffet_psy/app/views/compte_rendu_groupe/compte_rendu_groupe_view.dart';
import 'package:leffet_psy/app/views/compte_rendu_hub/compte_rendu_hub_view.dart';
import 'package:leffet_psy/app/views/compte_rendu_seance/compte_rendu_seance_view.dart';
import 'package:leffet_psy/app/views/compte_rendu_specialiste/compte_rendu_specialiste_view.dart';
import 'package:leffet_psy/app/views/creation_seance/creation_seance_view.dart';
import 'package:leffet_psy/app/views/detail_tache/detail_tache_view.dart';
import 'package:leffet_psy/app/views/dossier_medical/dossier_medical_view.dart';
import 'package:leffet_psy/app/views/edit_employe/edit_employe_view.dart';
import 'package:leffet_psy/app/views/edit_groupe/edit_groupe_view.dart';
import 'package:leffet_psy/app/views/edit_parent/edit_parent_view.dart';
import 'package:leffet_psy/app/views/edit_patient/edit_patient_view.dart';
import 'package:leffet_psy/app/views/employes/employes_liste_view.dart';
import 'package:leffet_psy/app/views/groupe_detail/groupe_detail_view.dart';
import 'package:leffet_psy/app/views/groupes/groupes_liste_view.dart';
import 'package:leffet_psy/app/views/historique_seances_patient/historique_seances_patient_view.dart';
import 'package:leffet_psy/app/views/login/login_view.dart';
import 'package:leffet_psy/app/views/notes_patient/notes_patient_view.dart';
import 'package:leffet_psy/app/views/parents/parents_liste_view.dart';
import 'package:leffet_psy/app/views/patient_info/patient_info_view.dart';
import 'package:leffet_psy/app/views/patients/patients_liste_view.dart';
import 'package:leffet_psy/app/views/plan_therapeutique/plan_therapeutique_view.dart';
import 'package:leffet_psy/app/views/planning_recurrent/planning_recurrent_view.dart';
import 'package:leffet_psy/app/views/profil/profil_view.dart';
import 'package:leffet_psy/app/views/seances_individuelles/seances_individuelles_view.dart';
import 'package:leffet_psy/app/views/statut_historique/statut_historique_view.dart';
import 'package:leffet_psy/app/views/taches/taches_view.dart';

class _MockHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final path = options.path;
    String responseString = '[]';

    if (path.contains('/api/auth/me')) {
      responseString =
          '{"id": 1, "nom": "Admin", "prenom": "Système", "username": "admin", "role": "admin"}';
    } else if (path.contains('/api/auth/login')) {
      responseString =
          '{"access_token": "mock_token", "token_type": "bearer", "user": {"id": 1, "nom": "Admin", "prenom": "Système", "username": "admin", "role": "admin"}}';
    } else if (path.contains('/dossier-medical')) {
      responseString =
          '{"id": 1, "patient_id": 1, "antecedents_medicaux": "None"}';
    } else if (path.contains('/planning-recurrent')) {
      responseString =
          '{"id": 1, "patient_id": 1, "jours_semaine": ["lundi"], "heure_debut": "09:00", "heure_fin": "09:45"}';
    } else if (RegExp(r'/api/(patients|groupes|seances|seances-groupe|taches|employees)/\w+')
        .hasMatch(path)) {
      responseString =
          '{"id": 1, "nom": "Test", "prenom": "Test", "titre": "Test", "statut": "actif", "date": "2026-08-26", "heure_debut": "10:00", "heure_fin": "10:45", "type_planning": "fixe", "username": "test", "role": "psychologue", "priorite": "normale"}';
    }

    return Future.value(
      ResponseBody.fromString(
        responseString,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
    final dio = DioClient.instance;
    dio.options.connectTimeout = null;
    dio.options.receiveTimeout = null;
    dio.options.sendTimeout = null;
    dio.httpClientAdapter = _MockHttpClientAdapter();
  });

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  Widget createTestApp(Widget home) {
    return GetMaterialApp(
      home: home,
    );
  }

  Future<void> pumpScreen(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(createTestApp(page));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('All 29 Pages Smoke Tests', () {
    testWidgets('1. LoginView renders without crashing', (tester) async {
      Get.put(AuthController());
      await pumpScreen(tester, const LoginView());
      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('2. AccueilView renders without crashing', (tester) async {
      final ctrl = Get.put(AccueilController());
      ctrl.status.value = 'success';
      await pumpScreen(tester, const AccueilView());
      expect(find.byType(AccueilView), findsOneWidget);
    });

    testWidgets('3. AgendaView renders without crashing', (tester) async {
      final ctrl = Get.put(AgendaController());
      ctrl.status.value = 'success';
      await pumpScreen(tester, const AgendaView());
      expect(find.byType(AgendaView), findsOneWidget);
    });

    testWidgets('4. ProfilView renders without crashing', (tester) async {
      final ctrl = Get.put(ProfilController());
      ctrl.status.value = 'success';
      await pumpScreen(tester, const ProfilView());
      expect(find.byType(ProfilView), findsOneWidget);
    });

    testWidgets('5. PatientsListeView renders without crashing', (tester) async {
      final ctrl = Get.put(PatientsListeController());
      ctrl.status.value = 'empty';
      await pumpScreen(tester, const PatientsListeView());
      expect(find.byType(PatientsListeView), findsOneWidget);
    });

    testWidgets('6. PatientInfoView renders without crashing', (tester) async {
      final ctrl = Get.put(PatientInfoController());
      ctrl.status.value = 'loading';
      await pumpScreen(tester, const PatientInfoView());
      expect(find.byType(PatientInfoView), findsOneWidget);
    });

    testWidgets('7. EditPatientView renders without crashing', (tester) async {
      Get.put(EditPatientController());
      await pumpScreen(tester, const EditPatientView());
      expect(find.byType(EditPatientView), findsOneWidget);
    });

    testWidgets('8. DossierMedicalView renders without crashing', (tester) async {
      final ctrl = Get.put(DossierMedicalController());
      ctrl.status.value = 'success';
      await pumpScreen(tester, const DossierMedicalView());
      expect(find.byType(DossierMedicalView), findsOneWidget);
    });

    testWidgets('9. StatutHistoriqueView renders without crashing', (tester) async {
      final ctrl = Get.put(StatutHistoriqueController());
      ctrl.status.value = 'empty';
      await pumpScreen(tester, const StatutHistoriqueView());
      expect(find.byType(StatutHistoriqueView), findsOneWidget);
    });

    testWidgets('10. NotesPatientView renders without crashing', (tester) async {
      final ctrl = Get.put(NotesPatientController());
      ctrl.status.value = 'empty';
      await pumpScreen(tester, const NotesPatientView());
      expect(find.byType(NotesPatientView), findsOneWidget);
    });

    testWidgets('11. PlanningRecurrentView renders without crashing', (tester) async {
      final ctrl = Get.put(PlanningRecurrentController());
      ctrl.status.value = 'success';
      await pumpScreen(tester, const PlanningRecurrentView());
      expect(find.byType(PlanningRecurrentView), findsOneWidget);
    });

    testWidgets('12. ParentsListeView renders without crashing', (tester) async {
      final ctrl = Get.put(ParentsListeController());
      ctrl.status.value = 'empty';
      await pumpScreen(tester, const ParentsListeView());
      expect(find.byType(ParentsListeView), findsOneWidget);
    });

    testWidgets('13. EditParentView renders without crashing', (tester) async {
      Get.put(EditParentController());
      await pumpScreen(tester, const EditParentView());
      expect(find.byType(EditParentView), findsOneWidget);
    });

    testWidgets('14. GroupesListeView renders without crashing', (tester) async {
      final ctrl = Get.put(GroupesListeController());
      ctrl.status.value = 'empty';
      await pumpScreen(tester, const GroupesListeView());
      expect(find.byType(GroupesListeView), findsOneWidget);
    });

    testWidgets('15. GroupeDetailView renders without crashing', (tester) async {
      final ctrl = Get.put(GroupeDetailController());
      ctrl.status.value = 'loading';
      await pumpScreen(tester, const GroupeDetailView());
      expect(find.byType(GroupeDetailView), findsOneWidget);
    });

    testWidgets('16. EditGroupeView renders without crashing', (tester) async {
      Get.put(EditGroupeController());
      await pumpScreen(tester, const EditGroupeView());
      expect(find.byType(EditGroupeView), findsOneWidget);
    });

    testWidgets('17. EmployesListeView renders without crashing', (tester) async {
      final ctrl = Get.put(EmployesListeController());
      ctrl.status.value = 'empty';
      await pumpScreen(tester, const EmployesListeView());
      expect(find.byType(EmployesListeView), findsOneWidget);
    });

    testWidgets('18. EditEmployeView renders without crashing', (tester) async {
      Get.put(EditEmployeController());
      await pumpScreen(tester, const EditEmployeView());
      expect(find.byType(EditEmployeView), findsOneWidget);
    });

    testWidgets('19. SeancesIndividuellesView renders without crashing', (tester) async {
      final ctrl = Get.put(SeancesIndividuellesController());
      ctrl.status.value = 'success';
      await pumpScreen(tester, const SeancesIndividuellesView());
      expect(find.byType(SeancesIndividuellesView), findsOneWidget);
    });

    testWidgets('20. CompteRenduHubView renders without crashing', (tester) async {
      final ctrl = Get.put(CompteRenduHubController());
      ctrl.status.value = 'success';
      await pumpScreen(tester, const CompteRenduHubView());
      expect(find.byType(CompteRenduHubView), findsOneWidget);
    });

    testWidgets('21. CompteRenduSpecialisteView renders without crashing', (tester) async {
      final ctrl = Get.put(CompteRenduSpecialisteController());
      ctrl.status.value = 'loading';
      await pumpScreen(tester, const CompteRenduSpecialisteView());
      expect(find.byType(CompteRenduSpecialisteView), findsOneWidget);
    });

    testWidgets('22. CompteRenduSeanceView renders without crashing', (tester) async {
      final ctrl = Get.put(CompteRenduSeanceController());
      ctrl.status.value = 'loading';
      await pumpScreen(tester, const CompteRenduSeanceView());
      expect(find.byType(CompteRenduSeanceView), findsOneWidget);
    });

    testWidgets('23. CompteRenduGroupeView renders without crashing', (tester) async {
      final ctrl = Get.put(CompteRenduGroupeController());
      ctrl.status.value = 'loading';
      await pumpScreen(tester, const CompteRenduGroupeView());
      expect(find.byType(CompteRenduGroupeView), findsOneWidget);
    });

    testWidgets('24. CreationSeanceView renders without crashing', (tester) async {
      final ctrl = Get.put(CreationSeanceController());
      ctrl.status.value = 'success';
      await pumpScreen(tester, const CreationSeanceView());
      expect(find.byType(CreationSeanceView), findsOneWidget);
    });

    testWidgets('25. PlanTherapeutiqueView renders without crashing', (tester) async {
      final ctrl = Get.put(PlanTherapeutiqueController());
      ctrl.status.value = 'empty';
      await pumpScreen(tester, const PlanTherapeutiqueView());
      expect(find.byType(PlanTherapeutiqueView), findsOneWidget);
    });

    testWidgets('26. TachesView renders without crashing', (tester) async {
      final ctrl = Get.put(TachesController());
      ctrl.status.value = 'empty';
      await pumpScreen(tester, const TachesView());
      expect(find.byType(TachesView), findsOneWidget);
    });

    testWidgets('27. DetailTacheView renders without crashing', (tester) async {
      final ctrl = Get.put(DetailTacheController());
      ctrl.status.value = 'success';
      await pumpScreen(tester, const DetailTacheView());
      expect(find.byType(DetailTacheView), findsOneWidget);
    });

    testWidgets('28. CalendrierView renders without crashing', (tester) async {
      final ctrl = Get.put(CalendrierController());
      ctrl.status.value = 'success';
      await pumpScreen(tester, const CalendrierView());
      expect(find.byType(CalendrierView), findsOneWidget);
    });

    testWidgets('29. HistoriqueSeancesPatientView renders without crashing', (tester) async {
      final ctrl = Get.put(HistoriqueSeancesPatientController());
      ctrl.status.value = 'success';
      await pumpScreen(tester, const HistoriqueSeancesPatientView());
      expect(find.byType(HistoriqueSeancesPatientView), findsOneWidget);
    });
  });
}
