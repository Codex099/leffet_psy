// ignore_for_file: use_null_aware_elements
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
import "../services/auth_service.dart";
import "../services/note_patient_service.dart";
import "../services/patient_service.dart";
import "../services/plan_therapeutique_service.dart";
import "../services/seance_service.dart";
import "../services/tache_service.dart";

class AssistantIaController extends GetxController {
  // Services
  final _storage = AssistantChatStorageService.instance;
  final _authService = AuthService();
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

  // RBAC & Auth state
  final isAdmin = false.obs;
  final currentUserId = "".obs;
  final currentUserName = "".obs;

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
          "إنشاء خطط علاجية، إدارة المهام، حجز الجلسات، والاطلاع على الرزنامة. "
          "كيف يمكنني مساعدتك اليوم؟";
    }
    return "Bonjour ! Je suis votre assistant clinique PsyCare. "
        "Je peux analyser des dossiers, rédiger des comptes-rendus, "
        "créer des plans thérapeutiques, des tâches, planifier des séances "
        "et consulter le calendrier. Comment puis-je vous aider ?";
  }

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
    _initGemini();
    _loadCurrentUserAndInit();
    _loadHistoryAndInit();

    ever(LanguageService.currentLocale, (_) => _initGemini());
  }

  Future<void> _loadCurrentUserAndInit() async {
    try {
      final user = await _authService.getCachedUser() ?? await _authService.getMe();
      isAdmin.value = (user.role.toLowerCase() == 'admin');
      currentUserId.value = user.id.toString();
      currentUserName.value = user.fullName;
    } catch (_) {}
    _initGemini();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ── Initialisation Gemini avec Function Calling ────────────────────────────

  /// Initialise le modèle Gemini avec le system prompt, le contexte patient
  /// et les outils de Function Calling natifs selon les droits RBAC de l'utilisateur.
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

    // Droits et sécurité RBAC
    if (isAdmin.value) {
      prompt += "\n\n=== PROFIL & DROITS : ADMINISTRATEUR ===\n"
          "Tu interagis avec un Administrateur du cabinet. Il dispose des droits de création de patients (creer_patient), "
          "de supervision globale des séances (obtenir_seances) et des tâches (obtenir_taches_employes).\n"
          "RÈGLE ABSOLUE : La suppression de données (delete) n'est JAMAIS autorisée via l'assistant.";
    } else {
      prompt += "\n\n=== PROFIL & DROITS : PRATICIEN / SPÉCIALISTE (${currentUserName.value.isNotEmpty ? currentUserName.value : 'Employé'}) ===\n"
          "Tu interagis avec un Praticien/Spécialiste de la structure. Ses droits sont strictement encadrés :\n"
          "- Séances : Il ne peut consulter QUE ses propres séances (obtenir_seances retourne uniquement son agenda). "
          "Il n'a JAMAIS accès aux séances des autres praticiens.\n"
          "- Tâches : Il ne consulte que ses tâches assignées (obtenir_taches_employes).\n"
          "- Patient : Il travaille sur le patient actuellement actif/sélectionné dans l'application. La création de nouveaux patients (creer_patient) ou la recherche globale ne lui sont pas permises.\n"
          "- Actions cliniques autorisées : Planifier des séances (creer_seance), ajouter des observations/notes (ajouter_note_patient), créer des tâches (creer_tache), et créer des plans thérapeutiques (creer_plan_therapeutique).\n"
          "RÈGLE ABSOLUE : La suppression de données (delete) n'est JAMAIS autorisée via l'assistant.";
    }

    // Contexte patient si disponible
    if (_lastExtraContext != null && _lastExtraContext!.isNotEmpty) {
      prompt += "\n\n=== CONTEXTE CLINIQUE DU DOSSIER PATIENT ===\n"
          "$_lastExtraContext\n"
          "Utilise ces données réelles pour répondre précisément.";
    }

    // Instructions pour les outils
    final adminToolLine = isAdmin.value
        ? "- creer_patient : Enregistrer un nouveau dossier patient. Exige nom, prénom, sexe (masculin/feminin), et date de naissance.\n"
        : "";
    prompt += "\n\n=== GUIDE D'UTILISATION DES OUTILS (FUNCTION CALLING) ===\n"
        "Tu as accès aux outils PsyCare autorisés pour ce compte. Utilise-les de façon proactive et rigoureuse :\n"
        "$adminToolLine"
        "- creer_plan_therapeutique : Structurer un plan thérapeutique clinique à 3 niveaux (Plan > Étapes > Sous-étapes/Séances). "
        "Pour chaque étape, fournis les sous-étapes représentant les séances avec le déroulement précis (exercices, consignes, matériel) "
        "et le spécialiste assigné si mentionné.\n"
        "- obtenir_plans_therapeutiques : Consulter les plans du patient avec l'état d'avancement de toutes leurs étapes et séances.\n"
        "- ajouter_seance_au_plan : Ajouter une séance (sous-étape) détaillée dans une étape d'un plan thérapeutique existant.\n"
        "- creer_tache : Créer et assigner une tâche clinique ou administrative (exige TOUJOURS la date d'échéance YYYY-MM-DD).\n"
        "- obtenir_taches_employes : Consulter les tâches en cours (filtrables par statut ou patient).\n"
        "- creer_seance : Planifier une consultation individuelle dans l'agenda (date YYYY-MM-DD, heure_debut HH:MM, heure_fin HH:MM, assigne_a_nom optionnel).\n"
        "- obtenir_seances : Consulter les séances de consultation prévues ou passées pour une date donnée.\n"
        "- obtenir_calendrier : Consulter les événements, réunions ou ateliers généraux du calendrier.\n"
        "- ajouter_note_patient : Consigner une observation clinique, un bilan ou une note d'évolution dans le dossier patient.\n\n"
        "=== RÈGLES DE DÉCISION CLINIQUE ===\n"
        "1. Lorsque le praticien demande un plan d'intervention ou des propositions de séances, structure un plan complet avec ses étapes et ses séances (sous-étapes avec déroulement), puis appelle creer_plan_therapeutique.\n"
        "2. Si des informations obligatoires manquent (ex: date/heure pour une séance, nom/prénom pour un patient), demande-les poliment à l'utilisateur avant d'appeler l'outil.\n"
        "3. RÈGLE STRICTE : La suppression de données (delete) n'est JAMAIS autorisée via l'assistant. Si l'utilisateur demande de supprimer quoi que ce soit, refuse poliment en expliquant que la suppression n'est pas autorisée par sécurité.";

    final tools = isAdmin.value ? GeminiTools.adminTools : GeminiTools.employeeTools;

    _model = GenerativeModel(
      model: overrideModel ?? GeminiConfig.model,
      apiKey: GeminiConfig.apiKey,
      systemInstruction: Content.system(prompt),
      tools: tools,
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

      try {
        final plans = await _planService.getPlansPatient(patient.id);
        if (plans.isNotEmpty) {
          buffer.writeln("\n--- PLANS THÉRAPEUTIQUES ACTUELS ---");
          for (final p in plans.take(3)) {
            final pAssign = p.assigneNom != null
                ? " (Assigné à: ${p.assigneNom})"
                : "";
            buffer.writeln("Plan #${p.id} : ${p.titre} [Statut: ${p.statut}]$pAssign");
            final pEtapes = p.etapes;
            if (pEtapes != null && pEtapes.isNotEmpty) {
              for (final e in pEtapes) {
                final eAssign = e.assigneNom != null
                    ? " (Assigné: ${e.assigneNom})"
                    : "";
                buffer.writeln("  - Étape #${e.id}: ${e.titre} [${e.statut}]$eAssign");
                final pSousEtapes = e.sousEtapes;
                if (pSousEtapes != null && pSousEtapes.isNotEmpty) {
                  for (final se in pSousEtapes) {
                    final seAssign = se.assigneNom != null
                        ? " [Resp: ${se.assigneNom}]"
                        : "";
                    final consignes = (se.description != null && se.description!.isNotEmpty)
                        ? " - Objectifs: ${se.description}"
                        : "";
                    buffer.writeln("    * Séance #${se.id}: ${se.titre}$consignes [${se.statut}]$seAssign");
                  }
                }
              }
            }
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
          _initGemini(overrideModel: "gemini-flash-latest");
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
      'obtenir_plans_therapeutiques': 'Consultation des plans thérapeutiques',
      'ajouter_seance_au_plan': 'Ajout d’une séance au plan',
      'obtenir_calendrier': 'Consultation du calendrier',
      'obtenir_taches_employes': "Récupération des tâches",
      'obtenir_seances': 'Consultation des séances',
      'creer_seance': 'Planification de la séance',
      'ajouter_note_patient': 'Ajout de la note clinique',
    };
    const labelsAr = {
      'creer_patient': 'إنشاء ملف المريض',
      'creer_tache': 'إنشاء المهمة',
      'creer_plan_therapeutique': 'إنشاء الخطة العلاجية',
      'obtenir_plans_therapeutiques': 'استرجاع الخطط العلاجية',
      'ajouter_seance_au_plan': 'إضافة جلسة للخطة',
      'obtenir_calendrier': 'استرجاع الرزنامة',
      'obtenir_taches_employes': "استرجاع المهام",
      'obtenir_seances': 'استرجاع الجلسات',
      'creer_seance': 'حجز الجلسة',
      'ajouter_note_patient': 'إضافة ملاحظة سريرية',
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
          if (!isAdmin.value) {
            return {
              'success': false,
              'error': isArabic
                  ? 'عذراً، صلاحية إنشاء المرضى مقتصرة على إدارة العيادة فقط.'
                  : 'Action non autorisée : la création de patients est réservée aux administrateurs.',
            };
          }
          return await _fcCreerPatient(args, isArabic: isArabic);

        case 'creer_tache':
          return await _fcCreerTache(args, isArabic: isArabic);

        case 'creer_plan_therapeutique':
          return await _fcCreerPlan(args, isArabic: isArabic);

        case 'obtenir_plans_therapeutiques':
          return await _fcObtenirPlansTherapeutiques(args, isArabic: isArabic);

        case 'ajouter_seance_au_plan':
          return await _fcAjouterSeanceAuPlan(args, isArabic: isArabic);

        case 'obtenir_calendrier':
          return await _fcObtenirCalendrier(args);

        case 'obtenir_taches_employes':
          return await _fcObtenirTaches(args);

        case 'obtenir_seances':
          return await _fcObtenirSeances(args);

        case 'creer_seance':
          return await _fcCreerSeance(args, isArabic: isArabic);

        case 'ajouter_note_patient':
          return await _fcAjouterNotePatient(args, isArabic: isArabic);

        default:
          return {
            'error': 'Outil inconnu ou non autorisé : ${call.name}',
            'success': false,
          };
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

  /// Résout un employé à partir d'un nom ou prénom partiel
  Future<Map<String, String>?> _resolveEmployee(String? nameQuery) async {
    if (nameQuery == null || nameQuery.trim().isEmpty) return null;
    final q = nameQuery.trim().toLowerCase();
    try {
      final employees = await _employeeService.getEmployees();
      final found = employees.firstWhereOrNull((e) {
        final prenomNom = "${e.prenom} ${e.nom}".toLowerCase();
        final nomPrenom = "${e.nom} ${e.prenom}".toLowerCase();
        final nom = e.nom.toLowerCase();
        final prenom = e.prenom.toLowerCase();
        return prenomNom.contains(q) ||
            nomPrenom.contains(q) ||
            nom.contains(q) ||
            prenom.contains(q);
      });
      if (found != null) {
        return {
          'id': found.id.toString(),
          'nom': "${found.prenom} ${found.nom}".trim(),
        };
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, Object?>> _fcCreerTache(
    Map<String, Object?> args, {
    bool isArabic = false,
  }) async {
    final titre = (args['titre'] as String? ?? 'Tâche clinique').trim();
    final description = args['description'] as String? ?? '';
    final assigneNomRaw = (args['assigne_a_nom'] as String? ?? '').trim();
    final priorite = args['priorite'] as String? ?? 'normale';
    final dateEcheance = args['date_echeance'] as String?;
    final heureEcheance = args['heure_echeance'] as String?;
    final patientIdArg = args['patient_id'] as String?;

    // Résoudre l'employé
    String? assigneId;
    String assigneAffiche = assigneNomRaw.isNotEmpty ? assigneNomRaw : 'Équipe';

    if (assigneNomRaw.isNotEmpty) {
      final res = await _resolveEmployee(assigneNomRaw);
      if (res != null) {
        assigneId = res['id'];
        assigneAffiche = res['nom']!;
      }
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

    final titre = (args['titre'] as String? ?? 'Plan thérapeutique').trim();
    final description = args['description'] as String?;
    final planAssigneNom = args['assigne_a_nom'] as String?;
    final etapesRaw = args['etapes'] as List<dynamic>? ?? [];

    String? planEmployeeId;
    String? planEmployeeNom;
    if (planAssigneNom != null && planAssigneNom.isNotEmpty) {
      final res = await _resolveEmployee(planAssigneNom);
      if (res != null) {
        planEmployeeId = res['id'];
        planEmployeeNom = res['nom'];
      }
    }

    final planPayload = <String, dynamic>{
      'titre': titre,
      'statut': 'actif',
      if (description != null && description.isNotEmpty) 'description': description,
      if (planEmployeeId != null) 'assigne_a': planEmployeeId,
    };

    final createdPlan = await _planService.createPlan(patientId, planPayload);

    int totalSousEtapes = 0;
    final etapesDetails = <Map<String, dynamic>>[];

    for (int i = 0; i < etapesRaw.length; i++) {
      final e = etapesRaw[i];
      if (e is Map) {
        final etapeTitre = (e['titre'] as String? ?? 'Étape ${i + 1}').trim();
        final etapeDesc = e['description'] as String? ?? '';
        final etapeOrdre = e['ordre'] is int ? e['ordre'] as int : (i + 1);
        final etapeAssigneNom = e['assigne_a_nom'] as String?;

        String? etapeEmployeeId;
        String? etapeEmployeeNom;
        if (etapeAssigneNom != null && etapeAssigneNom.isNotEmpty) {
          final res = await _resolveEmployee(etapeAssigneNom);
          if (res != null) {
            etapeEmployeeId = res['id'];
            etapeEmployeeNom = res['nom'];
          }
        }

        final etapePayload = <String, dynamic>{
          'titre': etapeTitre,
          if (etapeDesc.isNotEmpty) 'description': etapeDesc,
          'ordre': etapeOrdre,
          'statut': 'a_faire',
          if (etapeEmployeeId != null) 'assigne_a': etapeEmployeeId,
        };

        final createdEtape = await _planService.createEtape(createdPlan.id, etapePayload);

        // Sous-étapes (Séances d'application avec consignes)
        final sousEtapesRaw = e['sous_etapes'] as List<dynamic>? ?? [];
        final sousEtapesDetails = <Map<String, dynamic>>[];

        for (int j = 0; j < sousEtapesRaw.length; j++) {
          final se = sousEtapesRaw[j];
          if (se is Map) {
            final seTitre = (se['titre'] as String? ?? 'Séance ${j + 1}').trim();
            final seDesc = se['description'] as String? ?? '';
            final seOrdre = se['ordre'] is int ? se['ordre'] as int : (j + 1);
            final seAssigneNom = se['assigne_a_nom'] as String?;
            final seDate = se['date_prevue'] as String?;
            final seHeureDeb = se['heure_debut'] as String?;
            final seHeureFin = se['heure_fin'] as String?;

            String? seEmployeeId;
            String? seEmployeeNom;
            if (seAssigneNom != null && seAssigneNom.isNotEmpty) {
              final res = await _resolveEmployee(seAssigneNom);
              if (res != null) {
                seEmployeeId = res['id'];
                seEmployeeNom = res['nom'];
              }
            }

            final sePayload = <String, dynamic>{
              'titre': seTitre,
              if (seDesc.isNotEmpty) 'description': seDesc,
              'ordre': seOrdre,
              'statut': 'a_faire',
              if (seEmployeeId != null) 'assigne_a': seEmployeeId,
              if (seDate != null && seDate.isNotEmpty) 'date_prevue': seDate,
              if (seHeureDeb != null && seHeureDeb.isNotEmpty) 'heure_debut': seHeureDeb,
              if (seHeureFin != null && seHeureFin.isNotEmpty) 'heure_fin': seHeureFin,
            };

            final createdSousEtape = await _planService.createSousEtape(
              createdPlan.id,
              createdEtape.id,
              sePayload,
            );

            totalSousEtapes++;
            sousEtapesDetails.add({
              'id': createdSousEtape.id.toString(),
              'titre': createdSousEtape.titre,
              'description': createdSousEtape.description ?? '',
              'assigne_a': seEmployeeNom ?? 'Non assigné',
              'date_prevue': createdSousEtape.datePrevue ?? '',
            });
          }
        }

        etapesDetails.add({
          'id': createdEtape.id.toString(),
          'titre': createdEtape.titre,
          'assigne_a': etapeEmployeeNom ?? 'Non assigné',
          'nombre_seances': sousEtapesDetails.length,
          'seances': sousEtapesDetails,
        });
      }
    }

    final summaryMsg = isArabic
        ? 'تم إنشاء الخطة « $titre » بنجاح وتتضمن ${etapesRaw.length} مراحل و $totalSousEtapes جلسات.'
        : 'Le plan « $titre » a été enregistré avec ${etapesRaw.length} étapes et $totalSousEtapes séances.';

    Get.snackbar(
      'Plan enregistré ! 🎉'.tr,
      summaryMsg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0D9488),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    return {
      'success': true,
      'plan_id': createdPlan.id.toString(),
      'titre': titre,
      'assigne_a': planEmployeeNom ?? 'Non assigné',
      'nombre_etapes': etapesRaw.length,
      'nombre_sous_etapes_seances': totalSousEtapes,
      'etapes': etapesDetails,
      'message': 'Plan thérapeutique et ses séances créés avec succès',
    };
  }

  Future<Map<String, Object?>> _fcObtenirPlansTherapeutiques(
    Map<String, Object?> args, {
    bool isArabic = false,
  }) async {
    final patientIdArg = args['patient_id'] as String?;
    final pid = patientIdArg ?? selectedPatient.value?.id?.toString();

    if (pid == null || pid.isEmpty) {
      return {
        'success': false,
        'error': isArabic
            ? 'يرجى فتح أو تحديد ملف مريض لعرض الخطط العلاجية.'
            : 'Aucun patient actif sélectionné. Veuillez sélectionner un patient.',
      };
    }

    final plans = await _planService.getPlansPatient(pid);

    final list = plans.map((p) {
      final assignePlanNom = p.assigneNom;

      final pEtapes = p.etapes;
      final etapesList = (pEtapes ?? []).map((e) {
        final assigneEtapeNom = e.assigneNom;
        final pSousEtapes = e.sousEtapes;
        final sousEtapesList = (pSousEtapes ?? []).map((se) {
          final assigneSeanceNom = se.assigneNom;
          return {
            'id': se.id.toString(),
            'titre': se.titre,
            'description': se.description ?? '',
            'statut': se.statut,
            'date_prevue': se.datePrevue ?? '',
            'assigne_a': assigneSeanceNom ?? 'Non assigné',
          };
        }).toList();

        return {
          'id': e.id.toString(),
          'titre': e.titre,
          'description': e.description ?? '',
          'statut': e.statut,
          'ordre': e.ordre,
          'assigne_a': assigneEtapeNom ?? 'Non assigné',
          'seances_sous_etapes': sousEtapesList,
        };
      }).toList();

      return {
        'id': p.id.toString(),
        'titre': p.titre,
        'statut': p.statut,
        'assigne_a': assignePlanNom ?? 'Non assigné',
        'nombre_etapes': pEtapes?.length ?? 0,
        'etapes': etapesList,
      };
    }).toList();

    return {
      'success': true,
      'patient_id': pid,
      'nombre_plans': list.length,
      'plans': list,
    };
  }

  Future<Map<String, Object?>> _fcAjouterSeanceAuPlan(
    Map<String, Object?> args, {
    bool isArabic = false,
  }) async {
    final planId = args['plan_id']?.toString();
    final etapeId = args['etape_id']?.toString();
    final titre = (args['titre'] as String? ?? '').trim();
    final description = args['description'] as String? ?? '';
    final assigneNom = args['assigne_a_nom'] as String?;
    final datePrevue = args['date_prevue'] as String?;
    final heureDebut = args['heure_debut'] as String?;
    final heureFin = args['heure_fin'] as String?;
    final ordre = args['ordre'] as int?;

    if (planId == null || planId.isEmpty || etapeId == null || etapeId.isEmpty) {
      return {
        'success': false,
        'error': isArabic
            ? 'يجب توفير معرف الخطة (plan_id) ومعرف المرحلة (etape_id).'
            : 'plan_id et etape_id sont requis.',
      };
    }

    if (titre.isEmpty) {
      return {
        'success': false,
        'error': isArabic
            ? 'عنوان الجلسة إلزامي.'
            : 'Le titre de la séance est obligatoire.',
      };
    }

    String? assigneId;
    String? assigneAffiche;
    if (assigneNom != null && assigneNom.isNotEmpty) {
      final res = await _resolveEmployee(assigneNom);
      if (res != null) {
        assigneId = res['id'];
        assigneAffiche = res['nom'];
      }
    }

    final payload = <String, dynamic>{
      'titre': titre,
      if (description.isNotEmpty) 'description': description,
      'statut': 'a_faire',
      if (ordre != null) 'ordre': ordre,
      if (assigneId != null) 'assigne_a': assigneId,
      if (datePrevue != null && datePrevue.isNotEmpty) 'date_prevue': datePrevue,
      if (heureDebut != null && heureDebut.isNotEmpty) 'heure_debut': heureDebut,
      if (heureFin != null && heureFin.isNotEmpty) 'heure_fin': heureFin,
    };

    final created = await _planService.createSousEtape(planId, etapeId, payload);

    Get.snackbar(
      'Séance ajoutée ! 🎯'.tr,
      isArabic
          ? 'تمت إضافة الجلسة « $titre » للمرحلة بنجاح.'
          : 'La séance « $titre » a été ajoutée à l\'étape du plan.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0D9488),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    return {
      'success': true,
      'sous_etape_id': created.id.toString(),
      'titre': created.titre,
      'description': created.description ?? '',
      'assigne_a': assigneAffiche ?? 'Non assigné',
      'date_prevue': created.datePrevue ?? '',
      'message': 'Séance ajoutée avec succès au plan thérapeutique',
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

    // Pour les non-admins : restreindre strictement aux tâches assignées à l'utilisateur connecté
    final bool? assigneesAMoi = isAdmin.value ? null : true;

    List taches;
    if (statut != null) {
      taches = await _tacheService.getTaches(
        statut: statut,
        patientId: patientId,
        assigneesAMoi: assigneesAMoi,
      );
    } else {
      final aFaire = await _tacheService.getTaches(
        statut: 'a_faire',
        patientId: patientId,
        assigneesAMoi: assigneesAMoi,
      );
      final enCours = await _tacheService.getTaches(
        statut: 'en_cours',
        patientId: patientId,
        assigneesAMoi: assigneesAMoi,
      );
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

  Future<Map<String, Object?>> _fcObtenirSeances(
    Map<String, Object?> args,
  ) async {
    final date = args['date'] as String?;
    final patientIdArg = args['patient_id'] as String?;
    final pid = patientIdArg ?? selectedPatient.value?.id?.toString();

    // SÉCURITÉ RBAC ABSOLUE :
    // Si l'utilisateur n'est pas admin, il ne peut JAMAIS voir les séances des autres employés.
    // On force strictement son propre ID comme filtre employé.
    dynamic employeFilter;
    if (isAdmin.value) {
      employeFilter = args['employe_id'];
    } else {
      employeFilter =
          currentUserId.value.isNotEmpty ? currentUserId.value : null;
    }

    final seances = await _seanceService.getSeances(
      date: (date?.isNotEmpty == true) ? date : null,
      patientId: pid,
      employeId: employeFilter,
    );

    final list = seances.map((s) {
      final pNom = s.patient != null
          ? '${s.patient!["nom"] ?? ""} ${s.patient!["prenom"] ?? ""}'.trim()
          : '';
      return {
        'id': s.id.toString(),
        'date': s.date,
        'heure_debut': s.heureDebut,
        'heure_fin': s.heureFin,
        'statut': s.statut,
        'patient': pNom.isNotEmpty
            ? pNom
            : (selectedPatient.value != null
                ? '${selectedPatient.value!.nom} ${selectedPatient.value!.prenom}'
                : 'Patient #${s.patientId}'),
        'statut_presence': s.statutPresence ?? '',
        'motif_statut': s.motifStatut ?? '',
      };
    }).toList();

    return {
      'success': true,
      'nombre_seances': list.length,
      'filtre_employe_personnel': !isAdmin.value,
      'seances': list,
    };
  }

  Future<Map<String, Object?>> _fcCreerSeance(
    Map<String, Object?> args, {
    bool isArabic = false,
  }) async {
    final date = (args['date'] as String? ?? '').trim();
    final heureDebut = (args['heure_debut'] as String? ?? '').trim();
    final heureFin = (args['heure_fin'] as String? ?? '').trim();
    final patientIdArg = args['patient_id'] as String?;
    final assigneNom = args['assigne_a_nom'] as String?;

    final pid = patientIdArg ?? selectedPatient.value?.id?.toString();
    if (pid == null || pid.isEmpty) {
      return {
        'success': false,
        'error': isArabic
            ? 'يرجى تحديد أو فتح ملف مريض أولاً لحجز الجلسة.'
            : 'Aucun patient actif sélectionné. Veuillez d\'abord sélectionner un dossier patient.',
      };
    }

    if (date.isEmpty || heureDebut.isEmpty || heureFin.isEmpty) {
      return {
        'success': false,
        'error': 'La date, l\'heure de début et l\'heure de fin sont obligatoires.',
      };
    }

    String? employeId;
    String? employeNom;
    if (assigneNom != null && assigneNom.isNotEmpty) {
      final res = await _resolveEmployee(assigneNom);
      if (res != null) {
        employeId = res['id'];
        employeNom = res['nom'];
      }
    }
    employeId ??= currentUserId.value.isNotEmpty ? currentUserId.value : null;

    final payload = <String, dynamic>{
      'patient_id': pid,
      'date': date,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'statut': 'prevue',
      if (employeId != null) 'employe_ids': [employeId],
    };

    final created = await _seanceService.createSeance(payload);

    final snackMsg = isArabic
        ? 'تم حجز الجلسة بنجاح ليوم $date ($heureDebut - $heureFin)${employeNom != null ? " مع $employeNom" : ""}'
        : 'Séance planifiée le $date de $heureDebut à $heureFin${employeNom != null ? " avec $employeNom" : ""}';

    Get.snackbar(
      'Séance planifiée ! 📅'.tr,
      snackMsg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0D9488),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    return {
      'success': true,
      'seance_id': created.id.toString(),
      'date': created.date,
      'heure_debut': created.heureDebut,
      'heure_fin': created.heureFin,
      'assigne_a': employeNom ?? currentUserName.value,
      'patient_id': pid,
      'message': 'Séance planifiée avec succès',
    };
  }

  Future<Map<String, Object?>> _fcAjouterNotePatient(
    Map<String, Object?> args, {
    bool isArabic = false,
  }) async {
    final contenu = (args['contenu'] as String? ?? '').trim();
    final patientIdArg = args['patient_id'] as String?;
    final pid = patientIdArg ?? selectedPatient.value?.id?.toString();

    if (pid == null || pid.isEmpty) {
      return {
        'success': false,
        'error': isArabic
            ? 'يرجى تحديد أو فتح ملف مريض أولاً لإضافة ملاحظة سريرية.'
            : 'Aucun patient actif. Veuillez sélectionner un patient pour consigner une note.',
      };
    }

    if (contenu.isEmpty) {
      return {
        'success': false,
        'error': 'Le contenu de la note clinique est obligatoire.',
      };
    }

    final res = await _noteService.createNote(pid, {'contenu': contenu});

    Get.snackbar(
      'Note ajoutée 📝'.tr,
      isArabic
          ? 'تمت إضافة الملاحظة السريرية في ملف المريض.'
          : 'Note clinique consignée avec succès dans le dossier.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0D9488),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    return {
      'success': true,
      'note_id': res['id']?.toString() ?? '',
      'patient_id': pid,
      'contenu': contenu,
      'message': 'Note ajoutée au dossier avec succès',
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