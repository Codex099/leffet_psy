import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Composant réutilisable unique pour afficher les états de chargement, d'erreur et vide.
/// Conforme à la section 7.9 du PRD et observable dans les maquettes (ex: agenda.png, taches.png).
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
      title: title ?? 'Erreur réseau',
      message: message ?? 'Impossible de charger les données pour le moment.',
      actionLabel: actionLabel ?? 'Réessayer',
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (type == StatePlaceholderType.loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    final isError = type == StatePlaceholderType.error;
    final iconColor = isError ? AppColors.error : AppColors.secondary;
    final iconBgColor = isError ? AppColors.errorLight : AppColors.secondaryLight.withValues(alpha: 0.4);
    final iconData = isError ? Icons.wifi_off_rounded : Icons.inbox_rounded;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 32,
                ),
              ),
              if (title != null) ...[
                const SizedBox(height: 16),
                Text(
                  title!,
                  style: AppTextStyles.emptyStateTitle,
                  textAlign: TextAlign.center,
                ),
              ],
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  style: AppTextStyles.emptyStateBody,
                  textAlign: TextAlign.center,
                ),
              ],
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isError ? AppColors.primary : AppColors.primary,
                    minimumSize: const Size(160, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum StatePlaceholderType { loading, empty, error }
