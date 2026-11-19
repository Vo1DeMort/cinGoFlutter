import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';
import '../models/booking.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_widgets.dart';
import '../widgets/ui_kit.dart';

class ConfirmationScreen extends ConsumerWidget {
  const ConfirmationScreen({
    super.key,
    required this.booking,
    this.paymentLabel = 'Apple Pay',
    this.smsOptIn = true,
  });

  final Booking booking;
  final String paymentLabel;
  final bool smsOptIn;

  void _goToBookings(BuildContext context, WidgetRef ref) {
    ref.read(appStateProvider).selectTab(3);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _goToMovies(BuildContext context, WidgetRef ref) {
    ref.read(appStateProvider).selectTab(1);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seats = booking.seats.join(', ');
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [
                _buildConfirmationRibbon(),
                const SizedBox(height: 12),
                _buildTicketCard(context, seats),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Apple Wallet',
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: () => showCineSnack(
                          context,
                          'Pass added to Apple Wallet (demo).',
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Add to Calendar',
                        icon: Icons.calendar_month_outlined,
                        onTap: () => showCineSnack(
                          context,
                          'Showtime added to your calendar (demo).',
                          icon: Icons.event_available_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPaymentSummary(),
                const SizedBox(height: 12),
                _buildArrivalCard(context),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'View in My Bookings',
                  icon: Icons.confirmation_number_outlined,
                  onTap: () => _goToBookings(context, ref),
                ),
                const SizedBox(height: 8),
                SecondaryButton(
                  label: 'Back to Movies',
                  icon: Icons.home_outlined,
                  onTap: () => _goToMovies(context, ref),
                ),
                if (smsOptIn) ...[
                  const SizedBox(height: 10),
                  Text(
                    'SMS pass sent to +1 (415) 555-0192 • Email receipt sent to alex.chen@example.com',
                    textAlign: TextAlign.center,
                    style: AppText.bodySmall.copyWith(
                      fontSize: 8.5,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.92),
        border: const Border(bottom: BorderSide(color: AppColors.white06)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 46,
            child: Row(
              children: [
                RoundIconButton(
                  icon: Icons.close_rounded,
                  onTap: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                ),
                const SizedBox(width: 10),
                Text(
                  'E-Ticket',
                  style: AppText.headlineSmall.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                RoundIconButton(
                  icon: Icons.ios_share_rounded,
                  iconSize: 17,
                  size: 38,
                  background: AppColors.surfaceContainer,
                  onTap: () => showCineSnack(
                    context,
                    'Ticket link copied to clipboard (demo).',
                    icon: Icons.ios_share_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                RoundIconButton(
                  icon: Icons.download_rounded,
                  iconSize: 18,
                  size: 38,
                  background: AppColors.surfaceContainer,
                  onTap: () => showCineSnack(
                    context,
                    'E-ticket PDF download is not part of this demo.',
                    icon: Icons.download_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationRibbon() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white06),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tertiary.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tertiary.withValues(alpha: 0.22),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.tertiary,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Confirmed',
                  style: AppText.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Confirmation sent to alex.chen@example.com',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 9,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'BOOKING',
                  style: AppText.labelCaps.copyWith(
                    fontSize: 6,
                    color: AppColors.outline,
                  ),
                ),
                Text(
                  booking.code,
                  style: AppText.labelFormat.copyWith(
                    fontSize: 8.5,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, String seats) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            SizedBox(
              height: 168,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/backdrop_dune_ticket.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: AppColors.surfaceHigh),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x550A0E17),
                          Color(0x990A0E17),
                          AppColors.surfaceLow,
                        ],
                        stops: [0, 0.55, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 11,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        const FormatTag('IMAX 70MM', compact: true),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLowest.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            booking.movie.certificate,
                            style: AppText.labelCaps.copyWith(
                              fontSize: 7,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLowest.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            booking.movie.genres.join(' • '),
                            style: AppText.labelCaps.copyWith(
                              fontSize: 6.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLowest.withValues(
                              alpha: 0.65,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ADMIT ONE',
                            style: AppText.labelCaps.copyWith(
                              fontSize: 5.5,
                              color: AppColors.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.headlineLarge.copyWith(
                            fontSize: 27,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: AppColors.tertiary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${booking.cinema} • ${booking.auditorium.split(' • ').first}',
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: _TicketDatum(
                      icon: Icons.calendar_month_rounded,
                      label: 'DATE',
                      value: 'Today',
                      hint: '24 Oct',
                    ),
                  ),
                  _datumDivider(),
                  Expanded(
                    child: _TicketDatum(
                      icon: Icons.schedule_rounded,
                      label: 'TIME',
                      value: booking.time.replaceFirst(' PM', ''),
                      hint: 'PM',
                    ),
                  ),
                  _datumDivider(),
                  Expanded(
                    child: _TicketDatum(
                      icon: Icons.event_seat_rounded,
                      label: 'SEATS',
                      value: seats,
                      hint: 'VIP Recliner',
                      highlight: true,
                    ),
                  ),
                ],
              ),
            ),
            const TicketDivider(
              notchColor: AppColors.surface,
              lineColor: AppColors.white12,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'LIVE PASS',
                        style: AppText.labelCaps.copyWith(
                          fontSize: 7.5,
                          color: AppColors.tertiary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '  •  REFRESHING IN 38s',
                        style: AppText.labelFormat.copyWith(
                          fontSize: 7.5,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  QrView(size: 178, seed: booking.code.length + 3),
                  const SizedBox(height: 10),
                  Text(
                    '9048  •  1172  •  8942',
                    style: AppText.monoBold.copyWith(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Scan at Turnstile 1 or Metreon Express Concessions',
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

  Widget _datumDivider() {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: AppColors.white10,
    );
  }

  Widget _buildPaymentSummary() {
    final ticketTotal = booking.seats.length * 29.50;
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Text(
                'Payment Summary',
                style: AppText.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '\$${booking.total.toStringAsFixed(2)}',
                style: AppText.headlineSmall.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'VIP Ultra Recliner (x${booking.seats.length})',
            '\$${ticketTotal.toStringAsFixed(2)}',
          ),
          _summaryRow('IMAX Experience Fee', '\$3.50'),
          _summaryRow('Taxes & Local Surcharges', '\$2.10'),
          const SizedBox(height: 8),
          const Divider(color: AppColors.white10, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.phone_iphone_rounded,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                '$paymentLabel (•••• 4821)',
                style: AppText.bodySmall.copyWith(
                  fontSize: 9,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'Paid',
                style: AppText.bodySmall.copyWith(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppText.bodySmall.copyWith(
                fontSize: 9.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: AppText.monoSmall.copyWith(
              fontSize: 9.5,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalCard(BuildContext context) {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_walk_rounded,
                size: 17,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 7),
              Text(
                'Arrival & Amenities',
                style: AppText.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '0.8 mi away',
                style: AppText.labelCaps.copyWith(
                  fontSize: 8,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 108,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/map.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: AppColors.surfaceHigh),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLowest.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.navigation_rounded,
                          size: 11,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Start Directions',
                          style: AppText.bodySmall.copyWith(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _arrivalRow(
            Icons.door_front_door_outlined,
            'Doors open 20 mins prior to showtime (4:25 PM).',
          ),
          _arrivalRow(
            Icons.restaurant_outlined,
            'In-seat dining ordering window closes at 4:40 PM.',
          ),
          _arrivalRow(
            Icons.local_parking_rounded,
            '4-Hour parking validation available at the Metreon lobby desk.',
          ),
        ],
      ),
    );
  }

  Widget _arrivalRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: AppColors.outline),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: AppText.bodySmall.copyWith(
                fontSize: 8.5,
                height: 1.35,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketDatum extends StatelessWidget {
  const _TicketDatum({
    required this.icon,
    required this.label,
    required this.value,
    required this.hint,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String hint;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 11, color: AppColors.outline),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppText.labelCaps.copyWith(
                fontSize: 7,
                color: AppColors.outline,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.headlineSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: highlight ? AppColors.tertiary : AppColors.onSurface,
          ),
        ),
        Text(
          hint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.bodySmall.copyWith(
            fontSize: 7.5,
            color: AppColors.outline,
          ),
        ),
      ],
    );
  }
}
