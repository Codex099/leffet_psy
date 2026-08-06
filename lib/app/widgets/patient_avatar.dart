import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

import '../config/api_config.dart';

/// Avatar patient/employé réutilisable (initiales ou photo)
class PatientAvatar extends StatelessWidget {
  final String initials;
  final String? photoUrl;
  final double radius;
  final Color backgroundColor;
  final Color textColor;

  const PatientAvatar({
    super.key,
    required this.initials,
    this.photoUrl,
    this.radius = 24,
    this.backgroundColor = AppColors.secondaryLight,
    this.textColor = AppColors.primary,
  });

  String? get _resolvedUrl {
    if (photoUrl == null || photoUrl!.trim().isEmpty) return null;
    final url = photoUrl!.trim();

    // Si c'est déjà une URL complète
    if (url.startsWith('http://') || url.startsWith('https://')) {
      // Remplacer localhost / 127.0.0.1 par l'URL Cloudflare du backend
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

    // URL relative → préfixer avec la base
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$base$path';
  }

  Widget _buildFallback() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: AppTextStyles.bodyMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolvedUrl;
    if (resolved != null) {
      return CachedNetworkImage(
        imageUrl: resolved,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => _buildFallback(),
        errorWidget: (context, url, error) => _buildFallback(),
      );
    }

    return _buildFallback();
  }
}

