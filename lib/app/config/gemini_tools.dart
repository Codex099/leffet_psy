import 'package:google_generative_ai/google_generative_ai.dart';

/// Définit tous les outils (Function Calling) que Gemini peut invoquer
/// pour interagir directement avec le backend PsyCare.
class GeminiTools {
  GeminiTools._();

  // ── 1. Créer un patient ────────────────────────────────────────────────────
  static final creerPatient = FunctionDeclaration(
    'creer_patient',
    "Crée un nouveau dossier patient dans le système PsyCare. "
        "Demande TOUJOURS à l'utilisateur le nom, prénom, sexe et date de naissance "
        "avant d'appeler cet outil.",
    Schema.object(
      properties: {
        'nom': Schema.string(description: 'Nom de famille du patient'),
        'prenom': Schema.string(description: 'Prénom du patient'),
        'sexe': Schema.string(
          description: "Sexe du patient : 'masculin' ou 'feminin'",
          nullable: true,
        ),
        'date_naissance': Schema.string(
          description: 'Date de naissance au format YYYY-MM-DD',
          nullable: true,
        ),
        'nombre_freres_soeurs': Schema.integer(
          description: 'Nombre de frères et sœurs',
          nullable: true,
        ),
        'ordre_naissance': Schema.integer(
          description: "Ordre de naissance dans la fratrie",
          nullable: true,
        ),
      },
      requiredProperties: ['nom', 'prenom', 'sexe'],
    ),
  );

  // ── 2. Créer une tâche ─────────────────────────────────────────────────────
  static final creerTache = FunctionDeclaration(
    'creer_tache',
    "Crée une tâche clinique et l'assigne à un employé. "
        "Demande TOUJOURS la date d'échéance ET l'heure avant d'appeler cet outil.",
    Schema.object(
      properties: {
        'titre': Schema.string(description: 'Titre court et clair de la tâche'),
        'description': Schema.string(
          description: 'Description détaillée de la tâche',
          nullable: true,
        ),
        'assigne_a_nom': Schema.string(
          description: "Nom ou prénom de l'employé à qui assigner la tâche",
          nullable: true,
        ),
        'priorite': Schema.string(
          description: "Priorité : 'haute', 'normale' ou 'basse'",
          nullable: true,
        ),
        'date_echeance': Schema.string(
          description: "Date d'échéance au format YYYY-MM-DD",
        ),
        'heure_echeance': Schema.string(
          description: "Heure limite au format HH:MM (ex: 17:00)",
          nullable: true,
        ),
        'patient_id': Schema.string(
          description: "ID du patient lié à cette tâche (si applicable)",
          nullable: true,
        ),
      },
      requiredProperties: ['titre', 'priorite', 'date_echeance'],
    ),
  );

  // ── 3. Créer un plan thérapeutique ─────────────────────────────────────────
  static final creerPlanTherapeutique = FunctionDeclaration(
    'creer_plan_therapeutique',
    "Crée un plan thérapeutique avec ses étapes pour un patient. "
        "Un patient doit être sélectionné dans la conversation.",
    Schema.object(
      properties: {
        'patient_id': Schema.string(
          description: "ID du patient pour lequel créer le plan",
        ),
        'titre': Schema.string(
          description: 'Titre du plan thérapeutique',
        ),
        'etapes': Schema.array(
          items: Schema.object(
            properties: {
              'titre': Schema.string(description: "Titre de l'étape"),
              'description': Schema.string(
                description: "Description de l'étape",
                nullable: true,
              ),
              'ordre': Schema.integer(
                description: "Ordre de l'étape (1, 2, 3...)",
                nullable: true,
              ),
            },
            requiredProperties: ['titre'],
          ),
          description: 'Liste des étapes du plan',
        ),
      },
      requiredProperties: ['patient_id', 'titre', 'etapes'],
    ),
  );

  // ── 4. Obtenir les événements du calendrier ────────────────────────────────
  static final obtenirCalendrier = FunctionDeclaration(
    'obtenir_calendrier',
    "Récupère les événements et rendez-vous du calendrier PsyCare pour une période donnée.",
    Schema.object(
      properties: {
        'date_debut': Schema.string(
          description: "Date de début au format YYYY-MM-DD (défaut: aujourd'hui)",
          nullable: true,
        ),
        'date_fin': Schema.string(
          description:
              "Date de fin au format YYYY-MM-DD (défaut: dans 7 jours)",
          nullable: true,
        ),
      },
    ),
  );

  // ── 5. Obtenir les tâches des employés ─────────────────────────────────────
  static final obtenirTachesEmployes = FunctionDeclaration(
    'obtenir_taches_employes',
    "Récupère les tâches. Pour un employé, ne retourne que ses tâches assignées. Pour un admin, permet de suivre les tâches du cabinet.",
    Schema.object(
      properties: {
        'statut': Schema.string(
          description:
              "Filtre par statut : 'a_faire', 'en_cours', 'terminee'. Laisser vide pour tout.",
          nullable: true,
        ),
        'patient_id': Schema.string(
          description: "Filtrer les tâches d'un patient spécifique",
          nullable: true,
        ),
      },
    ),
  );

  // ── 6. Obtenir les séances (strictement isolé par praticien) ───────────────
  static final obtenirSeances = FunctionDeclaration(
    'obtenir_seances',
    "Récupère les séances de consultation ou de prise en charge pour une date donnée. "
        "Pour un praticien/employé, retourne strictement ses propres séances. "
        "Pour un administrateur, permet de voir l'ensemble des séances du cabinet.",
    Schema.object(
      properties: {
        'date': Schema.string(
          description:
              "Date des séances au format YYYY-MM-DD (défaut : aujourd'hui).",
          nullable: true,
        ),
      },
    ),
  );

  // ── 7. Créer / planifier une séance ────────────────────────────────────────
  static final creerSeance = FunctionDeclaration(
    'creer_seance',
    "Planifie une séance clinique individuelle pour un patient. "
        "Demande TOUJOURS la date, l'heure de début et l'heure de fin avant d'appeler cet outil. "
        "Si aucun patient n'est sélectionné, l'indiquer à l'utilisateur.",
    Schema.object(
      properties: {
        'date': Schema.string(
          description: "Date de la séance au format YYYY-MM-DD",
        ),
        'heure_debut': Schema.string(
          description: "Heure de début au format HH:MM (ex: 09:30)",
        ),
        'heure_fin': Schema.string(
          description: "Heure de fin au format HH:MM (ex: 10:30)",
        ),
        'patient_id': Schema.string(
          description: "ID du patient (optionnel si un patient est déjà actif)",
          nullable: true,
        ),
      },
      requiredProperties: ['date', 'heure_debut', 'heure_fin'],
    ),
  );

  // ── 8. Ajouter une note clinique au dossier patient ────────────────────────
  static final ajouterNotePatient = FunctionDeclaration(
    'ajouter_note_patient',
    "Ajoute une observation clinique ou une note de suivi dans le dossier du patient actif.",
    Schema.object(
      properties: {
        'contenu': Schema.string(
          description: "Contenu texte de la note clinique ou observation",
        ),
        'patient_id': Schema.string(
          description: "ID du patient (optionnel si un patient est déjà actif)",
          nullable: true,
        ),
      },
      requiredProperties: ['contenu'],
    ),
  );

  /// Outils réservés à l'Administrateur (gestion globale + création patient)
  static List<Tool> get adminTools => [
        Tool(functionDeclarations: [
          creerPatient,
          creerTache,
          creerPlanTherapeutique,
          obtenirCalendrier,
          obtenirTachesEmployes,
          obtenirSeances,
          creerSeance,
          ajouterNotePatient,
        ]),
      ];

  /// Outils autorisés aux Employés / Spécialistes (aucun accès à creerPatient,
  /// séances et tâches strictement limitées à leur propre compte).
  static List<Tool> get employeeTools => [
        Tool(functionDeclarations: [
          creerTache,
          creerPlanTherapeutique,
          obtenirCalendrier,
          obtenirTachesEmployes,
          obtenirSeances,
          creerSeance,
          ajouterNotePatient,
        ]),
      ];

  /// Liste complète (rétrocompatibilité)
  static List<Tool> get allTools => adminTools;
}
