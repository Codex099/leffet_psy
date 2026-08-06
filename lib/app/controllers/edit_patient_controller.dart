import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/parent_model.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';
import '../services/parent_service.dart';
import '../services/upload_service.dart';
import '../utils/json_utils.dart';

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
  final nom = ''.obs;
  final prenom = ''.obs;
  final dateNaissance = ''.obs;
  final sexe = 'Garçon'.obs;
  final nombreFreresSoeurs = ''.obs;
  final ordreNaissance = ''.obs;

  // Photo
  final Rx<File?> pickedPhoto = Rx<File?>(null);
  final RxString photoUrl = ''.obs;
  final RxBool photoUploading = false.obs;

  // ──── Step 2 — Dossier médical (Toutes les informations médicales) ────
  // Avant le titre
  final antecedentsMedicaux = ''.obs; // Antécédents médicaux / السوابق المرضية
  final medicamentsPris = ''.obs;     // Médicaments pris / الأدوية المتناولة

  // Historique du cas
  final dateCas = ''.obs;                    // Date de la case (historique) / تاريخ الحالة
  final naissance = ''.obs;                  // Naissance / الولادة
  final developpementPsychomoteur = ''.obs; // Développement psychomoteur / النمو النفسي الحركي
  final comportementAuditif = ''.obs;       // Comportement auditif / السلوك السمعي
  final developpementLangagier = ''.obs;    // Développement langagier / النمو اللغوي
  final adaptationSociale = ''.obs;         // Adaptation sociale / التكيف الاجتماعي
  final autonomie = ''.obs;                 // Autonomie / الاستقلالية
  final aspectSanitaire = ''.obs;           // Aspect sanitaire / médical / الجانب الصحي
  final stadeScolarisation = ''.obs;        // Stade de scolarisation / مرحلة التمدرس

  // ──── Step 3 — Tuteur ────
  final RxList<ParentModel> availableParents = <ParentModel>[].obs;
  final RxnInt selectedParentId = RxnInt(null);
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

  static const List<Map<String, String>> roleChoices = [
    {'value': 'pere', 'label': 'Père'},
    {'value': 'mere', 'label': 'Mère'},
    {'value': 'tuteur', 'label': 'Tuteur légal'},
    {'value': 'oncle', 'label': 'Oncle'},
    {'value': 'tante', 'label': 'Tante'},
    {'value': 'grand_pere', 'label': 'Grand-père'},
    {'value': 'grand_mere', 'label': 'Grand-mère'},
    {'value': 'autre', 'label': 'Autre'},
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

  Future<void> _loadPatient(dynamic id) async {
    try {
      status.value = 'loading';
      final p = await _patientService.getPatient(id);
      nom.value = p.nom;
      prenom.value = p.prenom;
      dateNaissance.value = p.dateNaissance ?? '';
      sexe.value = p.isFille ? 'Fille' : 'Garçon';
      photoUrl.value = p.photo ?? '';
      nombreFreresSoeurs.value = p.nombreFreresSoeurs?.toString() ?? '';
      ordreNaissance.value = p.ordreNaissance?.toString() ?? '';
      _savedPatientId = id;

      // Charger le dossier médical si disponible
      try {
        final dm = await _patientService.getDossierMedical(id);
        antecedentsMedicaux.value = dm.antecedentsMedicaux ?? '';
        medicamentsPris.value = dm.medicamentsPris ?? '';
        dateCas.value = dm.dateCas ?? '';
        naissance.value = dm.naissance ?? '';
        developpementPsychomoteur.value = dm.developpementPsychomoteur ?? '';
        comportementAuditif.value = dm.comportementAuditif ?? '';
        developpementLangagier.value = dm.developpementLangagier ?? '';
        adaptationSociale.value = dm.adaptationSociale ?? '';
        autonomie.value = dm.autonomie ?? '';
        aspectSanitaire.value = dm.aspectSanitaire ?? '';
        stadeScolarisation.value = dm.stadeScolarisation ?? '';
      } catch (_) {
        // Dossier médical non existant encore
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
    if (prenom.value.trim().isEmpty || nom.value.trim().isEmpty) {
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
        'nom': nom.value.trim(),
        'prenom': prenom.value.trim(),
        if (dateNaissance.value.isNotEmpty) 'date_naissance': dateNaissance.value,
        'sexe': sexe.value == 'Fille' ? 'feminin' : 'masculin',
        if (photoUrl.value.isNotEmpty) 'photo': photoUrl.value,
        if (nombreFreresSoeurs.value.isNotEmpty)
          'nombre_freres_soeurs': int.tryParse(nombreFreresSoeurs.value),
        if (ordreNaissance.value.isNotEmpty)
          'ordre_naissance': int.tryParse(ordreNaissance.value),
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
        if (antecedentsMedicaux.value.trim().isNotEmpty)
          'antecedents_medicaux': antecedentsMedicaux.value.trim(),
        if (medicamentsPris.value.trim().isNotEmpty)
          'medicaments_pris': medicamentsPris.value.trim(),
        if (dateCas.value.trim().isNotEmpty)
          'date_cas': dateCas.value.trim(),
        if (naissance.value.trim().isNotEmpty)
          'naissance': naissance.value.trim(),
        if (developpementPsychomoteur.value.trim().isNotEmpty)
          'developpement_psychomoteur': developpementPsychomoteur.value.trim(),
        if (comportementAuditif.value.trim().isNotEmpty)
          'comportement_auditif': comportementAuditif.value.trim(),
        if (developpementLangagier.value.trim().isNotEmpty)
          'developpement_langagier': developpementLangagier.value.trim(),
        if (adaptationSociale.value.trim().isNotEmpty)
          'adaptation_sociale': adaptationSociale.value.trim(),
        if (autonomie.value.trim().isNotEmpty)
          'autonomie': autonomie.value.trim(),
        if (aspectSanitaire.value.trim().isNotEmpty)
          'aspect_sanitaire': aspectSanitaire.value.trim(),
        if (stadeScolarisation.value.trim().isNotEmpty)
          'stade_scolarisation': stadeScolarisation.value.trim(),
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