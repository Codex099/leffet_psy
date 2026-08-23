import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/dossier_medical_model.dart';
import '../services/patient_service.dart';
import '../utils/json_utils.dart';

class DossierMedicalController extends GetxController {
  final PatientService _patientService = PatientService();

  final Rx<DossierMedicalModel?> dossier = Rx<DossierMedicalModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isEditing = false.obs;
  dynamic patientId;

  // Controllers pour les champs éditables
  final antecedentsController = TextEditingController();
  final medicamentsController = TextEditingController();
  final dateCasController = TextEditingController();
  final naissanceController = TextEditingController();
  final dateNaissanceController = TextEditingController();
  final nombreFreresSoeursController = TextEditingController();
  final rangFratrieController = TextEditingController();
  final devPsychomoteurController = TextEditingController();
  final compAuditifController = TextEditingController();
  final devLangagierController = TextEditingController();
  final adaptationSocialeController = TextEditingController();
  final autonomieController = TextEditingController();
  final aspectSanitaireController = TextEditingController();
  final stadeScolarisationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du patient non spécifié.';
    } else {
      loadDossier();
    }
  }

  @override
  void onClose() {
    antecedentsController.dispose();
    medicamentsController.dispose();
    dateCasController.dispose();
    naissanceController.dispose();
    dateNaissanceController.dispose();
    nombreFreresSoeursController.dispose();
    rangFratrieController.dispose();
    devPsychomoteurController.dispose();
    compAuditifController.dispose();
    devLangagierController.dispose();
    adaptationSocialeController.dispose();
    autonomieController.dispose();
    aspectSanitaireController.dispose();
    stadeScolarisationController.dispose();
    super.onClose();
  }

  Future<void> loadDossier() async {
    if (patientId == null) return;
    try {
      status.value = 'loading';
      dossier.value = await _patientService.getDossierMedical(patientId!);
      _fillControllers();
      status.value = 'success';
    } on DioException catch (e) {
      // 404 = dossier pas encore créé → formulaire vide, pas d'erreur bloquante
      if (e.response?.statusCode == 404) {
        dossier.value = null;
        _clearControllers();
        status.value = 'success';
      } else {
        errorMessage.value = e.message ?? e.toString();
        status.value = 'error';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  void _fillControllers() {
    antecedentsController.text = dossier.value?.antecedentsMedicaux ?? '';
    medicamentsController.text = dossier.value?.medicamentsPris ?? '';
    dateCasController.text = dossier.value?.dateCas ?? '';
    naissanceController.text = dossier.value?.naissance ?? '';
    dateNaissanceController.text = dossier.value?.dateNaissance ?? '';
    nombreFreresSoeursController.text = dossier.value?.nombreFreresSoeurs?.toString() ?? '';
    rangFratrieController.text = dossier.value?.rangFratrie?.toString() ?? '';
    devPsychomoteurController.text = dossier.value?.developpementPsychomoteur ?? '';
    compAuditifController.text = dossier.value?.comportementAuditif ?? '';
    devLangagierController.text = dossier.value?.developpementLangagier ?? '';
    adaptationSocialeController.text = dossier.value?.adaptationSociale ?? '';
    autonomieController.text = dossier.value?.autonomie ?? '';
    aspectSanitaireController.text = dossier.value?.aspectSanitaire ?? '';
    stadeScolarisationController.text = dossier.value?.stadeScolarisation ?? '';
  }

  void _clearControllers() {
    antecedentsController.clear();
    medicamentsController.clear();
    dateCasController.clear();
    naissanceController.clear();
    dateNaissanceController.clear();
    nombreFreresSoeursController.clear();
    rangFratrieController.clear();
    devPsychomoteurController.clear();
    compAuditifController.clear();
    devLangagierController.clear();
    adaptationSocialeController.clear();
    autonomieController.clear();
    aspectSanitaireController.clear();
    stadeScolarisationController.clear();
  }

  Future<void> saveDossier() async {
    if (patientId == null) return;
    try {
      status.value = 'loading';
      await _patientService.updateDossierMedical(patientId!, {
        'antecedents_medicaux': antecedentsController.text.isNotEmpty ? antecedentsController.text : null,
        'medicaments_pris': medicamentsController.text.isNotEmpty ? medicamentsController.text : null,
        'date_cas': dateCasController.text.isNotEmpty ? dateCasController.text : null,
        'naissance': naissanceController.text.isNotEmpty ? naissanceController.text : null,
        'date_naissance': dateNaissanceController.text.isNotEmpty ? dateNaissanceController.text : null,
        'nombre_freres_soeurs': nombreFreresSoeursController.text.isNotEmpty ? int.tryParse(nombreFreresSoeursController.text) : null,
        'rang_fratrie': rangFratrieController.text.isNotEmpty ? int.tryParse(rangFratrieController.text) : null,
        'developpement_psychomoteur': devPsychomoteurController.text.isNotEmpty ? devPsychomoteurController.text : null,
        'comportement_auditif': compAuditifController.text.isNotEmpty ? compAuditifController.text : null,
        'developpement_langagier': devLangagierController.text.isNotEmpty ? devLangagierController.text : null,
        'adaptation_sociale': adaptationSocialeController.text.isNotEmpty ? adaptationSocialeController.text : null,
        'autonomie': autonomieController.text.isNotEmpty ? autonomieController.text : null,
        'aspect_sanitaire': aspectSanitaireController.text.isNotEmpty ? aspectSanitaireController.text : null,
        'stade_scolarisation': stadeScolarisationController.text.isNotEmpty ? stadeScolarisationController.text : null,
      });
      await loadDossier();
      isEditing.value = false;
      Get.snackbar('Succès', 'Dossier médical mis à jour');
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }
}