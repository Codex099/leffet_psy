import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Carte Inset Grouped iOS premium avec variantes hero et glass.
class IosCard extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final String? subtitle;
  final String? footer;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Widget? headerTrailing;

  const IosCard({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.footer,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.headerTrailing,
  });

  /// Variante Hero avec en-tête dégradé.
  const factory IosCard.hero({
    Key? key,
    required List<Widget> children,
    required String title,
    String? subtitle,
    Gradient? gradient,
    Widget? icon,
    EdgeInsetsGeometry? margin,
  }) = _IosCardHero;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!.toUpperCase(),
                          style: AppTextStyles.iosCaption2.copyWith(
                            color: AppColors.textTertiary,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!, style: AppTextStyles.iosFootnote),
                        ],
                      ],
                    ),
                  ),
                  ?headerTrailing,
                ],
              ),
            ),
          ],
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    if (i > 0)
                      Container(
                        height: 0.6,
                        margin: const EdgeInsets.only(left: 16),
                        color: AppColors.separator.withValues(alpha: 0.7),
                      ),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
          if (footer != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: Text(
                footer!,
                style: AppTextStyles.iosFootnote.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Variante Hero ────────────────────────────────────────────────────────────
class _IosCardHero extends IosCard {
  final Gradient? gradient;
  final Widget? icon;

  const _IosCardHero({
    super.key,
    required super.children,
    required String title,
    super.subtitle,
    this.gradient,
    this.icon,
    super.margin,
  }) : super(title: title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  // Hero header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: gradient ?? AppColors.oceanGradient,
                    ),
                    child: Row(
                      children: [
                        if (icon != null) ...[icon!, const SizedBox(width: 12)],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title!,
                                style: AppTextStyles.iosHeadline.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  style: AppTextStyles.iosFootnote.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Children body
                  Container(
                    color: AppColors.surface,
                    child: Column(
                      children: [
                        for (int i = 0; i < children.length; i++) ...[
                          if (i > 0)
                            Container(
                              height: 0.6,
                              margin: const EdgeInsets.only(left: 16),
                              color: AppColors.separator.withValues(alpha: 0.7),
                            ),
                          children[i],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── IosCardTile Premium ─────────────────────────────────────────────────────
/// Ligne interactive standard enrichie.
class IosCardTile extends StatefulWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool showChevron;
  final EdgeInsetsGeometry padding;
  final Color? tileColor;

  const IosCardTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.showChevron = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    this.tileColor,
  });

  @override
  State<IosCardTile> createState() => _IosCardTileState();
}

class _IosCardTileState extends State<IosCardTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = false);
          HapticFeedback.selectionClick();
          widget.onTap!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _isPressed
            ? AppColors.primary.withValues(alpha: 0.04)
            : (widget.tileColor ?? Colors.transparent),
        padding: widget.padding,
        child: Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: AppTextStyles.iosHeadline.copyWith(
                      color: widget.titleColor ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.subtitle != null &&
                      widget.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle!,
                      style: AppTextStyles.iosFootnote.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
            if (widget.showChevron) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.iosSystemGray3,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
