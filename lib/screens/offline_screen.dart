import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/booking.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/error_ui.dart';
import '../widgets/ui_kit.dart';

/// Full-screen offline state with cached pass, diagnostics and venue guidance.
class OfflineScreen extends ConsumerStatefulWidget {
  const OfflineScreen({super.key});

  @override
  ConsumerState<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends ConsumerState<OfflineScreen> {
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    setState(() => _retrying = false);
    showCineSnack(
      context,
      'Connection restored — offline cache synced.',
      icon: Icons.wifi_rounded,
    );
    Navigator.of(context).maybePop();
  }

  void _browseCached() {
    ref.read(appStateProvider).selectTab(1);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final booking = state.upcomingBookings.isNotEmpty
        ? state.upcomingBookings.first
        : null;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const SubPageHeader(
            title: 'Connection Lost',
            subtitle: 'Offline cache is active on this device',
            trailing: TimerChip(label: 'OFFLINE', icon: Icons.wifi_off_rounded),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [
                const Row(
                  children: [
                    StatusPill(
                      label: 'Status: Disconnected',
                      icon: Icons.cloud_off_rounded,
                      color: AppColors.outline,
                    ),
                    Spacer(),
                    StatusPill(
                      label: 'Offline Cache',
                      icon: Icons.offline_bolt_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Center(
                  child: GlowIconOrb(
                    icon: Icons.wifi_off_rounded,
                    color: AppColors.tertiary,
                    badgeIcon: Icons.priority_high_rounded,
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: StatusPill(
                    label: 'No Internet Connection • Cache Active',
                    icon: Icons.bolt_rounded,
                    color: AppColors.tertiary,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "You're Currently Offline",
                  textAlign: TextAlign.center,
                  style: AppText.displayHeroMobile.copyWith(fontSize: 27),
                ),
                const SizedBox(height: 8),
                Text(
                  "We can't connect to CineGo servers right now, but your "
                  'tickets, QR boarding passes, and cinema directions remain '
                  'safely preserved on this device.',
                  textAlign: TextAlign.center,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 11,
                    height: 1.55,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                _buildSavedPass(booking),
                const SizedBox(height: 20),
                const SectionHeader(
                  title: 'Connection Diagnostics',
                  trailingLabel: '3 Channels',
                ),
                const SizedBox(height: 8),
                _buildDiagnostics(),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Troubleshooting Tips'),
                const SizedBox(height: 8),
                _buildTips(),
                const SizedBox(height: 20),
                const SectionHeader(
                  title: 'Cached Venue Navigation',
                  trailingLabel: 'GPS Offline',
                ),
                const SizedBox(height: 8),
                _buildVenueMap(booking),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: _retrying ? 'Checking Signal…' : 'Retry Connection',
                  icon: Icons.sync_rounded,
                  onTap: _retrying ? null : _retry,
                ),
                const SizedBox(height: 8),
                SecondaryButton(
                  label: 'Browse Cached Movies & Theaters',
                  icon: Icons.cloud_upload_outlined,
                  onTap: _browseCached,
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    text:
                        'Need urgent entry at the turnstile? Present your '
                        'Booking Order ',
                    children: [
                      TextSpan(
                        text: booking?.code ?? '#CG-98421',
                        style: const TextStyle(color: AppColors.tertiary),
                      ),
                      const TextSpan(
                        text: ' or show your ID to the theater desk manager.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 9.5,
                    height: 1.5,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPass(Booking? booking) {
    final movie = booking?.movie ?? MockData.dune;
    final poster = booking?.poster ?? movie.poster;
    final cinema = booking?.cinema ?? 'AMC Metreon 16 & IMAX';
    final seats = booking?.seats.join(', ') ?? 'E5, E6';
    final when = booking?.dateLabel ?? 'Today • 4:45 PM';
    final format = booking?.format ?? 'IMAX 70MM';

    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 16,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Offline Cinema Pass Ready',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const StatusPill(
                label: 'Saved',
                icon: Icons.verified_rounded,
                color: AppColors.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.white06),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    poster,
                    width: 76,
                    height: 104,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Tag(label: format),
                          const SizedBox(width: 5),
                          _Tag(label: 'AUD 1 • SEATS $seats'),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        movie.title,
                        style: AppText.headlineSmall.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cinema,
                        style: AppText.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: AppColors.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            when,
                            style: AppText.bodySmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                size: 15,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Digital QR entry token is locally stored and fully readable '
                  'by box office lasers without cell service.',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 9.5,
                    height: 1.45,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'View Saved Ticket & QR Pass',
            icon: Icons.qr_code_scanner_rounded,
            height: 44,
            fontSize: 11.5,
            onTap: () => showCineSnack(
              context,
              'Saved QR pass opened from local cache.',
              icon: Icons.qr_code_2_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnostics() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white06),
      ),
      child: Column(
        children: [
          ErrorInfoRow(
            icon: Icons.signal_cellular_connected_no_internet_0_bar_rounded,
            title: 'Cellular / Wi-Fi',
            subtitle: 'No network response detected',
            iconColor: AppColors.error,
            iconBackground: AppColors.errorContainer.withValues(alpha: 0.25),
            trailing: const StatusPill(
              label: 'Unreachable',
              color: AppColors.error,
              filled: true,
            ),
          ),
          const Divider(color: AppColors.white10, height: 1),
          const ErrorInfoRow(
            icon: Icons.dns_outlined,
            title: 'CineGo Cloud Gateway',
            subtitle: 'Waiting for SSL handshake…',
            iconColor: AppColors.tertiary,
            trailing: StatusPill(
              label: 'Standby',
              color: AppColors.amber,
              filled: true,
            ),
          ),
          const Divider(color: AppColors.white10, height: 1),
          const ErrorInfoRow(
            icon: Icons.fastfood_outlined,
            title: 'Concessions Sync',
            subtitle: 'Queued; will push upon reconnection',
            iconColor: AppColors.tertiary,
            trailing: StatusPill(label: 'Cached'),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white06),
      ),
      child: const Column(
        children: [
          ErrorInfoRow(
            icon: Icons.airplanemode_active_rounded,
            title: 'Toggle Airplane Mode',
            subtitle:
                'Turn Airplane Mode on for 5 seconds, then off to reset '
                'theater antenna bands.',
          ),
          Divider(color: AppColors.white10, height: 1),
          ErrorInfoRow(
            icon: Icons.wifi_find_rounded,
            title: 'Connect to Theater Wi-Fi',
            subtitle:
                'Look for "AMC-Guest-WiFi" in the main lobby or '
                'atrium concourse.',
          ),
          Divider(color: AppColors.white10, height: 1),
          ErrorInfoRow(
            icon: Icons.near_me_outlined,
            title: 'Relocate From Heavy Screening Rooms',
            subtitle:
                'Basement or heavily soundproofed auditoriums often '
                'block signal propagation.',
          ),
        ],
      ),
    );
  }

  Widget _buildVenueMap(Booking? booking) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 132,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF16404F),
                    Color(0xFF14303E),
                    Color(0xFF101E2C),
                  ],
                ),
              ),
            ),
            const CustomPaint(painter: _MapLinesPainter()),
            const Positioned(
              top: 10,
              right: 10,
              child: StatusPill(
                label: 'GPS Offline • Map Saved',
                icon: Icons.gps_off_rounded,
                color: AppColors.tertiary,
                filled: true,
              ),
            ),
            Positioned(
              left: 12,
              top: 34,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.tertiary.withValues(alpha: 0.45),
                  ),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 20,
                  color: AppColors.tertiary,
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking?.cinema ?? 'AMC Metreon 16',
                    style: AppText.bodySmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '135 4th St, San Francisco, CA',
                    style: AppText.bodySmall.copyWith(
                      fontSize: 8.5,
                      color: AppColors.onSurfaceVariant,
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppText.labelCaps.copyWith(
          fontSize: 6.5,
          color: AppColors.tertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MapLinesPainter extends CustomPainter {
  const _MapLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final street = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.14)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    final minor = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.4;

    for (var i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 14), minor);
    }
    for (var i = 1; i < 7; i++) {
      final x = size.width * i / 7;
      canvas.drawLine(Offset(x, 0), Offset(x - 18, size.height), minor);
    }
    final path = Path()
      ..moveTo(-10, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.52,
        size.width * 0.62,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.7,
        size.width + 10,
        size.height * 0.36,
      );
    canvas.drawPath(path, street);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
