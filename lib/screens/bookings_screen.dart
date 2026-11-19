import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../models/showtime.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/ticket_widgets.dart';
import '../widgets/ui_kit.dart';
import 'cancellation_screen.dart';
import 'confirmation_screen.dart';
import 'snacks_screen.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  int _tab = 0;
  bool _searching = false;
  String _query = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Booking> _filtered(List<Booking> source) {
    if (_query.isEmpty) return source;
    return source
        .where(
          (booking) =>
              booking.movie.title.toLowerCase().contains(
                _query.toLowerCase(),
              ) ||
              booking.code.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
  }

  void _openTicket(Booking booking) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConfirmationScreen(booking: booking),
      ),
    );
  }

  void _openCancellation(Booking booking) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CancellationScreen(booking: booking),
      ),
    );
  }

  void _openSnacks(Booking booking) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SnacksScreen(
          movie: booking.movie,
          seats: booking.seats,
          showtime: SelectedShowtime(
            cinema: booking.cinema,
            format: booking.format,
            time: booking.time,
            price: 29.50,
            day: 'Today',
            auditorium: booking.auditorium.split(' • ').first,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final upcoming = _filtered(state.upcomingBookings);
    final past = _filtered(state.pastBookings);

    return Column(
      children: [
        RootHeader(
          onLocationTap: () => ref.read(appStateProvider).selectTab(2),
          onAvatarTap: () => ref.read(appStateProvider).selectTab(4),
          onNotificationTap: () => showCineSnack(
            context,
            'No new notifications right now.',
            icon: Icons.notifications_none_rounded,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            children: [
              Row(
                children: [
                  Text(
                    'My Bookings',
                    style: AppText.headlineLarge.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.primaryContainer.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: Text(
                      '${state.upcomingBookings.length} ACTIVE',
                      style: AppText.labelFormat.copyWith(
                        fontSize: 7.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  RoundIconButton(
                    icon: _searching
                        ? Icons.close_rounded
                        : Icons.search_rounded,
                    size: 38,
                    background: AppColors.surfaceLow,
                    onTap: () {
                      setState(() {
                        _searching = !_searching;
                        if (!_searching) {
                          _query = '';
                          _controller.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  RoundIconButton(
                    icon: Icons.tune_rounded,
                    size: 38,
                    background: AppColors.surfaceLow,
                    onTap: () => showCineSnack(
                      context,
                      'Bookings are sorted by upcoming showtime.',
                      icon: Icons.sort_rounded,
                    ),
                  ),
                ],
              ),
              if (_searching) ...[
                const SizedBox(height: 12),
                SearchField(
                  controller: _controller,
                  autofocus: true,
                  hint: 'Search by movie or booking code',
                  height: 44,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ],
              const SizedBox(height: 14),
              SegmentedPills(
                labels: const ['Upcoming', 'Past History'],
                counts: [
                  state.upcomingBookings.length,
                  state.pastBookings.length,
                ],
                selectedIndex: _tab,
                onChanged: (index) => setState(() => _tab = index),
              ),
              const SizedBox(height: 14),
              if (_tab == 0)
                ..._buildUpcoming(upcoming)
              else
                ..._buildPast(past),
              const SizedBox(height: 4),
              _buildPerkBanner(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildUpcoming(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return [const _EmptyBookings(label: 'No upcoming bookings yet.')];
    }
    return bookings.map((booking) {
      final isPrimary = booking.hasPerk;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: isPrimary
            ? _ActiveTicketCard(
                booking: booking,
                onViewPass: () => _openTicket(booking),
                onSnacks: () => _openSnacks(booking),
                onCancel: () => _openCancellation(booking),
              )
            : _UpcomingTicketCard(
                booking: booking,
                onDetails: () => _openCancellation(booking),
                onShare: () => showCineSnack(
                  context,
                  'Booking link copied to clipboard (demo).',
                  icon: Icons.ios_share_rounded,
                ),
                onCalendar: () => showCineSnack(
                  context,
                  'Added to your calendar (demo).',
                  icon: Icons.event_available_outlined,
                ),
              ),
      );
    }).toList();
  }

  List<Widget> _buildPast(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return [const _EmptyBookings(label: 'No past bookings to show.')];
    }
    return bookings
        .map(
          (booking) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              radius: 16,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      booking.poster,
                      width: 56,
                      height: 78,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 78,
                        color: AppColors.surfaceHigh,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              booking.movie.title,
                              style: AppText.bodySmall.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'VIEWED',
                              style: AppText.labelCaps.copyWith(
                                fontSize: 6.5,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${booking.dateLabel} • ${booking.time}',
                          style: AppText.bodySmall.copyWith(
                            fontSize: 9,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${booking.cinema} • Seats ${booking.seatLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodySmall.copyWith(
                            fontSize: 8.5,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            FormatTag(booking.format, compact: true),
                            const SizedBox(width: 6),
                            Text(
                              '\$${booking.total.toStringAsFixed(2)}',
                              style: AppText.monoSmall.copyWith(
                                fontSize: 9,
                                color: AppColors.tertiary,
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
          ),
        )
        .toList();
  }

  Widget _buildPerkBanner() {
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
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_activity_rounded,
              size: 21,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Large Popcorn Perk',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Valid with your Dune: Part Two booking.',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 8.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showCineSnack(
              context,
              'Popcorn perk added to your next concession order.',
              icon: Icons.local_activity_rounded,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'CLAIM',
                style: AppText.labelFormat.copyWith(
                  fontSize: 9,
                  color: AppColors.onTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTicketCard extends StatelessWidget {
  const _ActiveTicketCard({
    required this.booking,
    required this.onViewPass,
    required this.onSnacks,
    required this.onCancel,
  });

  final Booking booking;
  final VoidCallback onViewPass;
  final VoidCallback onSnacks;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.white10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  booking.countdownLabel ?? 'UPCOMING',
                  style: AppText.labelFormat.copyWith(
                    fontSize: 8.5,
                    color: AppColors.tertiary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.door_front_door_outlined,
                  size: 12,
                  color: AppColors.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  booking.gateLabel ?? 'Gate opens 4:25 PM',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 8.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onCancel,
                  child: const Icon(
                    Icons.more_horiz_rounded,
                    size: 16,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    booking.poster,
                    width: 78,
                    height: 112,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 78,
                      height: 112,
                      color: AppColors.surfaceHigh,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(
                                alpha: 0.18,
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.primaryContainer.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                            child: Text(
                              booking.dateLabel.toUpperCase(),
                              style: AppText.labelFormat.copyWith(
                                fontSize: 7.5,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          FormatTag(booking.format, compact: true),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        booking.movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.headlineSmall.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${booking.cinema} • ${booking.auditorium.split(' • ').first}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.event_seat_rounded,
                                    size: 11,
                                    color: AppColors.outline,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Row ${booking.seats.first.substring(0, 1)} • ${booking.seatLabel}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppText.monoSmall.copyWith(
                                        fontSize: 8.5,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (booking.isVip) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'VIP',
                                    style: AppText.labelCaps.copyWith(
                                      fontSize: 6,
                                      color: AppColors.tertiary,
                                    ),
                                  ),
                                  Text(
                                    'RECLINER',
                                    style: AppText.labelCaps.copyWith(
                                      fontSize: 5,
                                      color: AppColors.tertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const TicketDivider(
            notchColor: AppColors.surface,
            lineColor: AppColors.white12,
            height: 18,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
            child: Row(
              children: [
                MiniQrView(size: 44, seed: booking.code.length + 5),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TURNSTILE PASS',
                        style: AppText.labelCaps.copyWith(
                          fontSize: 6.5,
                          color: AppColors.outline,
                        ),
                      ),
                      Text(
                        booking.code,
                        style: AppText.monoBold.copyWith(
                          fontSize: 12,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 10,
                            color: AppColors.tertiary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Scan at Turnstile 1',
                            style: AppText.bodySmall.copyWith(
                              fontSize: 8,
                              color: AppColors.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'CONFIRMED',
                    style: AppText.labelCaps.copyWith(
                      fontSize: 6.5,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: PrimaryButton(
              label: 'View Digital Pass',
              icon: Icons.confirmation_number_outlined,
              height: 44,
              fontSize: 12,
              onTap: onViewPass,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Directions',
                    icon: Icons.near_me_outlined,
                    height: 38,
                    fontSize: 10.5,
                    onTap: () => showCineSnack(
                      context,
                      'Opening directions to AMC Metreon 16.',
                      icon: Icons.near_me_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SecondaryButton(
                    label: 'Pre-order Snacks',
                    icon: Icons.local_dining_outlined,
                    height: 38,
                    fontSize: 10.5,
                    onTap: onSnacks,
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

class _UpcomingTicketCard extends StatelessWidget {
  const _UpcomingTicketCard({
    required this.booking,
    required this.onDetails,
    required this.onShare,
    required this.onCalendar,
  });

  final Booking booking;
  final VoidCallback onDetails;
  final VoidCallback onShare;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'ADVANCE PREMIERE',
                  style: AppText.labelCaps.copyWith(
                    fontSize: 6.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.event_available_outlined,
                size: 12,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 4),
              Text(
                booking.countdownLabel ?? 'Upcoming',
                style: AppText.bodySmall.copyWith(
                  fontSize: 8.5,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  booking.poster,
                  width: 64,
                  height: 92,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 92,
                    color: AppColors.surfaceHigh,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.format,
                      style: AppText.labelFormat.copyWith(
                        fontSize: 7.5,
                        color: AppColors.tertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.movie.title,
                      style: AppText.headlineSmall.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.dateLabel} • ${booking.time}',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9.5,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '${booking.cinema} • ${booking.auditorium}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 8.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.event_seat_rounded,
                          size: 11,
                          color: AppColors.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '2 Seats (${booking.seatLabel})',
                          style: AppText.monoSmall.copyWith(
                            fontSize: 8.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Booking Details',
                  icon: Icons.receipt_long_outlined,
                  height: 38,
                  fontSize: 10.5,
                  onTap: onDetails,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onShare,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.ios_share_rounded,
                    size: 15,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onCalendar,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            size: 38,
            color: AppColors.outline,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppText.bodySmall.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: 4),
          Text(
            'Browse what is playing and book your next seat.',
            style: AppText.bodySmall.copyWith(
              fontSize: 9,
              color: AppColors.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}
