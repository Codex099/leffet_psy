import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Page de connexion épurée, moderne et en français.
/// Inspirée fidèlement de la maquette avec en-tête en vague océanique et badge logo circulaire.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final controller = Get.find<AuthController>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _obscurePassword = true.obs;
  final _rememberMe = true.obs;

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final RxBool _isUsernameFocused = false.obs;
  final RxBool _isPasswordFocused = false.obs;

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(() {
      _isUsernameFocused.value = _usernameFocus.hasFocus;
    });
    _passwordFocus.addListener(() {
      _isPasswordFocused.value = _passwordFocus.hasFocus;
    });
  }

  @override
  void dispose() {
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
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
    final headerHeight = size.height * 0.38;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // ── 1. En-Tête Bleu avec Courbe & Vague Asymétrique ─────────────
              ClipPath(
                clipper: _WaveHeaderClipper(),
                child: Container(
                  height: headerHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF032B45),
                        Color(0xFF064973),
                        Color(0xFF0A5C8F),
                      ],
                    ),
                  ),
                  child: CustomPaint(
                    size: Size(size.width, headerHeight),
                    painter: _TopographyPainter(),
                  ),
                ),
              ),

              // ── 2. Badge Logo Circulaire en Chevauchement ──────────────────
              Positioned(
                top: headerHeight * 0.62,
                right: 28,
                child: Container(
                  width: 114,
                  height: 114,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF064973).withValues(alpha: 0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFE8F2F8),
                      width: 3.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (ctx, e, st) => const Icon(
                          Icons.psychology_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),
              ),

              // ── 3. Contenu & Formulaire de Connexion ───────────────────────
              Positioned.fill(
                top: headerHeight * 0.88,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre « Connexion » avec barre de soulignement
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connexion',
                            style: AppTextStyles.iosLargeTitleHero.copyWith(
                              color: const Color(0xFF062338),
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF064973),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideX(begin: -0.1, curve: Curves.easeOut),

                      const SizedBox(height: 28),

                      // ── Champ 1 : Identifiant / Email ─────────────────────
                      Text(
                        'Email / Nom d\'utilisateur',
                        style: AppTextStyles.iosCaption1.copyWith(
                          color: const Color(0xFF4A6B7F),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Obx(() => _buildCleanInputField(
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            isFocused: _isUsernameFocused.value,
                            hint: 'demo@email.com ou admin',
                            icon: Icons.mail_outline_rounded,
                            textInputAction: TextInputAction.next,
                          )),

                      const SizedBox(height: 22),

                      // ── Champ 2 : Mot de passe ────────────────────────────
                      Text(
                        'Mot de passe',
                        style: AppTextStyles.iosCaption1.copyWith(
                          color: const Color(0xFF4A6B7F),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Obx(() => _buildCleanInputField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            isFocused: _isPasswordFocused.value,
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword.value,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleSubmit(),
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: const Color(0xFF9EBDCE),
                              ),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                _obscurePassword.toggle();
                              },
                            ),
                          )),

                      const SizedBox(height: 14),

                      // ── Options : Se souvenir & Mot de passe oublié ────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Se souvenir de moi
                          InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _rememberMe.toggle();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Obx(() => Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: _rememberMe.value
                                              ? const Color(0xFF064973)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                            color: _rememberMe.value
                                                ? const Color(0xFF064973)
                                                : const Color(0xFFBED5E1),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: _rememberMe.value
                                            ? const Icon(
                                                Icons.check_rounded,
                                                size: 13,
                                                color: Colors.white,
                                              )
                                            : null,
                                      )),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Se souvenir de moi',
                                    style: AppTextStyles.iosFootnote.copyWith(
                                      color: const Color(0xFF4A6B7F),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Mot de passe oublié
                          GestureDetector(
                            onTap: () {
                              Get.snackbar(
                                'Assistance',
                                'Veuillez contacter l\'administrateur pour réinitialiser votre mot de passe.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF064973),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 14,
                              );
                            },
                            child: Text(
                              'Mot de passe oublié ?',
                              style: AppTextStyles.iosFootnote.copyWith(
                                color: const Color(0xFF064973),
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Message d'erreur éventuel ─────────────────────────
                      Obx(() {
                        if (controller.errorMessage.isNotEmpty) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 14),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.30),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage.value,
                                    style: AppTextStyles.iosFootnote.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms).shakeX();
                        }
                        return const SizedBox.shrink();
                      }),

                      const SizedBox(height: 32),

                      // ── Bouton Principal « Se connecter » ──────────────────
                      Obx(() {
                        final isLoading = controller.isLoading.value;
                        return Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF064973),
                                Color(0xFF0A5C8F),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF064973).withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isLoading ? null : _handleSubmit,
                              borderRadius: BorderRadius.circular(16),
                              splashColor: Colors.white.withValues(alpha: 0.15),
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Se connecter',
                                        style: AppTextStyles.iosHeadline.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 24),

                      // ── Pied de page ──────────────────────────────────────
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'Vous n\'avez pas de compte ? ',
                            style: AppTextStyles.iosFootnote.copyWith(
                              color: const Color(0xFF7B98A9),
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: 'Accès Praticien',
                                style: AppTextStyles.iosFootnote.copyWith(
                                  color: const Color(0xFF064973),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Champ de Saisie avec Ligne de Soulignement Épurée ─────────────────────
  Widget _buildCleanInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isFocused
                  ? const Color(0xFF064973)
                  : const Color(0xFF9EBDCE),
            ),
            const SizedBox(width: 10),
            Container(
              width: 1.2,
              height: 18,
              color: const Color(0xFFD3E4EC),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                obscureText: obscureText,
                textInputAction: textInputAction,
                onSubmitted: onSubmitted,
                style: AppTextStyles.iosBody.copyWith(
                  color: const Color(0xFF062338),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                cursorColor: const Color(0xFF064973),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.iosSubhead.copyWith(
                    color: const Color(0xFFBED5E1),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            ?suffix,
          ],
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isFocused ? 2.0 : 1.2,
          color: isFocused ? const Color(0xFF064973) : const Color(0xFFD3E4EC),
        ),
      ],
    );
  }
}

// ─── Découpe de Vague Asymétrique en Haut de Page ──────────────────────────────
class _WaveHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.68);

    // Vague fluide descendant vers la droite sous le logo
    path.cubicTo(
      size.width * 0.30,
      size.height * 0.64,
      size.width * 0.58,
      size.height * 0.98,
      size.width,
      size.height * 0.86,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ─── Lignes Topographiques Décoratives en Arrière-Plan ─────────────────────────
class _TopographyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF75AABF).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 1; i <= 6; i++) {
      final p = Path();
      final yOffset = size.height * (0.13 * i);
      p.moveTo(0, yOffset);
      p.cubicTo(
        size.width * 0.25,
        yOffset - 22,
        size.width * 0.55,
        yOffset + 30,
        size.width,
        yOffset - 12,
      );
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
