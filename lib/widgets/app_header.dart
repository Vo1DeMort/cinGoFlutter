import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'cinego_logo.dart';
import 'ui_kit.dart';

/// Shared top bar for the four root tabs, matching the CineGo discovery shell.
class RootHeader extends StatelessWidget {
  const RootHeader({
    super.key,
    this.onLocationTap,
    this.onNotificationTap,
    this.onAvatarTap,
    this.showLogo = true,
  });

  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withOpacity(0.86),
        border: const Border(
          bottom: BorderSide(color: AppColors.white06, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              if (showLogo)
                const CineGoWordmark(fontSize: 18)
              else
                const SizedBox(width: 4),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onLocationTap,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 17,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 116),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'AMC Metreon',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 15,
                                color: AppColors.outline,
                              ),
                            ],
                          ),
                          Text(
                            'SAN FRANCISCO, CA',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.labelCaps.copyWith(
                              color: AppColors.outline,
                              fontSize: 8.5,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _HeaderIcon(
                icon: Icons.notifications_none_rounded,
                showDot: true,
                onTap: onNotificationTap,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.tertiary, width: 1.5),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/avatar.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sub-page header with a back affordance, title and optional trailing widgets.
class SubPageHeader extends StatelessWidget {
  const SubPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.titleSize = 16,
    this.showBack = true,
    this.backIcon = Icons.arrow_back_rounded,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double titleSize;
  final bool showBack;
  final IconData backIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withOpacity(0.92),
        border: const Border(
          bottom: BorderSide(color: AppColors.white06, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                if (showBack) ...[
                  RoundIconButton(
                    icon: backIcon,
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          letterSpacing: -0.3,
                          height: 1.15,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant.withOpacity(0.85),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, this.onTap, this.showDot = false});

  final IconData icon;
  final VoidCallback? onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLow,
              ),
              child: Icon(icon, size: 19, color: AppColors.onSurface),
            ),
            if (showDot)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small glowing countdown chip used in the booking flow headers.
class TimerChip extends StatelessWidget {
  const TimerChip({super.key, required this.label, this.icon = Icons.timer_outlined});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiary.withOpacity(0.22),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.tertiary),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppText.labelFormat.copyWith(
              color: AppColors.tertiary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
