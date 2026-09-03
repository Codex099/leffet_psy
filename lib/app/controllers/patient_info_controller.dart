import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/patient_model.dart';
import '../models/parent_model.dart';
import '../models/patient_statut_historique_model.dart';
import '../models/plan_therapeutique_model.dart';
import '../models/employee_model.dart';
import '../services/cache_manager.dart';
import '../services/patient_service.dart';
import '../services/parent_service.dart';
import '../services/plan_therapeutique_service.dart';
import '../services/note_patient_service.dart';
import '../services/employee_service.dart';
import '../services/tache_service.dart';
import '../services/upload_service.dart';
import '../services/auth_service.dart';
import '../utils/json_utils.dart';
import 'accueil_controller.dart';
import 'patients_liste_controller.dart';

class PatientInfoController extends GetxController {
  final PatientService _patientService = PatientService();
  final PlanTherapeutiqueService _planService = PlanTherapeutiqueService();
  final NoteService _noteService = NoteService();
  final ParentService _parentService = ParentService();
  final EmployeeService _employeeService = EmployeeService();
  final TacheService _tacheService = TacheService();
  final UploadService _uploadService = UploadService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  final Rx<PatientModel?> patient = Rx<PatientModel?>(null);
  final RxList<PatientParentModel> parents = <PatientParentModel>[].obs;
  final RxList<PlanTherapeutiqueModel> plans = <PlanTherapeutiqueModel>[].obs;
  final RxList<NotePatientModel> notes = <NotePatientModel>[].obs;
  final RxList<PatientStatutHistoriqueModel> statutHistorique = <PatientStatutHistoriqueModel>[].obs;
  final RxList<ParentModel> availableParents = <ParentModel>[].obs;
  final RxList<EmployeeModel> availableEmployees = <EmployeeModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAdmin = false.obs;
  final RxBool photoUploading = false.obs;

  dynamic patientId;

  static const _cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    _checkAdmin();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null || patientId.toString().isEmpty) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du patient non spécifié.';
    } else {
      _loadFromCache();
      loadPatientInfo();
    }
  }

  Future<void> _checkAdmin() async {
    try {
      final me = await _authService.getCachedUser() ?? await _authService.getMe();
      isAdmin.value = me.role.toLowerCase() == 'admin';
    } catch (_) {}
  }

  void _loadFromCache() {
    if (patientId == null) return;
    final cached = AppCacheManager.get<Map<String, dynamic>>(CacheKeys.patientInfo(patientId));
    if (cached != null) {
      if (cached['patient'] is PatientModel) {
        patient.value = cached['patient'] as PatientModel;
      }
      if (cached['parents'] is List<PatientParentModel>) {
        parents.value = cached['parents'] as List<PatientParentModel>;
      }
      if (cached['plans'] is List<PlanTherapeutiqueModel>) {
        plans.value = cached['plans'] as List<PlanTherapeutiqueModel>;
      }
      if (cached['notes'] is List<NotePatientModel>) {
        notes.value = cached['notes'] as List<NotePatientModel>;
      }
      if (cached['statutHistorique'] is List<PatientStatutHistoriqueModel>) {
        statutHistorique.value = cached['statutHistorique'] as List<PatientStatutHistoriqueModel>;
      }
      status.value = 'success';
    }
  }

  Future<void> loadPatientInfo({bool forceRefresh = false}) async {
    if (patientId == null) return;
    final id = patientId!;

    final cacheKey = CacheKeys.patientInfo(id);
    if (AppCacheManager.isFresh(cacheKey) && !forceRefresh && patient.value != null) {
      return;
    }

    if (patient.value == null) {
      status.value = 'loading';
    }

    try {
      // Appel principal essentiel : données du patient
      final loadedPatient = await _patientService.getPatient(id);
      patient.value = loadedPatient;

      // Sous-ressources chargées en parallèle
      await Future.wait([
        _loadParents(id),
        _loadPlans(id),
        _loadNotes(id),
        _loadStatutHistorique(id),
        _loadAvailableParents(),
        _loadAvailableEmployees(),
      ]);

      // Sauvegarde dans le cache
      AppCacheManager.set<Map<String, dynamic>>(
        cacheKey,
        {
          'patient': loadedPatient,
          'parents': parents.toList(),
          'plans': plans.toList(),
          'notes': notes.toList(),
          'statutHistorique': statutHistorique.toList(),
        },
        ttl: _cacheDuration,
        tags: {CacheTags.patients},
      );

      status.value = 'success';
    } catch (e) {
      if (patient.value == null) {
        errorMessage.value = 'Impossible de charger le dossier patient : $e';
        status.value = 'error';
      }
    }
  }

  Future<void> refreshData() => loadPatientInfo(forceRefresh: true);

  Future<void> _loadParents(dynamic id) async {
    try {
      parents.value = await _patientService.getPatientParents(id);
    } catch (_) {
      parents.value = [];
    }
  }

  Future<void> _loadPlans(dynamic id) async {
    if (!isAdmin.value) {
      plans.value = [];
      return;
    }
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

  Future<void> _loadAvailableEmployees() async {
    try {
      final emps = await _employeeService.getEmployees();
      availableEmployees.value = emps;
    } catch (_) {}
  }

  /// Assigner une ou plusieurs étapes d'un plan thérapeutique à un employé sous forme de tâches
  Future<bool> assignEtapesAsTaches({
    required dynamic planId,
    required List<EtapePlanTherapeutiqueModel> etapes,
    required dynamic employeeId,
    String priorite = 'normale',
    String? dateEcheance,
    String? customNote,
  }) async {
    if (etapes.isEmpty || employeeId == null) return false;
    try {
      for (final etape in etapes) {
        final taskPayload = <String, dynamic>{
          'titre': etape.titre,
          'description': customNote != null && customNote.isNotEmpty
              ? '${etape.description ?? ""}\n\nNote: $customNote'.trim()
              : (etape.description ?? 'Étape du plan thérapeutique'),
          'assigne_a': employeeId.toString(),
          if (patientId != null) 'patient_id': patientId.toString(),
          'etape_plan_id': etape.id.toString(),
          'statut': 'a_faire',
          'priorite': priorite,
          if (dateEcheance != null && dateEcheance.isNotEmpty)
            'date_echeance': dateEcheance.contains('T')
                ? dateEcheance
                : '${dateEcheance}T18:00:00',
        };
        try {
          await _tacheService.createTache(taskPayload);
        } catch (_) {
          await _planService.creerTacheDepuisEtape(
            planId,
            etape.id,
            assigneA: employeeId.toString(),
          );
        }
      }

      AppCacheManager.invalidateTag(CacheTags.taches);
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar(
        'Succès'.tr,
        '${etapes.length} tâche(s) assignée(s) avec succès.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur'.tr,
        'Échec de l\'assignation des tâches: $e'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<void> associateParent(dynamic parentId, String role) async {
    if (patientId == null) return;
    try {
      await _patientService.addParentToPatient(patientId!, parentId: parentId, role: role);
      AppCacheManager.invalidateTag(CacheTags.patients);
      await loadPatientInfo(forceRefresh: true);
      Get.snackbar('Succès'.tr, 'Parent associé avec succès'.tr, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur'.tr, 'Impossible d\'associer le parent : $e'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> dissociateParent(dynamic parentId) async {
    if (patientId == null) return;
    try {
      await _patientService.removeParentFromPatient(patientId!, parentId);
      AppCacheManager.invalidateTag(CacheTags.patients);
      await loadPatientInfo(forceRefresh: true);
      Get.snackbar('Succès'.tr, 'Parent dissocié du patient.'.tr, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur'.tr, 'Impossible de dissocier le parent : $e'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> createAndAssociateParent({
    required String nom,
    required String prenom,
    required String telephone,
    String? etatCivil,
    String role = 'pere',
  }) async {
    if (patientId == null) return;
    final cleanPhone = telephone.trim();
    if (cleanPhone.isEmpty) {
      Get.snackbar('Téléphone requis'.tr, 'Veuillez renseigner le numéro de téléphone.'.tr);
      return;
    }

    try {
      // 1. Chercher si le parent existe déjà par téléphone
      ParentModel? parent = availableParents.firstWhereOrNull((p) => p.telephone?.trim() == cleanPhone);
      parent ??= await _parentService.getParentByPhone(cleanPhone);

      if (parent == null) {
        // 2. Créer le parent
        String mappedEc = 'autre';
        if (etatCivil != null) {
          final low = etatCivil.toLowerCase();
          if (low.contains('mari')) {
            mappedEc = 'marie';
          } else if (low.contains('divorc') || low.contains('spar') || low.contains('sépar')) {
            mappedEc = 'divorce';
          }
        }
        parent = await _parentService.createParent({
          'nom': nom.trim(),
          'prenom': prenom.trim(),
          'telephone': cleanPhone,
          'etat_civil': mappedEc,
        }, findExisting: true);
      }

      // 3. Associer au patient
      await _patientService.addParentToPatient(patientId!, parentId: parent.id, role: role);
      AppCacheManager.invalidateTag(CacheTags.patients);
      await loadPatientInfo(forceRefresh: true);
      Get.snackbar(
        'Succès'.tr,
        'Parent associé avec succès (${parent.fullName}).'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Erreur'.tr, 'Impossible d\'associer le parent : $e'.tr, snackPosition: SnackPosition.BOTTOM);
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

      AppCacheManager.invalidateTag(CacheTags.patients);
      AppCacheManager.invalidateTag(CacheTags.dashboard);
      await loadPatientInfo(forceRefresh: true);
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
      AppCacheManager.invalidateTag(CacheTags.patients);
      await loadPatientInfo(forceRefresh: true);
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
      AppCacheManager.invalidateTag(CacheTags.patients);
      AppCacheManager.invalidateTag(CacheTags.dashboard);
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
      AppCacheManager.invalidateTag(CacheTags.patients);
      await loadPatientInfo(forceRefresh: true);
      _notifyGlobalControllers();
      Get.snackbar('Succès', 'Note supprimée', snackPosition: SnackPosition.BOTTOM);
   } catch (_) {
      Get.snackbar('Erreur', 'Impossible de supprimer la note', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickAndUploadPhoto({bool fromCamera = false}) async {
    if (patientId == null) return;
    try {
      final XFile? xfile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );
      if (xfile == null) return;
      photoUploading.value = true;
      final file = File(xfile.path);
      final uploadedUrl = await _uploadService.uploadFile(file);
      if (uploadedUrl.isNotEmpty) {
        await _patientService.updatePatient(patientId!, {
          'photo': uploadedUrl,
          'photo_url': uploadedUrl,
        });
        AppCacheManager.invalidateTag(CacheTags.patients);
        AppCacheManager.invalidateTag(CacheTags.dashboard);
        AppCacheManager.invalidate(CacheKeys.patientInfo(patientId));
        await loadPatientInfo(forceRefresh: true);
        _notifyGlobalControllers();
        Get.snackbar(
          'Succès'.tr,
          'Photo du patient mise à jour avec succès.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur'.tr,
        'Impossible de mettre à jour la photo : $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      photoUploading.value = false;
    }
  }

  void _notifyGlobalControllers() {
    try {
      if (Get.isRegistered<PatientsListeController>()) {
        Get.find<PatientsListeController>().loadPatients(forceRefresh: true);
      }
    } catch (_) {}
    try {
      if (Get.isRegistered<AccueilController>()) {
        Get.find<AccueilController>().loadDashboard(forceRefresh: true);
      }
    } catch (_) {}
  }
}