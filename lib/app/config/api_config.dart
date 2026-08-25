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
  static const int connectTimeoutMs = 20000;
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
  static String patient(dynamic id) => '/api/patients/$id';
  static String patientParents(dynamic id) => '/api/patients/$id/parents';
  static String patientStatut(dynamic id) => '/api/patients/$id/statut';
  static String patientStatutHistorique(dynamic id) =>
      '/api/patients/$id/statut-historique';
  static String patientStatutHistoriqueItem(dynamic patientId, dynamic itemId) =>
      '/api/patients/$patientId/statut-historique/$itemId';
  static String patientDossierMedical(dynamic id) =>
      '/api/patients/$id/dossier-medical';
  static String patientNotes(dynamic id) => '/api/patients/$id/notes';
  static String patientPlanningRecurrent(dynamic id) =>
      '/api/patients/$id/planning-recurrent';
  static String patientPlanningRecurrentGenerer(dynamic id) =>
      '/api/patients/$id/planning-recurrent/generer';
  static String patientPlansTherapeutiques(dynamic id) =>
      '/api/patients/$id/plans-therapeutiques';

  // ─── Routes Parents ────────────────────────────────────────────────────────
  static const String parents = '/api/parents';
  static String parentById(dynamic id) => '/api/parents/$id';

  // ─── Routes Notes ──────────────────────────────────────────────────────────
  static String noteById(dynamic id) => '/api/notes/$id';

  // ─── Routes Groupes ────────────────────────────────────────────────────────
  static const String groupes = '/api/groupes';
  static String groupe(dynamic id) => '/api/groupes/$id';
  static String groupePlanningRecurrent(dynamic id) =>
      '/api/groupes/$id/planning-recurrent';
  static String groupePatients(dynamic id) => '/api/groupes/$id/patients';

  // ─── Routes Séances individuelles ──────────────────────────────────────────
  static const String seances = '/api/seances';
  static String seance(dynamic id) => '/api/seances/$id';

  // ─── Routes Séances de groupe ──────────────────────────────────────────────
  static const String seancesGroupe = '/api/seances-groupe';
  static String seanceGroupe(dynamic id) => '/api/seances-groupe/$id';
  static String seanceGroupeParticipant(dynamic seanceId, dynamic patientId) =>
      '/api/seances-groupe/$seanceId/participants/$patientId';

  // ─── Routes Plans thérapeutiques ───────────────────────────────────────────
  static String planTherapeutique(dynamic planId) =>
      '/api/plans-therapeutiques/$planId';
  static String planEtapes(dynamic planId) =>
      '/api/plans-therapeutiques/$planId/etapes';
  static String planEtape(dynamic planId, dynamic etapeId) =>
      '/api/plans-therapeutiques/$planId/etapes/$etapeId';
  static String planEtapeCreerTache(dynamic planId, dynamic etapeId) =>
      '/api/plans-therapeutiques/$planId/etapes/$etapeId/creer-tache';

  // ─── Routes Tâches ─────────────────────────────────────────────────────────
  static const String taches = '/api/taches';
  static String tache(dynamic id) => '/api/taches/$id';

  // ─── Routes Calendrier ─────────────────────────────────────────────────────
  static const String calendrier = '/api/calendrier';
  static String evenementCalendrier(dynamic id) => '/api/calendrier/$id';

  // ─── Routes Employés ───────────────────────────────────────────────────────
  static const String employees = '/api/employees';
  static String employee(dynamic id) => '/api/employees/$id';
  static String employeePatients(dynamic id) => '/api/employees/$id/patients';

  // ─── Routes Upload ─────────────────────────────────────────────────────────
  static const String uploads = '/api/uploads';
}
