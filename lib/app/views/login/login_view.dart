import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('PsyCare', style: AppTextStyles.screenTitle),
                const SizedBox(height: 8),
                Text(
                  'Gestion de clinique de psychologie',
                  style: AppTextStyles.screenSubtitle,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Nom d\'utilisateur',
                        hintText: 'Ex: dr.martin',
                        controller: usernameController,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Mot de passe',
                        hintText: '••••••••',
                        obscureText: true,
                        controller: passwordController,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                      ),
                      const SizedBox(height: 24),
                      Obx(() {
                        if (controller.errorMessage.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              controller.errorMessage.value,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(() => AppButton(
                            label: 'Se connecter',
                            isLoading: controller.isLoading.value,
                            onPressed: () {
                              controller.login(
                                usernameController.text.trim(),
                                passwordController.text.trim(),
                              );
                            },
                          )),
                    ],
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
