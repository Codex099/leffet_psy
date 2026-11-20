import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/app_release_model.dart';
import '../services/app_update_service.dart';
import '../theme/app_colors.dart';
import '../widgets/update_dialog.dart';

class UpdateController extends GetxController {
  final AppUpdateService _updateService = AppUpdateService();

  final RxBool isChecking = false.obs;
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxString progressText = ''.obs;
  final RxBool updateAvailable = false.obs;
  final Rxn<AppReleaseModel> latestRelease = Rxn<AppReleaseModel>();
  final Rxn<File> downloadedFile = Rxn<File>();

  final RxString currentVersion = AppUpdateService.currentAppVersion.obs;
  final RxString currentBuildNumber = AppUpdateService.currentBuildNumber.obs;

  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    _loadPackageInfoAndCheck();
  }

  Future<void> _loadPackageInfoAndCheck() async {
    try {
      final info = await PackageInfo.fromPlatform();
      currentVersion.value = info.version;
      currentBuildNumber.value = info.buildNumber;
      AppUpdateService.currentAppVersion = info.version;
      AppUpdateService.currentBuildNumber = info.buildNumber;
    } catch (_) {}

    // Vérification silencieuse différée de 3 secondes pour ne pas ralentir le démarrage
    Future.delayed(const Duration(seconds: 3), () {
      checkForUpdate(silent: true);
    });
  }

  /// Vérifie la présence d'une mise à jour
  Future<void> checkForUpdate({bool silent = false}) async {
    if (isChecking.value) return;
    isChecking.value = true;

    if (!silent) {
      Get.snackbar(
        'Mises à jour'.tr,
        'Vérification en cours...'.tr,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    try {
      final release = await _updateService.checkLatestRelease();
      isChecking.value = false;

      if (release != null) {
        latestRelease.value = release;
        final isNewer = release.isNewerThan(currentVersion.value);
        updateAvailable.value = isNewer;

        if (isNewer) {
          showUpdateDialog(release);
        } else if (!silent) {
          Get.snackbar(
            'Application à jour'.tr,
            '${'Vous utilisez déjà la version la plus récente.'.tr} (v${currentVersion.value})',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white.withValues(alpha: 0.95),
            colorText: AppColors.textPrimary,
            icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
            duration: const Duration(seconds: 3),
          );
        }
      } else if (!silent) {
        Get.snackbar(
          'Mises à jour'.tr,
          'Impossible de vérifier la mise à jour'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          colorText: AppColors.error,
          icon: const Icon(Icons.error_outline_rounded, color: AppColors.error),
        );
      }
    } catch (e) {
      isChecking.value = false;
      if (!silent) {
        Get.snackbar(
          'Erreur'.tr,
          '${"Impossible de vérifier la mise à jour".tr} : $e',
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  /// Affiche la boîte de dialogue de mise à jour
  void showUpdateDialog(AppReleaseModel release) {
    if (Get.isDialogOpen == true) return;
    Get.dialog(
      UpdateDialog(release: release),
      barrierDismissible: !isDownloading.value,
    );
  }

  /// Télécharge et lance l'installation d'un asset spécifique (APK ou ZIP)
  Future<void> downloadAndInstall(ReleaseAssetModel asset) async {
    if (isDownloading.value) return;

    isDownloading.value = true;
    downloadProgress.value = 0.0;
    progressText.value = '0%';
    _cancelToken = CancelToken();

    try {
      final file = await _updateService.downloadAsset(
        asset,
        cancelToken: _cancelToken,
        onProgress: (progress, received, total) {
          downloadProgress.value = progress;
          if (total > 0) {
            final recMo = (received / (1024 * 1024)).toStringAsFixed(1);
            final totMo = (total / (1024 * 1024)).toStringAsFixed(1);
            progressText.value = '$recMo Mo / $totMo Mo (${(progress * 100).toInt()}%)';
          } else {
            final recMo = (received / (1024 * 1024)).toStringAsFixed(1);
            progressText.value = '$recMo Mo';
          }
        },
      );

      isDownloading.value = false;

      if (file != null && await file.exists()) {
        downloadedFile.value = file;
        progressText.value = 'Téléchargement terminé'.tr;

        // Tenter d'ouvrir l'installateur
        final opened = await _updateService.installUpdate(file);
        if (!opened) {
          // Si l'ouverture directe échoue, informer l'utilisateur
          Get.snackbar(
            'Mise à jour prête à installer'.tr,
            '${'Fichier téléchargé :'.tr} ${file.path}',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
            mainButton: TextButton(
              onPressed: () => _updateService.installUpdate(file),
              child: Text('Installer maintenant'.tr),
            ),
          );
        }
      }
    } catch (e) {
      isDownloading.value = false;
      if (e is DioException && CancelToken.isCancel(e)) {
        progressText.value = '';
        return;
      }
      Get.snackbar(
        'Erreur'.tr,
        '${"Échec du téléchargement".tr} : $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: AppColors.error,
      );
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel('Annulé par l\'utilisateur');
    isDownloading.value = false;
    downloadProgress.value = 0.0;
    progressText.value = '';
  }

  void openReleaseInBrowser(String url) {
    _updateService.openReleaseInBrowser(url);
  }
}

