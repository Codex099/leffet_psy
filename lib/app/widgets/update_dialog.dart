import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/update_controller.dart';
import '../models/app_release_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UpdateDialog extends StatelessWidget {
  final AppReleaseModel release;

  const UpdateDialog({super.key, required this.release});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UpdateController>();

    final zipAsset = release.zipAsset;
    final bestAsset = release.bestAsset;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.softShadow,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icone d'en-tete animee
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.oceanGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1200.ms),
              ),
              const SizedBox(height: 16),

              // Titre
              Text(
                'Nouvelle version disponible !'.tr,
                style: AppTextStyles.iosTitle2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Badges de versions (Actuelle -> Nouvelle)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryUltraLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Text(
                        'v${controller.currentVersion.value}',
                        style: AppTextStyles.iosFootnote.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'v${release.cleanVersion}',
                        style: AppTextStyles.iosFootnote.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notes de version (Changelog)
              if (release.body.trim().isNotEmpty) ...[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'Notes de version :'.tr,
                    style: AppTextStyles.iosCaption1.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 140),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.scaffold,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      release.body.trim(),
                      style: AppTextStyles.iosBody.copyWith(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Barre de progression (si téléchargement en cours)
              Obx(() {
                if (!controller.isDownloading.value) return const SizedBox.shrink();

                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: controller.downloadProgress.value > 0
                            ? controller.downloadProgress.value
                            : null,
                        minHeight: 10,
                        backgroundColor: AppColors.borderLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Téléchargement en cours...'.tr,
                          style: AppTextStyles.iosCaption2.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          controller.progressText.value,
                          style: AppTextStyles.iosCaption2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                );
              }),

              // Boutons d'actions
              Obx(() {
                final isDownloading = controller.isDownloading.value;

                if (isDownloading) {
                  return OutlinedButton.icon(
                    onPressed: () => controller.cancelDownload(),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: Text('Annuler'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bouton Principal : Télécharger & Installer (APK ou Best Asset)
                    if (bestAsset != null) ...[
                      ElevatedButton.icon(
                        onPressed: () => controller.downloadAndInstall(bestAsset),
                        icon: const Icon(Icons.cloud_download_rounded, size: 20),
                        label: Text(
                          bestAsset.isApk
                              ? '${'Télécharger & Installer'.tr} (${bestAsset.formattedSize})'
                              : '${'Télécharger la mise à jour'.tr} (${bestAsset.formattedSize})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Bouton ZIP alternatif si disponible
                    if (zipAsset != null && zipAsset != bestAsset) ...[
                      OutlinedButton.icon(
                        onPressed: () => controller.downloadAndInstall(zipAsset),
                        icon: const Icon(Icons.folder_zip_rounded, size: 18),
                        label: Text(
                          '${'Télécharger le fichier ZIP'.tr} (${zipAsset.formattedSize})',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          side: const BorderSide(color: AppColors.secondary),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Liens secondaires : Voir sur GitHub / Fermer
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => controller.openReleaseInBrowser(release.htmlUrl),
                            icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                            label: Text('Voir sur GitHub'.tr),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'Plus tard'.tr,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
