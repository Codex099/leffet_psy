import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/note_patient_service.dart';

import '../utils/json_utils.dart';

class NotesPatientController extends GetxController {
  final NoteService _noteService = NoteService();

  final RxList<Map<String, dynamic>> notes = <Map<String, dynamic>>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  dynamic patientId;

  /// Source de vérité du champ de saisie : un TextEditingController permet de
  /// vider réellement le champ après l'enregistrement (un simple RxString ne
  /// remet pas à zéro le TextFormField).
  final TextEditingController contenuController = TextEditingController();

  final RxList<String> medias = <String>[].obs;

  /// Incrémenté après chaque enregistrement pour reconstruire le
  /// MediaPickerWidget (stateful, il conserve sinon ses vignettes).
  final RxInt formResetToken = 0.obs;

  final RxBool isSaving = false.obs;

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

  @override
  void onClose() {
    contenuController.dispose();
    super.onClose();
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
    if (patientId == null || isSaving.value) return;
    final contenu = contenuController.text.trim();
    if (contenu.isEmpty) {
      Get.snackbar('Erreur', 'Le contenu de la note est requis');
      return;
    }
    try {
      isSaving.value = true;
      await _noteService.createNote(patientId!, {
        'contenu': contenu,
        if (medias.isNotEmpty) 'medias': medias.toList(),
      });
      contenuController.clear();
      medias.clear();
      formResetToken.value++;
      await loadNotes();
      Get.snackbar('Note enregistrée', 'L\'observation a été ajoutée au dossier');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter la note');
    } finally {
      isSaving.value = false;
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

  /// Nom lisible du rédacteur : le backend renvoie `auteur` (objet employé
  /// imbriqué). Repli sur « Auteur inconnu » pour les notes anciennes.
  String auteurDe(Map<String, dynamic> note) {
    final auteur = note['auteur'];
    if (auteur is Map) {
      final nomComplet = [auteur['prenom'], auteur['nom']]
          .whereType<String>()
          .where((p) => p.trim().isNotEmpty)
          .join(' ');
      if (nomComplet.isNotEmpty) return nomComplet;
    }
    return 'Auteur inconnu';
  }

  /// Date de rédaction formatée JJ/MM/AAAA à HH:MM depuis `date_creation`.
  String dateDe(Map<String, dynamic> note) {
    final brut = note['date_creation'];
    if (brut is! String || brut.isEmpty) return '';
    final d = DateTime.tryParse(brut);
    if (d == null) return brut;
    final jj = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$jj/$mm/${d.year} à $hh:$mi';
  }

  /// URLs des médias attachés à une note (le backend stocke une liste JSON).
  List<String> mediasDe(Map<String, dynamic> note) {
    final brut = note['medias'];
    if (brut is List) {
      return brut.whereType<String>().where((u) => u.trim().isNotEmpty).toList();
    }
    return const [];
  }
}
