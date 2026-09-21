import "dart:async";
import "dart:convert";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "package:speech_to_text/speech_to_text.dart" as stt;
import "../config/gemini_config.dart";
import "../models/chat_session_model.dart";
import "../models/patient_model.dart";
import "../services/assistant_chat_storage_service.dart";
import "../services/employee_service.dart";
import "../services/language_service.dart";
import "../services/note_patient_service.dart";
import "../services/patient_service.dart";
import "../services/plan_therapeutique_service.dart";
import "../services/seance_service.dart";
import "../services/tache_service.dart";

class AssistantIaController extends GetxController {
  // Services
  final _storage = AssistantChatStorageService.instance;
  final _patientService = PatientService();
  final _noteService = NoteService();
  final _seanceService = SeanceService();
  final _planService = PlanTherapeutiqueService();
  final _tacheService = TacheService();
  final _employeeService = EmployeeService();

  // State observables
  final sessions = <ChatSessionModel>[].obs;
  final currentSession = Rxn<ChatSessionModel>();
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isListening = false.obs;
  final inputText = "".obs;

  // Patient context
  final selectedPatient = Rxn<PatientModel>();
  final isLoadingPatientData = false.obs;
  final isExecutingAction = false.obs;

  final textController = TextEditingController();
  final scrollController = ScrollController();

  late GenerativeModel _model;
  late ChatSession _chat;
  late final stt.SpeechToText _speech;

  static const _defaultWelcome =
      "Bonjour ! Je suis votre assistant clinique PsyCare. "
      "Je peux analyser des dossiers, rédiger des comptes-rendus, proposer des techniques thérapeutiques "
      "ou créer directement des plans de soins pour vos patients. Comment puis-je vous aider ?";

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
    _initGemini();
    _loadHistoryAndInit();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  String? _lastExtraContext;

  /// Initialise le modèle Gemini avec le prompt système et le contexte patient éventuel
  void _initGemini({String? extraContext, String? overrideModel}) {
    _lastExtraContext = extraContext ?? _lastExtraContext;
    String effectivePrompt = GeminiConfig.systemPrompt;

    if (_lastExtraContext != null && _lastExtraContext!.isNotEmpty) {
      effectivePrompt += "\n\n=== CONTEXTE CLINIQUE DU DOSSIER PATIENT ===\n"
          "$_lastExtraContext\n"
          "Utilise ces données réelles pour répondre précisément sur l'historique et les besoins de ce patient.";
    }

    effectivePrompt += "\n\n=== ACTIONS CLINIQUES AUTOMATIQUES ===\n"
        "1. PLAN THÉRAPEUTIQUE : Si l'utilisateur demande de concevoir, proposer ou créer un plan thérapeutique, "
        "détaille d'abord ton analyse et tes recommandations, puis inclus TOUJOURS à la toute fin de ton message "
        "le bloc JSON strict suivant :\n"
        "```json_action\n"
        "{\n"
        '  "action": "create_plan",\n'
        '  "titre": "Titre explicite du plan thérapeutique",\n'
        '  "etapes": [\n'
        '    {"titre": "Nom de l étape 1", "description": "Détails de l étape 1"},\n'
        '    {"titre": "Nom de l étape 2", "description": "Détails de l étape 2"}\n'
        "  ]\n"
        "}\n"
        "```\n\n"
        "2. TÂCHES CLINIQUES & ASSIGNATIONS : Si l'utilisateur te demande de créer, planifier ou assigner une tâche "
        "(pour lui-même ou pour un employé/collègue précis comme Hafidh, Sara, etc.), détaille ta réponse clinique "
        "puis inclus TOUJOURS à la toute fin de ton message le bloc JSON strict suivant :\n"
        "```json_action\n"
        "{\n"
        '  "action": "create_tache",\n'
        '  "titre": "Titre court et clair de la tâche",\n'
        '  "description": "Consignes et détails pour la réalisation de cette tâche",\n'
        '  "assigne_a_nom": "Nom ou prénom de l employé mentionné",\n'
        '  "priorite": "haute"\n'
        "}\n"
        "```";

    _model = GenerativeModel(
      model: overrideModel ?? GeminiConfig.model,
      apiKey: GeminiConfig.apiKey,
      systemInstruction: Content.system(effectivePrompt),
    );

    // Reconstruire l'historique pour Gemini si des messages existent déjà
    final history = <Content>[];
    for (final m in messages) {
      if (m.text.isNotEmpty && !m.isLoading) {
        if (m.role == MessageRole.user) {
          history.add(Content.text(m.text));
        } else {
          history.add(Content.model([TextPart(m.text)]));
        }
      }
    }

    _chat = _model.startChat(history: history.isNotEmpty ? history : null);
  }

  /// Charge l'historique des discussions sauvegardées
  Future<void> _loadHistoryAndInit() async {
    try {
      final list = await _storage.getAllSessions();
      sessions.value = list;

      if (list.isNotEmpty) {
        await loadSession(list.first.id);
      } else {
        await createNewSession();
      }
    } catch (_) {
      await createNewSession();
    }
  }

  /// Crée une nouvelle discussion
  Future<void> createNewSession({PatientModel? patient}) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final session = ChatSessionModel(
      id: newId,
      title: patient != null
          ? "Dossier : ${patient.nom} ${patient.prenom}"
          : "Nouvelle discussion",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      patientId: patient?.id,
      patientName: patient != null ? "${patient.nom} ${patient.prenom}" : null,
      messages: [
        ChatMessage(
          text: patient != null
              ? "Bonjour ! Le dossier de ${patient.prenom} ${patient.nom} est actif. "
                  "Comment souhaitez-vous orienter son suivi aujourd'hui ?"
              : _defaultWelcome,
          role: MessageRole.assistant,
        ),
      ],
    );

    currentSession.value = session;
    messages.value = List.from(session.messages);
    selectedPatient.value = patient;

    if (patient != null) {
      await _enrichGeminiWithPatientData(patient);
    } else {
      _initGemini();
    }

    await _storage.saveSession(session);
    final list = await _storage.getAllSessions();
    sessions.value = list;
    _scrollToBottom();
  }

  /// Bascule vers une discussion existante
  Future<void> loadSession(String sessionId) async {
    final session = await _storage.getSession(sessionId);
    if (session == null) return;

    currentSession.value = session;
    messages.value = List.from(session.messages);

    // Restaurer le patient si associé
    if (session.patientId != null) {
      try {
        final p = await _patientService.getPatient(session.patientId);
        selectedPatient.value = p;
        await _enrichGeminiWithPatientData(p, reloadChatHistory: true);
      } catch (_) {
        selectedPatient.value = null;
        _initGemini();
      }
    } else {
      selectedPatient.value = null;
      _initGemini();
    }

    _scrollToBottom();
  }

  /// Renomme une discussion
  Future<void> renameSession(String sessionId, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    await _storage.renameSession(sessionId, newTitle);

    if (currentSession.value?.id == sessionId) {
      currentSession.value?.title = newTitle.trim();
      currentSession.refresh();
    }

    sessions.value = await _storage.getAllSessions();
    Get.snackbar("Succès", "Discussion renommée",
        snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2));
  }

  /// Supprime une discussion
  Future<void> deleteSession(String sessionId) async {
    await _storage.deleteSession(sessionId);
    sessions.value = await _storage.getAllSessions();

    if (currentSession.value?.id == sessionId) {
      if (sessions.isNotEmpty) {
        await loadSession(sessions.first.id);
      } else {
        await createNewSession();
      }
    }

    Get.snackbar("Supprimé", "Discussion supprimée",
        snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2));
  }

  /// Sélectionne un patient et injecte son dossier complet dans le contexte
  Future<void> selectPatient(PatientModel? patient) async {
    selectedPatient.value = patient;
    final curr = currentSession.value;
    if (curr != null) {
      curr.patientId = patient?.id;
      curr.patientName = patient != null ? "${patient.nom} ${patient.prenom}" : null;
      if (patient != null && curr.title == "Nouvelle discussion") {
        curr.title = "Dossier : ${patient.nom} ${patient.prenom}";
      }
      await _storage.saveSession(curr);
      currentSession.refresh();
      sessions.value = await _storage.getAllSessions();
    }

    if (patient == null) {
      _initGemini();
      messages.add(ChatMessage(
        text: "ℹ️ Dossier patient détaché. L'assistant est maintenant en mode général.",
        role: MessageRole.assistant,
      ));
      _persistActiveMessages();
      _scrollToBottom();
      return;
    }

    await _enrichGeminiWithPatientData(patient);

    messages.add(ChatMessage(
      text: "✅ **Dossier patient synchronisé : ${patient.nom} ${patient.prenom}**.\n"
          "Vous pouvez maintenant analyser son dossier, rédiger des synthèses, ou créer un plan thérapeutique en 1 clic.",
      role: MessageRole.assistant,
    ));
    _persistActiveMessages();
    _scrollToBottom();
  }

  /// Récupère le dossier médical, les notes et les séances pour Gemini
  Future<void> _enrichGeminiWithPatientData(PatientModel patient,
      {bool reloadChatHistory = false}) async {
    isLoadingPatientData.value = true;
    try {
      final buffer = StringBuffer();
      buffer.writeln("Patient : ${patient.nom} ${patient.prenom}");
      if (patient.sexe != null) buffer.writeln("Sexe : ${patient.sexe}");
      if (patient.dateNaissance != null) {
        buffer.writeln("Date de naissance : ${patient.dateNaissance}");
      }
      buffer.writeln("Statut : ${patient.estActif ? 'Actif' : 'Inactif'}");

      // Dossier médical
      try {
        final dossier = await _patientService.getDossierMedical(patient.id);
        buffer.writeln("\n--- DOSSIER MÉDICAL ---");
        if (dossier.antecedentsMedicaux != null) {
          buffer.writeln("Antécédents médicaux : ${dossier.antecedentsMedicaux}");
        }
        if (dossier.medicamentsPris != null) {
          buffer.writeln("Médicaments pris : ${dossier.medicamentsPris}");
        }
        if (dossier.developpementPsychomoteur != null) {
          buffer.writeln("Développement psychomoteur : ${dossier.developpementPsychomoteur}");
        }
        if (dossier.developpementLangagier != null) {
          buffer.writeln("Développement langagier : ${dossier.developpementLangagier}");
        }
        if (dossier.adaptationSociale != null) {
          buffer.writeln("Adaptation sociale : ${dossier.adaptationSociale}");
        }
        if (dossier.stadeScolarisation != null) {
          buffer.writeln("Scolarisation : ${dossier.stadeScolarisation}");
        }
      } catch (_) {}

      // Notes cliniques
      try {
        final notes = await _noteService.getNotes(patient.id);
        if (notes.isNotEmpty) {
          buffer.writeln("\n--- DERNIÈRES NOTES CLINIQUES ---");
          for (final n in notes.take(5)) {
            buffer.writeln("- ${n['titre'] ?? 'Note'}: ${n['contenu'] ?? ''}");
          }
        }
      } catch (_) {}

      // Séances récentes
      try {
        final seances = await _seanceService.getSeances(patientId: patient.id);
        if (seances.isNotEmpty) {
          buffer.writeln("\n--- DERNIÈRES SÉANCES ---");
          for (final s in seances.take(5)) {
            buffer.writeln(
                "- Date: ${s.date} ${s.heureDebut} | Statut: ${s.statut} | Évolution: ${s.descriptionEtat ?? s.motifStatut ?? 'Non renseigné'}");
          }
        }
      } catch (_) {}

      _initGemini(extraContext: buffer.toString());
    } catch (e) {
      _initGemini();
    } finally {
      isLoadingPatientData.value = false;
    }
  }

  /// Envoie un message utilisateur à Gemini
  Future<void> sendMessage([String? text]) async {
    final msg = (text ?? textController.text).trim();
    if (msg.isEmpty || isLoading.value) return;

    textController.clear();
    inputText.value = "";

    final userMsg = ChatMessage(text: msg, role: MessageRole.user);
    messages.add(userMsg);
    messages.add(ChatMessage(text: "", role: MessageRole.assistant, isLoading: true));
    isLoading.value = true;
    _scrollToBottom();

    // Si premier message utilisateur, renommer automatiquement la discussion si titre par défaut
    final curr = currentSession.value;
    if (curr != null && (curr.title == "Nouvelle discussion" || curr.title.isEmpty)) {
      final autoTitle = msg.length > 30 ? "${msg.substring(0, 30)}..." : msg;
      curr.title = autoTitle;
      await _storage.saveSession(curr);
      sessions.value = await _storage.getAllSessions();
    }

    try {
      GenerateContentResponse response;
      try {
        response = await _chat.sendMessage(Content.text(msg));
      } catch (firstErr) {
        final errStr = firstErr.toString().toLowerCase();
        // Si les serveurs Google sont en pic de charge (503 / high demand)
        if (errStr.contains("503") || errStr.contains("high demand") || errStr.contains("unavailable")) {
          // Re-tenter automatiquement avec le modèle rapide et disponible
          _initGemini(overrideModel: "gemini-3.1-flash-lite");
          response = await _chat.sendMessage(Content.text(msg));
        } else {
          rethrow;
        }
      }

      messages.removeLast(); // Retire le loading

      final rawReply = response.text ?? "Je n'ai pas pu générer de réponse.";
      final parsed = _extractActionFromReply(rawReply);

      final assistantMsg = ChatMessage(
        text: parsed.cleanText,
        role: MessageRole.assistant,
        action: parsed.action,
      );

      messages.add(assistantMsg);
      await _persistActiveMessages();
    } catch (e) {
      messages.removeLast();
      final errStr = e.toString();
      String userFriendlyError = "Erreur : $errStr";
      if (errStr.contains("503") || errStr.contains("high demand") || errStr.contains("UNAVAILABLE")) {
        userFriendlyError = "⚠️ Les serveurs de Google subissent une forte affluence temporaire (erreur 503). "
            "Le modèle réessaie automatiquement, veuillez retaper votre message dans quelques secondes.";
      }
      messages.add(ChatMessage(
        text: userFriendlyError,
        role: MessageRole.assistant,
      ));
      await _persistActiveMessages();
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  /// Extrait un éventuel bloc json_action pour créer une Action Card dans l'UI
  ({String cleanText, ChatMessageAction? action}) _extractActionFromReply(String reply) {
    final regex = RegExp(r"```json_action\s*([\s\S]*?)\s*```");
    final match = regex.firstMatch(reply);

    if (match != null) {
      final jsonStr = match.group(1);
      final cleanText = reply.replaceRange(match.start, match.end, "").trim();

      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          final actionType = map['action'] as String? ?? 'create_plan';
          final action = ChatMessageAction(type: actionType, data: map);
          return (cleanText: cleanText, action: action);
        } catch (_) {}
      }
      return (cleanText: cleanText, action: null);
    }

    return (cleanText: reply, action: null);
  }

  /// Exécute l'action d'enregistrement direct d'un plan thérapeutique
  Future<void> executeCreatePlanAction(ChatMessage message) async {
    final action = message.action;
    if (action == null || action.isDone || isExecutingAction.value) return;

    final patient = selectedPatient.value;
    if (patient == null) {
      Get.snackbar(
        "Patient requis",
        "Veuillez lier un patient à cette discussion pour enregistrer ce plan thérapeutique.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return;
    }

    isExecutingAction.value = true;
    try {
      final titre = action.data['titre'] as String? ?? 'Plan thérapeutique IA';
      final etapes = (action.data['etapes'] as List<dynamic>? ?? []);

      // 1. Créer le plan
      final createdPlan = await _planService.createPlan(patient.id, {
        'titre': titre,
        'statut': 'actif',
      });

      // 2. Créer les étapes associées
      for (int i = 0; i < etapes.length; i++) {
        final e = etapes[i];
        if (e is Map) {
          await _planService.createEtape(createdPlan.id, {
            'titre': e['titre'] ?? 'Étape ${i + 1}',
            'description': e['description'] ?? '',
            'ordre': e['ordre'] is int ? e['ordre'] : (i + 1),
            'statut': 'a_faire',
          });
        }
      }

      action.isDone = true;
      messages.refresh();
      await _persistActiveMessages();

      Get.snackbar(
        "Plan enregistré ! 🎉",
        "Le plan « $titre » avec ${etapes.length} étapes a été ajouté au dossier de ${patient.nom}.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF0D9488),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible d'enregistrer le plan : $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isExecutingAction.value = false;
    }
  }

  /// Exécute l'action de création directe d'une tâche clinique et son assignation
  Future<void> executeCreateTacheAction(ChatMessage message) async {
    final action = message.action;
    if (action == null || action.isDone || isExecutingAction.value) return;

    isExecutingAction.value = true;
    try {
      final titre = action.data['titre'] as String? ?? 'Tâche clinique';
      final description = action.data['description'] as String? ?? '';
      final assigneNom = (action.data['assigne_a_nom'] as String? ?? '').trim().toLowerCase();
      final priorite = action.data['priorite'] as String? ?? 'normale';

      String? assigneId;
      String assigneAffiche = action.data['assigne_a_nom'] ?? 'Équipe';

      // Résoudre l'employé correspondant par nom ou prénom
      if (assigneNom.isNotEmpty) {
        try {
          final employees = await _employeeService.getEmployees();
          final found = employees.firstWhereOrNull((e) =>
              e.nom.toLowerCase().contains(assigneNom) ||
              e.prenom.toLowerCase().contains(assigneNom) ||
              "${e.prenom} ${e.nom}".toLowerCase().contains(assigneNom));
          if (found != null) {
            assigneId = found.id.toString();
            assigneAffiche = "${found.prenom} ${found.nom}";
          }
        } catch (_) {}
      }

      final payload = <String, dynamic>{
        'titre': titre,
        if (description.isNotEmpty) 'description': description,
        'statut': 'a_faire',
        'priorite': priorite,
      };
      if (assigneId != null) payload['assigne_a'] = assigneId;
      if (selectedPatient.value != null) {
        payload['patient_id'] = selectedPatient.value!.id.toString();
      }

      await _tacheService.createTache(payload);

      action.isDone = true;
      messages.refresh();
      await _persistActiveMessages();

      Get.snackbar(
        "Tâche créée ! 🎉",
        "La tâche « $titre » a été assignée avec succès à $assigneAffiche.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF0D9488),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de créer la tâche : $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isExecutingAction.value = false;
    }
  }

  /// Sauvegarde les messages actuels dans la session active
  Future<void> _persistActiveMessages() async {
    final curr = currentSession.value;
    if (curr != null) {
      curr.messages = List.from(messages);
      curr.updatedAt = DateTime.now();
      await _storage.saveSession(curr);
      sessions.value = await _storage.getAllSessions();
    }
  }

  /// Commande vocale
  Future<void> toggleVoice() async {
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
      return;
    }
    final available = await _speech.initialize(
      onError: (_) => isListening.value = false,
    );
    if (!available) {
      Get.snackbar("Micro", "Microphone non disponible",
          snackPosition: SnackPosition.TOP);
      return;
    }
    isListening.value = true;
    _speech.listen(
      listenOptions: stt.SpeechListenOptions(localeId: "fr_FR"),
      onResult: (r) {
        textController.text = r.recognizedWords;
        inputText.value = r.recognizedWords;
        if (r.finalResult) {
          isListening.value = false;
          if (r.recognizedWords.isNotEmpty) sendMessage(r.recognizedWords);
        }
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }
}