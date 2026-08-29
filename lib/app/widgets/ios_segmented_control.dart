import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Contrôle segmenté animé style Apple HIG (Cupertino Sliding Segmented Control).
class IosSegmentedControl<T> extends StatelessWidget {
  final Map<T, String> segments;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final EdgeInsetsGeometry margin;

  const IosSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onValueChanged,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.iosSystemGray5,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: segments.entries.map((entry) {
          final isSelected = entry.key == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.selectionClick();
                  onValueChanged(entry.key);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    entry.value.tr,
                    style: isSelected
                        ? AppTextStyles.iosCallout.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          )
                        : AppTextStyles.iosFootnote.copyWith(
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
