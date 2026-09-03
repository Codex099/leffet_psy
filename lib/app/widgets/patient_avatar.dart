import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Avatar patient/employé réutilisable (initiales gradient, photo réseau ou fichier local).
class PatientAvatar extends StatelessWidget {
  final String initials;
  final String? photoUrl;
  final double radius;
  final Color? backgroundColor;
  final Color textColor;

  const PatientAvatar({
    super.key,
    required this.initials,
    this.photoUrl,
    this.radius = 24,
    this.backgroundColor,
    this.textColor = Colors.white,
  });

  bool _isLocalFile(String path) {
    final clean = path.trim();
    if (clean.startsWith('file://')) return true;
    if (RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(clean)) return true;
    if (clean.startsWith('/data/') ||
        clean.startsWith('/storage/') ||
        clean.startsWith('/private/')) {
      return true;
    }
    try {
      if (File(clean).existsSync()) return true;
    } catch (_) {}
    return false;
  }

  // Choisit un gradient basé sur les initiales (déterministe, pour cohérence)
  Gradient _getGradient() {
    final gradients = [
      AppColors.oceanGradient,
      const LinearGradient(
        colors: [Color(0xFF0A5C8F), Color(0xFF75AABF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      AppColors.groupHeaderGradient,
      const LinearGradient(
        colors: [Color(0xFF064973), Color(0xFF1A7CB0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF075F8C), Color(0xFFADCCD9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    final index = initials.isNotEmpty
        ? (initials.codeUnitAt(0) % gradients.length)
        : 0;
    return gradients[index];
  }

  Widget _buildFallback() {
    if (backgroundColor != null) {
      // Mode couleur unie (rétrocompatibilité)
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Text(
          initials.length > 2 ? initials.substring(0, 2) : initials,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: radius * 0.65,
          ),
        ),
      );
    }

    // Mode gradient premium
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getGradient(),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials.length > 2 ? initials.substring(0, 2) : initials,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: radius * 0.65,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.trim().isEmpty) {
      return _buildFallback();
    }

    final raw = photoUrl!.trim();

    // 1. Cas fichier local sur le périphérique (ex: photo tout juste prise/choisie)
    if (_isLocalFile(raw)) {
      final localPath = raw.startsWith('file://')
          ? (Uri.tryParse(raw)?.toFilePath() ?? raw.replaceFirst('file://', ''))
          : raw;
      final file = File(localPath);
      return ClipOval(
        child: Image.file(
          file,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('PatientAvatar: local file load failed ($localPath): $error');
            return _buildFallback();
          },
        ),
      );
    }

    // 2. Cas URL réseau ou relative résolue
    final resolved = ApiConfig.resolveMediaUrl(raw);
    if (resolved.isNotEmpty &&
        (resolved.startsWith('http://') || resolved.startsWith('https://'))) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: resolved,
          httpHeaders: const {
            'ngrok-skip-browser-warning': 'true',
            'Accept': 'image/*,*/*',
          },
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildFallback(),
          errorWidget: (context, url, error) {
            debugPrint('PatientAvatar: network image load failed ($url): $error');
            return _buildFallback();
          },
        ),
      );
    }

    return _buildFallback();
  }
}
