import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';
import '../models/showtime.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/error_ui.dart';
import '../widgets/ui_kit.dart';
import 'checkout_screen.dart';
import 'seat_selection_screen.dart';

/// Shown when the checkout hold timer expires before authorization completes.
class PaymentTimeoutScreen extends ConsumerWidget {
  const PaymentTimeoutScreen({
    super.key,
    required this.movie,
    required this.showtime,
    required this.seats,
    this.paymentLabel = 'Apple Pay',
    this.walletCredit = 34.50,
  });

  final Movie movie;
  final SelectedShowtime showtime;
  final List<String> seats;
  final String paymentLabel;
  final double walletCredit;

  String get _seatLabel => seats.join(', ');

  void _lockSeats(BuildContext context, List<String> nextSeats) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SeatSelectionScreen(
          movie: movie,
          showtime: showtime,
          initialSeats: nextSeats,
        ),
      ),
    );
  }

  void _nextShowtime(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SeatSelectionScreen(
          movie: movie,
          showtime: SelectedShowtime(
            cinema: showtime.cinema,
            format: showtime.format,
            time: '8:15 PM',
            price: showtime.price,
            day: showtime.day,
            auditorium: showtime.auditorium,
          ),
          initialSeats: const [],
        ),
      ),
    );
  }

  void _updatePayment(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            CheckoutScreen(movie: movie, showtime: showtime, seats: seats),
      ),
    );
  }

  String _snackLabel(AppState state) {
    final ids = state.cart.keys.toList();
    if (ids.isEmpty) return 'No snacks added yet';
    final first = state.itemById(ids.first);
    final firstQty = state.cart[ids.first] ?? 1;
    final extra = state.cartCount - firstQty;
    final name = first?.name ?? 'Concessions';
    if (extra > 0) return '$name + $extra more';
    return firstQty > 1 ? '$firstQty× $name' : name;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final snackTotal = state.cartTotal;
    final hasSnacks = state.cartCount > 0;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          SubPageHeader(
            title: 'Booking Expired',
            subtitle:
                '${movie.title} • ${showtime.auditorium} • Seats '
                '$_seatLabel',
            trailing: const TimerChip(
              label: '00:00',
              icon: Icons.timer_off_rounded,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [
                _buildHero(),
                const SizedBox(height: 12),
                _buildZeroCharges(),
                const SizedBox(height: 12),
                _buildOrderDetails(state, snackTotal, hasSnacks),
                const SizedBox(height: 12),
                _buildRecovery(context),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Re-select Seats & Try Again',
                  icon: Icons.refresh_rounded,
                  onTap: () => _lockSeats(context, seats),
                ),
                const SizedBox(height: 8),
                SecondaryButton(
                  label: 'Update Payment Method',
                  icon: Icons.credit_card_rounded,
                  onTap: () => _updatePayment(context),
                ),
                const SizedBox(height: 16),
                _buildHelp(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        children: [
          const GlowIconOrb(
            icon: Icons.timer_off_rounded,
            color: AppColors.error,
            size: 78,
            badgeIcon: Icons.credit_card_off_rounded,
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusPill(
                label: 'Expired • 00:00',
                color: AppColors.error,
                filled: true,
              ),
              SizedBox(width: 6),
              StatusPill(
                label: 'ERR_AUTH_TIMEOUT',
                color: AppColors.outline,
                filled: true,
                fontSize: 7.5,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Booking Expired & Unpaid',
            textAlign: TextAlign.center,
            style: AppText.headlineMedium.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text:
                  'Bank authorization timed out during checkout. Your seat '
                  'hold elapsed, and seats ',
              children: [
                TextSpan(
                  text: _seatLabel,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' were returned to theater inventory.'),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppText.bodySmall.copyWith(
              fontSize: 10.5,
              height: 1.55,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZeroCharges() {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tertiaryContainer.withValues(alpha: 0.24),
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
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
                  'Zero Charges Incurred',
                  style: AppText.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    text: 'Your $paymentLabel was not billed. ',
                    children: [
                      if (walletCredit > 0) ...[
                        const TextSpan(text: 'Your CineGo Wallet balance of '),
                        TextSpan(
                          text: '\$${walletCredit.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ' remains completely untouched.'),
                      ] else
                        const TextSpan(
                          text: 'No wallet credit was applied to this order.',
                        ),
                    ],
                  ),
                  style: AppText.bodySmall.copyWith(
                    fontSize: 9.5,
                    height: 1.45,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(AppState state, double snackTotal, bool hasSnacks) {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Preserved Order Details',
                  style: AppText.labelCaps.copyWith(
                    fontSize: 9,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const StatusPill(
                label: 'Released 2m ago',
                color: AppColors.error,
                fontSize: 7,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.white06),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    movie.poster,
                    width: 74,
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
                          _FormatTag(label: showtime.format),
                          const SizedBox(width: 5),
                          const _FormatTag(
                            label: 'AUD 1',
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.headlineSmall.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${showtime.cinema} • San Francisco',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: AppColors.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${showtime.day}, ${showtime.time}',
                            style: AppText.bodySmall.copyWith(
                              fontSize: 9.5,
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
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREVIOUS SEATS',
                      style: AppText.labelCaps.copyWith(
                        fontSize: 7,
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _seatLabel,
                            style: AppText.headlineSmall.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Held',
                          style: AppText.bodySmall.copyWith(
                            fontSize: 8.5,
                            color: AppColors.error,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 34, color: AppColors.white10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SNACKS IN CART',
                      style: AppText.labelCaps.copyWith(
                        fontSize: 7,
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.fastfood_outlined,
                          size: 13,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          hasSnacks
                              ? '${state.cartCount} '
                                    '${state.cartCount == 1 ? 'Item' : 'Items'} '
                                    'Saved'
                              : 'No items saved',
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
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.white06),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 14,
                  color: AppColors.tertiary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    hasSnacks
                        ? '${_snackLabel(state)} held in cart'
                        : 'Concessions cart is empty',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySmall.copyWith(fontSize: 9.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${snackTotal.toStringAsFixed(2)}',
                  style: AppText.labelFormat.copyWith(
                    fontSize: 9.5,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecovery(BuildContext context) {
    final rowBehind = _alternateSeats();
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiaryContainer.withValues(alpha: 0.24),
                  border: Border.all(
                    color: AppColors.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.airline_seat_recline_extra_rounded,
                  size: 19,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seats $_seatLabel May Still Be Open',
                      style: AppText.bodyMedium.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Inventory was restored 120s ago. No other customer has '
                      'secured them yet.',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9,
                        height: 1.4,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'SUGGESTED RECOVERY OPTIONS',
            style: AppText.labelCaps.copyWith(
              fontSize: 7.5,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.white06),
            ),
            child: Column(
              children: [
                _RecoveryRow(
                  icon: Icons.sync_rounded,
                  title: 'Try Re-locking Seats $_seatLabel',
                  subtitle:
                      'Same ${showtime.time} showtime • Prime center view',
                  onTap: () => _lockSeats(context, seats),
                ),
                const Divider(color: AppColors.white10, height: 1),
                _RecoveryRow(
                  icon: Icons.event_seat_outlined,
                  title:
                      'Switch to Seats ${rowBehind.join(', ')} '
                      '(Row Behind)',
                  subtitle: 'Guaranteed instantly available now',
                  onTap: () => _lockSeats(context, rowBehind),
                ),
                const Divider(color: AppColors.white10, height: 1),
                _RecoveryRow(
                  icon: Icons.schedule_rounded,
                  title: 'Next ${showtime.format} at 8:15 PM',
                  subtitle: '14 Center seats remaining',
                  onTap: () => _nextShowtime(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _alternateSeats() {
    final row = seats.firstWhere((seat) => seat.isNotEmpty, orElse: () => 'E5');
    final letter = row.substring(0, 1);
    final nextLetter = String.fromCharCode(letter.codeUnitAt(0) + 1);
    return ['${nextLetter}5', '${nextLetter}6'];
  }

  Widget _buildHelp(BuildContext context) {
    return GestureDetector(
      onTap: () => showCineSnack(
        context,
        'CineGo Concierge is not part of this demo.',
        icon: Icons.support_agent_rounded,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.support_agent_rounded,
            size: 14,
            color: AppColors.outline,
          ),
          const SizedBox(width: 6),
          Text(
            'Need urgent help? Chat with CineGo Concierge',
            style: AppText.bodySmall.copyWith(
              fontSize: 9.5,
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryRow extends StatelessWidget {
  const _RecoveryRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.surfaceHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15, color: AppColors.tertiary),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.bodySmall.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: AppText.bodySmall.copyWith(
                      fontSize: 8.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatTag extends StatelessWidget {
  const _FormatTag({required this.label, this.color = AppColors.tertiary});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppText.labelFormat.copyWith(
          fontSize: 7.5,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
