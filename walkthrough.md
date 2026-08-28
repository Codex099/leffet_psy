# Optimisation Haute Performance & Mise en Cache Pro-Dev PsyCare

## 🚀 Vue d'Ensemble des Optimisations Réalisées

Une architecture de **mise en cache en mémoire à latence nulle (0ms)** et des **astuces de développement professionnel (Pro Dev)** ont été déployées sur l'intégralité de l'application (29 pages et leurs contrôleurs).

---

## 🏗️ 1. Architecture de Cache Centralisé (`AppCacheManager`)

- **Fichier** : [`cache_manager.dart`](file:///c:/Users/hafid/Desktop/myAPPS/projet%20freelance/psy/leffet_psy/lib/app/services/cache_manager.dart)
- **Modèle SWR (Stale-While-Revalidate)** : Retourne immédiatement la donnée présente en mémoire pour un affichage instantané (**0ms**) tout en rafraîchissant les données de manière transparente en arrière-plan si le TTL est expiré.
- **TTL Personnalisés par Domaine** :
  - `Agenda` & `Dashboard` : 2 minutes (synchronisation temps réel des rendez-vous)
  - `Tâches` : 3 minutes
  - `Patients` & `Dossiers médicaux` : 5 minutes
  - `Groupes` : 10 minutes
  - `Employés` & `Parents` : 15 minutes (données rarement modifiées)
- **Invalidation Intelligente par Tags (`CacheTags`)** :
  - `invalidateTag(CacheTags.patients)` : Invalide instantanément la liste des patients, le dashboard, les détails patients et fiches médicales lors de la création ou modification d'un patient.
  - `invalidateTag(CacheTags.seances)` : Invalide l'agenda, les séances individuelles, le dashboard, le hub comptes-rendus et le calendrier lors de la planification/déplacement/suppression d'une séance.
  - `invalidateTag(CacheTags.taches)` : Invalide la liste et les détails des tâches lors d'un changement de statut.
  - `invalidateTag(CacheTags.groupes)` : Invalide les groupes et l'agenda collectif.
  - `invalidateTag(CacheTags.employes)` & `CacheTags.parents`.
- **Nettoyage automatique à la déconnexion** : `AppCacheManager.clearAll()` est automatiquement déclenché lors du logout ou de l'expiration de session JWT (401).

---

## ⚡ 2. Optimisations Moteur & Mémoire (Pro Dev Best Practices)

- **Contrôle de la Mémoire d'Images (`main.dart`)** :
  - `PaintingBinding.instance.imageCache.maximumSizeBytes = 64 * 1024 * 1024;` (64 MB)
  - `PaintingBinding.instance.imageCache.maximumSize = 150;` (Max 150 images décodées en RAM)
  - Évite les micro-saccades et les fuites de mémoire lors du scroll rapide de listes contenant des avatars et des photos.
- **Initial Binding & Préservation des Contrôleurs Clés (`initial_binding.dart`)** :
  - Les contrôleurs des 4 onglets principaux (`AccueilController`, `PatientsListeController`, `AgendaController`, `ProfilController`) sont préservés en mémoire afin que la navigation entre onglets soit instantanée à 60/120 FPS.
- **Debouncing sur Toutes les Recherches (180–200ms)** :
  - Empêche les requêtes superflues ou les re-filtrages coûteux à chaque frappe de clavier sur les 6 pages de recherche (`PatientsListeView`, `EmployesListeView`, `GroupesListeView`, `ParentsListeView`, `CompteRenduHubView`, `SeancesIndividuellesView`).
- **Mises à Jour Optimistes (Optimistic UI)** :
  - Changement immédiat de statut pour les tâches (`TachesController`) et les séances sans attendre le retour réseau, avec rollback sécurisé en cas d'erreur.
- **Pull-to-Refresh (`refreshData(forceRefresh: true)`)** :
  - Intégré sur l'ensemble des pages de listes et de détails pour forcer une réactualisation immédiate sans attendre l'expiration du cache.

---

## 📊 3. Résultats des Tests Automatisés

```
flutter test test/controllers/ → 9/9 Tests réussis (100%)
flutter test test/widgets/     → 11/11 Tests réussis (100%)
flutter test test/views/       → 29/29 Pages Smoke Tests réussis (100%)
flutter test (Global Suite)    → 71/71 Tests réussis (100%)
flutter analyze                → 0 Erreur, 0 Warning bloquant
```
