/// Entrée de cache en mémoire avec horodatage et TTL (Time-To-Live).
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;
  final Set<String> tags;

  CacheEntry({
    required this.data,
    required this.ttl,
    this.tags = const {},
  }) : timestamp = DateTime.now();

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
  bool get isFresh => !isExpired;
  Duration get age => DateTime.now().difference(timestamp);
}

/// Tags de cache standardisés pour l'invalidation intelligente
class CacheTags {
  CacheTags._();
  static const String patients = 'patients';
  static const String seances = 'seances';
  static const String groupes = 'groupes';
  static const String employes = 'employes';
  static const String parents = 'parents';
  static const String taches = 'taches';
  static const String dashboard = 'dashboard';
  static const String auth = 'auth';
  static const String calendrier = 'calendrier';
}

/// Clés de cache standardisées
class CacheKeys {
  CacheKeys._();
  static const String dashboard = 'dashboard_data';
  static const String currentUser = 'current_user_profile';
  static const String patientsList = 'patients_list_all';
  static const String agendaAll = 'agenda_sessions_all';
  static const String employesList = 'employes_list_all';
  static const String parentsList = 'parents_list_all';
  static const String groupesList = 'groupes_list_all';
  static const String tachesList = 'taches_list_all';
  static const String seancesIndivList = 'seances_indiv_all';
  static const String compteRenduHub = 'compte_rendu_hub_data';
  static const String calendrierEvents = 'calendrier_events_all';

  static String patientInfo(dynamic id) => 'patient_info_$id';
  static String patientParents(dynamic id) => 'patient_parents_$id';
  static String patientPlans(dynamic id) => 'patient_plans_$id';
  static String patientNotes(dynamic id) => 'patient_notes_$id';
  static String patientStatut(dynamic id) => 'patient_statut_$id';
  static String patientDossier(dynamic id) => 'patient_dossier_$id';
  static String patientSeances(dynamic id) => 'patient_seances_hist_$id';
  static String patientPlanning(dynamic id) => 'patient_planning_rec_$id';
  static String groupeDetail(dynamic id) => 'groupe_detail_$id';
  static String tacheDetail(dynamic id) => 'tache_detail_$id';
  static String employeDetail(dynamic id) => 'employe_detail_$id';
}

/// Gestionnaire de cache centralisé en mémoire haute performance.
/// Implémente le pattern Stale-While-Revalidate (SWR), l'invalidation ciblée
/// par tags, et la gestion du cycle de vie des données pour 0ms de latence.
class AppCacheManager {
  AppCacheManager._();

  static final Map<String, CacheEntry<dynamic>> _cache = {};

  // TTL par défaut par domaine
  static const Duration defaultTtl = Duration(minutes: 5);
  static const Duration shortTtl = Duration(minutes: 1);
  static const Duration longTtl = Duration(minutes: 15);

  /// Enregistre une valeur dans le cache avec un TTL et des tags d'invalidation
  static void set<T>(
    String key,
    T data, {
    Duration ttl = defaultTtl,
    Set<String> tags = const {},
  }) {
    _cache[key] = CacheEntry<T>(
      data: data,
      ttl: ttl,
      tags: tags,
    );
  }

  /// Récupère la donnée en cache si elle existe (même si elle est périmée / stale)
  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.data is T) {
      return entry.data as T;
    }
    return null;
  }

  /// Vérifie si la donnée en cache est encore fraîche (non expirée)
  static bool isFresh(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    return entry.isFresh;
  }

  /// Vérifie si la clé existe dans le cache
  static bool has(String key) => _cache.containsKey(key);

  /// Invalide une clé précise
  static void invalidate(String key) {
    _cache.remove(key);
  }

  /// Invalide toutes les clés associées à un tag (ex: 'patients', 'seances', etc.)
  static void invalidateTag(String tag) {
    final keysToRemove = <String>[];
    for (final entry in _cache.entries) {
      if (entry.value.tags.contains(tag)) {
        keysToRemove.add(entry.key);
      }
    }
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// Invalide plusieurs tags simultanément
  static void invalidateTags(Iterable<String> tags) {
    for (final tag in tags) {
      invalidateTag(tag);
    }
  }

  /// Vide l'intégralité du cache (ex: à la déconnexion)
  static void clearAll() {
    _cache.clear();
  }

  /// Nombre d'entrées en cache
  static int get size => _cache.length;
}
