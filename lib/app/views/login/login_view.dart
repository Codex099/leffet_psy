import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final controller = Get.find<AuthController>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = true.obs;

  // Aurora animation
  late final AnimationController _auroraController;
  late final Animation<double> _auroraAnim;

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (!Get.testMode) {
      _auroraController.repeat(reverse: true);
    }
    _auroraAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _auroraController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _auroraController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    HapticFeedback.mediumImpact();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Champs requis',
        'Veuillez renseigner votre identifiant et mot de passe.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.92),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        icon: const Icon(Icons.warning_rounded, color: Colors.white),
      );
      return;
    }
    controller.login(username, password);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // ── Aurora Background Animé ──────────────────────────────────────
          AnimatedBuilder(
            animation: _auroraAnim,
            builder: (context, _) {
              return Stack(
                children: [
                  // Base gradient fond profond
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF021A2D),
                          Color(0xFF032B45),
                          Color(0xFF064973),
                        ],
                      ),
                    ),
                  ),
                  // Orbe 1 "” Bleu primaire
                  Positioned(
                    top: size.height * (-0.1 + _auroraAnim.value * 0.08),
                    left: size.width * (-0.2 + _auroraAnim.value * 0.05),
                    child: Container(
                      width: size.width * 0.85,
                      height: size.width * 0.85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryLight.withValues(alpha: 0.45),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Orbe 2 "” Secondaire ciel
                  Positioned(
                    top: size.height * (0.35 + _auroraAnim.value * 0.06),
                    right: size.width * (-0.3 + _auroraAnim.value * 0.04),
                    child: Container(
                      width: size.width * 0.75,
                      height: size.width * 0.75,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.secondary.withValues(alpha: 0.30),
                            AppColors.secondary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Orbe 3 "” Givré bas
                  Positioned(
                    bottom: size.height * (-0.05 - _auroraAnim.value * 0.03),
                    left: size.width * 0.1,
                    child: Container(
                      width: size.width * 0.70,
                      height: size.width * 0.70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.secondaryLight.withValues(alpha: 0.18),
                            AppColors.secondaryLight.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Voile de bruit subtil (patterns)
                  CustomPaint(
                    size: size,
                    painter: _AuroraNoisePainter(
                      progress: _auroraAnim.value,
                      color: AppColors.secondary.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Contenu Principal ────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo Hero ──────────────────────────────────────────
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 40,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, e, st) => const Icon(
                                Icons.psychology_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                        .scale(begin: const Offset(0.6, 0.6), curve: Curves.easeOutBack),

                    const SizedBox(height: 20),

                    // ── Titre ──────────────────────────────────────────────
                    Text(
                      'PsyCare',
                      style: AppTextStyles.iosLargeTitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 34,
                        letterSpacing: -0.8,
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 700.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOut),

                    const SizedBox(height: 6),

                    Text(
                      'Plateforme Clinique & Suivi Thérapeutique',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.iosSubhead.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14,
                      ),
                    )
                        .animate(delay: 350.ms)
                        .fadeIn(duration: 600.ms),

                    const SizedBox(height: 12),

                    // ── Badge Espace Sécurisé ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Espace Professionnel Sécurisé',
                            style: AppTextStyles.iosCaption1.copyWith(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate(delay: 450.ms)
                        .fadeIn(duration: 500.ms),

                    const SizedBox(height: 32),

                    // ── Formulaire Glass ──────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.11),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connexion Praticien',
                                style: AppTextStyles.iosTitle3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Saisissez vos identifiants pour accéder aux dossiers.',
                                style: AppTextStyles.iosFootnote.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Champ Identifiant
                              _buildDarkField(
                                controller: _usernameController,
                                label: 'Identifiant',
                                hint: 'Dr. Martin ou admin',
                                icon: Icons.badge_outlined,
                              ),
                              const SizedBox(height: 14),

                              // Champ Mot de passe
                              Obx(() => _buildDarkField(
                                    controller: _passwordController,
                                    label: 'Mot de passe',
                                    hint: '"¢"¢"¢"¢"¢"¢"¢"¢',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword.value,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscurePassword.value
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: Colors.white.withValues(alpha: 0.65),
                                      ),
                                      onPressed: () {
                                        HapticFeedback.selectionClick();
                                        _obscurePassword.toggle();
                                      },
                                    ),
                                  )),

                              const SizedBox(height: 14),

                              // Erreur auth
                              Obx(() {
                                if (controller.errorMessage.isNotEmpty) {
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 14),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.error.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          size: 17,
                                          color: Color(0xFFFF8080),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            controller.errorMessage.value,
                                            style: AppTextStyles.iosFootnote.copyWith(
                                              color: const Color(0xFFFF9999),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animate().fadeIn(duration: 300.ms).shakeX();
                                }
                                return const SizedBox.shrink();
                              }),

                              // Bouton Connexion
                              Obx(() {
                                final isLoading = controller.isLoading.value;
                                return Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0A5C8F),
                                        Color(0xFF75AABF),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.5),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: isLoading ? null : _handleSubmit,
                                      borderRadius: BorderRadius.circular(26),
                                      splashColor: Colors.white.withValues(alpha: 0.15),
                                      child: Center(
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(
                                                          Colors.white),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.login_rounded,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Accéder à  l\'espace',
                                                    style: AppTextStyles.iosHeadline.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate(delay: 550.ms)
                        .fadeIn(duration: 700.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                    const SizedBox(height: 28),

                    // ── Footer Sécurité ────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Données cliniques protégées & chiffrées de bout en bout',
                            style: AppTextStyles.iosCaption2.copyWith(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                        .animate(delay: 900.ms)
                        .fadeIn(duration: 600.ms),

                    const SizedBox(height: 6),

                    Text(
                      'PsyCare v1.0 "¢ Accès réservé au personnel autorisé',
                      style: AppTextStyles.iosCaption2.copyWith(
                        color: Colors.white.withValues(alpha: 0.28),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ).animate(delay: 1000.ms).fadeIn(duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.iosCaption1.copyWith(
            color: Colors.white.withValues(alpha: 0.80),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: AppTextStyles.iosBody.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: AppColors.secondary,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.iosSubhead.copyWith(
                color: Colors.white.withValues(alpha: 0.40),
              ),
              prefixIcon: Icon(icon, size: 20,
                  color: Colors.white.withValues(alpha: 0.65)),
              suffixIcon: suffix,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Aurora Noise Painter ─────────────────────────────────────────────────────
class _AuroraNoisePainter extends CustomPainter {
  final double progress;
  final Color color;

  _AuroraNoisePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * (0.55 + math.sin(progress * math.pi) * 0.06))
      ..cubicTo(
        size.width * 0.25,
        size.height * (0.45 + math.cos(progress * math.pi) * 0.05),
        size.width * 0.65,
        size.height * (0.68 + math.sin(progress * math.pi * 1.3) * 0.06),
        size.width,
        size.height * (0.52 + math.cos(progress * math.pi * 0.8) * 0.04),
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_AuroraNoisePainter old) => old.progress != progress;
}
