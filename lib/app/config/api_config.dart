import 'package:flutter/foundation.dart';

/// Configuration centralisée de l'API backend PsyCare.
/// TOUTES les URLs et constantes réseau sont définies ici.
/// Aucune URL ne doit être codée en dur dans les services.
class ApiConfig {
 ApiConfig._();

  // ─── Base URL ──────────────────────────────────────────────────────────────
  /// URL publique ngrok pour la release et les tests distants
  static const String ngrokUrl = 'https://jawless-refill-paycheck.ngrok-free.dev';

  /// Surcharge optionnelle via: flutter run/build --dart-define=API_URL=...
  static const String _customBaseUrl = String.fromEnvironment('API_URL');

  /// URL de base du backend FastAPI.
  /// S'adapte automatiquement selon l'environnement :
  /// - Release (`flutter build apk --release`) → Ngrok : https://jawless-refill-paycheck.ngrok-free.dev
  /// - Debug Émulateur Android (AVD) → http://10.0.2.2:8000 (loopback vers l'hôte)
  /// - Debug Web / Desktop → http://127.0.0.1:8000 (localhost)
  /// - Surchargé par `--dart-define=API_URL=...` si spécifié
  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    // En mode release (ex: flutter build apk --split-per-abi --release)
    if (kReleaseMode) {
      return ngrokUrl;
    }
    // Pour tester sur un appareil physique Android, on utilise l'URL ngrok.
    // (Pour l'émulateur AVD, vous pouvez utiliser 'http://10.0.2.2:8000')
    if (defaultTargetPlatform == TargetPlatform.android) {
      return ngrokUrl;
    }
    // Web, Windows, macOS
    return 'http://127.0.0.1:8000';
  }

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
  static String patientParent(dynamic patientId, dynamic parentId) =>
      '/api/patients/$patientId/parents/$parentId';
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
  static String parentByPhone(String phone) => '/api/parents/by-phone/$phone';
  static String parentPatients(dynamic id) => '/api/parents/$id/patients';

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
  static String employeeVisibilitePatients(dynamic id) =>
      '/api/employees/$id/visibilite-patients';
  static const String employeesVisibiliteGlobale =
      '/api/employees/visibilite-globale';

  // ─── Routes Upload ─────────────────────────────────────────────────────────
  static const String uploads = '/api/uploads';

  // ─── Media Helpers ─────────────────────────────────────────────────────────
  /// Résout une URL de média relative (ex: "/uploads/image.jpg" ou "uploads\video.mp4")
  /// ou remplace l'hôte local (localhost/127.0.0.1/10.0.2.2/0.0.0.0) par la baseUrl active.
  static String resolveMediaUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    // Normalisation des séparateurs de chemins (Windows backslashes)
    final normalized = url.trim().replaceAll(r'\', '/');

    if (normalized.startsWith('blob:') || normalized.startsWith('data:')) {
      return normalized;
    }

    // Fichier local sur le terminal (ex: file://, C:/..., /data/..., /storage/...)
    if (normalized.startsWith('file://') ||
        RegExp(r'^[a-zA-Z]:\/').hasMatch(normalized) ||
        normalized.startsWith('/data/') ||
        normalized.startsWith('/storage/') ||
        normalized.startsWith('/private/')) {
      return normalized;
    }

    final uri = Uri.tryParse(normalized);
    if (uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final host = uri.host.toLowerCase();
      if (host == 'localhost' ||
          host == '127.0.0.1' ||
          host == '10.0.2.2' ||
          host == '0.0.0.0' ||
          host.isEmpty) {
        final cleanBase = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
        final pathAndQuery = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
        final cleanPath = pathAndQuery.startsWith('/') ? pathAndQuery : '/$pathAndQuery';
        return '$cleanBase$cleanPath';
      }
      return normalized;
    }

    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = normalized.startsWith('/') ? normalized : '/$normalized';
    return '$cleanBase$cleanPath';
  }

  /// Détermine si une URL ou un chemin pointe vers un fichier vidéo.
  static bool isVideoUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final clean = url.trim().toLowerCase().split('?').first;
    return clean.endsWith('.mp4') ||
        clean.endsWith('.mov') ||
        clean.endsWith('.avi') ||
        clean.endsWith('.mkv') ||
        clean.endsWith('.webm') ||
        clean.endsWith('.3gp') ||
        clean.endsWith('.m4v') ||
        clean.endsWith('.flv') ||
        clean.endsWith('.wmv') ||
        clean.endsWith('.ogv');
  }
}
