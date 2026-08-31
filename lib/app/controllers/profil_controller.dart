import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../services/auth_service.dart';
import '../services/cache_manager.dart';
import '../services/employee_service.dart';
import '../routes/app_routes.dart';

class ProfilController extends GetxController {
 final AuthService _authService = AuthService();

  final Rx<EmployeeModel?> currentUser = Rx<EmployeeModel?>(null);
  final RxString status = 'loading'.obs;
 final RxString errorMessage = ''.obs;

 static const _cacheDuration = Duration(minutes: 10);

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadProfile();
  }

  @override
  void onReady() {
    super.onReady();
    if (!AppCacheManager.isFresh(CacheKeys.currentUser)) {
      loadProfile();
    }
  }

  void _loadFromCache() async {
    final cached = AppCacheManager.get<EmployeeModel>(CacheKeys.currentUser);
    if (cached != null) {
      currentUser.value = cached;
      status.value = 'success';
     return;
    }
    // Fallback to local storage cached user
    final storedUser = await _authService.getCachedUser();
    if (storedUser != null) {
      currentUser.value = storedUser;
      status.value = 'success';
   }
  }

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (AppCacheManager.isFresh(CacheKeys.currentUser) && !forceRefresh && currentUser.value != null) {
      return;
    }

    if (currentUser.value == null) {
      status.value = 'loading';
   }

    try {
      final user = await _authService.getMe();
      currentUser.value = user;
      AppCacheManager.set<EmployeeModel>(
        CacheKeys.currentUser,
        user,
        ttl: _cacheDuration,
        tags: {CacheTags.auth},
      );
      status.value = 'success';
   } catch (e) {
      if (currentUser.value == null) {
        errorMessage.value = e.toString();
        status.value = 'error';
     }
    }
  }

  Future<void> refreshData() => loadProfile(forceRefresh: true);

  Future<bool> updateProfile({required String nom, required String prenom, String? telephone}) async {
    final user = currentUser.value;
    if (user == null) return false;
    try {
      final updated = await EmployeeService().updateEmployee(user.id, {
        'nom': nom,
       'prenom': prenom,
       if (telephone != null && telephone.isNotEmpty) 'telephone': telephone,
      });
      currentUser.value = updated;
      AppCacheManager.invalidate(CacheKeys.currentUser);
      AppCacheManager.set<EmployeeModel>(
        CacheKeys.currentUser,
        updated,
        ttl: const Duration(minutes: 10),
        tags: {CacheTags.auth},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}