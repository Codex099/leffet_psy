import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/groupe_model.dart';
import '../services/patient_service.dart';
import '../services/groupe_service.dart';
import '../services/seance_service.dart';
import '../services/seance_groupe_service.dart';

class CreationSeanceController extends GetxController {
  final SeanceService _seanceService = SeanceService();
  final SeanceGroupeService _seanceGroupeService = SeanceGroupeService();
  final PatientService _patientService = PatientService();
  final GroupeService _groupeService = GroupeService();

  final typeSeance = 'individuelle'.obs; // 'individuelle' | 'groupe'
  final patients = <PatientModel>[].obs;
  final groupes = <GroupeModel>[].obs;

  final selectedPatientId = RxnInt();
  final selectedGroupeId = RxnInt();
  final date = ''.obs;
  final heureDebut = '10:00'.obs;
  final heureFin = '10:45'.obs;

  final RxString status = 'loading'.obs;

  @override
  void onInit() {
    super.onInit();
    date.value = DateTime.now().toIso8601String().split('T').first;
    loadOptions();
  }

  Future<void> loadOptions() async {
    try {
      status.value = 'loading';
      patients.value = await _patientService.getPatients(actif: true);
      groupes.value = await _groupeService.getGroupes();
      if (patients.isNotEmpty) selectedPatientId.value = patients.first.id;
      if (groupes.isNotEmpty) selectedGroupeId.value = groupes.first.id;
      status.value = 'success';
    } catch (e) {
      status.value = 'error';
    }
  }

  Future<void> createSeance() async {
    if (date.value.isEmpty || heureDebut.value.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs obligatoires');
      return;
    }

    try {
      status.value = 'loading';
      if (typeSeance.value == 'individuelle') {
        if (selectedPatientId.value == null) {
          Get.snackbar('Erreur', 'Veuillez sélectionner un patient');
          status.value = 'success';
          return;
        }
        await _seanceService.createSeance({
          'patient_id': selectedPatientId.value,
          'date': date.value,
          'heure_debut': heureDebut.value,
          'heure_fin': heureFin.value,
          'statut': 'planifiee',
        });
      } else {
        if (selectedGroupeId.value == null) {
          Get.snackbar('Erreur', 'Veuillez sélectionner un groupe');
          status.value = 'success';
          return;
        }
        await _seanceGroupeService.createSeanceGroupe({
          'groupe_id': selectedGroupeId.value,
          'date': date.value,
          'heure_debut': heureDebut.value,
          'heure_fin': heureFin.value,
          'statut': 'planifiee',
        });
      }
      Get.back();
      Get.snackbar('Succès', 'Séance planifiée avec succès');
    } catch (e) {
      status.value = 'success';
      Get.snackbar('Erreur', 'Impossible de planifier la séance');
    }
  }
}
