import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class NavDestination {
  const NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const cineGoDestinations = <NavDestination>[
  NavDestination(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'HOME',
  ),
  NavDestination(
    icon: Icons.local_movies_outlined,
    activeIcon: Icons.local_movies_rounded,
    label: 'MOVIES',
  ),
  NavDestination(
    icon: Icons.location_city_outlined,
    activeIcon: Icons.location_city_rounded,
    label: 'CINEMAS',
  ),
  NavDestination(
    icon: Icons.confirmation_number_outlined,
    activeIcon: Icons.confirmation_number_rounded,
    label: 'BOOKINGS',
  ),
  NavDestination(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'PROFILE',
  ),
];

class CineGoBottomNav extends StatelessWidget {
  const CineGoBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withOpacity(0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.white10),
        boxShadow: const [
          BoxShadow(
            color: Color(0xB3000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: List.generate(cineGoDestinations.length, (index) {
          final destination = cineGoDestinations[index];
          final selected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 38,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: selected ? AppColors.cyanGradient : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryContainer
                                    .withOpacity(0.45),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      selected ? destination.activeIcon : destination.icon,
                      size: 19,
                      color: selected ? Colors.white : AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    destination.label,
                    style: AppText.labelCaps.copyWith(
                      fontSize: 7.8,
                      letterSpacing: 0.8,
                      color: selected ? AppColors.tertiary : AppColors.outline,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
