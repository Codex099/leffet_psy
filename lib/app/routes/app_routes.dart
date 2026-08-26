/// Constantes de routes GetX pour PsyCare.
/// Toutes les navigations doivent utiliser ces constantes — jamais de strings en dur.
abstract class AppRoutes {
  // ─── Auth ──────────────────────────────────────────────────────────────────
  static const login = '/login';

  // ─── Navigation principale (bottom nav) ────────────────────────────────────
  static const accueil = '/accueil';
  static const agenda = '/agenda';
  static const profil = '/profil';

  // ─── Patients ──────────────────────────────────────────────────────────────
  static const patientsListe = '/patients';
  static const patientInfo = '/patients/detail';
  static const editPatient = '/patients/edit';
  static const dossierMedical = '/patients/dossier-medical';
  static const statutHistorique = '/patients/statut-historique';
  static const notesPatient = '/patients/notes';
  static const planningRecurrent = '/patients/planning-recurrent';
  static const historiqueSeancesPatient = '/patients/historique-seances';

  // ─── Parents ───────────────────────────────────────────────────────────────
  static const parentsListe = '/parents';
  static const editParent = '/parents/edit';

  // ─── Groupes ───────────────────────────────────────────────────────────────
  static const groupesListe = '/groupes';
  static const groupeDetail = '/groupes/detail';
  static const editGroupe = '/groupes/edit';

  // ─── Employés ──────────────────────────────────────────────────────────────
  static const employesListe = '/employes';
  static const editEmploye = '/employes/edit';

  // ─── Séances & Comptes-rendus ──────────────────────────────────────────────
  static const compteRenduHub = '/comptes-rendus';
  static const compteRenduSpecialiste = '/comptes-rendus/redaction';
  static const compteRenduSeance = '/seances/compte-rendu';
  static const compteRenduGroupe = '/seances-groupe/compte-rendu';
  static const creationSeance = '/seances/creation';

  // ─── Plans thérapeutiques ──────────────────────────────────────────────────
  static const planTherapeutique = '/plan-therapeutique';

  // ─── Tâches ────────────────────────────────────────────────────────────────
  static const taches = '/taches';
  static const detailTache = '/taches/detail';

  // ─── Calendrier admin ──────────────────────────────────────────────────────
  static const calendrier = '/calendrier';
}
