import 'package:material_ui/material_ui.dart';

import '../models/movie.dart';
import '../models/showtime.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/error_ui.dart';
import '../widgets/ui_kit.dart';

/// Sold-out showtime waitlist with drop alerts and queue automation.
class WaitlistScreen extends StatefulWidget {
  const WaitlistScreen({
    super.key,
    required this.movie,
    required this.showtime,
    this.waitingCount = 48,
    this.position = 4,
  });

  final Movie movie;
  final SelectedShowtime showtime;
  final int waitingCount;
  final int position;

  @override
  State<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen> {
  int _seatCount = 2;
  int _zone = 0;
  bool _autoLock = true;
  bool _audioPush = true;
  bool _smsFallback = true;
  bool _joined = false;

  void _join() {
    if (_joined) return;
    setState(() => _joined = true);
    showCineSnack(
      context,
      'Drop alert armed — you are #${widget.position + 1} in line.',
      icon: Icons.add_alert_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          SubPageHeader(
            title: 'Waitlist & Drop Alert',
            subtitle:
                '${widget.movie.title} • ${widget.showtime.time} • '
                '${widget.showtime.cinema}',
            trailing: StatusPill(
              label: '${widget.waitingCount} Waiting',
              icon: Icons.groups_rounded,
              color: AppColors.tertiary,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const StatusPill(
                      label: 'Showtime 100% Sold Out',
                      icon: Icons.remove_circle_outline_rounded,
                      color: AppColors.error,
                      filled: true,
                    ),
                    const Spacer(),
                    StatusPill(
                      label: '${widget.waitingCount} Waiting',
                      icon: Icons.groups_rounded,
                      color: AppColors.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMovieCard(),
                const SizedBox(height: 12),
                _buildQueueCard(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Number of Seats',
                      style: AppText.headlineSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Adjacent guarantee active',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SegmentedPills(
                  labels: const ['1', '2 Seats', '3', '4'],
                  selectedIndex: _seatCount - 1,
                  onChanged: (index) => setState(() => _seatCount = index + 1),
                  height: 44,
                  fontSize: 12,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Preferred Seating Zone',
                      style: AppText.headlineSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Select match filter',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildZones(),
                const SizedBox(height: 14),
                _buildAutomation(),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: _joined
                      ? 'On the Waitlist • #${widget.position + 1} in Line'
                      : 'Join Waitlist & Set Drop Alert',
                  icon: _joined
                      ? Icons.check_circle_rounded
                      : Icons.add_alert_rounded,
                  onTap: _joined ? null : _join,
                ),
                const SizedBox(height: 8),
                SecondaryButton(
                  label: 'Alternate Showtimes (8:15 PM & 10:30 PM)',
                  icon: Icons.swap_horiz_rounded,
                  onTap: () => showCineSnack(
                    context,
                    'Alternate showtimes can be selected from movie details.',
                    icon: Icons.schedule_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 13,
                      color: AppColors.outline,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Cancel anytime with 1-tap. No charges applied until '
                        'tickets are reserved.',
                        textAlign: TextAlign.center,
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9,
                          height: 1.4,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard() {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  widget.movie.poster,
                  width: 86,
                  height: 118,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 5,
                bottom: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLowest.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.showtime.format,
                    style: AppText.labelCaps.copyWith(
                      fontSize: 6.5,
                      color: AppColors.tertiary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${widget.showtime.cinema} • ${widget.showtime.auditorium}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  widget.movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.headlineSmall.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.showtime.day} • ${widget.showtime.time} '
                  '(Doors 30 min prior)',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 9.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text.rich(
                        const TextSpan(
                          text: '8.4% seats release\n',
                          children: [
                            TextSpan(
                              text: '2–4 hrs before showtime.',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        style: AppText.bodySmall.copyWith(
                          fontSize: 8.5,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard() {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiaryContainer.withValues(alpha: 0.24),
                  border: Border.all(
                    color: AppColors.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.radar_rounded,
                  size: 18,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Queue Odds: High Release',
                      style: AppText.headlineSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Calculated from 14 previous sold-out IMAX drops',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '82%',
                    style: AppText.headlineMedium.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.tertiary,
                    ),
                  ),
                  Text(
                    'SUCCESS RATE',
                    style: AppText.labelCaps.copyWith(
                      fontSize: 6.5,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 5, color: AppColors.surfaceHigh),
                FractionallySizedBox(
                  widthFactor: 0.82,
                  child: Container(
                    height: 5,
                    decoration: const BoxDecoration(
                      gradient: AppColors.cyanGradient,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Position: #${widget.position} in line',
                style: AppText.bodySmall.copyWith(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'Next release est. ~5:15 PM',
                style: AppText.bodySmall.copyWith(
                  fontSize: 9,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.white06),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  size: 17,
                  color: AppColors.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    const TextSpan(
                      text: 'CINEPASS GOLD ACTIVE',
                      children: [
                        TextSpan(
                          text: ' • Priority Jump\n',
                          style: TextStyle(color: AppColors.tertiary),
                        ),
                        TextSpan(
                          text: 'Bumped past 44 standard requests',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    style: AppText.labelCaps.copyWith(
                      fontSize: 7.5,
                      height: 1.6,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZones() {
    return Column(
      children: [
        _ZoneOption(
          icon: Icons.verified_rounded,
          title: 'Prime Center Sweetspot',
          badge: 'Rows D–G',
          subtitle: 'Optimum laser audio focal field',
          selected: _zone == 0,
          onTap: () => setState(() => _zone = 0),
        ),
        const SizedBox(height: 8),
        _ZoneOption(
          icon: Icons.auto_awesome_rounded,
          title: 'Any 2 Together',
          badge: '94% Alert Rate',
          subtitle: 'Fastest path to entering theater',
          selected: _zone == 1,
          onTap: () => setState(() => _zone = 1),
        ),
        const SizedBox(height: 8),
        _ZoneOption(
          icon: Icons.airline_seat_recline_extra_rounded,
          title: 'VIP Premium Recliner Loge',
          subtitle: 'Upper tier wide power-loungers',
          selected: _zone == 2,
          onTap: () => setState(() => _zone = 2),
        ),
      ],
    );
  }

  Widget _buildAutomation() {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FAST-ACTION AUTOMATION',
            style: AppText.labelCaps.copyWith(
              fontSize: 7.5,
              color: AppColors.outline,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 10),
          _AutomationRow(
            icon: Icons.flash_on_rounded,
            title: 'Auto-Lock & Purchase',
            subtitle:
                'Instant auto-hold & charge via Apple Pay if seats unlock. '
                '100% refundable within 15 minutes.',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const StatusPill(
                  label: 'FastPass',
                  color: AppColors.tertiary,
                  fontSize: 6.5,
                ),
                const SizedBox(width: 6),
                Switch(
                  value: _autoLock,
                  onChanged: (value) => setState(() => _autoLock = value),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.white10, height: 16),
          _AutomationRow(
            icon: Icons.notifications_active_outlined,
            title: 'Critical Audio Push',
            subtitle:
                'Overrides device mute switch with a high-priority cinema '
                'chime the millisecond drops occur.',
            trailing: Switch(
              value: _audioPush,
              onChanged: (value) => setState(() => _audioPush = value),
            ),
          ),
          const Divider(color: AppColors.white10, height: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _smsFallback = !_smsFallback),
            child: Row(
              children: [
                Icon(
                  _smsFallback
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 17,
                  color: _smsFallback ? AppColors.tertiary : AppColors.outline,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text.rich(
                    const TextSpan(
                      text: 'Send SMS fallback ping to ',
                      children: [
                        TextSpan(
                          text: '(415) •••-4821',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    style: AppText.bodySmall.copyWith(
                      fontSize: 9.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneOption extends StatelessWidget {
  const _ZoneOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer.withValues(alpha: 0.12)
              : AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primaryContainer.withValues(alpha: 0.4)
                : AppColors.white06,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryContainer.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: AppText.labelCaps.copyWith(
                              fontSize: 6.5,
                              color: AppColors.tertiary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySmall.copyWith(
                      fontSize: 8.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: selected ? AppColors.tertiary : AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _AutomationRow extends StatelessWidget {
  const _AutomationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
          ),
          child: Icon(icon, size: 17, color: AppColors.tertiary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppText.bodySmall.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppText.bodySmall.copyWith(
                  fontSize: 8.5,
                  height: 1.4,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    );
  }
}
