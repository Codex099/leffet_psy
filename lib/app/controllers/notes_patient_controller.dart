import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/cache_manager.dart';
import '../services/note_patient_service.dart';
import '../utils/json_utils.dart';

class NotesPatientController extends GetxController {
 final NoteService _noteService = NoteService();

  final RxList<Map<String, dynamic>> notes = <Map<String, dynamic>>[].obs;
  final RxString status = 'loading'.obs;
 final RxString errorMessage = ''.obs;
 dynamic patientId;

  final TextEditingController contenuController = TextEditingController();
  final RxList<String> medias = <String>[].obs;
  final RxInt formResetToken = 0.obs;
  final RxBool isSaving = false.obs;

  static const _cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null) {
      status.value = 'error';
     errorMessage.value = 'Identifiant du patient non spécifié.';
   } else {
      _loadFromCache();
      loadNotes();
    }
  }

  @override
  void onClose() {
    contenuController.dispose();
    super.onClose();
  }

  void _loadFromCache() {
    if (patientId == null) return;
    final cached = AppCacheManager.get<List<Map<String, dynamic>>>(CacheKeys.patientNotes(patientId));
    if (cached != null && cached.isNotEmpty) {
      notes.value = cached;
      status.value = 'success';
   }
  }

  Future<void> loadNotes({bool forceRefresh = false}) async {
    if (patientId == null) return;
    final cacheKey = CacheKeys.patientNotes(patientId);

    if (AppCacheManager.isFresh(cacheKey) && !forceRefresh && notes.isNotEmpty) {
      return;
    }

    if (notes.isEmpty) {
      status.value = 'loading';
   }

    try {
      final list = await _noteService.getNotes(patientId!);
      notes.value = list;

      AppCacheManager.set<List<Map<String, dynamic>>>(
        cacheKey,
        list,
        ttl: _cacheDuration,
        tags: {CacheTags.patients},
      );

      status.value = list.isEmpty ? 'empty' : 'success';
   } catch (e) {
      if (notes.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
     }
    }
  }

  Future<void> refreshData() => loadNotes(forceRefresh: true);

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
      AppCacheManager.invalidateTag(CacheTags.patients);
      await loadNotes(forceRefresh: true);
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
      AppCacheManager.invalidateTag(CacheTags.patients);
      await loadNotes(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la note');
   }
  }

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

  List<String> mediasDe(Map<String, dynamic> note) {
    final brut = note['medias'];
    if (brut is List) {
      return brut.whereType<String>().where((u) => u.trim().isNotEmpty).toList();
    }
    return const [];
  }
}
