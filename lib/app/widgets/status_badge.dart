import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Badges de statut colorés réutilisables (actif/inactif, assisté/absent/en attente).
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory StatusBadge.present({String label = 'Assisté'}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.statusPresentBg,
      textColor: AppColors.statusPresent,
    );
  }

  factory StatusBadge.absent({String label = 'Absent'}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.statusAbsentBg,
      textColor: AppColors.statusAbsent,
    );
  }

  factory StatusBadge.pending({String label = 'En attente'}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.statusPendingBg,
      textColor: AppColors.statusPending,
    );
  }

  factory StatusBadge.active({String? label}) {
    return StatusBadge(
      label: label ?? 'Actif'.tr,
      backgroundColor: AppColors.statusActiveBg,
      textColor: AppColors.statusActive,
    );
  }

  factory StatusBadge.inactive({String label = 'Inactif'}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.statusInactiveBg,
      textColor: AppColors.statusInactive,
    );
  }

  factory StatusBadge.custom({
    required String label,
    required Color color,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: color.withValues(alpha: 0.15),
      textColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: textColor),
      ),
    );
  }
}
