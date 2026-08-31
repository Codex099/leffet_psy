import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../controllers/profil_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_button.dart';
import '../../widgets/clinical_decorations.dart';
import '../../widgets/ios_card.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/state_placeholder.dart';
import '../../widgets/creative_app_bar.dart';

class ProfilView extends GetView<ProfilController> {
 const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      appBar: CreativeAppBar(
        title: 'Mon Profil'.tr,
        subtitle: 'Compte & Paramètres'.tr,
        showBackButton: false,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: Obx(() {
        if (controller.status.value == 'loading') {
         return const SafeArea(
            child: StatePlaceholder(type: StatePlaceholderType.loading),
          );
        }
        if (controller.status.value == 'error') {
         return SafeArea(
            child: StatePlaceholder.error(
              message: controller.errorMessage.value,
              onAction: () => controller.loadProfile(),
            ),
          );
        }

        final user = controller.currentUser.value;
        final isAdmin = user?.role == 'admin';

       return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Profile Centered Card Header ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 0.8),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      // Centered avatar with custom border/glow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            width: 6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: PatientAvatar(
                          initials: user?.initials ?? 'U',
                         radius: 46,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User name
                      Text(
                        user?.fullName ?? 'Utilisateur',
                       style: AppTextStyles.iosTitle2.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      // Username
                      Text(
                        '@${user?.username ?? "user"}',
                       style: AppTextStyles.iosSubhead.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          user?.roleLabel ?? 'Employé'.tr,
                         style: AppTextStyles.iosCaption1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Edit Profile Button
                      OutlinedButton.icon(
                        onPressed: () => _showEditProfileSheet(context, user),
                        icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
                        label: Text(
                          'Modifier mes informations'.tr,
                         style: AppTextStyles.iosCaption1.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Section: Coordonnées ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildSectionHeader('Coordonnées & Compte'.tr),
           ),
            SliverToBoxAdapter(
              child: IosCard(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  IosCardTile(
                    leading: _tintedIconCircle(
                      Icons.phone_outlined,
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.1),
                    ),
                    title: 'Téléphone'.tr,
                   subtitle: user?.telephone != null && user!.telephone!.isNotEmpty
                        ? user.telephone!
                        : 'Non renseigné'.tr,
                 ),
                  IosCardTile(
                    leading: _tintedIconCircle(
                      Icons.badge_outlined,
                      AppColors.secondary,
                      AppColors.secondary.withValues(alpha: 0.1),
                    ),
                    title: 'Identifiant système'.tr,
                   subtitle: '${user?.id ?? "—"}',
                 ),
                  IosCardTile(
                    leading: _tintedIconCircle(
                      Icons.security_rounded,
                      const Color(0xFF2E7D6B),
                      const Color(0xFFE3F4F0),
                    ),
                    title: 'Niveau d\'accès'.tr,
                   subtitle: user?.roleLabel ?? 'Standard'.tr,
                 ),
                ],
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),
            ),

            // ─── Section: Gestion Clinique (Grid) ────────────────────────────
            SliverToBoxAdapter(
              child: _buildSectionHeader('Gestion Clinique'.tr),
           ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
                delegate: SliverChildListDelegate([
                  _buildClinicalGridItem(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                    title: 'Séances Individuelles'.tr,
                   subtitle: 'Consultations & créneaux'.tr,
                   onTap: () => Get.toNamed(AppRoutes.seancesIndividuelles),
                  ),
                  _buildClinicalGridItem(
                    icon: Icons.groups_outlined,
                    iconColor: AppColors.accentCoral,
                    iconBgColor: AppColors.accentCoral.withValues(alpha: 0.1),
                    title: 'Groupes Thérapeutiques'.tr,
                   subtitle: 'Séances collectives'.tr,
                   onTap: () => Get.toNamed(AppRoutes.groupesListe),
                  ),
                  _buildClinicalGridItem(
                    icon: Icons.family_restroom_outlined,
                    iconColor: AppColors.secondary,
                    iconBgColor: AppColors.secondary.withValues(alpha: 0.1),
                    title: 'Parents & Tuteurs'.tr,
                   subtitle: 'Annuaire familial'.tr,
                   onTap: () => Get.toNamed(AppRoutes.parentsListe),
                  ),
                  _buildClinicalGridItem(
                    icon: Icons.task_alt_outlined,
                    iconColor: const Color(0xFFB8860B),
                    iconBgColor: const Color(0xFFFFF8E1),
                    title: 'Tâches & Actions'.tr,
                   subtitle: 'Gestion des todo-lists'.tr,
                   onTap: () => Get.toNamed(AppRoutes.taches),
                  ),
                  _buildClinicalGridItem(
                    icon: Icons.calendar_month_outlined,
                    iconColor: const Color(0xFF2E7D6B),
                    iconBgColor: const Color(0xFFE3F4F0),
                    title: 'Calendrier'.tr,
                   subtitle: 'Événements & Réunions'.tr,
                   onTap: () => Get.toNamed(AppRoutes.calendrier),
                  ),
                  if (isAdmin)
                    _buildClinicalGridItem(
                      icon: Icons.badge_rounded,
                      iconColor: AppColors.accentDeep,
                      iconBgColor: AppColors.accentDeep.withValues(alpha: 0.1),
                      title: 'Gestion de l\'Équipe'.tr,
                     subtitle: 'Comptes & droits'.tr,
                     onTap: () => Get.toNamed(AppRoutes.employesListe),
                    ),
                ]),
              ),
            ),

            // ─── Section: Préférences ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildSectionHeader('Préférences'.tr),
           ),
            SliverToBoxAdapter(
              child: IosCard(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  IosCardTile(
                    leading: _tintedIconCircle(
                      Icons.notifications_none_rounded,
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.1),
                    ),
                    title: 'Notifications push'.tr,
                   trailing: Switch.adaptive(
                      value: true,
                      activeTrackColor: AppColors.iosGreen,
                      onChanged: (_) {},
                    ),
                  ),
                  IosCardTile(
                    leading: _tintedIconCircle(
                      Icons.language_rounded,
                      AppColors.secondary,
                      AppColors.secondary.withValues(alpha: 0.1),
                    ),
                    title: 'Langue de l\'application'.tr,
                   trailing: Text(
                      Get.locale?.languageCode == 'ar' ? 'العربية' : 'Français',
                     style: AppTextStyles.iosSubhead,
                    ),
                    showChevron: true,
                    onTap: () async {
                      const storage = FlutterSecureStorage();
                      if (Get.locale?.languageCode == 'ar') {
                       await storage.write(key: 'app_language', value: 'fr');
                       Get.updateLocale(const Locale('fr', 'FR'));
                     } else {
                        await storage.write(key: 'app_language', value: 'ar');
                       Get.updateLocale(const Locale('ar', 'DZ'));
                     }
                    },
                  ),
                  IosCardTile(
                    leading: _tintedIconCircle(
                      Icons.info_outline_rounded,
                      const Color(0xFF2E7D6B),
                      const Color(0xFFE3F4F0),
                    ),
                    title: 'Version de l\'application'.tr,
                   trailing: Text(
                      '1.0.0 (Build 2026)',
                     style: AppTextStyles.iosFootnote,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.05),
            ),

            // ─── Section: Déconnexion ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 120),
                child: AppButton(
                  label: 'Se déconnecter'.tr,
                 icon: Icons.logout_rounded,
                  isDestructive: true,
                  isGradient: false,
                  onPressed: () => _confirmLogout(context),
                ),
              ).animate().fadeIn(duration: 500.ms),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: AppTextStyles.iosCaption1.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _tintedIconCircle(IconData icon, Color iconColor, Color bgColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }

  Widget _buildClinicalGridItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 0.8),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _tintedIconCircle(icon, iconColor, iconBgColor),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.iosHeadline.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.iosCaption2.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  void _showEditProfileSheet(BuildContext context, user) {
    final nomCtrl = TextEditingController(text: user.nom);
    final prenomCtrl = TextEditingController(text: user.prenom);
    final telCtrl = TextEditingController(text: user.telephone ?? '');
   final isSaving = false.obs;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: AppColors.softShadow,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Poignée
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Modifier mes informations'.tr,
               style: AppTextStyles.iosTitle3.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              // Champ Prénom
              _editField(
                controller: prenomCtrl,
                label: 'Prénom'.tr,
               icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              // Champ Nom
              _editField(
                controller: nomCtrl,
                label: 'Nom'.tr,
               icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              // Champ Téléphone
              _editField(
                controller: telCtrl,
                label: 'Téléphone'.tr,
               icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              // Bouton Enregistrer
              Obx(() => ElevatedButton(
                onPressed: isSaving.value
                    ? null
                    : () async {
                        isSaving.value = true;
                        final ok = await controller.updateProfile(
                          nom: nomCtrl.text.trim(),
                          prenom: prenomCtrl.text.trim(),
                          telephone: telCtrl.text.trim(),
                        );
                        isSaving.value = false;
                        if (ok) {
                          Get.back();
                          Get.snackbar(
                            'Succès'.tr,
                           'Profil mis à jour'.tr,
                           snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.iosGreen,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(12),
                            borderRadius: 14,
                          );
                        } else {
                          Get.snackbar(
                            'Erreur'.tr,
                           'Impossible de mettre à jour le profil.'.tr,
                           snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.error,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 3),
                            margin: const EdgeInsets.all(12),
                            borderRadius: 14,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: isSaving.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Enregistrer'.tr, style: AppTextStyles.iosBody.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
             )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.iosBody,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.iosCaption1.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, size: 20, color: AppColors.secondary),
        filled: true,
        fillColor: AppColors.fieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    HapticFeedback.lightImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fermer'.tr,
     barrierColor: Colors.black.withValues(alpha: 0.54),
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
              ],
              border: Border.all(color: AppColors.borderLight, width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône illustrée rouge avec aura douce
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentCoral.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Titre
                  Text(
                    'Se déconnecter ?'.tr,
                   textAlign: TextAlign.center,
                    style: AppTextStyles.iosTitle2.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  Text(
                    'Êtes-vous certain de vouloir fermer votre session clinique ? Vous devrez vous ré-authentifier pour accéder aux dossiers.'.tr,
                   textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 26),

                  // Boutons d'action
                  Row(
                    children: [
                      // Bouton Annuler
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.fieldBackground,
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Annuler'.tr,
                           style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Bouton Déconnexion
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(ctx);
                            controller.logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: AppColors.error.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Déconnexion'.tr,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
