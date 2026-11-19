import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/ui_kit.dart';

class CancellationScreen extends ConsumerStatefulWidget {
  const CancellationScreen({super.key, required this.booking});

  final Booking booking;

  @override
  ConsumerState<CancellationScreen> createState() => _CancellationScreenState();
}

class _CancellationScreenState extends ConsumerState<CancellationScreen> {
  int _payout = 0;
  String? _reason;
  bool _confirming = false;

  static const _reasons = [
    'Schedule Conflict',
    'Found Better Showtime',
    'Illness / Emergency',
    'Booked by Mistake',
    'Other',
  ];

  double get _baseRefund => widget.booking.total;

  double get _refund => _payout == 0 ? _baseRefund + 5.00 : _baseRefund;

  Future<void> _confirm() async {
    if (_confirming) return;
    setState(() => _confirming = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Cancel this booking?',
            style: AppText.headlineSmall.copyWith(fontSize: 18),
          ),
          content: Text(
            'Seats ${widget.booking.seatLabel} will be released and '
            '\$${_refund.toStringAsFixed(2)} will be refunded to '
            '${_payout == 0 ? 'your CineGo Wallet' : 'your original payment methods'}.',
            style: AppText.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Keep reservation',
                style: AppText.bodySmall.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Confirm cancellation',
                style: AppText.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (confirmed == true) {
      ref.read(appStateProvider).cancelBooking(widget.booking);
      showCineSnack(
        context,
        'Booking cancelled — \$${_refund.toStringAsFixed(2)} refund initiated.',
        icon: Icons.check_circle_outline_rounded,
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final seatTotal = booking.seats.length * 29.50;
    final surcharge = booking.format.contains('IMAX') ? 3.50 : 0.0;
    const taxes = 2.10;
    final concessions = (_baseRefund - seatTotal - surcharge - taxes).clamp(
      0.0,
      999.0,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          SubPageHeader(
            title: 'Ticket Cancellation & Refund',
            subtitle: '${booking.cinema} • ${booking.dateLabel}',
            trailing: const TimerChip(label: '10:00'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
              children: [
                _buildEligibility(),
                const SizedBox(height: 12),
                _buildMiniTicket(booking, concessions),
                const SizedBox(height: 12),
                _buildRefundBreakdown(
                  booking,
                  seatTotal,
                  surcharge,
                  taxes,
                  concessions,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Select Payout Destination',
                      style: AppText.headlineSmall.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '2 OPTIONS',
                      style: AppText.labelCaps.copyWith(
                        fontSize: 7.5,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                _buildPayoutOptions(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Reason for Cancelling',
                      style: AppText.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Optional',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _reasons
                      .map(
                        (reason) => FilterChipPill(
                          label: reason,
                          selected: _reason == reason,
                          onTap: () => setState(() => _reason = reason),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                _buildGoldNotice(),
                const SizedBox(height: 16),
                PrimaryButton(
                  label:
                      'Confirm Cancellation (Refund \$${_refund.toStringAsFixed(2)})',
                  icon: Icons.cancel_outlined,
                  height: 52,
                  fontSize: 12.5,
                  onTap: _confirming ? null : _confirm,
                ),
                const SizedBox(height: 8),
                SecondaryButton(
                  label: 'Keep My Reservation',
                  icon: Icons.bookmark_added_outlined,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 11,
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'By confirming, seats ${booking.seatLabel} will immediately become available to others.',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 8.5,
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

  Widget _buildEligibility() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.28)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF12303C), Color(0xFF121A2A), AppColors.surfaceLow],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'Eligible for 100% Full Refund',
                style: AppText.bodySmall.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'FREE WINDOW',
                  style: AppText.labelCaps.copyWith(
                    fontSize: 6,
                    color: AppColors.tertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 12,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Free cancellation closes 3:45 PM today ',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: '(60 mins before showtime).',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: '\n3h 15m remaining. Seats and pre-ordered treats release instantly.',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTicket(Booking booking, double concessions) {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  booking.poster,
                  width: 66,
                  height: 94,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 66,
                    height: 94,
                    color: AppColors.surfaceHigh,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FormatTag(booking.format, compact: true),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            booking.movie.certificate,
                            style: AppText.labelCaps.copyWith(
                              fontSize: 6,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.headlineSmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${booking.cinema} • ${booking.auditorium.split(' • ').first}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 8.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_seat_rounded,
                                size: 10,
                                color: AppColors.tertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Seats ${booking.seatLabel}',
                                style: AppText.monoSmall.copyWith(
                                  fontSize: 8.5,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          booking.code,
                          style: AppText.monoSmall.copyWith(
                            fontSize: 8,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (concessions > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_dining_rounded,
                    size: 13,
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '1x Collector\'s Tin Combo, 1x Warm Popcorn • In-seat delivery scheduled',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 8,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+\$${concessions.toStringAsFixed(2)}',
                    style: AppText.monoSmall.copyWith(
                      fontSize: 8,
                      color: AppColors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 12,
                    color: AppColors.tertiary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRefundBreakdown(
    Booking booking,
    double seatTotal,
    double surcharge,
    double taxes,
    double concessions,
  ) {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Refund Breakdown',
                style: AppText.headlineSmall.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'ITEMIZED',
                style: AppText.labelFormat.copyWith(
                  fontSize: 7.5,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _row(
            '${booking.seats.length}x VIP Ultra Recliner Seats',
            '\$${seatTotal.toStringAsFixed(2)}',
          ),
          _row(
            'IMAX 70mm Laser Surcharge',
            surcharge == 0 ? 'Waived' : '\$${surcharge.toStringAsFixed(2)}',
          ),
          if (concessions > 0)
            _row(
              'Pre-ordered Concessions',
              '\$${concessions.toStringAsFixed(2)}',
              highlight: '-\$2 Gold',
            ),
          _row('Online Booking Fee', 'Waived', strike: '\$3.00', accent: true),
          _row('Estimated State Tax & Fees', '\$${taxes.toStringAsFixed(2)}'),
          _row('Cancellation Processing Fee', 'FREE', accent: true),
          const SizedBox(height: 8),
          const Divider(color: AppColors.white10, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'ORIGINAL PAYMENT SPLIT',
                style: AppText.labelCaps.copyWith(
                  fontSize: 6.5,
                  color: AppColors.outline,
                ),
              ),
              const Spacer(),
              Text(
                'TOTAL PAID',
                style: AppText.labelCaps.copyWith(
                  fontSize: 6.5,
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${booking.total.toStringAsFixed(2)}',
                style: AppText.monoSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 11,
                color: AppColors.outline,
              ),
              const SizedBox(width: 4),
              Text(
                'CineGo Wallet',
                style: AppText.bodySmall.copyWith(
                  fontSize: 8.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                '  \$34.50',
                style: AppText.monoSmall.copyWith(
                  fontSize: 8.5,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.phone_iphone_rounded,
                size: 11,
                color: AppColors.outline,
              ),
              const SizedBox(width: 4),
              Text(
                'Apple Pay (•••• 4821)   \$61.60',
                style: AppText.monoSmall.copyWith(
                  fontSize: 8,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL REFUND DUE',
                      style: AppText.labelCaps.copyWith(
                        fontSize: 6.5,
                        color: AppColors.outline,
                      ),
                    ),
                    Text(
                      '100% of purchase value',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 8,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '\$${_refund.toStringAsFixed(2)}',
                  style: AppText.displayHeroMobile.copyWith(
                    fontSize: 24,
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

  Widget _row(
    String label,
    String value, {
    String? highlight,
    String? strike,
    bool accent = false,
  }) {
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
          if (highlight != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                highlight,
                style: AppText.labelCaps.copyWith(
                  fontSize: 6,
                  color: AppColors.tertiary,
                ),
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (strike != null) ...[
            Text(
              strike,
              style: AppText.bodySmall.copyWith(
                fontSize: 8.5,
                color: AppColors.outline,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            value,
            style: AppText.monoSmall.copyWith(
              fontSize: 9.5,
              color: accent ? AppColors.tertiary : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutOptions() {
    return Column(
      children: [
        _PayoutTile(
          selected: _payout == 0,
          title: 'CineGo Wallet',
          badge: 'INSTANT',
          amount: _baseRefund + 5.00,
          bonus: '+\$5.00 BONUS',
          description:
              'Receive \$${(_baseRefund + 5.00).toStringAsFixed(2)} instant credit ready for your next Dune or IMAX screening.',
          footer: 'Zero processing delays • No expiration date',
          icon: Icons.account_balance_wallet_rounded,
          onTap: () => setState(() => _payout = 0),
        ),
        const SizedBox(height: 9),
        _PayoutTile(
          selected: _payout == 1,
          title: 'Original Methods',
          badge: 'SPLIT BACK',
          amount: _baseRefund,
          description: '\$34.50 to CineGo Wallet (instant) • \$61.60 to Apple Pay Mastercard (3–5 business days).',
          icon: Icons.credit_card_rounded,
          onTap: () => setState(() => _payout = 1),
        ),
      ],
    );
  }

  Widget _buildGoldNotice() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white06),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 18,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CinePass Gold Notice',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Your ',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 8.5,
                          height: 1.45,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      TextSpan(
                        text: '168 pending CinePass Points',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 8.5,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tertiary,
                        ),
                      ),
                      TextSpan(
                        text: ' for this reservation will be reversed. Your Gold tier status and weekly streak remain preserved.',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 8.5,
                          height: 1.45,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
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

class _PayoutTile extends StatelessWidget {
  const _PayoutTile({
    required this.selected,
    required this.title,
    required this.badge,
    required this.amount,
    required this.description,
    required this.icon,
    required this.onTap,
    this.bonus,
    this.footer,
  });

  final bool selected;
  final String title;
  final String badge;
  final double amount;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final String? bonus;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceContainer : AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primaryContainer.withValues(alpha: 0.5)
                : AppColors.white06,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.primaryContainer
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryContainer
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryContainer
                        : AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    badge,
                    style: AppText.labelCaps.copyWith(
                      fontSize: 5.5,
                      color: selected
                          ? Colors.white
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: AppText.headlineSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 13, color: AppColors.outline),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bonus != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryContainer,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            bonus!,
                            style: AppText.labelCaps.copyWith(
                              fontSize: 5.5,
                              color: AppColors.onTertiary,
                            ),
                          ),
                        ),
                      Text(
                        description,
                        style: AppText.bodySmall.copyWith(
                          fontSize: 8.5,
                          height: 1.4,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (footer != null) ...[
              const SizedBox(height: 5),
              Row(
                children: [
                  const SizedBox(width: 19),
                  Text(
                    footer!,
                    style: AppText.bodySmall.copyWith(
                      fontSize: 7.5,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
