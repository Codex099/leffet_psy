# PRD — Mobile : PsyCare (v2 — avec design system)

## 1. Contexte
PsyCare gère une clinique de psychologie : patients, séances individuelles/groupe, plans thérapeutiques, tâches et calendrier administratif. L'app mobile Flutter est utilisée par **tous les employés** (admin, psychologue, éducatrice) au quotidien — c'est le point d'entrée principal du système, le web étant réservé à l'admin pour la saisie lourde et l'impression.

**Ce PRD est autonome** : un agent qui ne lit QUE ce fichier + le dossier `design-assets/` doit pouvoir livrer l'app complète, sans contexte externe.

## 2. Objectif de cette partie
L'application mobile doit couvrir **100% des fonctionnalités exposées par le backend** (voir section 9 — mapping complet routes API → écran) :
- Authentification par rôle (admin / psychologue / éducatrice) et navigation adaptée.
- Patients : liste, fiche, création/édition, statut actif/inactif + historique + note de dégradation, dossier médical structuré, association parents.
- Séances individuelles : agenda, planning récurrent (auto/manuel), compte-rendu avec médias.
- Groupes : liste, détail, édition, planning fixe, séances de groupe, compte-rendu par participant.
- Plans thérapeutiques (multi-plans par patient) : étapes ordonnées, conversion étape → tâche.
- Tâches internes et calendrier administratif.
- Parents : liste, création, association aux patients avec rôle (père/mère/tuteur).
- Employés (admin uniquement) : liste, création, édition, assignation de patients.
- Notes patients libres, liées ou non à une séance.
- Profil employé et déconnexion.

Hors périmètre :
- Aucune logique métier lourde côté app : toute règle (accès, génération de créneaux, calculs) vit dans le backend. L'app affiche, collecte, envoie.
- Pas de saisie de fiche détaillée longue ni d'impression PDF — réservé au web admin.
- Pixel-perfect uniquement sur les écrans fournis en maquette (section 6) ; pour les autres, respecter le design system (section 5) sans figer un style différent.

## 3. Stack technique imposée
- Flutter
- GetX pour : state management, routing (GetPage), injection de dépendances (Get.put/Get.lazyPut)
- Communication API : `dio` (intercepteurs pour injecter le JWT et gérer les erreurs globalement)
- Backend consommé : API REST FastAPI décrite dans `PRD-backend-psycare.md` (voir section 9 pour le mapping détaillé)
- Stockage local du token : `flutter_secure_storage` (jamais en `SharedPreferences` en clair)
- Icônes/esthétique : style iOS natif — les maquettes suivent cette esthétique (cartes arrondies, gros titres, bottom nav flottante)

## 4. Structure de dossiers imposée
```
lib/
├── main.dart                  # point d'entrée, GetMaterialApp
├── app/
│   ├── routes/
│   │   ├── app_pages.dart     # déclaration des GetPage
│   │   └── app_routes.dart    # constantes de routes
│   ├── controllers/           # 1 controller GetX par écran/feature
│   │   └── [feature]_controller.dart
│   ├── views/                 # 1 dossier par écran, UI uniquement
│   │   └── [feature]/
│   │       └── [feature]_view.dart
│   ├── bindings/               # bindings GetX (injection controllers par route)
│   │   └── [feature]_binding.dart
│   ├── models/                 # modèles de données (fromJson/toJson)
│   │   └── [entite]_model.dart
│   ├── services/                # appels API, isolés de l'UI et des controllers
│   │   └── [entite]_service.dart
│   ├── middlewares/             # GetMiddleware : auth guard, role guard
│   │   └── auth_middleware.dart
│   ├── theme/                    # design system centralisé (section 5)
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── widgets/                  # composants réutilisables (cartes, boutons, chips de statut, avatar, state_placeholder)
├── assets/
│   ├── images/logo.png
│   └── design-reference/         # copie des 18 captures fournies, pour référence visuelle pendant le dev
├── ARCHITECTURE.md               # vue d'ensemble, généré et tenu à jour par l'agent
```

## 5. Design system (extrait des maquettes réelles)

Les fichiers sources sont dans `design-assets/` (18 écrans PNG + `logo.png` + `palette_couleur.jpeg`). **Analyse ces fichiers toi-même avant de coder** — les valeurs ci-dessous sont un point de départ fiable, vérifie-les contre les images.

### 5.1 Palette de couleurs (extraite par pixel-sampling de `palette_couleur.jpeg`)
| Rôle | Hex | Usage observé dans les maquettes |
|---|---|---|
| Primaire (bleu marine) | `#064973` | Headers, bottom nav bar (état actif), boutons principaux, titres de section |
| Secondaire (bleu moyen) | `#76AABF` | Icônes secondaires, éléments décoratifs, dégradés |
| Fond bleu très clair | `#ACCCD9` | Fonds de cartes/chips, séparateurs doux, arrière-plan de sections |
| Accent (rouge corail) | `#D93735` | Boutons destructifs/urgents, badges d'alerte, notifications, statut "inactif"/"annulé" |
| Accent pressed | `#A52929` | Variante foncée du rouge (état pressed/hover) |
| Fond général | `#FFFFFF` / `#F7F7F7` | Fond d'écran, cartes |
| Texte principal | `#2C2C2C` | Texte foncé quasi-noir, jamais de noir pur |

Centralise ces valeurs dans `app/theme/app_colors.dart`, aucune couleur en dur ailleurs dans le code.

### 5.2 Style visuel général (observé sur les 18 maquettes)
- Esthétique **iOS moderne** : coins très arrondis (cartes, boutons, champs), ombres douces et diffuses, gros titres en haut d'écran, listes en cartes empilées plutôt que lignes brutes de tableau.
- Bottom navigation bar fixe/flottante (icônes + labels courts), état actif en bleu marine `#064973`, état inactif en gris/bleu clair.
- Avatars patients/employés en cercle avec initiales ou photo.
- Badges de statut colorés (actif = bleu/vert, inactif = rouge corail, en attente = gris) — même système de badge sur tous les écrans, y compris ceux à simuler.
- Boutons d'action principale : pilule pleine bleu marine, texte blanc. Boutons secondaires : contour ou fond bleu très clair.
- Formulaires : champs à fond blanc/gris très clair, label au-dessus, coins arrondis ~12-16px.
- Utilise `logo.png` sur l'écran de login (à simuler), cohérent avec son usage sur `profil.png`.

### 5.3 Typographie
Reproduis la hiérarchie visible dans les maquettes : gros titre par écran (bold, ~22-28px), sous-titres de section (semi-bold, ~16-18px), corps de texte (regular, ~14px), labels de champs (medium, ~13px, couleur atténuée). Centralise dans `app_text_styles.dart`.

### 5.4 Règle stricte sur les données factices
**Les 18 écrans déjà maquettés contiennent des données de démonstration (fake data) déjà remplies dans les captures.** Ne reproduis jamais ces valeurs comme données par défaut codées en dur. Chaque champ pré-rempli dans la capture doit correspondre, dans le code final, à une donnée **dynamique venant de l'API** (ou vide/placeholder tant qu'aucune donnée n'est chargée). Reproduis uniquement la **structure visuelle** (layout, espacement, style des champs, hiérarchie), jamais le contenu texte en dur.

## 6. Écrans déjà maquettés (18) — à reproduire fidèlement

Fichiers disponibles dans `design-assets/`. Reproduis la mise en page, les composants, les couleurs et la hiérarchie visuelle **à l'identique**. N'invente pas de variante — en cas de doute sur un détail, reste cohérent avec le design system (section 5) plutôt que d'improviser un style différent.

| Fichier maquette | Écran | Notes |
|---|---|---|
| `accueil.png` | Dashboard / Accueil | Résumé du jour (séances, tâches), point d'entrée après login |
| `agenda.png` | Agenda | Séances individuelles + de groupe, vue chronologique |
| `calendrier_admin.png` | Calendrier administratif | Événements admin (`evenements_calendrier`), création réservée admin |
| `patients_liste.png` | Liste des patients | Filtrée selon les droits d'accès de l'employé connecté |
| `patient_info.png` | Fiche patient | Infos, statut, parents liés — hub vers dossier médical, plan thérapeutique, séances |
| `edit_patient.png` | Édition / création patient | Formulaire complet patient |
| `groupes_liste.png` | Liste des groupes | |
| `groupe_detail.png` | Détail groupe | Membres + séances liées |
| `edit_groupe.png` | Édition / création groupe | Inclut planning récurrent fixe |
| `parents_liste.png` | Liste des parents | |
| `employes_liste.png` | Liste des employés | Admin uniquement |
| `edit_employe.png` | Édition / création employé | Admin uniquement, inclut assignation patients |
| `compte_rendu_seance.png` | Compte-rendu séance individuelle | Statut présence, description état, médias |
| `compte_rendu_groupe.png` | Compte-rendu séance de groupe | Par participant |
| `plan_therapeutique.png` | Plan thérapeutique | Étapes ordonnées, conversion en tâche |
| `planning_recurrent.png` | Planning récurrent patient | Mode auto/manuel, jours de la semaine |
| `taches.png` | Liste des tâches | |
| `profil.png` | Profil employé | Infos + déconnexion |

## 7. Écrans à simuler (non fournis) — à créer dans la continuité stricte du design system

Ces écrans n'ont **aucune maquette fournie**. Conçois-les en réutilisant exactement les mêmes composants, couleurs, espacements et styles de champs que les 18 écrans ci-dessus, pour qu'un utilisateur ne puisse pas deviner qu'ils n'ont pas été maquettés à part.

1. **Login** — champ username, champ password, bouton pilule bleu marine, `logo.png` centré en haut, fond clair. Pas de "mot de passe oublié" (JWT simple, pas de flow de reset côté backend).
2. **Dossier médical patient** (fiche clinique structurée) — accessible depuis `patient_info`. Style "formulaire en cartes" de `edit_patient.png`. Champs (détail en 9.1) : antécédents médicaux, médicaments pris, date de la case, naissance, développement psychomoteur, comportement auditif, développement langagier, adaptation sociale, autonomie, aspect sanitaire, stade de scolarisation — zones de texte multi-ligne, méta "mis à jour par / le [date]" en pied de section. Accès lecture/écriture uniquement si l'employé a un accès médical au patient (403 backend = message clair).
3. **Historique de statut patient** (actif/inactif) — accessible depuis `patient_info`. Timeline verticale, badge coloré par statut (actif = bleu, inactif = rouge corail), et pour chaque réactivation un champ optionnel "note de dégradation" éditable par le psychologue assigné + admin.
4. **Activation/désactivation patient** — bottom sheet ou modal depuis `patient_info`, toggle actif/inactif + confirmation.
5. **Ajout / édition parent** — formulaire (nom, prénom, téléphone, état civil, adresse) style `edit_patient.png`, accessible depuis `parents_liste.png` et depuis la fiche patient (association avec rôle père/mère/tuteur).
6. **Notes patient** — liste chronologique (timeline) avec médias attachés, accessible depuis `patient_info`, ajout en bottom sheet (contenu texte + médias).
7. **Détail tâche** — depuis `taches.png`, titre/description/priorité/échéance/statut, changement de statut possible, style carte.
8. **Création manuelle de séance individuelle / de groupe** — formulaire (patient ou groupe, date, heure début/fin) style `edit_patient.png` / `edit_groupe.png`.
9. **États vides / erreur / chargement** — composant réutilisable unique (`widgets/state_placeholder.dart`) pour loading (spinner bleu marine), erreur (icône + message + bouton réessayer), vide (icône légère + message), utilisé sur tous les écrans de la section 9.

## 8. Instructions pour l'agent
- Respecte strictement le pattern GetX : la UI (`views/`) ne contient aucune logique, uniquement de l'affichage réactif (`Obx`/`GetX`) piloté par le `controller`. Les appels réseau vivent dans `services/`, jamais directement dans les controllers ou les views.
- Un binding par route pour instancier les controllers via `Get.lazyPut`, pas d'instanciation manuelle dispersée.
- Crée `ARCHITECTURE.md` à la racine dès l'initialisation du projet, avec l'arborescence complète et une ligne de description par fichier/dossier important. Mets-le à jour à chaque changement structurel.
- Gère les états de chargement/erreur/vide de façon cohérente sur tous les écrans (variable `RxStatus` ou équivalent : loading / success / error / empty), affichés via le composant unique de la section 7.9.
- Centralise les URLs et constantes API dans un seul fichier de config (`app/config/api_config.dart`), jamais en dur dans les services.
- Le token JWT est injecté automatiquement via un intercepteur `dio` ; toute réponse 401 déclenche une déconnexion automatique et redirection vers login.
- Utilise un `GetMiddleware` (`auth_middleware.dart`) pour protéger toutes les routes sauf `/login` ; contrôle de rôle sur les routes réservées à l'admin (gestion employés, création calendrier admin, édition de groupe, suppression de plan thérapeutique).
- Centralise le design system dans `app/theme/` (section 5) : jamais de couleur, taille de police ou rayon de bordure codé en dur dans un widget.
- Les champs `medias` (upload photo/vidéo) utilisent `POST /api/uploads` ; uploader le fichier avant de soumettre le formulaire parent, puis n'envoyer que l'URL retournée.
- Le masquage des actions non autorisées se fait côté UI selon le rôle, mais la vérification définitive reste toujours côté backend (403 géré proprement, pas de crash).
- N'invente aucune règle métier (calculs, permissions fines, génération de créneaux) : tout vit dans le backend, l'app appelle l'API et affiche le résultat.

## 9. Mapping complet fonctionnalités backend → écran mobile

### 9.1 Patients & dossier médical
| Fonction backend (route) | Écran(s) mobile | Rôle requis |
|---|---|---|
| `GET /api/patients?actif=` | `patients_liste` | Tous (filtré accès) |
| `POST /api/patients` | `edit_patient` (création) | Admin + psy/éduc. assignée |
| `GET/PUT/DELETE /api/patients/{id}` | `patient_info`, `edit_patient` | Filtré accès |
| `POST /api/patients/{id}/parents` | Écran "Ajout/édition parent" (7.5), depuis `patient_info` | Admin + assigné |
| `PUT /api/patients/{id}/statut` | Écran "Activation/désactivation" (7.4) | Psy assigné + admin |
| `GET /api/patients/{id}/statut-historique` | Écran "Historique de statut" (7.3) | Accès patient requis |
| `PUT /api/patients/{id}/statut-historique/{id}` | Écran "Historique de statut" — édition note_degradation | Psy assigné + admin |
| `GET/PUT /api/patients/{id}/dossier-medical` | Écran "Dossier médical" (7.2) | Accès médical requis |

Champs du dossier médical (labels français uniquement dans l'UI) :
`antecedents_medicaux`, `medicaments_pris`, `date_cas`, `naissance`, `developpement_psychomoteur`, `comportement_auditif`, `developpement_langagier`, `adaptation_sociale`, `autonomie`, `aspect_sanitaire`, `stade_scolarisation`, plus méta lecture seule `mis_a_jour_par` / `date_maj`.

### 9.2 Parents
| Fonction backend | Écran(s) mobile |
|---|---|
| `GET/POST /api/parents` | `parents_liste`, écran "Ajout/édition parent" |
| `GET/PUT/DELETE /api/parents/{id}` | Écran "Ajout/édition parent" (admin) |

### 9.3 Groupes
| Fonction backend | Écran(s) mobile |
|---|---|
| `GET/POST /api/groupes` | `groupes_liste`, `edit_groupe` |
| `GET/PUT/DELETE /api/groupes/{id}` | `groupe_detail`, `edit_groupe` |
| `POST /api/groupes/{id}/planning-recurrent` | `edit_groupe` |
| `POST /api/groupes/{id}/patients` | `groupe_detail` (ajout membre) |

### 9.4 Séances individuelles & planning récurrent
| Fonction backend | Écran(s) mobile |
|---|---|
| `GET/POST /api/seances` | `agenda`, écran "Création séance" (7.8) |
| `GET/PUT/DELETE /api/seances/{id}` | `compte_rendu_seance` |
| `GET/POST /api/patients/{id}/planning-recurrent` | `planning_recurrent` |
| `POST .../planning-recurrent/generer` | `planning_recurrent` (bouton génération manuelle) |

### 9.5 Séances de groupe
| Fonction backend | Écran(s) mobile |
|---|---|
| `GET/POST /api/seances-groupe` | `agenda`, `groupe_detail` |
| `GET/PUT/DELETE /api/seances-groupe/{id}` | `compte_rendu_groupe` |
| `PUT /api/seances-groupe/{id}/participants/{patient_id}` | `compte_rendu_groupe` |

### 9.6 Plans thérapeutiques
| Fonction backend | Écran(s) mobile |
|---|---|
| `GET/POST /api/patients/{id}/plans-therapeutiques` | `plan_therapeutique` |
| `GET/PUT/DELETE /api/plans-therapeutiques/{plan_id}` | `plan_therapeutique` |
| `POST/PUT/DELETE .../etapes` | `plan_therapeutique` |
| `POST .../etapes/{etape_id}/creer-tache` | `plan_therapeutique` (action "convertir en tâche") |

### 9.7 Tâches & calendrier
| Fonction backend | Écran(s) mobile |
|---|---|
| `GET/POST/PUT/DELETE /api/taches` | `taches`, écran "Détail tâche" (7.7) |
| `GET/POST/PUT/DELETE /api/calendrier` | `calendrier_admin` |

### 9.8 Employés & auth
| Fonction backend | Écran(s) mobile |
|---|---|
| `POST /api/auth/login` | Écran "Login" (7.1) |
| `GET /api/auth/me` | `accueil`, `profil` |
| `GET/POST /api/employees` | `employes_liste`, `edit_employe` (admin) |
| `GET/PUT/DELETE /api/employees/{id}` | `edit_employe` (admin) |
| `POST /api/employees/{id}/patients` | `edit_employe` (assignation patients) |

### 9.9 Notes patients & médias
| Fonction backend | Écran(s) mobile |
|---|---|
| `GET/POST /api/patients/{id}/notes` | Écran "Notes patient" (7.6) |
| `DELETE /api/notes/{id}` | Écran "Notes patient" (auteur ou admin) |
| `POST /api/uploads` | Tout écran avec champ `medias` (comptes-rendus, notes) |

## 10. Modèles de données (Dart)

Chaque modèle implémente `fromJson`/`toJson`, aligné sur le schéma backend :

- `PatientModel` : id, nom, prenom, dateNaissance, photo, nombreFreresSoeurs, ordreNaissance, estActif, dateDesactivation, dateReactivation
- `ParentModel` : id, nom, prenom, telephone, etatCivil, adresse
- `PatientParentModel` : patientId, parentId, role
- `PatientStatutHistoriqueModel` : id, patientId, statut, dateChangement, changePar, noteDegradation
- `DossierMedicalModel` : id, patientId, antecedentsMedicaux, medicamentsPris, dateCas, naissance, developpementPsychomoteur, comportementAuditif, developpementLangagier, adaptationSociale, autonomie, aspectSanitaire, stadeScolarisation, misAJourPar, dateMaj
- `EmployeeModel` : id, nom, prenom, telephone, username, role
- `GroupeModel` : id, nom, typePlanning, description
- `GroupePlanningRecurrentModel` : id, groupeId, jourSemaine, heureDebut, heureFin
- `SeanceModel` : id, patientId, employeIds (liste), date, heureDebut, heureFin, statut, motifStatut, statutPresence, descriptionEtat, reponsesQuestionnaire, medias
- `PatientPlanningRecurrentModel` : id, patientId, joursSemaine, heureDebut, heureFin, dateDebut, dateFin, employeId, modeGeneration, horizonJours
- `SeanceGroupeModel` : id, groupeId, employeId, date, heureDebut, heureFin, statut
- `SeanceGroupeParticipantModel` : seanceGroupeId, patientId, statutPresence, descriptionEtat, reponsesQuestionnaire, redigePar, medias
- `TacheModel` : id, titre, description, assigneA, creePar, patientId, etapePlanId, statut, priorite, dateEcheance
- `EvenementCalendrierModel` : id, titre, description, date, notifierAvantJours, creePar
- `PlanTherapeutiqueModel` : id, patientId, titre, statut, dateDebut, dateFin, creePar
- `EtapePlanTherapeutiqueModel` : id, planId, titre, description, statut, ordre, creePar
- `NotePatientModel` : id, patientId, employeId, seanceId, seanceGroupeId, contenu, medias, dateCreation

## 11. Règles de navigation par rôle
- **Admin** : accès à tous les écrans, y compris gestion employés, édition de groupes, création calendrier admin, suppression de plans thérapeutiques.
- **Psychologue** : accès aux patients assignés, séances associées, plan thérapeutique et dossier médical des patients assignés, tâches, calendrier (lecture), agenda. Pas d'accès à la gestion des employés.
- **Éducatrice** : mêmes accès que psychologue sauf plan thérapeutique et dossier médical, réservés en écriture au psychologue assigné + admin — écran visible en lecture seule ou masqué selon les 403 backend.
- Le masquage des actions non autorisées se fait autant que possible côté UI, la vérification définitive reste côté backend.

## 12. Critères de complétion
- [ ] Les 18 écrans maquettés sont reproduits fidèlement (layout, couleurs, composants) — aucune donnée de démo codée en dur
- [ ] Les écrans simulés (section 7) sont cohérents visuellement avec les 18 maquettés, indiscernables au style
- [ ] Design system centralisé (`app/theme/`), aucune couleur/police en dur ailleurs
- [ ] Tous les écrans sont navigables via GetX routing
- [ ] ARCHITECTURE.md créé et à jour
- [ ] Gestion des erreurs réseau/API (loading / error / empty / success) sur chaque écran, via composant unique
- [ ] Séparation stricte view/controller/service respectée
- [ ] Configuration API centralisée et modifiable facilement
- [ ] Auth JWT fonctionnelle avec déconnexion automatique sur 401
- [ ] Navigation adaptée selon le rôle de l'employé connecté (section 11)
- [ ] Upload de médias fonctionnel sur comptes-rendus et notes
- [ ] Statut actif/inactif du patient géré avec historique et note de dégradation
- [ ] Dossier médical structuré consultable/éditable selon droits d'accès
- [ ] 100% des routes listées en section 9 sont consommées par au moins un écran
