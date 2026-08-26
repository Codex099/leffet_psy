import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/parent_model.dart';
import '../models/patient_statut_historique_model.dart';
import '../models/plan_therapeutique_model.dart';
import '../services/patient_service.dart';
import '../services/parent_service.dart';
import '../services/plan_therapeutique_service.dart';
import '../services/note_patient_service.dart';
import '../utils/json_utils.dart';
import 'accueil_controller.dart';
import 'patients_liste_controller.dart';

class PatientInfoController extends GetxController {
  final PatientService _patientService = PatientService();
  final PlanTherapeutiqueService _planService = PlanTherapeutiqueService();
  final NoteService _noteService = NoteService();
  final ParentService _parentService = ParentService();

  final Rx<PatientModel?> patient = Rx<PatientModel?>(null);
  final RxList<PatientParentModel> parents = <PatientParentModel>[].obs;
  final RxList<PlanTherapeutiqueModel> plans = <PlanTherapeutiqueModel>[].obs;
  final RxList<NotePatientModel> notes = <NotePatientModel>[].obs;
  final RxList<PatientStatutHistoriqueModel> statutHistorique = <PatientStatutHistoriqueModel>[].obs;
  final RxList<ParentModel> availableParents = <ParentModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  dynamic patientId;

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null || patientId.toString().isEmpty) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du patient non spécifié.';
    } else {
      loadPatientInfo();
    }
  }

  Future<void> loadPatientInfo() async {
    if (patientId == null) return;
    final id = patientId!;
    try {
      status.value = 'loading';
      
      // Appel principal essentiel : données du patient
      patient.value = await _patientService.getPatient(id);
      
      // Sous-ressources chargées de manière isolée pour éviter qu'une erreur ne bloque l'écran
      await Future.wait([
        _loadParents(id),
        _loadPlans(id),
        _loadNotes(id),
        _loadStatutHistorique(id),
        _loadAvailableParents(),
      ]);

      status.value = 'success';
    } catch (e) {
      errorMessage.value = 'Impossible de charger le dossier patient : $e';
      status.value = 'error';
    }
  }

  Future<void> _loadParents(dynamic id) async {
    try {
      parents.value = await _patientService.getPatientParents(id);
    } catch (_) {
      parents.value = [];
    }
  }

  Future<void> _loadPlans(dynamic id) async {
    try {
      plans.value = await _planService.getPlansPatient(id);
    } catch (_) {
      plans.value = [];
    }
  }

  Future<void> _loadNotes(dynamic id) async {
    try {
      final notesList = await _noteService.getNotes(id);
      notes.value = notesList.map((e) => NotePatientModel.fromJson(e)).toList();
    } catch (_) {
      notes.value = [];
    }
  }

  Future<void> _loadStatutHistorique(dynamic id) async {
    try {
      statutHistorique.value = await _patientService.getStatutHistorique(id);
    } catch (_) {
      statutHistorique.value = [];
    }
  }

  Future<void> _loadAvailableParents() async {
    try {
      availableParents.value = await _parentService.getParents();
    } catch (_) {
      availableParents.value = [];
    }
  }

  Future<void> associateParent(dynamic parentId, String role) async {
    if (patientId == null) return;
    try {
      await _patientService.addParentToPatient(patientId!, parentId: parentId, role: role);
      await loadPatientInfo();
      Get.snackbar('Succès', 'Parent associé avec succès', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'associer le parent : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> toggleStatut({String? noteDegradation}) async {
    if (patient.value == null || patientId == null) return;
    try {
      final current = patient.value!.estActif;
      final newStatus = !current;
      final cleanNote = noteDegradation?.trim();

      // 1. Enregistre le statut et la note de dégradation dans l'historique
      await _patientService.updateStatut(
        patientId!,
        estActif: newStatus,
        noteDegradation: cleanNote,
      );

      // 2. Si une note est rédigée, on l'enregistre également comme note d'évolution clinique
      if (cleanNote != null && cleanNote.isNotEmpty) {
        try {
          final todayStr = DateTime.now().toIso8601String().split('T')[0];
          await _noteService.createNote(patientId!, {
            'titre': newStatus ? 'Note de réactivation' : 'Note de désactivation',
            'contenu': cleanNote,
            'date': todayStr,
          });
        } catch (_) {}
      }

      await loadPatientInfo();
      _notifyGlobalControllers();
      Get.snackbar(
        'Statut mis à jour',
        newStatus ? 'Patient réactivé avec succès' : 'Patient désactivé',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier le statut : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addClinicalNote(String titre, String contenu) async {
    if (patientId == null || contenu.trim().isEmpty) return;
    try {
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      await _noteService.createNote(patientId!, {
        'titre': titre.trim().isNotEmpty ? titre.trim() : 'Observation clinique',
        'contenu': contenu.trim(),
        'date': todayStr,
      });
      await loadPatientInfo();
      _notifyGlobalControllers();
      Get.snackbar('Succès', 'Note enregistrée avec succès', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'enregistrer la note : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deletePatient() async {
    if (patientId == null) return;
    try {
      await _patientService.deletePatient(patientId!);
      _notifyGlobalControllers();
      Get.back();
      Get.snackbar('Succès', 'Patient supprimé', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer le patient', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteNote(dynamic noteId) async {
    try {
      await _noteService.deleteNote(noteId);
      await loadPatientInfo();
      _notifyGlobalControllers();
      Get.snackbar('Succès', 'Note supprimée', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible de supprimer la note', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _notifyGlobalControllers() {
    try {
      if (Get.isRegistered<PatientsListeController>()) {
        Get.find<PatientsListeController>().loadPatients();
      }
    } catch (_) {}
    try {
      if (Get.isRegistered<AccueilController>()) {
        Get.find<AccueilController>().loadDashboard();
      }
    } catch (_) {}
  }
}