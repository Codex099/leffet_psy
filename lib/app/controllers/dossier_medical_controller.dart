import 'package:get/get.dart';
import '../models/dossier_medical_model.dart';
import '../services/patient_service.dart';
import '../utils/json_utils.dart';

class DossierMedicalController extends GetxController {
  final PatientService _patientService = PatientService();

  final Rx<DossierMedicalModel?> dossier = Rx<DossierMedicalModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  int? patientId;

  final antecedents = ''.obs;
  final medicaments = ''.obs;
  final dateCas = ''.obs;
  final naissance = ''.obs;
  final devPsychomoteur = ''.obs;
  final compAuditif = ''.obs;
  final devLangagier = ''.obs;
  final adaptationSociale = ''.obs;
  final autonomie = ''.obs;
  final aspectSanitaire = ''.obs;
  final stadeScolarisation = ''.obs;

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

  Future<void> loadDossier() async {
    if (patientId == null) return;
    try {
      status.value = 'loading';
      dossier.value = await _patientService.getDossierMedical(patientId!);
      antecedents.value = dossier.value?.antecedentsMedicaux ?? '';
      medicaments.value = dossier.value?.medicamentsPris ?? '';
      dateCas.value = dossier.value?.dateCas ?? '';
      naissance.value = dossier.value?.naissance ?? '';
      devPsychomoteur.value = dossier.value?.developpementPsychomoteur ?? '';
      compAuditif.value = dossier.value?.comportementAuditif ?? '';
      devLangagier.value = dossier.value?.developpementLangagier ?? '';
      adaptationSociale.value = dossier.value?.adaptationSociale ?? '';
      autonomie.value = dossier.value?.autonomie ?? '';
      aspectSanitaire.value = dossier.value?.aspectSanitaire ?? '';
      stadeScolarisation.value = dossier.value?.stadeScolarisation ?? '';
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> saveDossier() async {
    if (patientId == null) return;
    try {
      status.value = 'loading';
      await _patientService.updateDossierMedical(patientId!, {
        'antecedents_medicaux': antecedents.value,
        'medicaments_pris': medicaments.value,
        'date_cas': dateCas.value,
        'naissance': naissance.value,
        'developpement_psychomoteur': devPsychomoteur.value,
        'comportement_auditif': compAuditif.value,
        'developpement_langagier': devLangagier.value,
        'adaptation_sociale': adaptationSociale.value,
        'autonomie': autonomie.value,
        'aspect_sanitaire': aspectSanitaire.value,
        'stade_scolarisation': stadeScolarisation.value,
      });
      Get.back();
      Get.snackbar('Succès', 'Dossier médical mis à jour');
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

}