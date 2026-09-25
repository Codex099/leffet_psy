import "dart:ui";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:get/get.dart";
import "../../controllers/assistant_ia_controller.dart";
import "../../models/chat_session_model.dart";
import "../../models/patient_model.dart";
import "../../services/patient_service.dart";
import "../../theme/app_colors.dart";
import "../../theme/app_text_styles.dart";
import "../../widgets/clinical_decorations.dart";
import "../../widgets/creative_app_bar.dart";

class AssistantIaView extends GetView<AssistantIaController> {
  const AssistantIaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: CreativeAppBar(
          title: "Assistant IA".tr,
          subtitle: "Gemini PsyCare".tr,
          showBackButton: true,
          actions: [
            // Bouton Historique des discussions
            BouncyTap(
              onTap: () {
                HapticFeedback.lightImpact();
                _showHistorySheet(context);
              },
              child: Container(
                padding: const EdgeInsets.all(9),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: const Icon(
                  Icons.forum_outlined,
                  size: 19,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Bouton Nouvelle discussion
            BouncyTap(
              onTap: () {
                HapticFeedback.lightImpact();
                controller.createNewSession();
              },
              child: Container(
                padding: const EdgeInsets.all(9),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  gradient: AppColors.oceanGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 19,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Contexte patient actif ou sélecteur
          _PatientContextHeader(controller: controller),
          _SuggestionsBar(controller: controller),
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: controller.messages.length,
              itemBuilder: (_, i) => _MessageBubble(
                message: controller.messages[i],
                index: i,
                controller: controller,
              ),
            )),
          ),
          _InputBar(controller: controller),
        ],
      ),
    );
  }

  /// Affiche l'historique et la gestion des discussions (CRUD)
  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DiscussionsModal(controller: controller),
    );
  }
}

// ── Header Contexte Patient (Sélecteur & Badge) ───────────────────────────────
class _PatientContextHeader extends StatelessWidget {
  final AssistantIaController controller;
  const _PatientContextHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final patient = controller.selectedPatient.value;
      final loadingData = controller.isLoadingPatientData.value;

      if (patient != null) {
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryUltraLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 0.9,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.oceanGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "${patient.nom} ${patient.prenom}",
                            style: AppTextStyles.iosSubhead.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (loadingData) ...[
                          const SizedBox(width: 6),
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      loadingData
                          ? "Synchronisation du dossier en cours...".tr
                          : "Dossier médical & antécédents synchronisés".tr,
                      style: AppTextStyles.iosCaption2.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton changer de patient
              IconButton(
                icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                color: AppColors.primary,
                tooltip: "Changer de patient".tr,
                onPressed: () => _openPatientPicker(context),
              ),
              // Bouton détacher patient
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.textTertiary,
                tooltip: "Détacher du dossier".tr,
                onPressed: () => controller.selectPatient(null),
              ),
            ],
          ),
        );
      }

      // Aucun patient lié : bouton incitatif discret
      return Container(
        margin: const EdgeInsets.fromLTRB(14, 6, 14, 2),
        child: InkWell(
          onTap: () => _openPatientPicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lier un dossier patient pour des analyses précises".tr,
                    style: AppTextStyles.iosCaption1.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _openPatientPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PatientPickerSheet(controller: controller),
    );
  }
}

// ── Modale de sélection de patient ───────────────────────────────────────────
class _PatientPickerSheet extends StatefulWidget {
  final AssistantIaController controller;
  const _PatientPickerSheet({required this.controller});

  @override
  State<_PatientPickerSheet> createState() => _PatientPickerSheetState();
}

class _PatientPickerSheetState extends State<_PatientPickerSheet> {
  final _searchCtrl = TextEditingController();
  final _patientService = PatientService();
  List<PatientModel> _allPatients = [];
  List<PatientModel> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final list = await _patientService.getPatients(actif: true);
      if (mounted) {
        setState(() {
          _allPatients = list;
          _filteredPatients = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients.where((p) {
          final nom = p.nom.toLowerCase();
          final prenom = p.prenom.toLowerCase();
          return nom.contains(q) || prenom.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Poignée
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sélectionner un patient".tr,
                  style: AppTextStyles.iosTitle3.copyWith(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Champ recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: "Rechercher par nom ou prénom...".tr,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.fieldBackground,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border, width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border, width: 0.8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? Center(
                        child: Text(
                          "Aucun patient trouvé".tr,
                          style: AppTextStyles.iosBody.copyWith(color: AppColors.textTertiary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredPatients.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final p = _filteredPatients[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppColors.oceanGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 22),
                            ),
                            title: Text(
                              "${p.nom} ${p.prenom}",
                              style: AppTextStyles.iosBody.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              p.dateNaissance != null
                                  ? "${"Né(e) le".tr} ${p.dateNaissance}"
                                  : "Dossier actif".tr,
                              style: AppTextStyles.iosCaption2.copyWith(color: AppColors.textSecondary),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                            onTap: () {
                              Navigator.pop(context);
                              widget.controller.selectPatient(p);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Modale Historique & Gestion des Discussions (CRUD) ────────────────────────
class _DiscussionsModal extends StatelessWidget {
  final AssistantIaController controller;
  const _DiscussionsModal({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Barre de drag
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
            child: Row(
              children: [
                Text(
                  "Historique des discussions".tr,
                  style: AppTextStyles.iosTitle3.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Bouton Nouvelle discussion
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: BouncyTap(
              onTap: () {
                Navigator.pop(context);
                controller.createNewSession();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.oceanGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_comment_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Nouvelle discussion".tr,
                      style: AppTextStyles.iosBody.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final list = controller.sessions;
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    "Aucune discussion enregistrée".tr,
                    style: AppTextStyles.iosBody.copyWith(color: AppColors.textTertiary),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: list.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final session = list[i];
                  final isCurrent = controller.currentSession.value?.id == session.id;

                  return Container(
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primaryUltraLight.withValues(alpha: 0.5)
                          : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          session.patientId != null
                              ? Icons.person_outline_rounded
                              : Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: isCurrent ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      title: Text(
                        session.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.iosBody.copyWith(
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                          color: isCurrent ? AppColors.primaryDark : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (session.patientName != null)
                            Container(
                              margin: const EdgeInsets.only(top: 2, bottom: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${"Patient :".tr} ${session.patientName}",
                                style: AppTextStyles.iosCaption2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Text(
                            session.previewText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.iosCaption2.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Éditer nom
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            color: AppColors.textSecondary,
                            tooltip: "Renommer".tr,
                            onPressed: () => _showRenameDialog(context, session),
                          ),
                          // Supprimer
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            color: AppColors.error,
                            tooltip: "Supprimer".tr,
                            onPressed: () => _confirmDelete(context, session),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        controller.loadSession(session.id);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, ChatSessionModel session) {
    final textCtrl = TextEditingController(text: session.title);
    Get.defaultDialog(
      title: "Renommer la discussion".tr,
      titleStyle: AppTextStyles.iosTitle3.copyWith(fontWeight: FontWeight.w700),
      content: Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: textCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Titre".tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      textConfirm: "Enregistrer".tr,
      textCancel: "Annuler".tr,
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        controller.renameSession(session.id, textCtrl.text);
        Get.back();
      },
    );
  }

  void _confirmDelete(BuildContext context, ChatSessionModel session) {
    Get.defaultDialog(
      title: "Supprimer la discussion ?".tr,
      middleText: "Voulez-vous vraiment supprimer cette discussion ?".tr,
      textConfirm: "Supprimer".tr,
      textCancel: "Annuler".tr,
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        controller.deleteSession(session.id);
        Get.back();
      },
    );
  }
}

// ── Barre de suggestions rapides ──────────────────────────────────────────────
class _SuggestionsBar extends StatelessWidget {
  final AssistantIaController controller;
  const _SuggestionsBar({required this.controller});

  static const _suggestions = [
    ("Proposer un plan thérapeutique", Icons.assignment_outlined),
    ("Synthèse clinique du dossier", Icons.person_search_rounded),
    ("Rédiger un compte-rendu", Icons.edit_note_rounded),
    ("Techniques TCC adaptées", Icons.psychology_rounded),
    ("Évaluation des objectifs", Icons.fact_check_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _suggestions.length,
        itemBuilder: (_, i) {
          final (label, icon) = _suggestions[i];
          return BouncyTap(
            onTap: () => controller.sendMessage(label.tr),
            child: Container(
              margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    label.tr,
                    style: AppTextStyles.iosCaption1.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Bulle de message ───────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final int index;
  final AssistantIaController controller;

  const _MessageBubble({
    required this.message,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _AvatarIA(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (isUser)
                  GestureDetector(
                    onLongPress: () => _showEditMessageModal(context),
                    child: _BubbleContent(message: message, isUser: isUser),
                  )
                else
                  _BubbleContent(message: message, isUser: isUser),
                const SizedBox(height: 3),
                if (isUser)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BouncyTap(
                        onTap: () => _showEditMessageModal(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              width: 0.6,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.edit_rounded,
                                size: 10.5,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "Modifier".tr,
                                style: AppTextStyles.iosCaption2.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(message.time),
                        style: AppTextStyles.iosCaption2.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    _formatTime(message.time),
                    style: AppTextStyles.iosCaption2.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index < 10 ? 0 : 100))
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.15, end: 0, duration: 250.ms);
  }

  void _showEditMessageModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditMessageSheet(
        message: message,
        index: index,
        controller: controller,
      ),
    );
  }

  String _formatTime(DateTime t) =>
      "${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}";
}

// ── Feuille de modification de message utilisateur ────────────────────────────
class _EditMessageSheet extends StatefulWidget {
  final ChatMessage message;
  final int index;
  final AssistantIaController controller;

  const _EditMessageSheet({
    required this.message,
    required this.index,
    required this.controller,
  });

  @override
  State<_EditMessageSheet> createState() => _EditMessageSheetState();
}

class _EditMessageSheetState extends State<_EditMessageSheet> {
  late final TextEditingController _textCtrl;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.message.text);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset + 12 : 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barre de drag
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // En-tête
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.oceanGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Modifier le message".tr,
                        style: AppTextStyles.iosTitle3.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Champ d'édition du texte
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: TextField(
                    controller: _textCtrl,
                    focusNode: _focusNode,
                    minLines: 2,
                    maxLines: 8,
                    style: AppTextStyles.iosBody.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "Texte du message...".tr,
                      border: InputBorder.none,
                      hintStyle: AppTextStyles.iosBody.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Raccourcis Copier / Copier dans la saisie
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(color: AppColors.border, width: 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Clipboard.setData(ClipboardData(text: _textCtrl.text));
                          Get.snackbar(
                            "Succès".tr,
                            "Message copié".tr,
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 14),
                        label: Text(
                          "Copier le message".tr,
                          style: AppTextStyles.iosCaption1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          widget.controller.copyToInput(_textCtrl.text);
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.input_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          "Copier dans la saisie".tr,
                          style: AppTextStyles.iosCaption1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Boutons d'action principaux
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Bouton Modifier et renvoyer à l'IA
                    BouncyTap(
                      onTap: () {
                        final newText = _textCtrl.text.trim();
                        if (newText.isEmpty) return;
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        widget.controller.editUserMessage(
                          widget.index,
                          newText,
                          resend: true,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: AppColors.oceanGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 17,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Modifier et renvoyer".tr,
                              style: AppTextStyles.iosCallout.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Bouton Enregistrer seulement
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        final newText = _textCtrl.text.trim();
                        if (newText.isEmpty) return;
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        widget.controller.editUserMessage(
                          widget.index,
                          newText,
                          resend: false,
                        );
                      },
                      child: Text(
                        "Enregistrer seulement".tr,
                        style: AppTextStyles.iosSubhead.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarIA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.oceanGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.psychology_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  const _BubbleContent({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: _TypingIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: isUser ? AppColors.oceanGradient : null,
        color: isUser ? null : AppColors.surfaceCard,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        border: isUser ? null : Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: isUser
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isUser
          ? Text(
              message.text,
              style: AppTextStyles.iosBody.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            )
          : MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: AppTextStyles.iosBody.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                h1: AppTextStyles.iosTitle3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
                h2: AppTextStyles.iosHeadline.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                h3: AppTextStyles.iosBody.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                strong: AppTextStyles.iosBody.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                listBullet: AppTextStyles.iosBody.copyWith(
                  color: AppColors.textSecondary,
                ),
                blockquoteDecoration: BoxDecoration(
                  color: AppColors.primaryUltraLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(color: AppColors.primary, width: 3),
                  ),
                ),
              ),
            ),
    );
  }
}

// ── Typing Indicator ───────────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..repeat(reverse: true, period: Duration(milliseconds: 900 + i * 150)),
    );
    _anims = _controllers
        .map((c) => Tween<double>(begin: 0, end: 6).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (context, child) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 7,
            height: 7 + _anims[i].value,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

// ── Barre de saisie ────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final AssistantIaController controller;
  const _InputBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottom),
          decoration: BoxDecoration(
            color: AppColors.frostedGlassColor.withValues(alpha: 0.94),
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Bouton micro
              Obx(() => BouncyTap(
                    onTap: controller.toggleVoice,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: controller.isListening.value
                            ? AppColors.accentGradient
                            : null,
                        color: controller.isListening.value
                            ? null
                            : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: controller.isListening.value
                              ? Colors.transparent
                              : AppColors.border,
                          width: 0.8,
                        ),
                        boxShadow: controller.isListening.value
                            ? [
                                BoxShadow(
                                  color: AppColors.error.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Tooltip(
                        message: controller.isListening.value
                            ? "Arrêter l'écoute".tr
                            : "Dictée vocale".tr,
                        child: Icon(
                          controller.isListening.value
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded,
                          size: 20,
                          color: controller.isListening.value
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(width: 8),
              // Champ texte
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: TextField(
                    controller: controller.textController,
                    maxLines: null,
                    onChanged: (v) => controller.inputText.value = v,
                    onSubmitted: (_) => controller.sendMessage(),
                    textInputAction: TextInputAction.newline,
                    style: AppTextStyles.iosBody.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "Posez votre question clinique...".tr,
                      hintStyle: AppTextStyles.iosBody.copyWith(
                        color: AppColors.textHint,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Bouton envoyer
              Obx(() {
                final hasText = controller.inputText.value.trim().isNotEmpty;
                final loading = controller.isLoading.value;
                return BouncyTap(
                  onTap: (hasText && !loading) ? controller.sendMessage : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: (hasText && !loading)
                          ? AppColors.oceanGradient
                          : null,
                      color: (hasText && !loading)
                          ? null
                          : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      boxShadow: (hasText && !loading)
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Tooltip(
                      message: "Envoyer".tr,
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.arrow_upward_rounded,
                              size: 20,
                              color: (hasText && !loading)
                                  ? Colors.white
                                  : AppColors.textTertiary,
                            ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}