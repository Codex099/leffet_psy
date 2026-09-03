import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/plan_therapeutique_model.dart';
import '../models/employee_model.dart';
import '../services/cache_manager.dart';
import '../services/plan_therapeutique_service.dart';
import '../services/employee_service.dart';
import '../services/tache_service.dart';
import '../services/auth_service.dart';
import '../utils/json_utils.dart';

class PlanTherapeutiqueController extends GetxController {
  final PlanTherapeutiqueService _planService = PlanTherapeutiqueService();
  final EmployeeService _employeeService = EmployeeService();
  final TacheService _tacheService = TacheService();
  final AuthService _authService = AuthService();

  final RxList<PlanTherapeutiqueModel> plans = <PlanTherapeutiqueModel>[].obs;
  final RxList<EmployeeModel> availableEmployees = <EmployeeModel>[].obs;
  final Rx<PlanTherapeutiqueModel?> selectedPlan = Rx<PlanTherapeutiqueModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAdmin = false.obs;
  dynamic patientId;

  // Form controllers for creating plan
  final TextEditingController titreController = TextEditingController();
  final RxString statutPlan = 'actif'.obs;

 // Form controllers for adding step
  final TextEditingController etapeTitreController = TextEditingController();
  final TextEditingController etapeDescController = TextEditingController();
  final RxString statutEtape = 'a_faire'.obs;

 static const _cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null) {
      status.value = 'error';
     errorMessage.value = 'Identifiant du patient non spécifié.';
   } else {
      _checkAdminAndLoad();
    }
  }

  Future<void> _checkAdminAndLoad() async {
    try {
      final me = await _authService.getCachedUser() ?? await _authService.getMe();
      isAdmin.value = me.role.toLowerCase() == 'admin';
    } catch (_) {}

    if (!isAdmin.value) {
      status.value = 'error';
      errorMessage.value = 'Accès réservé aux administrateurs.';
      return;
    }

    _loadFromCache();
    loadPlan();
    _loadEmployees();
  }

  @override
  void onClose() {
    titreController.dispose();
    etapeTitreController.dispose();
    etapeDescController.dispose();
    super.onClose();
  }

  void _loadFromCache() {
    if (patientId == null) return;
    final cached = AppCacheManager.get<List<PlanTherapeutiqueModel>>(CacheKeys.patientPlans(patientId));
    if (cached != null && cached.isNotEmpty) {
      plans.value = cached;
      selectedPlan.value = cached.first;
      status.value = 'success';
   }
  }

  Future<void> loadPlan({bool forceRefresh = false}) async {
    if (patientId == null) return;
    final cacheKey = CacheKeys.patientPlans(patientId);

    if (AppCacheManager.isFresh(cacheKey) && !forceRefresh && plans.isNotEmpty) {
      return;
    }

    if (plans.isEmpty) {
      status.value = 'loading';
   }

    try {
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
      AppCacheManager.set<List<PlanTherapeutiqueModel>>(
        cacheKey,
        updatedPlans,
        ttl: _cacheDuration,
        tags: {CacheTags.patients},
      );

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
      if (plans.isEmpty) {
        errorMessage.value = e.toString();
        status.value = 'error';
     }
    }
  }

  Future<void> refreshData() => loadPlan(forceRefresh: true);

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
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès', 'Plan créé avec succès', snackPosition: SnackPosition.BOTTOM);
     await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer le plan: $e', snackPosition: SnackPosition.BOTTOM);
     status.value = 'error';
     errorMessage.value = e.toString();
    }
  }

  Future<void> updatePlanStatut(dynamic planId, String newStatut) async {
    try {
      await _planService.updatePlan(planId, {'statut': newStatut});
     AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès', 'Statut du plan mis à jour', snackPosition: SnackPosition.BOTTOM);
     await loadPlan(forceRefresh: true);
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
     AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès', 'Étape ajoutée', snackPosition: SnackPosition.BOTTOM);
     await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter l\'étape: $e', snackPosition: SnackPosition.BOTTOM);
   }
  }

  Future<void> updateEtapeStatut(dynamic planId, dynamic etapeId, String newStatut) async {
    try {
      final statutVal = newStatut == 'termine' ? 'fait' : newStatut;
     await _planService.updateEtape(planId, etapeId, {'statut': statutVal});
     AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès', 'Statut de l\'étape mis à jour', snackPosition: SnackPosition.BOTTOM);
     await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le statut: $e', snackPosition: SnackPosition.BOTTOM);
   }
  }

  Future<void> deleteEtape(dynamic planId, dynamic etapeId) async {
    try {
      await _planService.deleteEtape(planId, etapeId);
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès', 'Étape supprimée', snackPosition: SnackPosition.BOTTOM);
     await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer l\'étape', snackPosition: SnackPosition.BOTTOM);
   }
  }

  Future<void> _loadEmployees() async {
    try {
      final emps = await _employeeService.getEmployees();
      availableEmployees.value = emps;
    } catch (_) {}
  }

  Future<void> convertEtapeToTache(
    dynamic planId,
    dynamic etapeId, {
    required String assigneA,
    String priorite = 'normale',
    String? dateEcheance,
    String? titre,
    String? description,
  }) async {
    try {
      try {
        await _tacheService.createTache({
          'titre': titre ?? 'Étape du plan thérapeutique',
          'description': description ?? '',
          'assigne_a': assigneA,
          if (patientId != null) 'patient_id': patientId.toString(),
          'etape_plan_id': etapeId.toString(),
          'statut': 'a_faire',
          'priorite': priorite,
          if (dateEcheance != null && dateEcheance.isNotEmpty)
            'date_echeance': dateEcheance.contains('T')
                ? dateEcheance
                : '${dateEcheance}T18:00:00',
        });
      } catch (_) {
        await _planService.creerTacheDepuisEtape(
          planId,
          etapeId,
          assigneA: assigneA,
        );
      }
      AppCacheManager.invalidateTag(CacheTags.taches);
      Get.snackbar('Succès'.tr, 'Étape convertie en tâche avec succès'.tr, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur'.tr, 'Impossible de convertir en tâche : $e'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }
}