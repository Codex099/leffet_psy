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
  final RxSet<dynamic> expandedEtapeIds = <dynamic>{}.obs;
  dynamic patientId;

  // Form controllers for creating plan
  final TextEditingController titreController = TextEditingController();
  final RxString statutPlan = 'actif'.obs;
  final Rx<dynamic> assignePlanEmployeeId = Rx<dynamic>(null);

  // Form controllers for adding step
  final TextEditingController etapeTitreController = TextEditingController();
  final TextEditingController etapeDescController = TextEditingController();
  final RxString statutEtape = 'a_faire'.obs;
  final Rx<dynamic> assigneEtapeEmployeeId = Rx<dynamic>(null);

  // Form controllers for adding sub-step (séance)
  final TextEditingController sousEtapeTitreController = TextEditingController();
  final TextEditingController sousEtapeDescController = TextEditingController();
  final RxString statutSousEtape = 'a_faire'.obs;
  final Rx<dynamic> assigneSousEtapeEmployeeId = Rx<dynamic>(null);

  static const _cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    patientId = extractIdParam(Get.arguments, Get.parameters);
    if (patientId == null) {
      status.value = 'error';
      errorMessage.value = 'Identifiant du patient non spécifié.'.tr;
    } else {
      _checkAdminAndLoad();
    }
  }

  Future<void> _checkAdminAndLoad() async {
    try {
      final me = await _authService.getCachedUser() ?? await _authService.getMe();
      isAdmin.value = me.role.toLowerCase() == 'admin';
    } catch (_) {}

    _loadFromCache();
    loadPlan();
    _loadEmployees();
  }

  @override
  void onClose() {
    titreController.dispose();
    etapeTitreController.dispose();
    etapeDescController.dispose();
    sousEtapeTitreController.dispose();
    sousEtapeDescController.dispose();
    super.onClose();
  }

  void toggleEtapeExpanded(dynamic etapeId) {
    if (expandedEtapeIds.contains(etapeId)) {
      expandedEtapeIds.remove(etapeId);
    } else {
      expandedEtapeIds.add(etapeId);
    }
  }

  void _loadFromCache() {
    if (patientId == null) return;
    final cached = AppCacheManager.get<List<PlanTherapeutiqueModel>>(CacheKeys.patientPlans(patientId));
    if (cached != null && cached.isNotEmpty) {
      plans.value = cached;
      selectedPlan.value = cached.first;
      _expandAllEtapes(cached.first);
      status.value = 'success';
    }
  }

  void _expandAllEtapes(PlanTherapeutiqueModel? plan) {
    if (plan?.etapes != null) {
      for (final e in plan!.etapes!) {
        expandedEtapeIds.add(e.id);
      }
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
        try {
          final fullPlan = await _planService.getPlan(p.id);
          updatedPlans.add(fullPlan);
        } catch (_) {
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
        _expandAllEtapes(selectedPlan.value);
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
    _expandAllEtapes(plan);
  }

  // ─── Plan CRUD & Assignation ───────────────────────────────────────────────

  Future<void> createPlan() async {
    if (patientId == null || titreController.text.trim().isEmpty) return;
    try {
      status.value = 'loading';
      await _planService.createPlan(patientId!, {
        'titre': titreController.text.trim(),
        'statut': statutPlan.value,
        if (assignePlanEmployeeId.value != null)
          'assigne_a': assignePlanEmployeeId.value.toString(),
      });
      titreController.clear();
      assignePlanEmployeeId.value = null;
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès'.tr, 'Plan créé avec succès'.tr, snackPosition: SnackPosition.BOTTOM);
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible de créer le plan'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
      status.value = 'error';
      errorMessage.value = e.toString();
    }
  }

  Future<void> updatePlanStatut(dynamic planId, String newStatut) async {
    try {
      await _planService.updatePlan(planId, {'statut': newStatut});
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès'.tr, 'Statut du plan mis à jour'.tr, snackPosition: SnackPosition.BOTTOM);
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible de modifier le statut'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deletePlan(dynamic planId) async {
    try {
      await _planService.deletePlan(planId);
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès'.tr, 'Plan supprimé avec succès'.tr, snackPosition: SnackPosition.BOTTOM);
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible de supprimer le plan'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> assignPlan(dynamic planId, dynamic employeeId, {bool propager = false}) async {
    try {
      await _planService.assignPlan(planId, employeeId, propager: propager);
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar(
        'Succès'.tr,
        propager
            ? 'Plan et ensemble des étapes/séances assignés avec succès'.tr
            : 'Plan assigné avec succès'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible d\'assigner le plan'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Étapes CRUD & Assignation ─────────────────────────────────────────────

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
        if (assigneEtapeEmployeeId.value != null)
          'assigne_a': assigneEtapeEmployeeId.value.toString(),
      });
      etapeTitreController.clear();
      etapeDescController.clear();
      statutEtape.value = 'a_faire';
      assigneEtapeEmployeeId.value = null;
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès'.tr, 'Étape ajoutée avec succès'.tr, snackPosition: SnackPosition.BOTTOM);
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible d\'ajouter l\'étape'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateEtapeStatut(dynamic planId, dynamic etapeId, String newStatut) async {
    try {
      final statutVal = newStatut == 'termine' ? 'fait' : newStatut;
      await _planService.updateEtape(planId, etapeId, {'statut': statutVal});
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès'.tr, 'Statut de l\'étape mis à jour'.tr, snackPosition: SnackPosition.BOTTOM);
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible de mettre à jour le statut'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteEtape(dynamic planId, dynamic etapeId) async {
    try {
      await _planService.deleteEtape(planId, etapeId);
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès'.tr, 'Étape supprimée'.tr, snackPosition: SnackPosition.BOTTOM);
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible de supprimer l\'étape'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> assignEtape(dynamic planId, dynamic etapeId, dynamic employeeId, {bool propager = false}) async {
    try {
      await _planService.assignEtape(planId, etapeId, employeeId, propager: propager);
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar(
        'Succès'.tr,
        propager
            ? 'Étape et ses séances assignées avec succès'.tr
            : 'Étape assignée avec succès'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible d\'assigner l\'étape'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Sous-Étapes (Séances) CRUD & Assignation ──────────────────────────────

  Future<void> addSousEtape(dynamic planId, dynamic etapeId) async {
    if (sousEtapeTitreController.text.trim().isEmpty) return;
    try {
      final etape = selectedPlan.value?.etapes?.firstWhereOrNull((e) => e.id == etapeId);
      final currentSousEtapes = etape?.sousEtapes ?? [];
      final statutVal = statutSousEtape.value == 'termine' ? 'fait' : statutSousEtape.value;

      await _planService.createSousEtape(planId, etapeId, {
        'titre': sousEtapeTitreController.text.trim(),
        'description': sousEtapeDescController.text.trim(),
        'statut': statutVal,
        'ordre': currentSousEtapes.length + 1,
        if (assigneSousEtapeEmployeeId.value != null)
          'assigne_a': assigneSousEtapeEmployeeId.value.toString(),
      });

      sousEtapeTitreController.clear();
      sousEtapeDescController.clear();
      statutSousEtape.value = 'a_faire';
      assigneSousEtapeEmployeeId.value = null;
      expandedEtapeIds.add(etapeId);

      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès'.tr, 'Séance ajoutée avec succès'.tr, snackPosition: SnackPosition.BOTTOM);
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible d\'ajouter la séance'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateSousEtapeStatut(
    dynamic planId,
    dynamic etapeId,
    dynamic sousEtapeId,
    String newStatut,
  ) async {
    try {
      final statutVal = newStatut == 'termine' ? 'fait' : newStatut;
      await _planService.updateSousEtape(planId, etapeId, sousEtapeId, {'statut': statutVal});
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès'.tr, 'Statut de la séance mis à jour'.tr, snackPosition: SnackPosition.BOTTOM);
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible de mettre à jour le statut'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateSousEtapeDetails(
    dynamic planId,
    dynamic etapeId,
    dynamic sousEtapeId, {
    required String titre,
    String? description,
    String? statut,
  }) async {
    try {
      final data = <String, dynamic>{'titre': titre};
      if (description != null) data['description'] = description;
      if (statut != null) data['statut'] = statut == 'termine' ? 'fait' : statut;
      await _planService.updateSousEtape(planId, etapeId, sousEtapeId, data);
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès'.tr, 'Séance mise à jour'.tr, snackPosition: SnackPosition.BOTTOM);
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible de modifier la séance'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteSousEtape(dynamic planId, dynamic etapeId, dynamic sousEtapeId) async {
    try {
      await _planService.deleteSousEtape(planId, etapeId, sousEtapeId);
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès'.tr, 'Séance supprimée'.tr, snackPosition: SnackPosition.BOTTOM);
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible de supprimer la séance'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> assignSousEtape(
    dynamic planId,
    dynamic etapeId,
    dynamic sousEtapeId,
    dynamic employeeId,
  ) async {
    try {
      await _planService.assignSousEtape(planId, etapeId, sousEtapeId, employeeId);
      AppCacheManager.invalidateTag(CacheTags.patients);
      Get.snackbar('Succès'.tr, 'Séance assignée avec succès'.tr, snackPosition: SnackPosition.BOTTOM);
      await loadPlan(forceRefresh: true);
    } catch (e) {
      Get.snackbar('Erreur'.tr, '${'Impossible d\'assigner la séance'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Employés & Tâches ─────────────────────────────────────────────────────

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
      Get.snackbar('Erreur'.tr, '${'Impossible de convertir en tâche'.tr} : $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
