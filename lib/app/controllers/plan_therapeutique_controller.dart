import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/plan_therapeutique_model.dart';
import '../services/plan_therapeutique_service.dart';
import '../utils/json_utils.dart';

class PlanTherapeutiqueController extends GetxController {
  final PlanTherapeutiqueService _planService = PlanTherapeutiqueService();

  final RxList<PlanTherapeutiqueModel> plans = <PlanTherapeutiqueModel>[].obs;
  final Rx<PlanTherapeutiqueModel?> selectedPlan = Rx<PlanTherapeutiqueModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  dynamic patientId;

  // Form controllers for creating plan
  final TextEditingController titreController = TextEditingController();
  final RxString statutPlan = 'actif'.obs;

  // Form controllers for adding step
  final TextEditingController etapeTitreController = TextEditingController();
  final TextEditingController etapeDescController = TextEditingController();
  final RxString statutEtape = 'a_faire'.obs;

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du patient non spécifié.';
    } else {
      loadPlan();
    }
  }

  @override
  void onClose() {
    titreController.dispose();
    etapeTitreController.dispose();
    etapeDescController.dispose();
    super.onClose();
  }

  Future<void> loadPlan() async {
    if (patientId == null) return;
    try {
      status.value = 'loading';
      final fetchedPlans = await _planService.getPlansPatient(patientId!);
      
      final updatedPlans = <PlanTherapeutiqueModel>[];
      for (final p in fetchedPlans) {
        if (p.etapes == null || p.etapes!.isEmpty) {
          try {
            final etapes = await _planService.getEtapes(p.id);
            updatedPlans.add(PlanTherapeutiqueModel(
              id: p.id,
              patientId: p.patientId,
              titre: p.titre,
              statut: p.statut,
              dateDebut: p.dateDebut,
              dateFin: p.dateFin,
              creePar: p.creePar,
              etapes: etapes,
            ));
          } catch (_) {
            updatedPlans.add(p);
          }
        } else {
          updatedPlans.add(p);
        }
      }

      plans.value = updatedPlans;
      if (plans.isNotEmpty) {
        if (selectedPlan.value != null) {
          final found = plans.firstWhereOrNull((item) => item.id == selectedPlan.value!.id);
          selectedPlan.value = found ?? plans.first;
        } else {
          selectedPlan.value = plans.first;
        }
        status.value = 'success';
      } else {
        selectedPlan.value = null;
        status.value = 'empty';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  void selectPlan(PlanTherapeutiqueModel plan) {
    selectedPlan.value = plan;
  }

  Future<void> createPlan() async {
    if (patientId == null || titreController.text.trim().isEmpty) return;
    try {
      status.value = 'loading';
      await _planService.createPlan(patientId!, {
        'titre': titreController.text.trim(),
        'statut': statutPlan.value,
      });
      titreController.clear();
      Get.snackbar('Succès', 'Plan créé avec succès', snackPosition: SnackPosition.BOTTOM);
      await loadPlan();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer le plan: $e', snackPosition: SnackPosition.BOTTOM);
      status.value = 'error';
      errorMessage.value = e.toString();
    }
  }

  Future<void> updatePlanStatut(dynamic planId, String newStatut) async {
    try {
      await _planService.updatePlan(planId, {'statut': newStatut});
      Get.snackbar('Succès', 'Statut du plan mis à jour', snackPosition: SnackPosition.BOTTOM);
      await loadPlan();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier le statut du plan: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addEtape() async {
    if (selectedPlan.value == null || etapeTitreController.text.trim().isEmpty) return;
    try {
      final currentEtapes = selectedPlan.value!.etapes ?? [];
      final statutVal = statutEtape.value == 'termine' ? 'fait' : statutEtape.value;
      await _planService.createEtape(selectedPlan.value!.id, {
        'titre': etapeTitreController.text.trim(),
        'description': etapeDescController.text.trim(),
        'statut': statutVal,
        'ordre': currentEtapes.length + 1,
      });
      etapeTitreController.clear();
      etapeDescController.clear();
      statutEtape.value = 'a_faire';
      Get.snackbar('Succès', 'Étape ajoutée', snackPosition: SnackPosition.BOTTOM);
      await loadPlan();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter l\'étape: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateEtapeStatut(dynamic planId, dynamic etapeId, String newStatut) async {
    try {
      final statutVal = newStatut == 'termine' ? 'fait' : newStatut;
      await _planService.updateEtape(planId, etapeId, {'statut': statutVal});
      Get.snackbar('Succès', 'Statut de l\'étape mis à jour', snackPosition: SnackPosition.BOTTOM);
      await loadPlan();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le statut: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteEtape(dynamic planId, dynamic etapeId) async {
    try {
      await _planService.deleteEtape(planId, etapeId);
      Get.snackbar('Succès', 'Étape supprimée', snackPosition: SnackPosition.BOTTOM);
      await loadPlan();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer l\'étape', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> convertEtapeToTache(dynamic planId, dynamic etapeId) async {
    try {
      await _planService.creerTacheDepuisEtape(planId, etapeId);
      Get.snackbar('Succès', 'Étape convertie en tâche', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de convertir en tâche', snackPosition: SnackPosition.BOTTOM);
    }
  }
}