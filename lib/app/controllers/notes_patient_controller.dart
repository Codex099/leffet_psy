import 'package:get/get.dart';
import '../services/employee_service.dart';

class NotesPatientController extends GetxController {
  final NoteService _noteService = NoteService();

  final RxList<Map<String, dynamic>> notes = <Map<String, dynamic>>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  late int patientId;

  final contenu = ''.obs;

  @override
  void onInit() {
    super.onInit();
    patientId = Get.arguments as int? ?? 1;
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      status.value = 'loading';
      notes.value = await _noteService.getNotes(patientId);
      status.value = notes.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> addNote() async {
    if (contenu.value.trim().isEmpty) {
      Get.snackbar('Erreur', 'Le contenu de la note est requis');
      return;
    }
    try {
      await _noteService.createNote(patientId, {'contenu': contenu.value.trim()});
      contenu.value = '';
      loadNotes();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter la note');
    }
  }

  Future<void> deleteNote(int noteId) async {
    try {
      await _noteService.deleteNote(noteId);
      loadNotes();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la note');
    }
  }
}
