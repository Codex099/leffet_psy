import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'clinical_decorations.dart';

/// Bouton d'action principal premium iOS — Gradient, loading animé, spring physics.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;
  final bool isSecondary;
  final bool isGradient;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.isSecondary = false,
    this.isGradient = true,
    this.icon,
    this.width,
    this.height = 52,
    this.padding,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn, reverseCurve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Gradient? get _gradient {
    if (widget.isSecondary) return null;
    if (widget.isDestructive) return AppColors.accentGradient;
    if (widget.isGradient) return AppColors.oceanGradient;
    return null;
  }

  Color get _solidColor {
    if (widget.isDestructive) return AppColors.error;
    if (widget.isSecondary) return AppColors.fieldBackground;
    return AppColors.primary;
  }

  Color get _fgColor {
    if (widget.isSecondary) return AppColors.primary;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isLoading || widget.onPressed == null;

    return GestureDetector(
      onTapDown: (_) { if (!isDisabled) _ctrl.forward(); },
      onTapUp: (_) {
        if (!isDisabled) {
          _ctrl.reverse();
          HapticFeedback.lightImpact();
          widget.onPressed!();
        }
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: isDisabled ? null : _gradient,
            color: isDisabled
                ? AppColors.iosSystemGray5
                : (_gradient == null ? _solidColor : null),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDisabled
                ? null
                : (widget.isDestructive
                    ? AppColors.accentShadow
                    : (widget.isSecondary ? null : AppColors.softShadow)),
            border: widget.isSecondary
                ? Border.all(color: AppColors.border, width: 0.8)
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isSecondary ? AppColors.primary : Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 20,
                          color: isDisabled ? AppColors.textTertiary : _fgColor,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: AppTextStyles.buttonPrimary.copyWith(
                          color: isDisabled ? AppColors.textTertiary : _fgColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Bouton texte léger iOS.
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isDestructive;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = isDestructive ? AppColors.error : (color ?? AppColors.primary);
    return BouncyTap(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: c),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.iosHeadline.copyWith(
                color: c,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
