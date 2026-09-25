import "package:flutter/material.dart";

import "package:get/get.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "package:speech_to_text/speech_to_text.dart" as stt;
import "../config/gemini_config.dart";
import "../config/gemini_tools.dart";
import "../models/chat_session_model.dart";
import "../models/patient_model.dart";
import "../services/assistant_chat_storage_service.dart";
import "../services/calendrier_service.dart";
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
  final _calendrierService = CalendrierService();

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

  final textController = TextEditingController();
  final scrollController = ScrollController();

  late GenerativeModel _model;
  late ChatSession _chat;
  late final stt.SpeechToText _speech;

  String? _lastExtraContext;

  static String get _defaultWelcome {
    final isArabic = (Get.locale?.languageCode == 'ar' ||
        LanguageService.currentLocale.value.languageCode == 'ar');
    if (isArabic) {
      return "مرحباً بك! أنا مساعدك العيادي الذكي PsyCare. "
          "يمكنني مساعدتك في تحليل الملفات الطبية، صياغة تقارير المتابعة، "
          "إنشاء خطط علاجية، إنشاء مهام، إضافة مرضى جدد، والاطلاع على الرزنامة. "
          "كيف يمكنني مساعدتك اليوم؟";
    }
    return "Bonjour ! Je suis votre assistant clinique PsyCare. "
        "Je peux analyser des dossiers, rédiger des comptes-rendus, "
        "créer des plans thérapeutiques, des tâches, ajouter des patients "
        "et consulter le calendrier. Comment puis-je vous aider ?";
  }

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
    _initGemini();
    _loadHistoryAndInit();

    ever(LanguageService.currentLocale, (_) => _initGemini());
  }


  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ── Initialisation Gemini avec Function Calling ────────────────────────────

  /// Initialise le modèle Gemini avec le system prompt, le contexte patient
  /// et les outils de Function Calling natifs.
  void _initGemini({String? extraContext, String? overrideModel}) {
    _lastExtraContext = extraContext ?? _lastExtraContext;

    final isArabic = (Get.locale?.languageCode == 'ar' ||
        LanguageService.currentLocale.value.languageCode == 'ar');

    String prompt = GeminiConfig.systemPrompt;

    // Règle de langue
    if (isArabic) {
      prompt += "\n\n=== RÈGLE ABSOLUE DE LANGUE ===\n"
          "L'application est en ARABE. Réponds TOUJOURS en العربية الفصحى السريرية.\n"
          "Structure : الملاحظات / النقاط الرئيسية / المقترحات العلاجية.\n"
          "Les arguments des outils (titres, descriptions, étapes) doivent aussi être en arabe.";
    } else {
      prompt += "\n\n=== LANGUE ===\n"
          "Détecte la langue du message et réponds TOUJOURS dans la même langue (Français ou Arabe).";
    }

    // Contexte patient si disponible
    if (_lastExtraContext != null && _lastExtraContext!.isNotEmpty) {
      prompt += "\n\n=== CONTEXTE CLINIQUE DU DOSSIER PATIENT ===\n"
          "$_lastExtraContext\n"
          "Utilise ces données réelles pour répondre précisément.";
    }

    // Instructions pour les outils
    prompt += "\n\n=== OUTILS DISPONIBLES ===\n"
        "Tu as accès à des outils pour interagir directement avec le backend PsyCare :\n"
        "- creer_patient : ajouter un nouveau dossier patient\n"
        "- creer_tache : créer et assigner une tâche (demande TOUJOURS date ET heure avant)\n"
        "- creer_plan_therapeutique : créer un plan avec étapes\n"
        "- obtenir_calendrier : consulter les événements/RDV\n"
        "- obtenir_taches_employes : voir les tâches des employés\n"
        "Utilise ces outils dès que l'utilisateur demande une action correspondante. "
        "Pour creer_tache : TOUJOURS demander la date et l'heure AVANT d'appeler l'outil. "
        "Pour creer_patient : demander nom, prénom, sexe au minimum. "
        "Après avoir exécuté un outil, confirme à l'utilisateur ce qui a été fait.";

    _model = GenerativeModel(
      model: overrideModel ?? GeminiConfig.model,
      apiKey: GeminiConfig.apiKey,
      systemInstruction: Content.system(prompt),
      tools: GeminiTools.allTools,
    );

    // Reconstruire l'historique de chat (texte seulement)
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

  // ── Gestion des sessions ───────────────────────────────────────────────────

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

  Future<void> createNewSession({PatientModel? patient}) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final isArabic = (Get.locale?.languageCode == 'ar' ||
        LanguageService.currentLocale.value.languageCode == 'ar');
    final session = ChatSessionModel(
      id: newId,
      title: patient != null
          ? (isArabic
              ? "ملف : ${patient.nom} ${patient.prenom}"
              : "Dossier : ${patient.nom} ${patient.prenom}")
          : (isArabic ? "محادثة جديدة" : "Nouvelle discussion"),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      patientId: patient?.id,
      patientName:
          patient != null ? "${patient.nom} ${patient.prenom}" : null,
      messages: [
        ChatMessage(
          text: patient != null
              ? (isArabic
                  ? "مرحباً بك! ملف المريض ${patient.prenom} ${patient.nom} نشط الآن. كيف تود توجيه المتابعة العلاجية اليوم؟"
                  : "Bonjour ! Le dossier de ${patient.prenom} ${patient.nom} est actif. "
                      "Comment souhaitez-vous orienter son suivi aujourd'hui ?")
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
      _lastExtraContext = null;
      _initGemini();
    }

    await _storage.saveSession(session);
    sessions.value = await _storage.getAllSessions();
    _scrollToBottom();
  }

  Future<void> loadSession(String sessionId) async {
    final session = await _storage.getSession(sessionId);
    if (session == null) return;

    currentSession.value = session;
    messages.value = List.from(session.messages);

    if (session.patientId != null) {
      try {
        final p = await _patientService.getPatient(session.patientId);
        selectedPatient.value = p;
        await _enrichGeminiWithPatientData(p, reloadChatHistory: true);
      } catch (_) {
        selectedPatient.value = null;
        _lastExtraContext = null;
        _initGemini();
      }
    } else {
      selectedPatient.value = null;
      _lastExtraContext = null;
      _initGemini();
    }

    _scrollToBottom();
  }

  Future<void> renameSession(String sessionId, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    await _storage.renameSession(sessionId, newTitle);

    if (currentSession.value?.id == sessionId) {
      currentSession.value?.title = newTitle.trim();
      currentSession.refresh();
    }

    sessions.value = await _storage.getAllSessions();
    Get.snackbar("Succès".tr, "Discussion renommée".tr,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2));
  }

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

    Get.snackbar("Succès".tr, "Discussion supprimée".tr,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2));
  }

  Future<void> selectPatient(PatientModel? patient) async {
    selectedPatient.value = patient;
    final curr = currentSession.value;
    final isArabic = (Get.locale?.languageCode == 'ar' ||
        LanguageService.currentLocale.value.languageCode == 'ar');

    if (curr != null) {
      curr.patientId = patient?.id;
      curr.patientName =
          patient != null ? "${patient.nom} ${patient.prenom}" : null;
      if (patient != null &&
          (curr.title == "Nouvelle discussion" ||
              curr.title == "محادثة جديدة")) {
        curr.title = isArabic
            ? "ملف : ${patient.nom} ${patient.prenom}"
            : "Dossier : ${patient.nom} ${patient.prenom}";
      }
      await _storage.saveSession(curr);
      currentSession.refresh();
      sessions.value = await _storage.getAllSessions();
    }

    if (patient == null) {
      _lastExtraContext = null;
      _initGemini();
      messages.add(ChatMessage(
        text: isArabic
            ? "ℹ️ تم فصل ملف المريض. المساعد الآن في الوضع العام."
            : "ℹ️ Dossier patient détaché. L'assistant est maintenant en mode général.",
        role: MessageRole.assistant,
      ));
    } else {
      await _enrichGeminiWithPatientData(patient);
      messages.add(ChatMessage(
        text: isArabic
            ? "✅ **تمت مزامنة ملف المريض : ${patient.nom} ${patient.prenom}**.\n"
                "يمكنك الآن تحليل الملف الطبي، صياغة تقارير المتابعة، أو إنشاء خطة علاجية وتعيين المهام."
            : "✅ **Dossier patient synchronisé : ${patient.nom} ${patient.prenom}**.\n"
                "Vous pouvez maintenant analyser son dossier, rédiger des synthèses, ou créer un plan thérapeutique.",
        role: MessageRole.assistant,
      ));
    }

    if (curr != null) {
      await _storage.saveSession(curr);
      sessions.value = await _storage.getAllSessions();
    }
    _scrollToBottom();
  }

  // ── Enrichissement du contexte patient ────────────────────────────────────

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
      buffer.writeln("ID patient : ${patient.id}");

      try {
        final dossier = await _patientService.getDossierMedical(patient.id);
        buffer.writeln("\n--- DOSSIER MÉDICAL ---");
        if (dossier.antecedentsMedicaux != null) {
          buffer.writeln(
              "Antécédents médicaux : ${dossier.antecedentsMedicaux}");
        }
        if (dossier.medicamentsPris != null) {
          buffer.writeln("Médicaments pris : ${dossier.medicamentsPris}");
        }
        if (dossier.developpementPsychomoteur != null) {
          buffer.writeln(
              "Développement psychomoteur : ${dossier.developpementPsychomoteur}");
        }
        if (dossier.developpementLangagier != null) {
          buffer.writeln(
              "Développement langagier : ${dossier.developpementLangagier}");
        }
        if (dossier.adaptationSociale != null) {
          buffer.writeln("Adaptation sociale : ${dossier.adaptationSociale}");
        }
        if (dossier.stadeScolarisation != null) {
          buffer.writeln("Scolarisation : ${dossier.stadeScolarisation}");
        }
      } catch (_) {}

      try {
        final notes = await _noteService.getNotes(patient.id);
        if (notes.isNotEmpty) {
          buffer.writeln("\n--- DERNIÈRES NOTES CLINIQUES ---");
          for (final n in notes.take(5)) {
            buffer.writeln("- ${n['titre'] ?? 'Note'}: ${n['contenu'] ?? ''}");
          }
        }
      } catch (_) {}

      try {
        final seances =
            await _seanceService.getSeances(patientId: patient.id);
        if (seances.isNotEmpty) {
          buffer.writeln("\n--- DERNIÈRES SÉANCES ---");
          for (final s in seances.take(5)) {
            buffer.writeln(
                "- Date: ${s.date} ${s.heureDebut} | Statut: ${s.statut} | Évolution: ${s.descriptionEtat ?? s.motifStatut ?? 'Non renseigné'}");
          }
        }
      } catch (_) {}

      _initGemini(extraContext: buffer.toString());
    } catch (_) {
      _initGemini();
    } finally {
      isLoadingPatientData.value = false;
    }
  }

  // ── Envoi et modification de message avec boucle Function Calling ───────────

  /// Copie le texte d'un message dans la zone de saisie principale
  void copyToInput(String text) {
    textController.text = text;
    inputText.value = text;
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  /// Modifie un message utilisateur existant.
  /// - [resend] = true : met à jour le message, retire les réponses postérieures et relance l'IA.
  /// - [resend] = false : met à jour le texte du message dans l'historique sans relancer l'IA.
  Future<void> editUserMessage(int messageIndex, String newText, {bool resend = true}) async {
    if (messageIndex < 0 || messageIndex >= messages.length) return;
    if (isLoading.value) {
      if (Get.context != null) {
        Get.snackbar(
          "Patientez".tr,
          "Veuillez attendre la fin de la réponse en cours".tr,
          snackPosition: SnackPosition.TOP,
        );
      }
      return;
    }

    final trimmed = newText.trim();
    if (trimmed.isEmpty) return;

    if (!resend) {
      final old = messages[messageIndex];
      messages[messageIndex] = ChatMessage(
        id: old.id,
        text: trimmed,
        role: old.role,
        time: old.time,
        action: old.action,
      );
      await _persistActiveMessages();
      if (Get.context != null) {
        Get.snackbar(
          "Succès".tr,
          "Message modifié".tr,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
      return;
    }

    // Retirer les réponses et messages qui suivent pour régénérer proprement
    if (messageIndex < messages.length - 1) {
      messages.removeRange(messageIndex + 1, messages.length);
    }

    final old = messages[messageIndex];
    messages[messageIndex] = ChatMessage(
      id: old.id,
      text: trimmed,
      role: old.role,
      time: DateTime.now(),
      action: old.action,
    );

    // Reconstruire l'historique Gemini précédent ce message
    final history = <Content>[];
    for (int j = 0; j < messageIndex; j++) {
      final m = messages[j];
      if (m.text.isNotEmpty && !m.isLoading) {
        if (m.role == MessageRole.user) {
          history.add(Content.text(m.text));
        } else {
          history.add(Content.model([TextPart(m.text)]));
        }
      }
    }
    _chat = _model.startChat(history: history.isNotEmpty ? history : null);

    messages.add(ChatMessage(text: "", role: MessageRole.assistant, isLoading: true));
    isLoading.value = true;
    _scrollToBottom();

    await _executeModelPrompt(trimmed);
  }

  Future<void> sendMessage([String? text]) async {
    final msg = (text ?? textController.text).trim();
    if (msg.isEmpty || isLoading.value) return;

    textController.clear();
    inputText.value = "";

    messages.add(ChatMessage(text: msg, role: MessageRole.user));
    messages.add(ChatMessage(text: "", role: MessageRole.assistant, isLoading: true));
    isLoading.value = true;
    _scrollToBottom();

    // Auto-rename session si titre par défaut
    final curr = currentSession.value;
    if (curr != null &&
        (curr.title == "Nouvelle discussion" ||
            curr.title == "محادثة جديدة" ||
            curr.title.isEmpty)) {
      curr.title = msg.length > 30 ? "${msg.substring(0, 30)}..." : msg;
      await _storage.saveSession(curr);
      sessions.value = await _storage.getAllSessions();
    }

    await _executeModelPrompt(msg);
  }

  Future<void> _executeModelPrompt(String msg) async {
    final isArabic = (Get.locale?.languageCode == 'ar' ||
        LanguageService.currentLocale.value.languageCode == 'ar');

    final promptForModel = isArabic
        ? "$msg\n\n[تنبيه: الرد يجب أن يكون باللغة العربية الفصحى السريرية.]"
        : msg;

    if (!GeminiConfig.isConfigured) {
      messages.removeLast(); // Retire le loading
      final missingKeyMsg = isArabic
          ? "⚠️ **مفتاح Gemini API غير مفعّل أو غير موجود.**\n\n"
              "لتشغيل المساعد الذكي، يجب تمرير المفتاح عند التشغيل :\n"
              "```bash\nflutter run --dart-define=GEMINI_API_KEY=votre_cle_ici\n```\n"
              "احصل على مفتاح مجاني من : https://aistudio.google.com/app/apikey"
          : "⚠️ **La clé Gemini API n'est pas configurée.**\n\n"
              "Pour utiliser l'assistant, lancez l'application avec votre clé API :\n"
              "```bash\nflutter run --dart-define=GEMINI_API_KEY=votre_cle_ici\n```\n"
              "Vous pouvez obtenir une clé gratuite sur : https://aistudio.google.com/app/apikey";
      messages.add(ChatMessage(
        text: missingKeyMsg,
        role: MessageRole.assistant,
      ));
      await _persistActiveMessages();
      isLoading.value = false;
      _scrollToBottom();
      return;
    }

    try {
      // ── Boucle Function Calling ──────────────────────────────────────────
      GenerateContentResponse response;
      try {
        response = await _chat.sendMessage(Content.text(promptForModel));
      } catch (firstErr) {
        final errStr = firstErr.toString().toLowerCase();
        if (errStr.contains("503") ||
            errStr.contains("high demand") ||
            errStr.contains("unavailable")) {
          _initGemini(overrideModel: "gemini-1.5-flash");
          response = await _chat.sendMessage(Content.text(promptForModel));
        } else {
          rethrow;
        }
      }

      // Traiter les appels de fonctions en boucle jusqu'à la réponse finale
      while (response.functionCalls.isNotEmpty) {
        final functionResponses = <FunctionResponse>[];

        for (final call in response.functionCalls) {
          _updateLoadingStatus(
            isArabic
                ? "⚙️ Exécution : ${_toolLabel(call.name, isArabic: true)}..."
                : "⚙️ Exécution : ${_toolLabel(call.name)}...",
          );

          final result = await _handleFunctionCall(call, isArabic: isArabic);
          functionResponses.add(FunctionResponse(call.name, result));
        }

        // Renvoyer les résultats à Gemini pour qu'il génère la réponse finale
        response = await _chat.sendMessage(
          Content.functionResponses(functionResponses),
        );
      }

      // ── Réponse finale texte ─────────────────────────────────────────────
      messages.removeLast(); // Retire le loading

      final finalText = response.text ??
          (isArabic
              ? "لم أتمكن من إنشاء إجابة."
              : "Je n'ai pas pu générer de réponse.");

      messages.add(ChatMessage(
        text: finalText,
        role: MessageRole.assistant,
      ));
      await _persistActiveMessages();
    } catch (e) {
      messages.removeLast();
      final errStr = e.toString();
      String userFriendlyError = "Erreur : $errStr";
      if (errStr.contains("unregistered callers") ||
          errStr.contains("API consumer identity") ||
          errStr.contains("API Key")) {
        userFriendlyError = isArabic
            ? "⚠️ **مفتاح Gemini API غير صالح أو غير معرف.**\n\n"
                "يرجى التأكد من استخدام مفتاح Google AI Studio صالح (يبدأ بـ `AIzaSy...`) عبر :\n"
                "```bash\nflutter run --dart-define=GEMINI_API_KEY=AIzaSy...\n```"
            : "⚠️ **Clé API Gemini invalide ou absente.**\n\n"
                "Veuillez vérifier que vous utilisez une clé API Google AI Studio valide (commençant par `AIzaSy...`) avec :\n"
                "```bash\nflutter run --dart-define=GEMINI_API_KEY=AIzaSy...\n```";
      } else if (errStr.contains("503") ||
          errStr.contains("high demand") ||
          errStr.contains("UNAVAILABLE")) {
        userFriendlyError = isArabic
            ? "⚠️ تشهد خوادم Google ضغطاً كبيراً مؤقتاً (خطأ 503). يرجى إعادة إرسال رسالتك بعد ثوانٍ قليلة."
            : "⚠️ Les serveurs de Google subissent une forte affluence temporaire (erreur 503). "
                "Veuillez retaper votre message dans quelques secondes.";
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

  /// Met à jour le texte du message de chargement en cours
  void _updateLoadingStatus(String status) {
    if (messages.isNotEmpty && messages.last.isLoading) {
      final idx = messages.length - 1;
      messages[idx] = ChatMessage(
        text: status,
        role: MessageRole.assistant,
        isLoading: true,
      );
    }
  }

  /// Label lisible pour un nom d'outil
  String _toolLabel(String name, {bool isArabic = false}) {
    const labels = {
      'creer_patient': 'Création du dossier patient',
      'creer_tache': 'Création de la tâche',
      'creer_plan_therapeutique': 'Création du plan thérapeutique',
      'obtenir_calendrier': 'Consultation du calendrier',
      'obtenir_taches_employes': "Récupération des tâches",
    };
    const labelsAr = {
      'creer_patient': 'إنشاء ملف المريض',
      'creer_tache': 'إنشاء المهمة',
      'creer_plan_therapeutique': 'إنشاء الخطة العلاجية',
      'obtenir_calendrier': 'استرجاع الرزنامة',
      'obtenir_taches_employes': "استرجاع المهام",
    };
    return (isArabic ? labelsAr[name] : labels[name]) ?? name;
  }

  // ── Dispatcher des appels de fonctions ────────────────────────────────────

  /// Exécute l'appel de fonction Gemini et retourne le résultat en Map
  Future<Map<String, Object?>> _handleFunctionCall(
    FunctionCall call, {
    bool isArabic = false,
  }) async {
    final args = call.args;
    try {
      switch (call.name) {
        case 'creer_patient':
          return await _fcCreerPatient(args, isArabic: isArabic);

        case 'creer_tache':
          return await _fcCreerTache(args, isArabic: isArabic);

        case 'creer_plan_therapeutique':
          return await _fcCreerPlan(args, isArabic: isArabic);

        case 'obtenir_calendrier':
          return await _fcObtenirCalendrier(args);

        case 'obtenir_taches_employes':
          return await _fcObtenirTaches(args);

        default:
          return {'error': 'Outil inconnu : ${call.name}'};
      }
    } catch (e) {
      return {'error': e.toString(), 'success': false};
    }
  }

  // ── Implémentations des fonctions ──────────────────────────────────────────

  Future<Map<String, Object?>> _fcCreerPatient(
    Map<String, Object?> args, {
    bool isArabic = false,
  }) async {
    final nom = (args['nom'] as String? ?? '').trim();
    final prenom = (args['prenom'] as String? ?? '').trim();
    final sexeRaw = args['sexe'] as String?;
    final dateNaissanceRaw = args['date_naissance'] as String?;
    final nombreFreresSoeurs = args['nombre_freres_soeurs'] as int?;
    final ordreNaissance = args['ordre_naissance'] as int?;

    if (nom.isEmpty || prenom.isEmpty) {
      return {'error': 'Nom et prénom sont requis', 'success': false};
    }

    // Normaliser le sexe
    String? sexe;
    if (sexeRaw != null) {
      final s = sexeRaw.trim().toLowerCase();
      if (s.contains('masc') || s == 'm' || s.contains('ذكر')) {
        sexe = 'masculin';
      } else if (s.contains('fem') || s.contains('fill') || s == 'f' || s.contains('أنثى')) {
        sexe = 'feminin';
      } else {
        sexe = sexeRaw;
      }
    }

    final dateNaissance = (dateNaissanceRaw == null ||
            dateNaissanceRaw.toLowerCase() == 'null' ||
            dateNaissanceRaw.isEmpty)
        ? null
        : dateNaissanceRaw;

    final payload = <String, dynamic>{
      'nom': nom,
      'prenom': prenom,
      'est_actif': true,
      if (sexe != null) 'sexe': sexe,
      if (dateNaissance != null) 'date_naissance': dateNaissance,
      if (nombreFreresSoeurs != null)
        'nombre_freres_soeurs': nombreFreresSoeurs,
      if (ordreNaissance != null) 'ordre_naissance': ordreNaissance,
    };

    final created = await _patientService.createPatient(payload);

    Get.snackbar(
      'Patient créé ! 🎉'.tr,
      isArabic
          ? 'تم إنشاء ملف المريض ${created.prenom} ${created.nom} بنجاح.'
          : 'Le dossier de ${created.prenom} ${created.nom} a été créé avec succès.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0D9488),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    return {
      'success': true,
      'patient_id': created.id.toString(),
      'nom': created.nom,
      'prenom': created.prenom,
      'sexe': created.sexe ?? '',
      'message': 'Patient créé avec succès',
    };
  }

  Future<Map<String, Object?>> _fcCreerTache(
    Map<String, Object?> args, {
    bool isArabic = false,
  }) async {
    final titre = (args['titre'] as String? ?? 'Tâche clinique').trim();
    final description = args['description'] as String? ?? '';
    final assigneNomRaw =
        (args['assigne_a_nom'] as String? ?? '').trim().toLowerCase();
    final priorite = args['priorite'] as String? ?? 'normale';
    final dateEcheance = args['date_echeance'] as String?;
    final heureEcheance = args['heure_echeance'] as String?;
    final patientIdArg = args['patient_id'] as String?;

    // Résoudre l'employé
    String? assigneId;
    String assigneAffiche =
        args['assigne_a_nom'] as String? ?? 'Équipe';

    if (assigneNomRaw.isNotEmpty) {
      try {
        final employees = await _employeeService.getEmployees();
        final found = employees.firstWhereOrNull((e) =>
            e.nom.toLowerCase().contains(assigneNomRaw) ||
            e.prenom.toLowerCase().contains(assigneNomRaw) ||
            "${e.prenom} ${e.nom}".toLowerCase().contains(assigneNomRaw));
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

    // Patient : depuis arg ou depuis le patient sélectionné
    final pid = patientIdArg ?? selectedPatient.value?.id?.toString();
    if (pid != null) payload['patient_id'] = pid;

    // Date + heure
    if (dateEcheance != null &&
        dateEcheance.isNotEmpty &&
        dateEcheance.toLowerCase() != 'null') {
      if (heureEcheance != null &&
          heureEcheance.isNotEmpty &&
          heureEcheance.toLowerCase() != 'null') {
        payload['date_echeance'] = '$dateEcheance $heureEcheance';
      } else {
        payload['date_echeance'] = dateEcheance;
      }
    }

    final created = await _tacheService.createTache(payload);

    final echeanceStr = dateEcheance != null
        ? (heureEcheance != null ? '$dateEcheance à $heureEcheance' : dateEcheance)
        : '';

    Get.snackbar(
      'Tâche créée ! 🎉'.tr,
      isArabic
          ? 'تم تعيين المهمة « $titre » بنجاح إلى $assigneAffiche.'
          : 'La tâche « $titre » a été assignée avec succès à $assigneAffiche.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0D9488),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    return {
      'success': true,
      'tache_id': created.id.toString(),
      'titre': created.titre,
      'assigne_a': assigneAffiche,
      'priorite': priorite,
      'echeance': echeanceStr,
      'message': 'Tâche créée et assignée avec succès',
    };
  }

  Future<Map<String, Object?>> _fcCreerPlan(
    Map<String, Object?> args, {
    bool isArabic = false,
  }) async {
    // Patient depuis args ou depuis le patient sélectionné
    final patientIdArg = args['patient_id'] as String?;
    final patient = selectedPatient.value;
    final patientId = patientIdArg ?? patient?.id?.toString();

    if (patientId == null) {
      return {
        'error': isArabic
            ? 'يجب تحديد مريض لإنشاء خطة علاجية.'
            : 'Un patient doit être sélectionné pour créer un plan thérapeutique.',
        'success': false,
      };
    }

    final titre = (args['titre'] as String? ?? 'Plan thérapeutique IA').trim();
    final etapesRaw = args['etapes'] as List<dynamic>? ?? [];

    final createdPlan = await _planService.createPlan(patientId, {
      'titre': titre,
      'statut': 'actif',
    });

    for (int i = 0; i < etapesRaw.length; i++) {
      final e = etapesRaw[i];
      if (e is Map) {
        await _planService.createEtape(createdPlan.id, {
          'titre': e['titre'] ?? 'Étape ${i + 1}',
          'description': e['description'] ?? '',
          'ordre': e['ordre'] is int ? e['ordre'] : (i + 1),
          'statut': 'a_faire',
        });
      }
    }

    Get.snackbar(
      'Plan enregistré ! 🎉'.tr,
      isArabic
          ? 'تمت إضافة الخطة « $titre » بنجاح.'
          : 'Le plan « $titre » avec ${etapesRaw.length} étapes a été enregistré.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0D9488),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    return {
      'success': true,
      'plan_id': createdPlan.id.toString(),
      'titre': titre,
      'nombre_etapes': etapesRaw.length,
      'message': 'Plan thérapeutique créé avec succès',
    };
  }

  Future<Map<String, Object?>> _fcObtenirCalendrier(
    Map<String, Object?> args,
  ) async {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final dateDebut = (args['date_debut'] as String?)?.isNotEmpty == true
        ? args['date_debut'] as String
        : fmt(now);
    final dateFin = (args['date_fin'] as String?)?.isNotEmpty == true
        ? args['date_fin'] as String
        : fmt(weekEnd);

    final evenements = await _calendrierService.getEvenements(
      dateDebut: dateDebut,
      dateFin: dateFin,
    );

    final events = evenements.map((e) => {
          'date': e.date,
          'titre': e.titre,
          'description': e.description ?? '',
          'cree_par': e.creerPar ?? '',
        }).toList();

    return {
      'success': true,
      'periode': '$dateDebut → $dateFin',
      'nombre_evenements': events.length,
      'evenements': events,
    };
  }

  Future<Map<String, Object?>> _fcObtenirTaches(
    Map<String, Object?> args,
  ) async {
    final statut = args['statut'] as String?;
    final patientId = args['patient_id'] as String?;

    List taches;
    if (statut != null) {
      taches = await _tacheService.getTaches(
        statut: statut,
        patientId: patientId,
      );
    } else {
      final aFaire = await _tacheService.getTaches(statut: 'a_faire');
      final enCours = await _tacheService.getTaches(statut: 'en_cours');
      taches = [...aFaire, ...enCours];
    }

    final result = taches.map((t) {
      final assigneNom = t.assigneEmployee != null
          ? '${t.assigneEmployee!["prenom"] ?? ""} ${t.assigneEmployee!["nom"] ?? ""}'
              .trim()
          : 'Non assigné';
      final patientNom = t.patient != null
          ? '${t.patient!["nom"] ?? ""} ${t.patient!["prenom"] ?? ""}'.trim()
          : '';
      return {
        'id': t.id.toString(),
        'titre': t.titre,
        'statut': t.statut,
        'priorite': t.priorite,
        'assigne_a': assigneNom,
        'echeance': t.dateEcheance ?? '',
        'patient': patientNom,
        'description': t.description ?? '',
      };
    }).toList();

    return {
      'success': true,
      'nombre_taches': result.length,
      'taches': result,
    };
  }

  // ── Persistance ────────────────────────────────────────────────────────────

  Future<void> _persistActiveMessages() async {
    final curr = currentSession.value;
    if (curr != null) {
      curr.messages = List.from(messages);
      curr.updatedAt = DateTime.now();
      await _storage.saveSession(curr);
      sessions.value = await _storage.getAllSessions();
    }
  }

  // ── Commande vocale ────────────────────────────────────────────────────────

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
      Get.snackbar("Micro".tr, "Microphone non disponible".tr,
          snackPosition: SnackPosition.TOP);
      return;
    }
    final isArabic = (Get.locale?.languageCode == 'ar' ||
        LanguageService.currentLocale.value.languageCode == 'ar');
    isListening.value = true;
    _speech.listen(
      listenOptions:
          stt.SpeechListenOptions(localeId: isArabic ? "ar_DZ" : "fr_FR"),
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