import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Composant réutilisable pour afficher les états de chargement, d'erreur et vide.
/// Conforme au design system iOS moderne avec nettoyage automatique des messages d'erreur.
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
    if (raw == null || raw.isEmpty) {
      return 'Impossible de charger les données pour le moment.';
    }
    if (raw.contains('connection timeout') ||
        raw.contains('receive timeout') ||
        raw.contains('Délai d\'attente')) {
      return 'Le délai d\'attente vers le serveur a expiré. Veuillez vérifier votre connexion internet ou réattaquer la synchronisation.';
    }
    if (raw.contains('connection error') ||
        raw.contains('Impossible de se connecter') ||
        raw.contains('SocketException')) {
      return 'Impossible de joindre le serveur clinique. Vérifiez votre accès réseau.';
    }
    if (raw.contains('403') || raw.contains('Accès refusé')) {
      return 'Accès restreint : vous ne disposez pas des droits suffisants pour consulter cette section.';
    }
    if (raw.contains('404') || raw.contains('introuvable')) {
      return 'Les informations demandées n\'ont pas été trouvées.';
    }

    final clean = raw
        .replaceAll(RegExp(r'^DioException\s*\[.*?\]:\s*'), '')
        .replaceAll(RegExp(r'^Exception:\s*'), '')
        .replaceAll(RegExp(r'Error:\s*.*$'), '')
        .trim();

    return clean.isNotEmpty ? clean : 'Une anomalie réseau est survenue.';
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
                strokeWidth: 2.8,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: AppTextStyles.iosSubhead.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    final isError = type == StatePlaceholderType.error;
    final iconColor = isError ? AppColors.logoCoral : AppColors.secondary;
    final iconBgColor = isError
        ? AppColors.logoCoralLight
        : AppColors.secondaryLight.withValues(alpha: 0.4);
    final iconData = isError ? Icons.wifi_off_rounded : Icons.inbox_rounded;
    final displayMessage = isError ? sanitizeErrorMessage(message) : message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isError
                  ? AppColors.logoCoral.withValues(alpha: 0.2)
                  : AppColors.border,
              width: 1,
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 28,
                ),
              ),
              if (title != null) ...[
                const SizedBox(height: 16),
                Text(
                  title!,
                  style: AppTextStyles.iosHeadline.copyWith(
                    color: isError ? AppColors.textPrimary : AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (displayMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  displayMessage,
                  style: AppTextStyles.iosSubhead.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: Icon(
                    isError ? Icons.refresh_rounded : Icons.add_rounded,
                    size: 18,
                  ),
                  label: Text(actionLabel!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(160, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 0,
                  ),
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
