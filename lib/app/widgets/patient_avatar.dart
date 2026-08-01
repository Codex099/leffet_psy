import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: CachedNetworkImageProvider(photoUrl!),
      );
    }

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
}
