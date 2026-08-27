import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Widget interactif avec animation de rebond élastique + retour haptique.
class BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final BorderRadius? borderRadius;

  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
    this.borderRadius,
  });

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (widget.onTap != null) _controller.forward(); },
      onTapUp: (_) { if (widget.onTap != null) _controller.reverse(); },
      onTapCancel: () { if (widget.onTap != null) _controller.reverse(); },
      onTap: () {
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ─── PulseDot ─────────────────────────────────────────────────────────────────
/// Indicateur de statut avec pulsation lumineuse animée.
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulseDot({
    super.key,
    this.color = AppColors.primary,
    this.size = 8,
  });

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.7).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.size * _pulseAnimation.value,
            height: widget.size * _pulseAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.28 / _pulseAnimation.value),
            ),
          ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.55),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ZenWavePainter ───────────────────────────────────────────────────────────
/// Peintre de vagues organiques apaisantes.
class ZenWavePainter extends CustomPainter {
  final Color waveColor;
  final Color accentColor;

  ZenWavePainter({required this.waveColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;
    final path1 = Path()
      ..moveTo(0, size.height * 0.68)
      ..cubicTo(size.width * 0.22, size.height * 0.52, size.width * 0.62,
          size.height * 0.84, size.width, size.height * 0.62)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    final path2 = Path()
      ..moveTo(0, size.height * 0.82)
      ..cubicTo(size.width * 0.32, size.height * 0.70, size.width * 0.72,
          size.height * 0.94, size.width, size.height * 0.76)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── GlassCard ────────────────────────────────────────────────────────────────
/// Carte glassmorphism avec backdrop blur premium.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double blur;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.blur = 28,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.glassWhite,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(color: AppColors.glassBorder, width: 1.2),
            boxShadow: boxShadow ?? AppColors.glassShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── CircularMetricIndicator ─────────────────────────────────────────────────
/// Arc métrique circulaire pour la progression.
class CircularMetricIndicator extends StatelessWidget {
  final double percentage;
  final double size;
  final double strokeWidth;
  final Color activeColor;
  final Color backgroundColor;
  final Widget? child;

  const CircularMetricIndicator({
    super.key,
    required this.percentage,
    this.size = 54,
    this.strokeWidth = 5.0,
    this.activeColor = AppColors.primary,
    this.backgroundColor = AppColors.secondaryLight,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(
              percentage: percentage,
              strokeWidth: strokeWidth,
              activeColor: activeColor,
              backgroundColor: backgroundColor,
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color activeColor;
  final Color backgroundColor;

  _ArcPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.activeColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweepAngle = 2 * math.pi * percentage.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.percentage != percentage || oldDelegate.activeColor != activeColor;
}
