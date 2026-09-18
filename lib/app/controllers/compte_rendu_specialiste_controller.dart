import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/plan_therapeutique_model.dart';
import '../models/seance_groupe_model.dart';
import '../models/seance_model.dart';
import '../services/auth_service.dart';
import '../services/employee_service.dart';
import '../services/plan_therapeutique_service.dart';
import '../services/seance_groupe_service.dart';
import '../services/seance_service.dart';
import '../services/tache_service.dart';
import '../utils/json_utils.dart';
import 'accueil_controller.dart';
import 'agenda_controller.dart';

/// Participant model for group session report
class ParticipantPresenceNote {
  final dynamic patientId;
  final String patientNom;
  final String patientPrenom;
  final String? photoUrl;
  final RxString statutPresence; // 'present' | 'absent' | 'excuse'
  final RxString noteIndividuelle;
  final TextEditingController noteController;

  ParticipantPresenceNote({
    required this.patientId,
    required this.patientNom,
    required this.patientPrenom,
    this.photoUrl,
    String initialPresence = 'present',
    String initialNote = '',
  })  : statutPresence = initialPresence.obs,
        noteIndividuelle = initialNote.obs,
        noteController = TextEditingController(text: initialNote);

  String get fullName => '$patientPrenom $patientNom'.trim();
  String get initials {
    final p = patientPrenom.isNotEmpty ? patientPrenom[0].toUpperCase() : '';
    final n = patientNom.isNotEmpty ? patientNom[0].toUpperCase() : '';
    return '$p$n'.isEmpty ? 'P' : '$p$n';
  }
}

class CompteRenduSpecialisteController extends GetxController {
  final SeanceService _seanceService = SeanceService();
  final SeanceGroupeService _seanceGroupeService = SeanceGroupeService();
  final EmployeeService _employeeService = EmployeeService();
  final PlanTherapeutiqueService _planService = PlanTherapeutiqueService();
  final TacheService _tacheService = TacheService();
  final AuthService _authService = AuthService();

  final RxString status = 'loading'.obs; // 'loading' | 'success' | 'error' | 'unauthorized'
  final RxString errorMessage = ''.obs;

  // Session identification
  dynamic seanceId;
  final RxBool isGroupe = false.obs;

  // Models
  final Rx<SeanceModel?> seanceIndiv = Rx<SeanceModel?>(null);
  final Rx<SeanceGroupeModel?> seanceGroupe = Rx<SeanceGroupeModel?>(null);

  // Specialist / Responsible
  final RxList<EmployeeModel> praticiens = <EmployeeModel>[].obs;
  final Rx<dynamic> selectedResponsableId = Rx<dynamic>(null);

  // Current user & Permissions
  final Rx<EmployeeModel?> currentUser = Rx<EmployeeModel?>(null);
  final RxBool isAuthor = false.obs;
  final RxBool isAdmin = false.obs;
  final RxBool canEdit = false.obs;
  final RxBool isAlreadyValidated = false.obs;

  // Form fields - General
  final TextEditingController clinicalNotesController = TextEditingController();
  final RxString statutPresence = 'present'.obs; // 'present' | 'excuse' | 'absent'
  final RxString descriptionEtat = ''.obs; // Observations cliniques
  final RxString objectifsTravailles = ''.obs; // Objectifs de séance
  final Rx<dynamic> etapePlanId = Rx<dynamic>(null);
  final RxList<EtapePlanTherapeutiqueModel> etapesDisponibles = <EtapePlanTherapeutiqueModel>[].obs;
  final RxList<String> medias = <String>[].obs;

  // Group session participants
  final RxList<ParticipantPresenceNote> participants = <ParticipantPresenceNote>[].obs;

  // ── Section Rappels & Notifications de Suivi ──
  final RxBool activerRappel = false.obs;
  final RxString rappelDate = ''.obs;
  final RxString rappelMessage = ''.obs;
  final RxString rappelPriorite = 'normale'.obs; // 'normale' | 'haute'
  final RxBool notifierEquipe = true.obs;

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    clinicalNotesController.addListener(() {
      descriptionEtat.value = clinicalNotesController.text;
    });
    loadData();
  }

  @override
  void onClose() {
    clinicalNotesController.dispose();
    for (final p in participants) {
      p.noteController.dispose();
    }
    super.onClose();
  }

  void _parseArguments() {
    final args = Get.arguments;
    if (args is Map) {
      seanceId = extractIdParam(args['seance_id'] ?? args['id'], Get.parameters);
      isGroupe.value = args['is_groupe'] == true || args['type'] == 'groupe';
    } else {
      seanceId = extractIdParam(args, Get.parameters);
    }
  }

  Future<void> loadData() async {
    if (seanceId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant de séance non spécifié.'.tr;
      return;
    }

    try {
      status.value = 'loading';

      // 1. Charger la liste des praticiens
      try {
        final emps = await _employeeService.getEmployees();
        praticiens.value = emps;
      } catch (_) {}

      // 2. Utilisateur connecté
      EmployeeModel? me;
      try {
        me = await _authService.getMe();
        currentUser.value = me;
        isAdmin.value = me.isAdmin;
      } catch (_) {}

      // 3. Charger la séance (individuelle ou groupe)
      if (isGroupe.value) {
        await _loadGroupeSession(me);
      } else {
        try {
          await _loadIndivSession(me);
        } catch (e) {
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('403') || errStr.contains('autoris') || errStr.contains('interdit')) {
            status.value = 'unauthorized';
            errorMessage.value =
                "Vous n'êtes pas assigné(e) à ce patient. Vous n'avez pas l'autorisation de consulter ce compte-rendu médical.".tr;
            return;
          }
          // Si échec de chargement indiv, tenter en tant que séance de groupe
          isGroupe.value = true;
          await _loadGroupeSession(me);
        }
      }

      // Si le statut est passé en unauthorized pendant le chargement
      if (status.value == 'unauthorized') return;

      // Initialiser date de rappel par défaut à J+7
      if (rappelDate.value.isEmpty) {
        final j7 = DateTime.now().add(const Duration(days: 7));
        rappelDate.value = j7.toIso8601String().split('T').first;
      }

      status.value = 'success';
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('403') || errStr.contains('autoris') || errStr.contains('interdit')) {
        status.value = 'unauthorized';
        errorMessage.value =
            "Vous n'êtes pas assigné(e) à ce patient. Vous n'avez pas l'autorisation de consulter ce compte-rendu médical.".tr;
      } else {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
    }
  }

  Future<void> _loadIndivSession(EmployeeModel? me) async {
    final s = await _seanceService.getSeance(seanceId);
    seanceIndiv.value = s;

    // Statut de validation
    isAlreadyValidated.value = s.statut == 'faite';

    // Règle 1 : Vérifier si l'employé est concerné par ce patient
    if (me != null && !me.isAdmin) {
      final assignedPatients = me.patientsAssignesIds?.map((id) => id.toString()).toList() ?? [];
      final pIdStr = s.patientId?.toString();
      final bool hasPatientAccess = pIdStr != null && assignedPatients.contains(pIdStr);
      final bool isAssignedInSession = s.employeIds.any((id) => id.toString() == me.id.toString()) ||
          (s.employe != null && s.employe!['id']?.toString() == me.id.toString());

      if (!hasPatientAccess && !isAssignedInSession) {
        status.value = 'unauthorized';
        errorMessage.value =
            "Vous n'êtes pas assigné(e) à ce patient. Vous ne pouvez pas consulter ce compte-rendu médical.".tr;
        return;
      }
    }

    // Règle 2 : Déterminer si l'utilisateur est l'auteur
    if (s.employeIds.isNotEmpty) {
      selectedResponsableId.value = s.employeIds.first;
    } else if (s.employe != null && s.employe!['id'] != null) {
      selectedResponsableId.value = s.employe!['id'];
    } else if (selectedResponsableId.value == null && me != null) {
      selectedResponsableId.value = me.id;
    }

    final bool userIsAuthor = me != null &&
        (s.employeIds.any((id) => id.toString() == me.id.toString()) ||
            (s.employe != null && s.employe!['id']?.toString() == me.id.toString()) ||
            (s.employeIds.isEmpty && selectedResponsableId.value?.toString() == me.id.toString()));

    isAuthor.value = userIsAuthor;

    // Règle 3 : Autorisations de modification :
    // - L'auteur a le droit de modifier (canEdit = true)
    // - L'administrateur N'A PAS le droit de modifier (canEdit = false) -> lecture seule
    // - Un utilisateur non-auteur n'a pas le droit de modifier
    if (me != null && me.isAdmin) {
      canEdit.value = false;
    } else {
      canEdit.value = userIsAuthor;
    }

    // Données de séance
    descriptionEtat.value = s.descriptionEtat ?? '';
    clinicalNotesController.text = descriptionEtat.value;
    medias.value = s.medias ?? [];
    statutPresence.value = s.statutPresence ?? 'present';

    // Charger les étapes du plan thérapeutique du patient si disponible
    if (s.patientId != null) {
      try {
        final plans = await _planService.getPlansPatient(s.patientId);
        if (plans.isNotEmpty) {
          final etapes = await _planService.getEtapes(plans.first.id);
          etapesDisponibles.value = etapes;
        }
      } catch (_) {}
    }
  }

  Future<void> _loadGroupeSession(EmployeeModel? me) async {
    final s = await _seanceGroupeService.getSeanceGroupe(seanceId);
    seanceGroupe.value = s;

    isAlreadyValidated.value = s.statut == 'faite';

    // Règle 1 : Vérifier si l'employé est concerné par ce groupe
    if (me != null && !me.isAdmin) {
      final isSessionAnimator = s.employeId != null && s.employeId.toString() == me.id.toString();
      final assignedPatients = me.patientsAssignesIds?.map((id) => id.toString()).toList() ?? [];
      final bool hasParticipantAccess = (s.participants ?? []).any(
        (p) => assignedPatients.contains(p.patientId?.toString()),
      );

      if (!isSessionAnimator && !hasParticipantAccess) {
        status.value = 'unauthorized';
        errorMessage.value =
            "Vous n'êtes pas concerné(e) par cette séance de groupe. Vous ne pouvez pas consulter ce compte-rendu.".tr;
        return;
      }
    }

    if (s.employeId != null) {
      selectedResponsableId.value = s.employeId;
    } else if (selectedResponsableId.value == null && me != null) {
      selectedResponsableId.value = me.id;
    }

    final bool userIsAuthor = me != null &&
        (s.employeId?.toString() == me.id.toString() ||
            (s.employeId == null && selectedResponsableId.value?.toString() == me.id.toString()));

    isAuthor.value = userIsAuthor;

    if (me != null && me.isAdmin) {
      canEdit.value = false;
    } else {
      canEdit.value = userIsAuthor;
    }

    final parts = <ParticipantPresenceNote>[];
    if (s.participants != null && s.participants!.isNotEmpty) {
      for (final p in s.participants!) {
        final pat = p.patient ?? {};
        final presence = p.statutPresence;
        final partItem = ParticipantPresenceNote(
          patientId: p.patientId,
          patientNom: pat['nom'] as String? ?? 'Patient',
          patientPrenom: pat['prenom'] as String? ?? '',
          photoUrl: pat['photo'] as String?,
          initialPresence: (presence != null && presence.isNotEmpty) ? presence : 'present',
          initialNote: p.descriptionEtat ?? '',
        );
        partItem.noteController.addListener(() {
          partItem.noteIndividuelle.value = partItem.noteController.text;
        });
        parts.add(partItem);
      }
    }
    participants.value = parts;
  }

  /// Titre de la séance
  String get sessionTitle {
    if (isGroupe.value) {
      final name = seanceGroupe.value?.groupeName ?? 'Atelier Collectif';
      return 'Atelier : $name';
    }
    return seanceIndiv.value?.patientFullName ?? 'Consultation Individuelle'.tr;
  }

  /// Date et heure formatées
  String get sessionDateTimeInfo {
    if (isGroupe.value) {
      final s = seanceGroupe.value;
      if (s == null) return '';
      return '${s.date} · ${s.heureDebut} — ${s.heureFin}';
    }
    final s = seanceIndiv.value;
    if (s == null) return '';
    return '${s.date} · ${s.heureDebut} — ${s.heureFin} (${s.duree})';
  }

  /// Nom du responsable
  String get responsableNom {
    if (selectedResponsableId.value == null) return 'Non attribué'.tr;
    final emp = praticiens.firstWhereOrNull((e) => e.id?.toString() == selectedResponsableId.value?.toString());
    return emp?.fullName ?? 'Spécialiste Référent'.tr;
  }

  /// Sauvegarder ou mettre à jour le compte-rendu clinique
  Future<void> saveRapport({bool cloturer = true}) async {
    if (seanceId == null) return;

    if (!canEdit.value) {
      Get.snackbar(
        'Action refusée'.tr,
        isAdmin.value
            ? 'En tant qu\'administrateur, vous êtes en mode consultation (lecture seule).'.tr
            : 'Seul le spécialiste auteur peut modifier ce compte-rendu.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      status.value = 'loading';
      descriptionEtat.value = clinicalNotesController.text.trim();

      if (isGroupe.value) {
        // Mise à jour de la séance de groupe
        await _seanceGroupeService.updateSeanceGroupe(seanceId, {
          'statut': cloturer ? 'faite' : 'prevue',
          if (selectedResponsableId.value != null) 'employe_id': selectedResponsableId.value,
        });

        // Mise à jour individuelle des participants (présence + observation clinique)
        for (final part in participants) {
          try {
            await _seanceGroupeService.updateParticipant(seanceId, part.patientId, {
              'statut_presence': part.statutPresence.value,
              'note_individuelle': part.noteController.text.trim(),
            });
          } catch (_) {}
        }
      } else {
        // Mise à jour de la séance individuelle
        final payload = <String, dynamic>{
          'description_etat': descriptionEtat.value,
          'statut_presence': statutPresence.value,
          'statut': cloturer ? 'faite' : 'prevue',
          if (etapePlanId.value != null) 'etape_plan_id': etapePlanId.value,
          if (selectedResponsableId.value != null) 'employe_id': selectedResponsableId.value,
          'medias': medias.toList(),
        };
        await _seanceService.updateSeance(seanceId, payload);
      }

      // ── Enregistrement du Rappel / Notification de suivi ──
      if (activerRappel.value && rappelMessage.value.trim().isNotEmpty) {
        try {
          final tacheTitre = isGroupe.value
              ? '[Rappel Groupe] ${rappelMessage.value.trim()}'
              : '[Rappel Patient] ${rappelMessage.value.trim()}';

          await _tacheService.createTache({
            'titre': tacheTitre,
            'description':
                'Rappel généré suite au compte-rendu du $sessionDateTimeInfo.\nPraticien : $responsableNom\nObservations : ${descriptionEtat.value}',
            'date_echeance': rappelDate.value.isNotEmpty ? rappelDate.value : null,
            'priorite': rappelPriorite.value,
            'statut': 'a_faire',
            if (!isGroupe.value && seanceIndiv.value?.patientId != null)
              'patient_id': seanceIndiv.value!.patientId,
            if (selectedResponsableId.value != null)
              'assigne_a': selectedResponsableId.value,
          });
        } catch (_) {}
      }

      // Rafraîchissement global réactif
      try {
        if (Get.isRegistered<AgendaController>()) {
          Get.find<AgendaController>().loadAgenda(forceRefresh: true);
        }
      } catch (_) {}
      try {
        if (Get.isRegistered<AccueilController>()) {
          Get.find<AccueilController>().loadDashboard(forceRefresh: true);
        }
      } catch (_) {}

      status.value = 'success';
      Get.back(result: true);

      final String messageSucces = isAlreadyValidated.value
          ? 'Compte-rendu mis à jour avec succès.'.tr
          : (activerRappel.value
              ? 'Le bilan a été validé et un rappel de suivi a été programmé.'.tr
              : 'Le bilan clinique a été enregistré avec succès.'.tr);

      Get.snackbar(
        'Compte-rendu enregistré'.tr,
        messageSucces,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.80),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
      Get.snackbar('Erreur'.tr, 'Impossible d\'enregistrer le compte-rendu : $e'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
