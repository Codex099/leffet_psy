import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../models/patient_model.dart';
import '../models/tache_model.dart';
import '../services/auth_service.dart';
import '../services/cache_manager.dart';
import '../services/employee_service.dart';
import '../services/patient_service.dart';
import '../services/tache_service.dart';
import '../utils/json_utils.dart';
import 'taches_controller.dart';

class DetailTacheController extends GetxController {
  final TacheService _tacheService = TacheService();
  final EmployeeService _employeeService = EmployeeService();
  final PatientService _patientService = PatientService();
  final AuthService _authService = AuthService();

  final Rx<TacheModel?> tache = Rx<TacheModel?>(null);
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;

  // ── Utilisateur & permissions ──────────────────────────────────────────────
  final RxBool isAdmin = false.obs;
  final RxBool canAssignTasks = false.obs;
  final RxString currentUserId = ''.obs;

  /// Mode édition ou consultation
  final RxBool isEditing = false.obs;

  // Form fields
  final titre = ''.obs;
  final description = ''.obs;
  final priorite = 'normale'.obs;
  final statut = 'a_faire'.obs;
  final dateEcheance = ''.obs;

  // Assignee & Patient
  final Rx<dynamic> assigneA = Rx<dynamic>(null);
  final RxList<EmployeeModel> availableEmployees = <EmployeeModel>[].obs;
  final RxString employeesStatus = 'loading'.obs;

  final Rx<dynamic> patientId = Rx<dynamic>(null);
  final RxList<PatientModel> availablePatients = <PatientModel>[].obs;

  bool get isNew => tache.value == null;

  /// Droit d'assigner à d'autres praticiens
  bool get hasAssignPermission => isAdmin.value || canAssignTasks.value;

  /// Droit de modifier tous les détails de la tâche
  bool get canEdit {
    if (isNew) return true;
    if (isAdmin.value || canAssignTasks.value) return true;
    // L'employé peut modifier si c'est sa propre tâche ou s'il l'a créée
    final curId = currentUserId.value;
    if (curId.isEmpty) return false;
    final t = tache.value;
    if (t == null) return true;
    final isMine = t.assigneA?.toString() == curId;
    final isCreator = t.creePar?.toString() == curId;
    return isMine || isCreator;
  }

  /// Tâche assignée à l'utilisateur actuel
  bool get isAssignedToMe {
    final curId = currentUserId.value;
    if (curId.isEmpty) return false;
    return tache.value?.assigneA?.toString() == curId || assigneA.value?.toString() == curId;
  }

  @override
  void onInit() {
    super.onInit();
    _checkUser();
    _loadEmployees();
    _loadPatients();
    final id = extractIdParam(Get.arguments, Get.parameters);
    if (id != null) {
      _loadFromCache(id);
      loadTache(id);
    } else {
      isEditing.value = true;
      status.value = 'success';
    }
  }

  Future<void> _checkUser() async {
    try {
      final me = await _authService.getCachedUser() ?? await _authService.getMe();
      isAdmin.value = me.isAdmin;
      canAssignTasks.value = me.canAssignTasks;
      currentUserId.value = me.id.toString();
      if (!hasAssignPermission && isNew) {
        assigneA.value = me.id;
      }
    } catch (_) {}
  }

  void _loadFromCache(dynamic id) {
    final cached = AppCacheManager.get<TacheModel>(CacheKeys.tacheDetail(id));
    if (cached != null) {
      _populateFromModel(cached);
      status.value = 'success';
    }
  }

  void _populateFromModel(TacheModel t) {
    tache.value = t;
    titre.value = t.titre;
    description.value = t.description ?? '';
    priorite.value = t.priorite;
    statut.value = t.statut;
    assigneA.value = t.assigneA;
    patientId.value = t.patientId;
    dateEcheance.value = t.dateEcheance ?? '';
  }

  Future<void> _loadEmployees() async {
    final cached = AppCacheManager.get<List<EmployeeModel>>(CacheKeys.employesList);
    if (cached != null && cached.isNotEmpty) {
      availableEmployees.value = cached;
      employeesStatus.value = 'success';
      return;
    }
    try {
      employeesStatus.value = 'loading';
      final list = await _employeeService.getEmployees();
      availableEmployees.value = list;
      employeesStatus.value = 'success';
    } catch (_) {
      employeesStatus.value = 'error';
    }
  }

  Future<void> _loadPatients() async {
    final cached = AppCacheManager.get<List<PatientModel>>(CacheKeys.patientsList);
    if (cached != null && cached.isNotEmpty) {
      availablePatients.value = cached.where((p) => p.estActif).toList();
      return;
    }
    try {
      final list = await _patientService.getPatients(actif: true);
      availablePatients.value = list;
    } catch (_) {}
  }

  Future<void> loadTache(dynamic id, {bool forceRefresh = false}) async {
    final cacheKey = CacheKeys.tacheDetail(id);
    if (AppCacheManager.isFresh(cacheKey) && !forceRefresh && tache.value != null) {
      return;
    }

    if (tache.value == null) {
      status.value = 'loading';
    }

    try {
      final t = await _tacheService.getTache(id);
      _populateFromModel(t);

      AppCacheManager.set<TacheModel>(
        cacheKey,
        t,
        ttl: const Duration(minutes: 5),
        tags: {CacheTags.taches},
      );

      status.value = 'success';
    } catch (e) {
      if (tache.value == null) {
        errorMessage.value = e.toString();
        status.value = 'error';
      }
    }
  }

  void toggleEditMode() {
    if (!canEdit) return;
    if (isEditing.value && !isNew) {
      // Annuler les modifications non sauvegardées et revenir aux valeurs enregistrées
      if (tache.value != null) {
        _populateFromModel(tache.value!);
      }
    }
    isEditing.value = !isEditing.value;
  }

  // Quick status cycle
  static const _statutOrder = ['a_faire', 'en_cours', 'fait'];

  Future<void> cycleStatut() async {
    if (tache.value == null) return;
    final idx = _statutOrder.indexOf(statut.value);
    final next = _statutOrder[(idx + 1) % _statutOrder.length];
    statut.value = next;
    await _patchStatut(tache.value!.id, next);
  }

  Future<void> setStatut(String newStatut) async {
    if (tache.value == null) {
      statut.value = newStatut;
      return;
    }
    statut.value = newStatut;
    await _patchStatut(tache.value!.id, newStatut);
  }

  Future<void> _patchStatut(dynamic id, String newStatut) async {
    try {
      final updated = await _tacheService.updateTache(id, {'statut': newStatut});
      tache.value = updated;
      AppCacheManager.invalidateTag(CacheTags.taches);
      Get.snackbar('Statut mis à jour'.tr, _statutLabel(newStatut),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    } catch (_) {
      Get.snackbar('Erreur'.tr, 'Impossible de mettre à jour le statut.'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _statutLabel(String s) {
    switch (s) {
      case 'a_faire': return 'À faire'.tr;
      case 'en_cours': return 'En cours'.tr;
      case 'fait': return 'Terminée'.tr;
      default: return s;
    }
  }

  Future<void> saveTache() async {
    if (titre.value.trim().isEmpty) {
      Get.snackbar('Champ requis'.tr, 'Le titre de la tâche est obligatoire.'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      // Si l'utilisateur n'a pas le droit d'assigner à d'autres, assigner à lui-même
      final targetAssignee = hasAssignPermission
          ? assigneA.value
          : (currentUserId.value.isNotEmpty ? currentUserId.value : assigneA.value);

      final data = <String, dynamic>{
        'titre': titre.value.trim(),
        if (description.value.trim().isNotEmpty) 'description': description.value.trim(),
        'priorite': priorite.value,
        'statut': statut.value,
        if (targetAssignee != null) ...{'assigne_a': targetAssignee},
        if (patientId.value != null) ...{'patient_id': patientId.value},
        if (dateEcheance.value.isNotEmpty) 'date_echeance': dateEcheance.value,
      };

      if (isNew) {
        final created = await _tacheService.createTache(data);
        tache.value = created;
        isEditing.value = false;
        Get.snackbar('Succès'.tr, 'Tâche créée avec succès.'.tr, snackPosition: SnackPosition.BOTTOM);
      } else {
        final updated = await _tacheService.updateTache(tache.value!.id, data);
        tache.value = updated;
        isEditing.value = false;
        Get.snackbar('Succès'.tr, 'Tâche mise à jour.'.tr, snackPosition: SnackPosition.BOTTOM);
      }

      AppCacheManager.invalidateTag(CacheTags.taches);
      AppCacheManager.invalidateTag(CacheTags.patients);

      try {
        if (Get.isRegistered<TachesController>()) {
          Get.find<TachesController>().loadTaches(forceRefresh: true);
        }
      } catch (_) {}

      if (isNew) {
        Get.back(result: true);
      }
    } catch (e) {
      Get.snackbar('Erreur'.tr, 'Impossible d\'enregistrer la tâche: $e'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteTache() async {
    if (tache.value == null) return;
    try {
      await _tacheService.deleteTache(tache.value!.id);
      AppCacheManager.invalidateTag(CacheTags.taches);
      try {
        if (Get.isRegistered<TachesController>()) {
          Get.find<TachesController>().loadTaches(forceRefresh: true);
        }
      } catch (_) {}
      Get.back(result: true);
      Get.snackbar('Supprimée'.tr, 'Tâche supprimée.'.tr, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erreur'.tr, 'Impossible de supprimer la tâche.'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  String get employeeName {
    if (assigneA.value == null) {
      if (tache.value?.assigneEmployee != null) {
        final a = tache.value!.assigneEmployee!;
        return '${a['prenom'] ?? ''} ${a['nom'] ?? ''}'.trim();
      }
      return 'Non assignée'.tr;
    }
    final emp = availableEmployees.firstWhereOrNull(
      (e) => e.id.toString() == assigneA.value.toString(),
    );
    if (emp != null) return emp.fullName;
    if (tache.value?.assigneEmployee != null) {
      final a = tache.value!.assigneEmployee!;
      return '${a['prenom'] ?? ''} ${a['nom'] ?? ''}'.trim();
    }
    return 'Non assignée'.tr;
  }

  String? get employeeRole {
    final emp = availableEmployees.firstWhereOrNull(
      (e) => e.id.toString() == assigneA.value.toString(),
    );
    return emp?.roleLabel;
  }

  PatientModel? get linkedPatient {
    if (patientId.value == null) return null;
    return availablePatients.firstWhereOrNull(
      (p) => p.id.toString() == patientId.value.toString(),
    );
  }

  String get linkedPatientName {
    final p = linkedPatient;
    if (p != null) return p.fullName;
    if (tache.value?.patient != null) {
      final pt = tache.value!.patient!;
      return '${pt['prenom'] ?? ''} ${pt['nom'] ?? ''}'.trim();
    }
    return 'Aucun patient lié'.tr;
  }
}
