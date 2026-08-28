import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Barre de navigation flottante premium iOS 17 — Frosted glass + Sliding pill indicator.
class AppBottomNav extends StatefulWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  static const _tabRoutes = [
    AppRoutes.accueil,
    AppRoutes.patientsListe,
    AppRoutes.agenda,
    AppRoutes.profil,
  ];

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pillController;
  late Animation<double> _pillPosition;
  int _currentIndex = 0;

  static const _items = [
    _NavItem(
      Icons.home_outlined,
      Icons.home_rounded,
      'Accueil',
      AppRoutes.accueil,
    ),
    _NavItem(
      Icons.people_outline_rounded,
      Icons.people_alt_rounded,
      'Patients',
      AppRoutes.patientsListe,
    ),
    _NavItem(
      Icons.calendar_today_outlined,
      Icons.calendar_month_rounded,
      'Agenda',
      AppRoutes.agenda,
    ),
    _NavItem(
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'Profil',
      AppRoutes.profil,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pillPosition =
        Tween<double>(
          begin: _currentIndex.toDouble(),
          end: _currentIndex.toDouble(),
        ).animate(
          CurvedAnimation(parent: _pillController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _pillController.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();

    _pillPosition =
        Tween<double>(
          begin: _pillPosition.value,
          end: index.toDouble(),
        ).animate(
          CurvedAnimation(parent: _pillController, curve: Curves.easeOutCubic),
        );

    _pillController
      ..reset()
      ..forward();

    setState(() => _currentIndex = index);

    final route = _items[index].route;
    Get.offNamedUntil(
      route,
      (r) => !AppBottomNav._tabRoutes.contains(r.settings.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final screenWidth = mediaQuery.size.width;
    final horizontalMargin = screenWidth > 600 ? 48.0 : 20.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalMargin,
          right: horizontalMargin,
          bottom: bottomPadding > 0 ? 16 : 32, // Float significantly higher
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 460,
              minHeight: 66,
              maxHeight: 72,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50), // Perfect pill
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.98),
                        width: 1.5,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = constraints.maxWidth / _items.length;
                        return Stack(
                          children: [
                            // ── Sliding pill indicator ──
                            AnimatedBuilder(
                              animation: _pillPosition,
                              builder: (context, _) {
                                return Positioned(
                                  left: _pillPosition.value * itemWidth + 4,
                                  top: 0,
                                  bottom: 0,
                                  width: itemWidth - 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF064973),
                                          Color(0xFF0A5C8F),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 14,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // ── Nav items ──
                            Row(
                              children: List.generate(_items.length, (index) {
                                final isSelected = index == _currentIndex;
                                final item = _items[index];
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _navigateTo(index),
                                    behavior: HitTestBehavior.opaque,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          child: Icon(
                                            isSelected
                                                ? item.selectedIcon
                                                : item.icon,
                                            key: ValueKey(isSelected),
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.textTertiary,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          style: AppTextStyles.iosCaption2
                                              .copyWith(
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppColors.textTertiary,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                fontSize: 10,
                                              ),
                                          child: Text(item.label),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavItem(this.icon, this.selectedIcon, this.label, this.route);
}
