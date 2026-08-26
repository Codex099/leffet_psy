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

  ParticipantPresenceNote({
    required this.patientId,
    required this.patientNom,
    required this.patientPrenom,
    this.photoUrl,
    String initialPresence = 'present',
    String initialNote = '',
  })  : statutPresence = initialPresence.obs,
        noteIndividuelle = initialNote.obs;

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

  final RxString status = 'loading'.obs;
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

  // Form fields - General
  final RxString statutPresence = 'present'.obs; // 'present' | 'absent_justifie' | 'absent_non_justifie'
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
    loadData();
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
      errorMessage.value = 'Identifiant de séance non spécifié.';
      return;
    }

    try {
      status.value = 'loading';

      // 1. Charger les praticiens
      try {
        final emps = await _employeeService.getEmployees();
        praticiens.value = emps;
      } catch (_) {}

      // Praticien connecté par défaut
      try {
        final me = await _authService.getMe();
        if (selectedResponsableId.value == null) {
          selectedResponsableId.value = me.id;
        }
      } catch (_) {}

      // 2. Charger la séance (individuelle ou groupe)
      if (isGroupe.value) {
        await _loadGroupeSession();
      } else {
        try {
          await _loadIndivSession();
        } catch (_) {
          // Si échoue, tenter en tant que séance de groupe
          isGroupe.value = true;
          await _loadGroupeSession();
        }
      }

      // Initialiser date de rappel par défaut à J+7
      if (rappelDate.value.isEmpty) {
        final j7 = DateTime.now().add(const Duration(days: 7));
        rappelDate.value = j7.toIso8601String().split('T').first;
      }

      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> _loadIndivSession() async {
    final s = await _seanceService.getSeance(seanceId);
    seanceIndiv.value = s;
    descriptionEtat.value = s.descriptionEtat ?? '';
    medias.value = s.medias ?? [];
    statutPresence.value = s.statutPresence ?? 'present';
    if (s.employeIds.isNotEmpty) {
      selectedResponsableId.value = s.employeIds.first;
    }

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

  Future<void> _loadGroupeSession() async {
    final s = await _seanceGroupeService.getSeanceGroupe(seanceId);
    seanceGroupe.value = s;
    if (s.employeId != null) selectedResponsableId.value = s.employeId;

    final parts = <ParticipantPresenceNote>[];
    if (s.participants != null && s.participants!.isNotEmpty) {
      for (final p in s.participants!) {
        final pat = p.patient ?? {};
        final presence = p.statutPresence;
        parts.add(ParticipantPresenceNote(
          patientId: p.patientId,
          patientNom: pat['nom'] as String? ?? 'Patient',
          patientPrenom: pat['prenom'] as String? ?? '',
          photoUrl: pat['photo'] as String?,
          initialPresence: (presence != null && presence.isNotEmpty) ? presence : 'present',
          initialNote: p.descriptionEtat ?? '',
        ));
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
    return seanceIndiv.value?.patientFullName ?? 'Consultation Individuelle';
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
    if (selectedResponsableId.value == null) return 'Non attribué';
    final emp = praticiens.firstWhereOrNull((e) => e.id == selectedResponsableId.value);
    return emp?.fullName ?? 'Spécialiste Référent';
  }

  /// Sauvegarder le compte-rendu clinique avec rappel
  Future<void> saveRapport({bool cloturer = true}) async {
    if (seanceId == null) return;
    try {
      status.value = 'loading';

      if (isGroupe.value) {
        // Mise à jour de la séance de groupe
        await _seanceGroupeService.updateSeanceGroupe(seanceId, {
          'statut': cloturer ? 'realisee' : 'prevue',
          if (selectedResponsableId.value != null) 'employe_id': selectedResponsableId.value,
        });

        // Mise à jour individuelle des participants (présence + observation clinique)
        for (final part in participants) {
          try {
            await _seanceGroupeService.updateParticipant(seanceId, part.patientId, {
              'statut_presence': part.statutPresence.value,
              'note_individuelle': part.noteIndividuelle.value.trim(),
            });
          } catch (_) {}
        }
      } else {
        // Mise à jour de la séance individuelle
        final payload = <String, dynamic>{
          'description_etat': descriptionEtat.value.trim(),
          'statut_presence': statutPresence.value,
          'statut': cloturer ? 'realisee' : 'prevue',
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
            'description': 'Rappel généré suite au compte-rendu du $sessionDateTimeInfo.\nPraticien : $responsableNom\nObservations : ${descriptionEtat.value}',
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
      Get.snackbar(
        'Compte-rendu enregistré',
        activerRappel.value
            ? 'Le bilan a été validé et un rappel de suivi a été programmé.'
            : 'Le bilan clinique a été enregistré avec succès.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.80),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
      Get.snackbar('Erreur', 'Impossible d\'enregistrer le compte-rendu : $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
