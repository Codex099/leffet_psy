import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Page de connexion épurée, moderne et en français.
/// Inspirée fidèlement de la maquette avec le logo centré et un style "pill".
class LoginView extends StatefulWidget {
 const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final controller = Get.find<AuthController>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  final _obscurePassword = true.obs;
  final _rememberMe = false.obs;

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
    _loadSavedUsername();
  }

  Future<void> _loadSavedUsername() async {
    final savedUsername = await _storage.read(key: 'saved_username');
   if (savedUsername != null && savedUsername.isNotEmpty) {
      _usernameController.text = savedUsername;
      _rememberMe.value = true;
    }
  }

  @override
  void dispose() {
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
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

    if (_rememberMe.value) {
      await _storage.write(key: 'saved_username', value: username);
   } else {
      await _storage.delete(key: 'saved_username');
   }

    controller.login(username, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Obx(
                            () => InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                LanguageService.toggleLanguage();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.language_rounded, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      LanguageService.isArabic ? 'العربية' : 'Français',
                                      style: AppTextStyles.iosCaption1.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // ── 1. Logo dans un cercle ─────────────────────────────
                        Center(
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  blurRadius: 32,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                 width: 160,
                                  height: 160,
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, e, st) => const Icon(
                                    Icons.psychology_rounded,
                                    size: 100,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                        ),

                        const SizedBox(height: 24),

                        // ── 2. Titles ───────────────────────────────────────────────────
                        Text(
                          'Connexion'.tr,
                         style: AppTextStyles.iosLargeTitleHero.copyWith(
                            color: const Color(0xFF1E293B),
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Veuillez vous connecter pour continuer.'.tr,
                         style: AppTextStyles.iosSubhead.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.1),

                        const SizedBox(height: 36),

                        // ── 3. Username Field ───────────────────────────────────────────
                        Obx(
                          () => _buildMockupInputField(
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            isFocused: _isUsernameFocused.value,
                            hint: 'Email ou nom d\'utilisateur',
                           icon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: -0.1),

                        const SizedBox(height: 16),

                        // ── 4. Password Field ───────────────────────────────────────────
                        Obx(
                          () => _buildMockupInputField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            isFocused: _isPasswordFocused.value,
                            hint: 'Mot de passe',
                           icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword.value,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleSubmit(),
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 22,
                                color: const Color(0xFF64748B),
                              ),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                _obscurePassword.toggle();
                              },
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideX(begin: -0.1),

                        const SizedBox(height: 20),

                        // ── 5. Remember Me Switch ───────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Se souvenir de moi'.tr,
                             style: AppTextStyles.iosFootnote.copyWith(
                                color: const Color(0xFF1E293B),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Obx(
                              () => Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: _rememberMe.value,
                                  onChanged: (val) {
                                    HapticFeedback.selectionClick();
                                    _rememberMe.value = val;
                                  },
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: AppColors.primary,
                                  inactiveTrackColor: const Color(0xFFE2E8F0),
                                  inactiveThumbColor: Colors.white,
                                  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                        // Error Message
                        Obx(() {
                          if (controller.errorMessage.isNotEmpty) {
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
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

                        const Spacer(), // Pousse le bouton vers le bas
                        const SizedBox(height: 32),

                        // ── 6. Sign In Button ───────────────────────────────────────────
                        Obx(() {
                          final isLoading = controller.isLoading.value;
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28), // Pill shape
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Se connecter'.tr,
                                     style: AppTextStyles.iosHeadline.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          );
                        }).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.1),

                        const SizedBox(height: 32),

                        // ── 7. Sign Up Link ─────────────────────────────────────────────
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Get.snackbar(
                                'Information',
                               'Veuillez contacter l\'administrateur pour créer un compte.',
                               snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.primary,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 14,
                              );
                            },
                            child: Text.rich(
                              TextSpan(
                                text: 'Vous n\'avez pas de compte ? ',
                               style: AppTextStyles.iosFootnote.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'S\'inscrire',
                                    style: AppTextStyles.iosFootnote.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                        
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Input Field Widget (Mockup Style) ───────────────────────────────────
  Widget _buildMockupInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
    Widget? suffix,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Light grey background
        borderRadius: BorderRadius.circular(28), // Pill shape
        border: Border.all(
          color: isFocused ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isFocused ? AppColors.primary : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              style: AppTextStyles.iosBody.copyWith(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hint,
                hintStyle: AppTextStyles.iosBody.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }
}

