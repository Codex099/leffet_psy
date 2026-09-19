import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utilitaire de dialogues de confirmation et d'alerte pour toute l'application.
class AppDialogs {
  AppDialogs._();

  static const Color _danger = Color(0xFFE53935);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _success = Color(0xFF10B981);
  static const Color _primary = Color(0xFF3B82F6);

  // ─────────────────────────────────────────────────────────────────────────
  // Dialog de confirmation générique
  // ─────────────────────────────────────────────────────────────────────────

  /// Affiche un dialog de confirmation. Retourne `true` si confirmé.
  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
    Color confirmColor = _primary,
    IconData? icon,
    Color iconColor = _primary,
  }) async {
    final result = await Get.dialog<bool>(
      _ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        icon: icon,
        iconColor: iconColor,
      ),
      barrierDismissible: true,
    );
    return result ?? false;
  }

  /// Confirmation de suppression (rouge).
  static Future<bool> confirmDelete({
    String title = 'Supprimer',
    String message = 'Cette action est irréversible. Voulez-vous continuer ?',
    String confirmLabel = 'Supprimer',
    String cancelLabel = 'Annuler',
  }) {
    return confirm(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      confirmColor: _danger,
      icon: Icons.delete_outline_rounded,
      iconColor: _danger,
    );
  }

  /// Confirmation de modification (bleu).
  static Future<bool> confirmModify({
    String title = 'Modifier',
    String message = 'Voulez-vous enregistrer ces modifications ?',
    String confirmLabel = 'Enregistrer',
    String cancelLabel = 'Annuler',
  }) {
    return confirm(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      confirmColor: _primary,
      icon: Icons.edit_rounded,
      iconColor: _primary,
    );
  }

  /// Confirmation d'annulation de séance (orange).
  static Future<bool> confirmCancel({
    String title = 'Annuler la séance',
    String message = 'Voulez-vous vraiment annuler cette séance ?',
    String confirmLabel = 'Oui, annuler',
    String cancelLabel = 'Retour',
  }) {
    return confirm(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      confirmColor: _warning,
      icon: Icons.event_busy_rounded,
      iconColor: _warning,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Snackbars de résultat
  // ─────────────────────────────────────────────────────────────────────────

  static void showSuccess(String message, {String title = 'Succès'}) {
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _success.withValues(alpha: 0.92),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String message, {String title = 'Erreur'}) {
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _danger.withValues(alpha: 0.92),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 22),
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: const Duration(seconds: 4),
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _primary.withValues(alpha: 0.92),
      colorText: Colors.white,
      icon: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 22),
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget interne du dialog
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.confirmColor,
    this.icon,
    this.iconColor = Colors.blue,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;
  final IconData? icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: Icon(icon, color: iconColor, size: 26),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.07)),

            // Boutons
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: cancelLabel,
                      textColor: const Color(0xFF9CA3AF),
                      onTap: () => Get.back(result: false),
                    ),
                  ),
                  Container(width: 1, color: Colors.white.withValues(alpha: 0.07)),
                  Expanded(
                    child: _DialogButton(
                      label: confirmLabel,
                      textColor: confirmColor,
                      onTap: () => Get.back(result: true),
                      isBold: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  const _DialogButton({
    required this.label,
    required this.textColor,
    required this.onTap,
    this.isBold = false,
  });

  final String label;
  final Color textColor;
  final VoidCallback onTap;
  final bool isBold;

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 15,
                fontWeight: widget.isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
