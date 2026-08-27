import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Avatar patient/employé réutilisable (initiales gradient ou photo réseau).
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

  String? get _resolvedUrl {
    if (photoUrl == null || photoUrl!.trim().isEmpty) return null;
    final url = photoUrl!.trim();

    if (url.startsWith('http://') || url.startsWith('https://')) {
      final uri = Uri.tryParse(url);
      if (uri != null &&
          (uri.host == 'localhost' ||
              uri.host == '127.0.0.1' ||
              uri.host == '0.0.0.0')) {
        final base = ApiConfig.baseUrl;
        final baseUri = Uri.tryParse(base);
        if (baseUri != null) {
          final fixed = uri.replace(
            scheme: baseUri.scheme,
            host: baseUri.host,
            port: baseUri.hasPort ? baseUri.port : null,
          );
          return fixed.toString();
        }
      }
      return url;
    }

    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$base$path';
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
    final resolved = _resolvedUrl;
    if (resolved != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: resolved,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildFallback(),
          errorWidget: (context, url, error) => _buildFallback(),
        ),
      );
    }
    return _buildFallback();
  }
}
