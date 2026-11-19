import 'package:google_generative_ai/google_generative_ai.dart';

/// Définit tous les outils (Function Calling) que Gemini peut invoquer
/// pour interagir directement avec le système PsyCare.
///
/// Chaque outil dispose d'une description détaillée indiquant sa finalité,
/// ses règles d'usage et les formats attendus pour chaque paramètre.
class GeminiTools {
  GeminiTools._();

  // ── 1. Créer un patient (Admin uniquement) ──────────────────────────────────
  static final creerPatient = FunctionDeclaration(
    'creer_patient',
    "Crée un nouveau dossier patient dans le système PsyCare. "
    "À utiliser uniquement lorsque l'utilisateur demande explicitement d'enregistrer un nouveau patient. "
    "Demande TOUJOURS au préalable à l'utilisateur le nom, prénom et sexe s'ils ne sont pas fournis.",
    Schema.object(
      properties: {
        'nom': Schema.string(
          description: "Nom de famille officiel du patient (ex: 'Benali', 'Dupont')",
        ),
        'prenom': Schema.string(
          description: "Prénom du patient (ex: 'Youssef', 'Sarah')",
        ),
        'sexe': Schema.string(
          description: "Sexe biologique du patient : uniquement 'masculin' ou 'feminin'",
          nullable: true,
        ),
        'date_naissance': Schema.string(
          description: "Date de naissance exacte au format ISO YYYY-MM-DD (ex: '2016-04-12')",
          nullable: true,
        ),
        'telephone': Schema.string(
          description: "Numéro de téléphone de contact du patient ou des parents",
          nullable: true,
        ),
        'nombre_freres_soeurs': Schema.integer(
          description: "Nombre de frères et sœurs du patient dans la fratrie",
          nullable: true,
        ),
        'ordre_naissance': Schema.integer(
          description: "Position de l'enfant dans la fratrie (1 pour l'aîné, 2 pour le second, etc.)",
          nullable: true,
        ),
      },
      requiredProperties: ['nom', 'prenom', 'sexe'],
    ),
  );

  // ── 2. Créer une tâche clinique ou administrative ──────────────────────────
  static final creerTache = FunctionDeclaration(
    'creer_tache',
    "Crée une tâche clinique ou administrative et l'assigne à un professionnel de l'équipe PsyCare. "
    "À utiliser pour planifier une action à faire, un bilan à rédiger, ou une relance parent. "
    "Exige impérativement une date d'échéance au format YYYY-MM-DD.",
    Schema.object(
      properties: {
        'titre': Schema.string(
          description: "Intitulé concis et explicite de la tâche (ex: 'Rédiger bilan sensoriel', 'Contacter les parents')",
        ),
        'description': Schema.string(
          description: "Description détaillée des instructions ou consignes pour réaliser la tâche",
          nullable: true,
        ),
        'assigne_a_nom': Schema.string(
          description: "Nom ou prénom du collaborateur à qui assigner la tâche (ex: 'Amina', 'Karim'). Si omis, la tâche reste non assignée.",
          nullable: true,
        ),
        'priorite': Schema.string(
          description: "Niveau de priorité clinique : 'haute', 'normale' ou 'basse' (défaut: 'normale')",
          nullable: true,
        ),
        'date_echeance': Schema.string(
          description: "Date limite impérative d'exécution au format ISO YYYY-MM-DD (ex: '2026-11-25')",
        ),
        'heure_echeance': Schema.string(
          description: "Heure limite d'exécution au format HH:MM (ex: '17:00', '11:30')",
          nullable: true,
        ),
        'patient_id': Schema.string(
          description: "Identifiant du patient concerné par cette tâche (optionnel si un dossier patient est déjà actif)",
          nullable: true,
        ),
      },
      requiredProperties: ['titre', 'date_echeance'],
    ),
  );

  // ── 3. Créer un plan thérapeutique à 3 niveaux ─────────────────────────────
  static final creerPlanTherapeutique = FunctionDeclaration(
    'creer_plan_therapeutique',
    "Crée un plan thérapeutique complet structuré en 3 niveaux : "
    "1. Plan global (titre et spécialiste référent). "
    "2. Étapes (phases ou axes thérapeutiques majeurs). "
    "3. Sous-étapes / Séances (séances concrètes avec le détail de ce qu'on doit faire dans chaque séance). "
    "À utiliser lorsque le praticien demande de concevoir, structurer ou enregistrer un protocole de prise en charge pour un patient.",
    Schema.object(
      properties: {
        'patient_id': Schema.string(
          description: "Identifiant du patient concerné (optionnel si un dossier patient est déjà actif en contexte)",
          nullable: true,
        ),
        'titre': Schema.string(
          description: "Intitulé global du plan (ex: 'Plan de remédiation cognitive', 'Protocole orthophonique langage oral')",
        ),
        'assigne_a_nom': Schema.string(
          description: "Nom ou prénom du spécialiste référent principal du plan (ex: 'Dr. Benali', 'Amina')",
          nullable: true,
        ),
        'etapes': Schema.array(
          items: Schema.object(
            properties: {
              'titre': Schema.string(
                description: "Titre de la phase ou de l'étape clinique (ex: 'Phase 1 : Attention soutenue', 'Phase 2 : Fonctions exécutives')",
              ),
              'description': Schema.string(
                description: "Objectifs cliniques visés par cette étape",
                nullable: true,
              ),
              'ordre': Schema.integer(
                description: "Ordre chronologique de l'étape (1, 2, 3...)",
                nullable: true,
              ),
              'assigne_a_nom': Schema.string(
                description: "Nom ou prénom du spécialiste dédié à cette étape spécifique (optionnel, hérite du plan si omis)",
                nullable: true,
              ),
              'sous_etapes': Schema.array(
                items: Schema.object(
                  properties: {
                    'titre': Schema.string(
                      description: "Titre de la séance (ex: 'Séance 1 : Bilan attentionnel', 'Séance 2 : Exercices de flexibilité')",
                    ),
                    'description': Schema.string(
                      description: "DÉROULEMENT PRÉCIS : ce que le praticien doit faire lors de cette séance (exercices, consignes, matériel, activités)",
                    ),
                    'ordre': Schema.integer(
                      description: "Numéro ou ordre de la séance (1, 2, 3...)",
                      nullable: true,
                    ),
                    'assigne_a_nom': Schema.string(
                      description: "Nom ou prénom du spécialiste en charge de cette séance précise (optionnel)",
                      nullable: true,
                    ),
                  },
                  requiredProperties: ['titre', 'description'],
                ),
                description: "Liste des séances (sous-étapes) détaillant ce qu'il faut faire dans chaque séance",
                nullable: true,
              ),
            },
            requiredProperties: ['titre'],
          ),
          description: "Liste ordonnée des étapes constituant le plan thérapeutique",
        ),
      },
      requiredProperties: ['titre', 'etapes'],
    ),
  );

  // ── 4. Obtenir les plans thérapeutiques existants d'un patient ───────────────
  static final obtenirPlansTherapeutiques = FunctionDeclaration(
    'obtenir_plans_therapeutiques',
    "Consulte et récupère l'ensemble des plans thérapeutiques du patient sélectionné avec leurs étapes, "
    "leurs séances (sous-étapes avec déroulement), leur progression et les spécialistes assignés. "
    "À utiliser dès que l'utilisateur demande où en est le plan, quelles séances sont prévues, ou l'historique thérapeutique.",
    Schema.object(
      properties: {
        'patient_id': Schema.string(
          description: "ID du patient dont on souhaite consulter les plans (optionnel si un dossier patient est déjà actif)",
          nullable: true,
        ),
      },
    ),
  );

  // ── 5. Ajouter une séance (sous-étape) à une étape de plan existante ─────────
  static final ajouterSeanceAuPlan = FunctionDeclaration(
    'ajouter_seance_au_plan',
    "Ajoute une nouvelle séance (sous-étape) avec ses consignes d'exercices à une étape d'un plan thérapeutique existant.",
    Schema.object(
      properties: {
        'plan_id': Schema.string(
          description: "ID du plan thérapeutique existant",
        ),
        'etape_id': Schema.string(
          description: "ID de l'étape à laquelle rattacher cette nouvelle séance",
        ),
        'titre': Schema.string(
          description: "Titre de la séance (ex: 'Séance 3 : Renforcement de la mémoire de travail')",
        ),
        'description': Schema.string(
          description: "Détail de ce qui doit être fait lors de la séance (exercices, protocoles, consignes)",
        ),
        'assigne_a_nom': Schema.string(
          description: "Nom ou prénom du spécialiste auquel assigner cette séance spécifique (optionnel)",
          nullable: true,
        ),
      },
      requiredProperties: ['plan_id', 'etape_id', 'titre', 'description'],
    ),
  );

  // ── 6. Obtenir les événements du calendrier ────────────────────────────────
  static final obtenirCalendrier = FunctionDeclaration(
    'obtenir_calendrier',
    "Consulte les événements, réunions, ateliers et rendez-vous du calendrier PsyCare pour une période temporelle. "
    "À utiliser pour vérifier les disponibilités, les conflits d'horaires ou les plannings généraux.",
    Schema.object(
      properties: {
        'date_debut': Schema.string(
          description: "Date de début de recherche au format YYYY-MM-DD (défaut: date du jour)",
          nullable: true,
        ),
        'date_fin': Schema.string(
          description: "Date de fin de recherche au format YYYY-MM-DD (défaut: 7 jours après la date de début)",
          nullable: true,
        ),
      },
    ),
  );

  // ── 7. Obtenir les tâches des employés ─────────────────────────────────────
  static final obtenirTachesEmployes = FunctionDeclaration(
    'obtenir_taches_employes',
    "Consulte la liste des tâches à accomplir. "
    "Pour un praticien, ne retourne que ses tâches personnelles assignées. "
    "Pour un administrateur, permet de suivre l'ensemble des tâches du cabinet.",
    Schema.object(
      properties: {
        'statut': Schema.string(
          description: "Filtre par statut de tâche : 'a_faire', 'en_cours', 'terminee' ou laisser vide pour toutes les tâches actives",
          nullable: true,
        ),
        'patient_id': Schema.string(
          description: "Filtrer uniquement les tâches liées à un patient spécifique",
          nullable: true,
        ),
      },
    ),
  );

  // ── 8. Obtenir les séances de consultation (planning clinique) ─────────────
  static final obtenirSeances = FunctionDeclaration(
    'obtenir_seances',
    "Récupère les séances de consultation individuelles pour une date ou un patient donné. "
    "Permet de savoir quelles séances sont programmées, passées, annulées ou en attente. "
    "Pour un praticien, respecte strictement la confidentialité en ne retournant que ses séances.",
    Schema.object(
      properties: {
        'date': Schema.string(
          description: "Date cible des séances au format ISO YYYY-MM-DD (ex: '2026-11-20'). Laisser vide pour aujourd'hui.",
          nullable: true,
        ),
        'patient_id': Schema.string(
          description: "ID du patient pour filtrer ses séances spécifiques",
          nullable: true,
        ),
      },
    ),
  );

  // ── 9. Créer / planifier une séance individuelle ───────────────────────────
  static final creerSeance = FunctionDeclaration(
    'creer_seance',
    "Planifie une séance clinique individuelle pour un patient dans le planning. "
    "Demande TOUJOURS la date (YYYY-MM-DD), l'heure de début (HH:MM) et l'heure de fin (HH:MM) avant d'exécuter. "
    "Nécessite qu'un patient soit actif dans la discussion ou fourni en paramètre.",
    Schema.object(
      properties: {
        'date': Schema.string(
          description: "Date de la séance au format ISO YYYY-MM-DD (ex: '2026-11-25')",
        ),
        'heure_debut': Schema.string(
          description: "Heure de début au format HH:MM (ex: '09:00', '14:30')",
        ),
        'heure_fin': Schema.string(
          description: "Heure de fin au format HH:MM (ex: '10:00', '15:30')",
        ),
        'patient_id': Schema.string(
          description: "Identifiant du patient (optionnel si le patient est déjà actif dans la conversation)",
          nullable: true,
        ),
        'assigne_a_nom': Schema.string(
          description: "Nom ou prénom du praticien en charge de la séance (ex: 'Amina', 'Karim'). Défaut: praticien connecté.",
          nullable: true,
        ),
      },
      requiredProperties: ['date', 'heure_debut', 'heure_fin'],
    ),
  );

  // ── 10. Ajouter une note clinique au dossier patient ───────────────────────
  static final ajouterNotePatient = FunctionDeclaration(
    'ajouter_note_patient',
    "Consigne une observation clinique, un compte-rendu ou une note d'évolution dans le dossier du patient actif. "
    "À utiliser lorsque le praticien partage des observations de séance ou souhaite enrichir le dossier médical.",
    Schema.object(
      properties: {
        'contenu': Schema.string(
          description: "Texte complet de la note clinique rédigée de manière professionnelle et bienveillante",
        ),
        'patient_id': Schema.string(
          description: "Identifiant du patient (optionnel si le dossier est déjà actif en contexte)",
          nullable: true,
        ),
      },
      requiredProperties: ['contenu'],
    ),
  );

  /// Outils réservés à l'Administrateur (gestion globale + création de patient)
  static List<Tool> get adminTools => [
        Tool(functionDeclarations: [
          creerPatient,
          creerTache,
          creerPlanTherapeutique,
          obtenirPlansTherapeutiques,
          ajouterSeanceAuPlan,
          obtenirCalendrier,
          obtenirTachesEmployes,
          obtenirSeances,
          creerSeance,
          ajouterNotePatient,
        ]),
      ];

  /// Outils autorisés aux Employés / Spécialistes (séances et tâches isolées selon leur compte,
  /// pas de création de patient).
  static List<Tool> get employeeTools => [
        Tool(functionDeclarations: [
          creerTache,
          creerPlanTherapeutique,
          obtenirPlansTherapeutiques,
          ajouterSeanceAuPlan,
          obtenirCalendrier,
          obtenirTachesEmployes,
          obtenirSeances,
          creerSeance,
          ajouterNotePatient,
        ]),
      ];

  /// Liste complète
  static List<Tool> get allTools => adminTools;
}
