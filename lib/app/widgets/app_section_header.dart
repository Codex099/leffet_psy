import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Composant d en-tete de section unifie — Design Premium iOS PsyCare.
///
/// Remplace tous les strings ALL_CAPS eparpilles dans les vues par un
/// composant coherent : icone coloree + titre labelOverline + action trailing.
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBg;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;
  final bool showAccentLine;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.iconBg,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 16, 8),
    this.showAccentLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveIconBg = iconBg ?? AppColors.primaryUltraLight;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: effectiveIconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: effectiveIconColor),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTextStyles.labelOverline.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 1.4,
                  ),
                ),
                if (showAccentLine) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: AppColors.oceanGradient,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.iosCaption1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
