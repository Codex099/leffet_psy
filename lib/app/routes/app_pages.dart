import 'package:get/get.dart';
import 'app_routes.dart';

import '../bindings/accueil_binding.dart';
import '../bindings/agenda_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/calendrier_binding.dart';
import '../bindings/compte_rendu_hub_binding.dart';
import '../bindings/compte_rendu_specialiste_binding.dart';
import '../bindings/creation_seance_binding.dart';
import '../bindings/detail_tache_binding.dart';
import '../bindings/dossier_medical_binding.dart';
import '../bindings/edit_employe_binding.dart';
import '../bindings/edit_groupe_binding.dart';
import '../bindings/edit_parent_binding.dart';
import '../bindings/edit_patient_binding.dart';
import '../bindings/employes_liste_binding.dart';
import '../bindings/groupe_detail_binding.dart';
import '../bindings/groupes_liste_binding.dart';
import '../bindings/historique_seances_patient_binding.dart';
import '../bindings/notes_patient_binding.dart';
import '../bindings/parents_liste_binding.dart';
import '../bindings/patient_info_binding.dart';
import '../bindings/patients_liste_binding.dart';
import '../bindings/plan_therapeutique_binding.dart';
import '../bindings/planning_recurrent_binding.dart';
import '../bindings/profil_binding.dart';
import '../bindings/seances_individuelles_binding.dart';
import '../bindings/statut_historique_binding.dart';
import '../bindings/taches_binding.dart';

import '../views/accueil/accueil_view.dart';
import '../views/agenda/agenda_view.dart';
import '../views/calendrier/calendrier_view.dart';
import '../views/compte_rendu_hub/compte_rendu_hub_view.dart';
import '../views/compte_rendu_specialiste/compte_rendu_specialiste_view.dart';
import '../views/creation_seance/creation_seance_view.dart';
import '../views/detail_tache/detail_tache_view.dart';
import '../views/dossier_medical/dossier_medical_view.dart';
import '../views/edit_employe/edit_employe_view.dart';
import '../views/edit_groupe/edit_groupe_view.dart';
import '../views/edit_parent/edit_parent_view.dart';
import '../views/edit_patient/edit_patient_view.dart';
import '../views/employes/employes_liste_view.dart';
import '../views/groupe_detail/groupe_detail_view.dart';
import '../views/groupes/groupes_liste_view.dart';
import '../views/historique_seances_patient/historique_seances_patient_view.dart';
import '../views/login/login_view.dart';
import '../views/notes_patient/notes_patient_view.dart';
import '../views/parents/parents_liste_view.dart';
import '../views/patient_info/patient_info_view.dart';
import '../views/patients/patients_liste_view.dart';
import '../views/plan_therapeutique/plan_therapeutique_view.dart';
import '../views/planning_recurrent/planning_recurrent_view.dart';
import '../views/profil/profil_view.dart';
import '../views/seances_individuelles/seances_individuelles_view.dart';
import '../views/statut_historique/statut_historique_view.dart';
import '../views/taches/taches_view.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.accueil,
      page: () => const AccueilView(),
      binding: AccueilBinding(),
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
    GetPage(
      name: AppRoutes.agenda,
      page: () => const AgendaView(),
      binding: AgendaBinding(),
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
    GetPage(
      name: AppRoutes.profil,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
    GetPage(
      name: AppRoutes.patientsListe,
      page: () => const PatientsListeView(),
      binding: PatientsListeBinding(),
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
    GetPage(
      name: AppRoutes.patientInfo,
      page: () => const PatientInfoView(),
      binding: PatientInfoBinding(),
    ),
    GetPage(
      name: AppRoutes.editPatient,
      page: () => const EditPatientView(),
      binding: EditPatientBinding(),
    ),
    GetPage(
      name: AppRoutes.dossierMedical,
      page: () => const DossierMedicalView(),
      binding: DossierMedicalBinding(),
    ),
    GetPage(
      name: AppRoutes.statutHistorique,
      page: () => const StatutHistoriqueView(),
      binding: StatutHistoriqueBinding(),
    ),
    GetPage(
      name: AppRoutes.notesPatient,
      page: () => const NotesPatientView(),
      binding: NotesPatientBinding(),
    ),
    GetPage(
      name: AppRoutes.planningRecurrent,
      page: () => const PlanningRecurrentView(),
      binding: PlanningRecurrentBinding(),
    ),
    GetPage(
      name: AppRoutes.parentsListe,
      page: () => const ParentsListeView(),
      binding: ParentsListeBinding(),
    ),
    GetPage(
      name: AppRoutes.editParent,
      page: () => const EditParentView(),
      binding: EditParentBinding(),
    ),
    GetPage(
      name: AppRoutes.groupesListe,
      page: () => const GroupesListeView(),
      binding: GroupesListeBinding(),
    ),
    GetPage(
      name: AppRoutes.groupeDetail,
      page: () => const GroupeDetailView(),
      binding: GroupeDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.editGroupe,
      page: () => const EditGroupeView(),
      binding: EditGroupeBinding(),
    ),
    GetPage(
      name: AppRoutes.employesListe,
      page: () => const EmployesListeView(),
      binding: EmployesListeBinding(),
    ),
    GetPage(
      name: AppRoutes.editEmploye,
      page: () => const EditEmployeView(),
      binding: EditEmployeBinding(),
    ),
    GetPage(
      name: AppRoutes.seancesIndividuelles,
      page: () => const SeancesIndividuellesView(),
      binding: SeancesIndividuellesBinding(),
    ),
    GetPage(
      name: AppRoutes.compteRenduHub,
      page: () => const CompteRenduHubView(),
      binding: CompteRenduHubBinding(),
    ),
    GetPage(
      name: AppRoutes.compteRenduSpecialiste,
      page: () => const CompteRenduSpecialisteView(),
      binding: CompteRenduSpecialisteBinding(),
    ),
    GetPage(
      name: AppRoutes.compteRenduSeance,
      page: () => const CompteRenduSpecialisteView(),
      binding: CompteRenduSpecialisteBinding(),
    ),
    GetPage(
      name: AppRoutes.compteRenduGroupe,
      page: () => const CompteRenduSpecialisteView(),
      binding: CompteRenduSpecialisteBinding(),
    ),
    GetPage(
      name: AppRoutes.creationSeance,
      page: () => const CreationSeanceView(),
      binding: CreationSeanceBinding(),
    ),
    GetPage(
      name: AppRoutes.planTherapeutique,
      page: () => const PlanTherapeutiqueView(),
      binding: PlanTherapeutiqueBinding(),
    ),
    GetPage(
      name: AppRoutes.taches,
      page: () => const TachesView(),
      binding: TachesBinding(),
    ),
    GetPage(
      name: AppRoutes.detailTache,
      page: () => const DetailTacheView(),
      binding: DetailTacheBinding(),
    ),
    GetPage(
      name: AppRoutes.calendrier,
      page: () => const CalendrierView(),
      binding: CalendrierBinding(),
    ),
    GetPage(
      name: AppRoutes.historiqueSeancesPatient,
      page: () => const HistoriqueSeancesPatientView(),
      binding: HistoriqueSeancesPatientBinding(),
    ),
  ];
}
