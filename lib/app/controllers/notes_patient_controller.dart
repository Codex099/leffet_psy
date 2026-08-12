import 'package:get/get.dart';
import '../services/employee_service.dart';

import '../utils/json_utils.dart';

class NotesPatientController extends GetxController {
  final NoteService _noteService = NoteService();

  final RxList<Map<String, dynamic>> notes = <Map<String, dynamic>>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  dynamic patientId;

  final contenu = ''.obs;

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du patient non spécifié.';
    } else {
      loadNotes();
    }
  }

  Future<void> loadNotes() async {
    if (patientId == null) return;
    try {
      status.value = 'loading';
      notes.value = await _noteService.getNotes(patientId!);
      status.value = notes.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> addNote() async {
    if (patientId == null) return;
    if (contenu.value.trim().isEmpty) {
      Get.snackbar('Erreur', 'Le contenu de la note est requis');
      return;
    }
    try {
      await _noteService.createNote(patientId!, {'contenu': contenu.value.trim()});
      contenu.value = '';
      loadNotes();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter la note');
    }
  }

  Future<void> deleteNote(dynamic noteId) async {
    try {
      await _noteService.deleteNote(noteId);
      loadNotes();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la note');
    }
  }
}
