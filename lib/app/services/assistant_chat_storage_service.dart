import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session_model.dart';

class AssistantChatStorageService {
  static const String _indexKey = 'psycare_ai_sessions_index';
  static const String _sessionPrefix = 'psycare_ai_session_';

  static AssistantChatStorageService? _instance;
  static AssistantChatStorageService get instance =>
      _instance ??= AssistantChatStorageService._();

  AssistantChatStorageService._();

  /// Récupère la liste ordonnée de toutes les sessions
  Future<List<ChatSessionModel>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final indexJson = prefs.getString(_indexKey);
    if (indexJson == null || indexJson.isEmpty) return [];

    try {
      final List<dynamic> ids = jsonDecode(indexJson) as List<dynamic>;
      final sessions = <ChatSessionModel>[];

      for (final id in ids) {
        final sessionStr = prefs.getString('$_sessionPrefix$id');
        if (sessionStr != null && sessionStr.isNotEmpty) {
          try {
            final map = jsonDecode(sessionStr) as Map<String, dynamic>;
            sessions.add(ChatSessionModel.fromJson(map));
          } catch (_) {}
        }
      }

      // Trier par date de mise à jour décroissante
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return sessions;
    } catch (_) {
      return [];
    }
  }

  /// Récupère une session par ID
  Future<ChatSessionModel?> getSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionStr = prefs.getString('$_sessionPrefix$id');
    if (sessionStr == null || sessionStr.isEmpty) return null;
    try {
      final map = jsonDecode(sessionStr) as Map<String, dynamic>;
      return ChatSessionModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Sauvegarde ou met à jour une session
  Future<void> saveSession(ChatSessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    session.updatedAt = DateTime.now();

    // Sauvegarder la session elle-même
    final sessionStr = jsonEncode(session.toJson());
    await prefs.setString('$_sessionPrefix${session.id}', sessionStr);

    // Mettre à jour l'index des IDs
    final indexJson = prefs.getString(_indexKey);
    List<String> ids = [];
    if (indexJson != null && indexJson.isNotEmpty) {
      try {
        ids = (jsonDecode(indexJson) as List<dynamic>).map((e) => e.toString()).toList();
      } catch (_) {}
    }

    if (!ids.contains(session.id)) {
      ids.insert(0, session.id);
    } else {
      // Déplacer en tête car récemment mis à jour
      ids.remove(session.id);
      ids.insert(0, session.id);
    }
    await prefs.setString(_indexKey, jsonEncode(ids));
  }

  /// Supprime une session
  Future<void> deleteSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_sessionPrefix$id');

    final indexJson = prefs.getString(_indexKey);
    if (indexJson != null && indexJson.isNotEmpty) {
      try {
        final ids = (jsonDecode(indexJson) as List<dynamic>).map((e) => e.toString()).toList();
        ids.remove(id);
        await prefs.setString(_indexKey, jsonEncode(ids));
      } catch (_) {}
    }
  }

  /// Renomme une session
  Future<void> renameSession(String id, String newTitle) async {
    final session = await getSession(id);
    if (session != null) {
      session.title = newTitle.trim();
      await saveSession(session);
    }
  }
}
