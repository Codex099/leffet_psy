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

class EditPatientController extends GetxController {
  final PatientService _patientService = PatientService();
  final ParentService _parentService = ParentService();
  final UploadService _uploadService = UploadService();
  final ImagePicker _picker = ImagePicker();

  // Edit mode: non-null means edit an existing patient
  dynamic patientId;

  // Wizard step (1–4)
  final RxInt currentStep = 1.obs;

  // ──── Step 1 — Infos perso ────
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final dateNaissance = ''.obs;
  final sexe = 'Garçon'.obs;
  final nombreFreresSoeursController = TextEditingController();
  final ordreNaissanceController = TextEditingController();

  // Photo
  final Rx<File?> pickedPhoto = Rx<File?>(null);
  final RxString photoUrl = ''.obs;
  final RxBool photoUploading = false.obs;

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

  // ──── Step 3 — Tuteur ────
  final RxList<ParentModel> availableParents = <ParentModel>[].obs;
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

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    _loadParents();
    if (patientId != null) {
      _loadPatient(patientId!);
    }
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
      final p = await _patientService.getPatient(id);
      nomController.text = p.nom;
      prenomController.text = p.prenom;
      dateNaissance.value = p.dateNaissance ?? '';
      sexe.value = p.isFille ? 'Fille' : 'Garçon';
      photoUrl.value = p.photo ?? '';
      nombreFreresSoeursController.text = p.nombreFreresSoeurs?.toString() ?? '';
      ordreNaissanceController.text = p.ordreNaissance?.toString() ?? '';
      _savedPatientId = id;

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

      // Charger le parent/tuteur si disponible
      try {
        final linked = await _patientService.getPatientParents(id);
        if (linked.isNotEmpty) {
          final first = linked.first;
          selectedParentId.value = first.parentId;
          roleParent.value = first.role;
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

  Future<void> createParentInline(Map<String, dynamic> data) async {
    try {
      parentsStatus.value = 'loading';
      final newParent = await _parentService.createParent(data);
      await _loadParents();
      selectedParentId.value = newParent.id;
      Get.snackbar('Succès', 'Parent créé et sélectionné', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer le parent: $e', snackPosition: SnackPosition.BOTTOM);
      parentsStatus.value = 'success';
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
      photoUrl.value = url;
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du téléchargement de la photo: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      photoUploading.value = false;
    }
  }

  void nextStep() {
    if (currentStep.value < 4) {
      _saveCurrentStep();
    } else {
      _finishWizard();
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
        await _saveStep1();
        break;
      case 2:
        await _saveStep2();
        break;
      case 3:
        await _saveStep3();
        break;
    }
  }

  // Step 1: Create or update patient basic info
  Future<void> _saveStep1() async {
    final prenomText = prenomController.text.trim();
    final nomText = nomController.text.trim();
    if (prenomText.isEmpty || nomText.isEmpty) {
      Get.snackbar('Champs requis', 'Prénom et nom sont obligatoires.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      // ── Upload photo d'abord si sélectionnée et non encore uploadée ──
      if (pickedPhoto.value != null && photoUrl.value.isEmpty && !photoUploading.value) {
        await _uploadPhoto(pickedPhoto.value!);
      }
      while (photoUploading.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final data = <String, dynamic>{
        'nom': nomText,
        'prenom': prenomText,
        if (dateNaissance.value.isNotEmpty) 'date_naissance': dateNaissance.value,
        'sexe': sexe.value == 'Fille' ? 'feminin' : 'masculin',
        if (photoUrl.value.isNotEmpty) 'photo': photoUrl.value,
        if (nombreFreresSoeursController.text.trim().isNotEmpty)
          'nombre_freres_soeurs': int.tryParse(nombreFreresSoeursController.text.trim()),
        if (ordreNaissanceController.text.trim().isNotEmpty)
          'ordre_naissance': int.tryParse(ordreNaissanceController.text.trim()),
      };

      PatientModel saved;
      if (_savedPatientId != null) {
        saved = await _patientService.updatePatient(_savedPatientId!, data);
      } else {
        saved = await _patientService.createPatient(data);
        _savedPatientId = saved.id;
      }
      status.value = 'success';
      currentStep.value = 2;
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
      Get.snackbar('Erreur', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Step 2: Update dossier médical (toutes les informations médicales)
  Future<void> _saveStep2() async {
    if (_savedPatientId == null) {
      currentStep.value = 3;
      return;
    }
    try {
      status.value = 'loading';
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
        await _patientService.updateDossierMedical(_savedPatientId!, payload);
      }
      status.value = 'success';
      currentStep.value = 3;
    } catch (e) {
      status.value = 'success';
      currentStep.value = 3;
    }
  }

  // Step 3: Link parent/tuteur
  Future<void> _saveStep3() async {
    if (_savedPatientId == null || selectedParentId.value == null) {
      currentStep.value = 4;
      return;
    }
    try {
      status.value = 'loading';
      await _patientService.addParentToPatient(
        _savedPatientId!,
        parentId: selectedParentId.value!,
        role: roleParent.value,
      );
      status.value = 'success';
      currentStep.value = 4;
    } catch (e) {
      status.value = 'success';
      currentStep.value = 4;
    }
  }

  // Step 4: Finish & optional plan
  Future<void> _finishWizard() async {
    AppCacheManager.invalidateTag(CacheTags.patients);
    AppCacheManager.invalidateTag(CacheTags.dashboard);

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

    Get.back(result: true);
    Get.snackbar(
      'Succès',
      patientId != null
          ? 'Patient mis à jour avec succès.'
          : 'Nouveau patient créé avec succès.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
