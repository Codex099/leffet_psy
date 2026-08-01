import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;
  final bool isSecondary;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.primary;
    Color fg = AppColors.textOnPrimary;

    if (isDestructive) {
      bg = AppColors.error;
      fg = AppColors.textOnPrimary;
    } else if (isSecondary) {
      bg = AppColors.secondaryLight;
      fg = AppColors.primary;
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: fg,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: fg),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: isSecondary
                      ? AppTextStyles.buttonSecondary
                      : AppTextStyles.buttonPrimary,
                ),
              ],
            ),
    );
  }
}
