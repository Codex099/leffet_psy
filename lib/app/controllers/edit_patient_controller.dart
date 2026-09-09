import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/parent_model.dart';
import '../models/patient_model.dart';
import '../services/cache_manager.dart';
import '../services/patient_service.dart';
import '../services/parent_service.dart';
import '../services/upload_service.dart';
import '../utils/json_utils.dart';
import 'accueil_controller.dart';
import 'patient_info_controller.dart';
import 'patients_liste_controller.dart';

import '../services/auth_service.dart';

class PatientParentSelection {
  final dynamic parentId;
  String role;
  final ParentModel parent;

  PatientParentSelection({
    required this.parentId,
    required this.role,
    required this.parent,
  });
}

class EditPatientController extends GetxController {
  final PatientService _patientService = PatientService();
  final ParentService _parentService = ParentService();
  final UploadService _uploadService = UploadService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  // Edit mode: non-null means edit an existing patient
  dynamic patientId;
  final RxBool isAdmin = false.obs;

  // Wizard step (1–4)
  final RxInt currentStep = 1.obs;

  // ──── Step 1 — Identité ────
  final prenomController = TextEditingController();
  final nomController = TextEditingController();
  final dateNaissance = ''.obs;
  final sexe = 'Masculin'.obs;
  final photoUrl = ''.obs;
  final Rx<File?> pickedPhoto = Rx<File?>(null);
  final isUploadingPhoto = false.obs;
  final RxBool photoUploading = false.obs;
  final uploadProgress = 0.0.obs;

  // ──── Step 2 — Dossier médical ────
  final antecedentsMedicauxController = TextEditingController();
  final medicamentsPrisController = TextEditingController();
  final dateCas = ''.obs;
  final naissanceController = TextEditingController();
  final developpementPsychomoteurController = TextEditingController();
  final comportementAuditifController = TextEditingController();
  final developpementLangagierController = TextEditingController();
  final adaptationSocialeController = TextEditingController();
  final autonomieController = TextEditingController();
  final aspectSanitaireController = TextEditingController();
  final stadeScolarisationController = TextEditingController();
  final nombreFreresSoeursController = TextEditingController();
  final ordreNaissanceController = TextEditingController();

  // ──── Step 3 — Tuteur / Parents (Support Multi-parents) ────
  final RxList<ParentModel> availableParents = <ParentModel>[].obs;
  final RxList<PatientParentSelection> selectedParents = <PatientParentSelection>[].obs;
  final Rx<dynamic> selectedParentId = Rx<dynamic>(null);
  final roleParent = 'pere'.obs;
  final RxString parentsStatus = 'loading'.obs;

  // ──── Step 4 — Plan thérapeutique ────
  final objectifs = ''.obs;
  final addPlanTherapeutique = true.obs;

  // Global status
  final RxString status = 'success'.obs;
  final RxString errorMessage = ''.obs;

  // Saved patient id (after step-1 save)
  dynamic _savedPatientId;

  static List<Map<String, String>> roleChoices = [
    {'value': 'pere', 'label': 'Père'.tr},
    {'value': 'mere', 'label': 'Mère'.tr},
    {'value': 'tuteur', 'label': 'Tuteur légal'.tr},
    {'value': 'oncle', 'label': 'Oncle'.tr},
    {'value': 'tante', 'label': 'Tante'.tr},
    {'value': 'grand_pere', 'label': 'Grand-père'.tr},
    {'value': 'grand_mere', 'label': 'Grand-mère'.tr},
    {'value': 'autre', 'label': 'Autre'.tr},
  ];

  static List<Map<String, String>> sexeChoices = [
    {'value': 'Masculin', 'label': 'Masculin'.tr},
    {'value': 'Féminin', 'label': 'Féminin'.tr},
  ];

  @override
  void onInit() {
    super.onInit();
    _checkAdmin();
    final args = Get.arguments;
    patientId = extractIdParam(args, Get.parameters);
    if (patientId != null) {
      _savedPatientId = patientId;
      _loadPatient(patientId!);
    }
    _loadParents();
  }

  Future<void> _checkAdmin() async {
    try {
      final me = await _authService.getCachedUser() ?? await _authService.getMe();
      isAdmin.value = me.role.toLowerCase() == 'admin';
      if (!isAdmin.value) {
        Get.back();
        Get.snackbar(
          'Accès restreint'.tr,
          'Seul l\'administrateur peut ajouter ou modifier les dossiers patients.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    nomController.dispose();
    prenomController.dispose();
    nombreFreresSoeursController.dispose();
    ordreNaissanceController.dispose();
    antecedentsMedicauxController.dispose();
    medicamentsPrisController.dispose();
    naissanceController.dispose();
    developpementPsychomoteurController.dispose();
    comportementAuditifController.dispose();
    developpementLangagierController.dispose();
    adaptationSocialeController.dispose();
    autonomieController.dispose();
    aspectSanitaireController.dispose();
    stadeScolarisationController.dispose();
    super.onClose();
  }

  Future<void> _loadPatient(dynamic id) async {
    try {
      status.value = 'loading';
      final patient = await _patientService.getPatient(id);
      prenomController.text = patient.prenom;
      nomController.text = patient.nom;
      dateNaissance.value = patient.dateNaissance ?? '';
      sexe.value = patient.sexe == 'feminin' ? 'Féminin' : 'Masculin';
      photoUrl.value = patient.photo ?? '';

      // Charger le dossier médical si disponible
      try {
        final dm = await _patientService.getDossierMedical(id);
        antecedentsMedicauxController.text = dm.antecedentsMedicaux ?? '';
        medicamentsPrisController.text = dm.medicamentsPris ?? '';
        dateCas.value = dm.dateCas ?? '';
        naissanceController.text = dm.naissance ?? '';
        developpementPsychomoteurController.text = dm.developpementPsychomoteur ?? '';
        comportementAuditifController.text = dm.comportementAuditif ?? '';
        developpementLangagierController.text = dm.developpementLangagier ?? '';
        adaptationSocialeController.text = dm.adaptationSociale ?? '';
        autonomieController.text = dm.autonomie ?? '';
        aspectSanitaireController.text = dm.aspectSanitaire ?? '';
        stadeScolarisationController.text = dm.stadeScolarisation ?? '';
      } catch (_) {
        // Dossier médical non existant encore
      }

      // Charger tous les parents/tuteurs liés
      try {
        final linked = await _patientService.getPatientParents(id);
        selectedParents.clear();
        for (final l in linked) {
          if (l.parent != null) {
            selectedParents.add(
              PatientParentSelection(
                parentId: l.parentId,
                role: l.role,
                parent: l.parent!,
              ),
            );
          }
        }
        if (selectedParents.isNotEmpty) {
          selectedParentId.value = selectedParents.first.parentId;
          roleParent.value = selectedParents.first.role;
        }
      } catch (_) {
        // Aucun parent associé pour le moment
      }

      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> _loadParents() async {
    try {
      parentsStatus.value = 'loading';
      final list = await _parentService.getParents();
      availableParents.value = list;
      parentsStatus.value = 'success';
    } catch (_) {
      parentsStatus.value = 'error';
    }
  }

  void addSelectedParent(ParentModel parent, String role) {
    final idx = selectedParents.indexWhere((p) => p.parentId == parent.id);
    if (idx >= 0) {
      selectedParents[idx].role = role;
      selectedParents.refresh();
      if (Get.context != null) {
        Get.snackbar('Mis à jour'.tr, 'Rôle familial mis à jour : ${parent.fullName}'.tr, snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      selectedParents.add(PatientParentSelection(
        parentId: parent.id,
        role: role,
        parent: parent,
      ));
      if (Get.context != null) {
        Get.snackbar('Ajouté'.tr, 'Parent associé : ${parent.fullName}'.tr, snackPosition: SnackPosition.BOTTOM);
      }
    }
    selectedParentId.value = selectedParents.first.parentId;
    roleParent.value = selectedParents.first.role;
  }

  void removeSelectedParent(dynamic parentId) {
    selectedParents.removeWhere((p) => p.parentId == parentId);
    if (selectedParents.isNotEmpty) {
      selectedParentId.value = selectedParents.first.parentId;
      roleParent.value = selectedParents.first.role;
    } else {
      selectedParentId.value = null;
    }
  }

  Future<ParentModel?> createParentInline(
    dynamic dataOrNom, {
    String? nom,
    String? prenom,
    String? telephone,
    String? etatCivil,
    String role = 'pere',
  }) async {
    String finalNom = '';
    String finalPrenom = '';
    String finalTel = '';
    String? finalEc = etatCivil;
    String finalRole = role;

    if (dataOrNom is Map) {
      finalNom = (dataOrNom['nom'] ?? '').toString().trim();
      finalPrenom = (dataOrNom['prenom'] ?? '').toString().trim();
      finalTel = (dataOrNom['telephone'] ?? '').toString().trim();
      finalEc = dataOrNom['etat_civil']?.toString() ?? finalEc;
      finalRole = (dataOrNom['role'] ?? finalRole).toString();
    } else if (dataOrNom is String) {
      finalNom = dataOrNom.trim();
      finalPrenom = (prenom ?? '').trim();
      finalTel = (telephone ?? '').trim();
    } else {
      finalNom = (nom ?? '').trim();
      finalPrenom = (prenom ?? '').trim();
      finalTel = (telephone ?? '').trim();
    }

    if (finalTel.isEmpty) {
      if (Get.context != null) {
        Get.snackbar('Téléphone requis'.tr, 'Veuillez saisir le numéro de téléphone du parent.'.tr, snackPosition: SnackPosition.BOTTOM);
      }
      return null;
    }

    try {
      parentsStatus.value = 'loading';

      // 1. Vérifier si un parent existe déjà avec ce téléphone localement
      ParentModel? existingParent = availableParents.firstWhereOrNull(
        (p) => p.telephone?.trim() == finalTel,
      );

      // 2. Si pas en mémoire, interroger l'API par téléphone
      if (existingParent == null) {
        try {
          existingParent = await _parentService.getParentByPhone(finalTel);
        } catch (_) {}
      }

      // Si le parent existe déjà : réutilisation immédiate
      if (existingParent != null) {
        addSelectedParent(existingParent, finalRole);
        try {
          await _loadParents();
        } catch (_) {}
        parentsStatus.value = 'success';
        if (Get.context != null) {
          Get.snackbar(
            'Parent existant'.tr,
            'Un parent avec le numéro $finalTel existe déjà (${existingParent.fullName}). Il a été automatiquement sélectionné.'.tr,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        }
        return existingParent;
      }

      // 3. Nouveau parent : mapper l'état civil
      String mappedEc = 'autre';
      if (finalEc != null) {
        final low = finalEc.toLowerCase();
        if (low.contains('mari')) {
          mappedEc = 'marie';
        } else if (low.contains('divorc') || low.contains('spar') || low.contains('sépar')) {
          mappedEc = 'divorce';
        }
      }

      final payload = {
        'nom': finalNom.isNotEmpty ? finalNom : 'Parent',
        'prenom': finalPrenom.isNotEmpty ? finalPrenom : 'Nouveau',
        'telephone': finalTel,
        'etat_civil': mappedEc,
      };

      final newParent = await _parentService.createParent(payload, findExisting: true);
      await _loadParents();
      addSelectedParent(newParent, finalRole);
      parentsStatus.value = 'success';
      Get.snackbar('Succès'.tr, 'Parent créé et associé avec succès.'.tr, snackPosition: SnackPosition.BOTTOM);
      return newParent;
    } catch (e) {
      parentsStatus.value = 'success';
      Get.snackbar('Erreur'.tr, 'Impossible d\'enregistrer le parent: $e', snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  /// Pick photo from gallery or camera
  Future<void> pickPhoto({bool fromCamera = false}) async {
    try {
      final XFile? xfile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );
      if (xfile == null) return;
      pickedPhoto.value = File(xfile.path);
      // Immediately upload
      await _uploadPhoto(pickedPhoto.value!);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'accéder à la galerie: $e',
         snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _uploadPhoto(File file) async {
    try {
      photoUploading.value = true;
      final url = await _uploadService.uploadFile(file);
      if (url.isNotEmpty) {
        photoUrl.value = url;
      }
    } catch (e) {
      Get.snackbar('Erreur'.tr, 'Échec du téléchargement de la photo: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      photoUploading.value = false;
    }
  }

  void goToStep(int step) {
    if (step < 1 || step > 4) return;
    if (step == currentStep.value) return;

    // Si on quitte l'étape 1 et que nom et prénom sont renseignés,
    // on peut tenter de pré-créer ou mettre à jour le patient en arrière-plan
    if (currentStep.value == 1 && (_savedPatientId == null && patientId == null)) {
      final prenomText = prenomController.text.trim();
      final nomText = nomController.text.trim();
      if (prenomText.isNotEmpty && nomText.isNotEmpty) {
        _saveStep1(advance: false, silent: true);
      }
    }

    currentStep.value = step;
  }

  void nextStep() {
    if (currentStep.value < 4) {
      _saveCurrentStep();
    } else {
      finishWizard();
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  Future<void> _saveCurrentStep() async {
    switch (currentStep.value) {
      case 1:
        await _saveStep1(advance: true);
        break;
      case 2:
        await _saveStep2(advance: true);
        break;
      case 3:
        await _saveStep3(advance: true);
        break;
    }
  }

  // Step 1: Create or update patient basic info
  Future<bool> _saveStep1({bool advance = true, bool silent = false}) async {
    final prenomText = prenomController.text.trim();
    final nomText = nomController.text.trim();
    if (prenomText.isEmpty || nomText.isEmpty) {
      if (!silent) {
        Get.snackbar(
          'Champs requis'.tr,
          'Prénom et nom sont obligatoires.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }
    try {
      // ── Upload photo d'abord si sélectionnée et non encore uploadée ──
      if (pickedPhoto.value != null && photoUrl.value.isEmpty && !photoUploading.value) {
        await _uploadPhoto(pickedPhoto.value!);
      }
      while (photoUploading.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final isFeminin = sexe.value == 'Fille' ||
          sexe.value == 'Féminin' ||
          sexe.value.toLowerCase() == 'feminin';

      final data = <String, dynamic>{
        'nom': nomText,
        'prenom': prenomText,
        if (dateNaissance.value.isNotEmpty) 'date_naissance': dateNaissance.value,
        'sexe': isFeminin ? 'feminin' : 'masculin',
        if (photoUrl.value.isNotEmpty) ...{
          'photo': photoUrl.value,
          'photo_url': photoUrl.value,
        },
        if (nombreFreresSoeursController.text.trim().isNotEmpty)
          'nombre_freres_soeurs': int.tryParse(nombreFreresSoeursController.text.trim()),
        if (ordreNaissanceController.text.trim().isNotEmpty)
          'ordre_naissance': int.tryParse(ordreNaissanceController.text.trim()),
      };

      PatientModel saved;
      final targetId = _savedPatientId ?? patientId;
      if (targetId != null) {
        saved = await _patientService.updatePatient(targetId, data);
      } else {
        saved = await _patientService.createPatient(data);
        _savedPatientId = saved.id;
      }
      status.value = 'success';
      if (advance) {
        currentStep.value = 2;
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
      if (!silent) {
        Get.snackbar('Erreur'.tr, errorMessage.value, snackPosition: SnackPosition.BOTTOM);
      }
      return false;
    }
  }

  // Step 2: Update dossier médical (toutes les informations médicales)
  Future<bool> _saveStep2({bool advance = true, bool silent = false}) async {
    final targetId = _savedPatientId ?? patientId;
    if (targetId == null) {
      if (advance) currentStep.value = 3;
      return true;
    }
    try {
      if (!silent) status.value = 'loading';
      final payload = <String, dynamic>{
        if (antecedentsMedicauxController.text.trim().isNotEmpty)
          'antecedents_medicaux': antecedentsMedicauxController.text.trim(),
        if (medicamentsPrisController.text.trim().isNotEmpty)
          'medicaments_pris': medicamentsPrisController.text.trim(),
        if (dateCas.value.trim().isNotEmpty)
          'date_cas': dateCas.value.trim(),
        if (naissanceController.text.trim().isNotEmpty)
          'naissance': naissanceController.text.trim(),
        if (developpementPsychomoteurController.text.trim().isNotEmpty)
          'developpement_psychomoteur': developpementPsychomoteurController.text.trim(),
        if (comportementAuditifController.text.trim().isNotEmpty)
          'comportement_auditif': comportementAuditifController.text.trim(),
        if (developpementLangagierController.text.trim().isNotEmpty)
          'developpement_langagier': developpementLangagierController.text.trim(),
        if (adaptationSocialeController.text.trim().isNotEmpty)
          'adaptation_sociale': adaptationSocialeController.text.trim(),
        if (autonomieController.text.trim().isNotEmpty)
          'autonomie': autonomieController.text.trim(),
        if (aspectSanitaireController.text.trim().isNotEmpty)
          'aspect_sanitaire': aspectSanitaireController.text.trim(),
        if (stadeScolarisationController.text.trim().isNotEmpty)
          'stade_scolarisation': stadeScolarisationController.text.trim(),
      };

      if (payload.isNotEmpty) {
        await _patientService.updateDossierMedical(targetId, payload);
      }
      status.value = 'success';
      if (advance) currentStep.value = 3;
      return true;
    } catch (e) {
      status.value = 'success';
      if (advance) currentStep.value = 3;
      return false;
    }
  }

  // Step 3: Link parent/tuteur (Multi-parents support)
  Future<bool> _saveStep3({bool advance = true, bool silent = false}) async {
    final targetId = _savedPatientId ?? patientId;
    if (targetId == null) {
      if (advance) currentStep.value = 4;
      return true;
    }
    try {
      if (!silent) status.value = 'loading';
      if (selectedParents.isNotEmpty) {
        for (final sp in selectedParents) {
          try {
            await _patientService.addParentToPatient(
              targetId,
              parentId: sp.parentId,
              role: sp.role,
            );
          } catch (_) {}
        }
      } else if (selectedParentId.value != null) {
        await _patientService.addParentToPatient(
          targetId,
          parentId: selectedParentId.value!,
          role: roleParent.value,
        );
      }
      status.value = 'success';
      if (advance) currentStep.value = 4;
      return true;
    } catch (e) {
      status.value = 'success';
      if (advance) currentStep.value = 4;
      return false;
    }
  }

  Future<void> finishWizard() async {
    final prenomText = prenomController.text.trim();
    final nomText = nomController.text.trim();

    // Vérifier l'étape 1 obligatoire (nom et prénom)
    if (prenomText.isEmpty || nomText.isEmpty) {
      currentStep.value = 1;
      Get.snackbar(
        'Champs requis'.tr,
        'Prénom et nom sont obligatoires (Étape 1 - Identité).'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      status.value = 'loading';

      // 1. Sauvegarder l'étape 1
      final ok1 = await _saveStep1(advance: false, silent: false);
      if (!ok1) {
        status.value = 'error';
        return;
      }

      final targetId = _savedPatientId ?? patientId;
      if (targetId != null) {
        // 2. Sauvegarder l'étape 2 (Dossier médical)
        await _saveStep2(advance: false, silent: true);

        // 3. Sauvegarder l'étape 3 (Parents / Tuteurs)
        await _saveStep3(advance: false, silent: true);
      }

      AppCacheManager.invalidateTag(CacheTags.patients);
      AppCacheManager.invalidateTag(CacheTags.dashboard);
      if (targetId != null) {
        AppCacheManager.invalidate(CacheKeys.patientInfo(targetId));
      }

      try {
        if (Get.isRegistered<PatientsListeController>()) {
          Get.find<PatientsListeController>().loadPatients(forceRefresh: true);
        }
      } catch (_) {}
      try {
        if (Get.isRegistered<PatientInfoController>()) {
          Get.find<PatientInfoController>().loadPatientInfo(forceRefresh: true);
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
        'Succès'.tr,
        patientId != null
            ? 'Patient mis à jour avec succès.'.tr
            : 'Nouveau patient créé avec succès.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      status.value = 'error';
      Get.snackbar('Erreur'.tr, e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}

