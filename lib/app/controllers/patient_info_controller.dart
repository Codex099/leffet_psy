import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/parent_model.dart';
import '../models/plan_therapeutique_model.dart';
import '../services/patient_service.dart';
import '../services/parent_service.dart';
import '../services/plan_therapeutique_service.dart';
import '../services/employee_service.dart';
import '../services/note_patient_service.dart';
import '../utils/json_utils.dart';

class PatientInfoController extends GetxController {
  final PatientService _patientService = PatientService();
  final PlanTherapeutiqueService _planService = PlanTherapeutiqueService();
  final NoteService _noteService = NoteService();

  final Rx<PatientModel?> patient = Rx<PatientModel?>(null);
  final RxList<PatientParentModel> parents = <PatientParentModel>[].obs;
  final RxList<PlanTherapeutiqueModel> plans = <PlanTherapeutiqueModel>[].obs;
  final RxList<NotePatientModel> notes = <NotePatientModel>[].obs;
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
      patient.value = await _patientService.getPatient(id);
      parents.value = await _patientService.getPatientParents(id);
      plans.value = await _planService.getPlansPatient(id);
      
      final notesList = await _noteService.getNotes(id);
      notes.value = notesList.map((e) => NotePatientModel.fromJson(e)).toList();

      availableParents.value = await ParentService().getParents();
      
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> associateParent(dynamic parentId, String role) async {
    if (patientId == null) return;
    try {
      await _patientService.addParentToPatient(patientId!, parentId: parentId, role: role);
      loadPatientInfo();
      Get.snackbar('Succès', 'Parent associé avec succès', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible d\'associer le parent', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> toggleStatut() async {
    if (patient.value == null || patientId == null) return;
    try {
      final current = patient.value!.estActif;
      await _patientService.updateStatut(patientId!, estActif: !current);
      loadPatientInfo();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier le statut');
    }
  }

  Future<void> deletePatient() async {
    if (patientId == null) return;
    try {
      await _patientService.deletePatient(patientId!);
      Get.back();
      Get.snackbar('Succès', 'Patient supprimé');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer le patient');
    }
  }

  Future<void> deleteNote(dynamic noteId) async {
    try {
      await _noteService.deleteNote(noteId);
      loadPatientInfo();
      Get.snackbar('Succès', 'Note supprimée', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible de supprimer la note', snackPosition: SnackPosition.BOTTOM);
    }
  }
}