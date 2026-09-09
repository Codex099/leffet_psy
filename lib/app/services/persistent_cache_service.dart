import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de cache persistant (SharedPreferences).
/// Complète [AppCacheManager] (RAM) en sauvegardant les données critiques
/// sur le disque pour les afficher en mode hors-ligne ou au redémarrage.
///
/// Stratégie :
///   1. Au démarrage → lire le cache persistant (instantané, 0ms)
///   2. Appel réseau réussi → mettre à jour RAM + persistant
///   3. Appel réseau échoué + cache persistant dispo → afficher le cache
class PersistentCacheService {
  PersistentCacheService._();

  static SharedPreferences? _prefs;

  static const String _prefixData = 'pcache_data_';
  static const String _prefixTimestamp = 'pcache_ts_';

  /// Initialise SharedPreferences — appeler une seule fois au démarrage
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    assert(_prefs != null, 'PersistentCacheService.init() doit être appelé d\'abord');
    return _prefs!;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // API publique
  // ─────────────────────────────────────────────────────────────────────────

  /// Sauvegarde [data] (encodable en JSON) sous [key].
  static Future<void> set(String key, dynamic data) async {
    try {
      final json = jsonEncode(data);
      await _p.setString(_prefixData + key, json);
      await _p.setInt(_prefixTimestamp + key, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      // Ne jamais crasher pour un cache
    }
  }

  /// Récupère la valeur JSON brute (Map, List, String, int, etc.) ou null.
  static dynamic get(String key) {
    try {
      final raw = _p.getString(_prefixData + key);
      if (raw == null) return null;
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// Vérifie si la clé existe dans le cache persistant.
  static bool has(String key) => _p.containsKey(_prefixData + key);

  /// Retourne la date de la dernière sauvegarde ou null.
  static DateTime? lastSaved(String key) {
    final ts = _p.getInt(_prefixTimestamp + key);
    if (ts == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ts);
  }

  /// Retourne une description humaine de l'âge du cache (ex: "il y a 2h").
  static String? lastSavedLabel(String key) {
    final saved = lastSaved(key);
    if (saved == null) return null;
    final diff = DateTime.now().difference(saved);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays}j';
  }

  /// Supprime une entrée du cache.
  static Future<void> remove(String key) async {
    await _p.remove(_prefixData + key);
    await _p.remove(_prefixTimestamp + key);
  }

  /// Vide tout le cache persistant (ex: déconnexion).
  static Future<void> clearAll() async {
    final keys = _p.getKeys().where((k) => k.startsWith(_prefixData) || k.startsWith(_prefixTimestamp)).toList();
    for (final k in keys) {
      await _p.remove(k);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Clés standardisées (miroir de CacheKeys)
  // ─────────────────────────────────────────────────────────────────────────
  static const String dashboard = 'dashboard';
  static const String patientsList = 'patients_list';
}
