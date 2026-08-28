import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../services/auth_service.dart';
import '../services/cache_manager.dart';
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

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}