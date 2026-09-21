import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/error_translator.dart';
import 'app_animations.dart';

/// Composant réutilisable pour les états de chargement, d'erreur et vide.
/// Design premium iOS avec shimmer loading et illustrations animées.
class StatePlaceholder extends StatelessWidget {
 final StatePlaceholderType type;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StatePlaceholder({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  factory StatePlaceholder.loading({String? message}) {
    return StatePlaceholder(
      type: StatePlaceholderType.loading,
      message: message ?? 'Chargement en cours...',
   );
  }

  factory StatePlaceholder.empty({
    String? title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return StatePlaceholder(
      type: StatePlaceholderType.empty,
      title: title ?? 'Aucune donnée disponible',
     message: message ?? 'Il n\'y a aucun élément à afficher pour le moment.',
     actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory StatePlaceholder.error({
    String? title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return StatePlaceholder(
      type: StatePlaceholderType.error,
      title: title ?? 'Erreur de connexion',
     message: message ?? 'Impossible de charger les données pour le moment.',
     actionLabel: actionLabel ?? 'Réessayer',
     onAction: onAction,
    );
  }

  static String sanitizeErrorMessage(String? raw) {
    return ErrorTranslator.translate(raw);
  }

  @override
  Widget build(BuildContext context) {
    // ── Loading: Shimmer skeleton ────────────────────────────────────────────
    if (type == StatePlaceholderType.loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: ShimmerListLoader(count: 3, scrollable: true),
      );
    }

    // ── Error / Empty ────────────────────────────────────────────────────────
    final isError = type == StatePlaceholderType.error;
    final iconColor = isError ? AppColors.logoCoral : AppColors.secondary;
    final iconBgColor = isError
        ? AppColors.logoCoralLight
        : AppColors.secondaryLight.withValues(alpha: 0.35);
    final iconData = isError
        ? Icons.cloud_off_rounded
        : Icons.folder_open_rounded;
    final displayMessage = isError ? sanitizeErrorMessage(message) : message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: FadeSlideIn(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isError
                    ? AppColors.logoCoral.withValues(alpha: 0.18)
                    : AppColors.borderLight,
                width: 0.8,
              ),
              boxShadow: AppColors.cardShadow,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon circle
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(iconData, color: iconColor, size: 32),
                  ),
                  if (title != null) ...[
                    const SizedBox(height: 18),
                    Text(
                      title!.tr,
                      style: AppTextStyles.iosTitle3.copyWith(
                        color: isError
                            ? AppColors.textPrimary
                            : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (displayMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      displayMessage.tr,
                      style: AppTextStyles.iosSubhead.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (onAction != null && actionLabel != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: isError
                            ? AppColors.accentGradient
                            : AppColors.oceanGradient,
                        borderRadius: BorderRadius.circular(23),
                        boxShadow: isError
                            ? AppColors.accentShadow
                            : AppColors.softShadow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onAction,
                          borderRadius: BorderRadius.circular(23),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isError
                                    ? Icons.refresh_rounded
                                    : Icons.add_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                actionLabel!.tr,
                                style: AppTextStyles.iosHeadline.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum StatePlaceholderType { loading, empty, error }
