import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Floating AppBar conforming to Floating UI design principles:
/// Detached floating capsule, multi-layer soft diffuse shadow, frosted glass & gradients.
class CreativeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool isGradient;
  final Color? backgroundColor;

  const CreativeAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.isGradient = false,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 70.0 : 60.0);

  @override
  Widget build(BuildContext context) {
    if (isGradient) {
      return _GradientAppBar(
        title: title,
        subtitle: subtitle,
        leading: leading,
        actions: actions,
        showBackButton: showBackButton,
        preferredSize: preferredSize,
      );
    }
    return _FrostedAppBar(
      title: title,
      subtitle: subtitle,
      leading: leading,
      actions: actions,
      showBackButton: showBackButton,
      backgroundColor: backgroundColor,
      preferredSize: preferredSize,
    );
  }
}

// ─── Gradient Floating AppBar ────────────────────────────────────────────────
class _GradientAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final Size preferredSize;

  const _GradientAppBar({
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    required this.showBackButton,
    required this.preferredSize,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                if (showBackButton) _BackButton(isOnDark: true) else ?leading,
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle != null)
                        Text(
                          subtitle!.toUpperCase(),
                          style: AppTextStyles.iosCaption2.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 0.9,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        title,
                        style: AppTextStyles.iosTitle3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ...?actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Frosted Glass Floating AppBar ───────────────────────────────────────────
class _FrostedAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final Size preferredSize;

  const _FrostedAppBar({
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    required this.showBackButton,
    this.backgroundColor,
    required this.preferredSize,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.95),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      if (showBackButton)
                        _BackButton(isOnDark: false)
                      else
                        ?leading,
                      const SizedBox(width: 8),
                      Expanded(
                        child: subtitle != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subtitle!.toUpperCase(),
                                    style: AppTextStyles.iosCaption2.copyWith(
                                      color: AppColors.secondary,
                                      letterSpacing: 0.9,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    title,
                                    style: AppTextStyles.iosTitle3.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              )
                            : Text(
                                title,
                                style: AppTextStyles.iosTitle3.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      ...?actions,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Back Button ──────────────────────────────────────────────────────────────
class _BackButton extends StatefulWidget {
  final bool isOnDark;
  const _BackButton({required this.isOnDark});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        Get.back();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.isOnDark
              ? Colors.white.withValues(alpha: _pressed ? 0.3 : 0.18)
              : AppColors.fieldBackground.withValues(
                  alpha: _pressed ? 0.7 : 1.0,
                ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: widget.isOnDark ? Colors.white : AppColors.primary,
          size: 16,
        ),
      ),
    );
  }
}
