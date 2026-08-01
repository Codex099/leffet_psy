/// Configuration centralisée de l'API backend PsyCare.
/// TOUTES les URLs et constantes réseau sont définies ici.
/// Aucune URL ne doit être codée en dur dans les services.
class ApiConfig {
  ApiConfig._();

  // ─── Base URL ──────────────────────────────────────────────────────────────
  /// URL de base du backend FastAPI.
  /// Modifier cette valeur pour pointer vers staging/production.
  static const String baseUrl = 'http://10.0.2.2:8000';

  // ─── Timeouts ──────────────────────────────────────────────────────────────
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 60000; // Plus long pour les uploads

  // ─── En-têtes ──────────────────────────────────────────────────────────────
  static const String contentType = 'application/json';
  static const String headerAuthorization = 'Authorization';
  static const String tokenPrefix = 'Bearer ';

  // ─── Clés de stockage sécurisé ─────────────────────────────────────────────
  static const String secureKeyToken = 'psycare_jwt_token';
  static const String secureKeyUser = 'psycare_current_user';

  // ─── Routes Auth ───────────────────────────────────────────────────────────
  static const String authLogin = '/api/auth/login';
  static const String authMe = '/api/auth/me';

  // ─── Routes Patients ───────────────────────────────────────────────────────
  static const String patients = '/api/patients';
  static String patient(int id) => '/api/patients/$id';
  static String patientParents(int id) => '/api/patients/$id/parents';
  static String patientStatut(int id) => '/api/patients/$id/statut';
  static String patientStatutHistorique(int id) =>
      '/api/patients/$id/statut-historique';
  static String patientStatutHistoriqueItem(int patientId, int itemId) =>
      '/api/patients/$patientId/statut-historique/$itemId';
  static String patientDossierMedical(int id) =>
      '/api/patients/$id/dossier-medical';
  static String patientNotes(int id) => '/api/patients/$id/notes';
  static String patientPlanningRecurrent(int id) =>
      '/api/patients/$id/planning-recurrent';
  static String patientPlanningRecurrentGenerer(int id) =>
      '/api/patients/$id/planning-recurrent/generer';
  static String patientPlansTherapeutiques(int id) =>
      '/api/patients/$id/plans-therapeutiques';

  // ─── Routes Parents ────────────────────────────────────────────────────────
  static const String parents = '/api/parents';
  static String parentById(int id) => '/api/parents/$id';

  // ─── Routes Notes ──────────────────────────────────────────────────────────
  static String noteById(int id) => '/api/notes/$id';

  // ─── Routes Groupes ────────────────────────────────────────────────────────
  static const String groupes = '/api/groupes';
  static String groupe(int id) => '/api/groupes/$id';
  static String groupePlanningRecurrent(int id) =>
      '/api/groupes/$id/planning-recurrent';
  static String groupePatients(int id) => '/api/groupes/$id/patients';

  // ─── Routes Séances individuelles ──────────────────────────────────────────
  static const String seances = '/api/seances';
  static String seance(int id) => '/api/seances/$id';

  // ─── Routes Séances de groupe ──────────────────────────────────────────────
  static const String seancesGroupe = '/api/seances-groupe';
  static String seanceGroupe(int id) => '/api/seances-groupe/$id';
  static String seanceGroupeParticipant(int seanceId, int patientId) =>
      '/api/seances-groupe/$seanceId/participants/$patientId';

  // ─── Routes Plans thérapeutiques ───────────────────────────────────────────
  static String planTherapeutique(int planId) =>
      '/api/plans-therapeutiques/$planId';
  static String planEtapes(int planId) =>
      '/api/plans-therapeutiques/$planId/etapes';
  static String planEtape(int planId, int etapeId) =>
      '/api/plans-therapeutiques/$planId/etapes/$etapeId';
  static String planEtapeCreerTache(int planId, int etapeId) =>
      '/api/plans-therapeutiques/$planId/etapes/$etapeId/creer-tache';

  // ─── Routes Tâches ─────────────────────────────────────────────────────────
  static const String taches = '/api/taches';
  static String tache(int id) => '/api/taches/$id';

  // ─── Routes Calendrier ─────────────────────────────────────────────────────
  static const String calendrier = '/api/calendrier';
  static String evenementCalendrier(int id) => '/api/calendrier/$id';

  // ─── Routes Employés ───────────────────────────────────────────────────────
  static const String employees = '/api/employees';
  static String employee(int id) => '/api/employees/$id';
  static String employeePatients(int id) => '/api/employees/$id/patients';

  // ─── Routes Upload ─────────────────────────────────────────────────────────
  static const String uploads = '/api/uploads';
}
