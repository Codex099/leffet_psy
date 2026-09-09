import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_text_styles.dart';

/// Bannière discrète affichée quand les données proviennent du cache persistant
/// (mode hors-ligne ou absence de connexion au démarrage).
///
/// Usage :
/// ```dart
/// Obx(() {
///   if (controller.isOfflineData.value) {
///     return OfflineBanner(savedLabel: controller.offlineSavedLabel.value);
///   }
///   return const SizedBox.shrink();
/// })
/// ```
class OfflineBanner extends StatelessWidget {
  /// Texte décrivant l'âge du cache, ex: "il y a 2h". Peut être null.
  final String? savedLabel;

  const OfflineBanner({super.key, this.savedLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFCC02).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFCC02).withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: Color(0xFFB07A00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              savedLabel != null
                  ? 'Mode hors-ligne · Données sauvegardées $savedLabel'
                  : 'Mode hors-ligne · Dernières données disponibles',
              style: AppTextStyles.iosCaption2.copyWith(
                color: const Color(0xFF7A5500),
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.3, curve: Curves.easeOut);
  }
}

/// Version compacte pour les AppBar ou headers
class OfflineDot extends StatelessWidget {
  const OfflineDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Mode hors-ligne',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFCC02).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFCC02).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFB07A00),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Hors-ligne',
              style: AppTextStyles.iosCaption2.copyWith(
                color: const Color(0xFF7A5500),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
