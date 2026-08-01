# Architecture Technique — PsyCare Mobile

Ce document décrit le choix des architectures, la structure des dossiers et les choix techniques effectués pour l'application mobile **PsyCare** (gestion de clinique de psychologie).

---

## 1. Architecture Générale (MVC / GetX)

L'application respecte scrupuleusement l'architecture **Model-View-Controller (MVC)** réactive basée sur **GetX** et **Dio** :

- **Backend-Driven Architecture** : L'application mobile ne contient **aucune logique métier lourde**. Toute la logique de calcul, de validation d'accès, d'attribution de rôle et de génération de planning est déportée sur l'API FastAPI backend.
- **State Management Réactif** : Utilisation des `RxString`, `RxList`, et `RxBool` avec les widgets `Obx()` pour une mise à jour instantanée de l'interface sans rebuild inutile.
- **Dependency Injection (Bindings)** : Injection paresseuse des contrôleurs (`Get.lazyPut()`) liée aux routes pour garantir un nettoyage automatique de la mémoire lorsqu'un écran est fermé.

---

## 2. Structure des Dossiers

```
lib/
├── app.dart                        # Configuration GetMaterialApp & Thème
├── main.dart                       # Point d'entrée de l'application
└── app/
    ├── bindings/                   # 21 Bindings GetX (injection de dépendances)
    ├── config/                     # Configuration centralisée (ApiConfig)
    ├── controllers/                # 22 Controllers GetX (gestion d'état & actions UI)
    ├── middlewares/                # AuthMiddleware (sécurité & vérification JWT)
    ├── models/                     # 9 Modèles de données (fromJson / toJson)
    ├── routes/                     # AppRoutes (constantes) & AppPages (GetPage config)
    ├── services/                   # 11 Services API Dio (40 routes d'API FastAPI)
    ├── theme/                      # Design System (AppColors, AppTextStyles, AppTheme)
    ├── views/                      # 19 Écrans fidèles aux maquettes réelles
    └── widgets/                    # Widgets communs réutilisables
```

---

## 3. Gestion de l'Authentification & Sécurité

1. **Stockage Sécurisé du Token JWT** :
   Utilisation de `flutter_secure_storage` avec l'option `AndroidOptions(encryptedSharedPreferences: true)` pour garantir le chiffrement AES natif du jeton d'accès sur Android et Keychain sur iOS.
2. **Interceptor Dio (`DioClient`)** :
   - Injection automatique de l'en-tête `Authorization: Bearer <token>` sur toutes les requêtes réseau.
   - Redirection automatique vers l'écran `/login` en cas d'erreur `401 Unauthorized`.
3. **Guard de Route (`AuthMiddleware`)** :
   Intercepte les navigations vers les routes protégées si l'utilisateur n'est pas authentifié.

---

## 4. Choix de Design & Graphisme

- **Palette de Couleurs** : Extraite directement de `palette_couleur.jpeg` :
  - `AppColors.primary` (`#064973`) : Bleu marine profond (Boutons principaux, headers, nav).
  - `AppColors.secondary` (`#76AABF`) : Bleu moyen (Badges, accents).
  - `AppColors.secondaryLight` (`#ACCCD9`) : Bleu très pâle (Fonds de cartes).
  - `AppColors.error` (`#D93735`) : Rouge/Corail (Destructif, alertes).
  - `AppColors.surface` (`#FFFFFF`) / `scaffold` (`#F7F7F7`).
- **Typographie** : `GoogleFonts.inter` avec une hiérarchie stricte (`screenTitle`, `sectionTitle`, `body`, `badge`, `dashboardNumber`).
- **Composants Réutilisables** :
  - `AppBottomNav` : Barre de navigation inférieure flottante style iOS.
  - `StatusBadge` : Badges colorés réutilisables (Assisté, Absent, En attente, Actif, Inactif).
  - `StatePlaceholder` : Composant unique pour les états `loading`, `empty` et `error`.
  - `MediaPickerWidget` : Sélection et upload immédiat de fichiers médias via `POST /api/uploads`.

---

## 5. Couverture des 40 Routes API

Tous les endpoints documentés dans la section 9 du PRD sont entièrement implémentés dans la couche `services/` :
- Auth (`/api/auth/login`, `/api/auth/me`)
- Patients & Dossier Médical (`/api/patients`, `/api/patients/{id}/dossier-medical`, `/api/patients/{id}/statut-historique`)
- Parents (`/api/parents`)
- Groupes & Planning fixe (`/api/groupes`, `/api/groupes/{id}/planning-recurrent`)
- Séances individuelles & Groupe (`/api/seances`, `/api/seances-groupe`)
- Plans Thérapeutiques (`/api/plans-therapeutiques`, conversion étape->tâche)
- Tâches (`/api/taches`)
- Calendrier administratif (`/api/calendrier`)
- Employés (`/api/employees`)
- Uploads (`/api/uploads`)

---

## 6. Choix et Décisions de Cohérence

1. **Génération manuelle/automatique du planning récurrent** : Le backend est l'unique responsable du calcul des créneaux. Le frontend envoie simplement une requête `POST /api/patients/{id}/planning-recurrent/generer`.
2. **Transition Cupertino** : `defaultTransition: Transition.cupertino` configuré dans `GetMaterialApp` pour assurer des transitions fluides iOS-like conformément au cahier des charges.
