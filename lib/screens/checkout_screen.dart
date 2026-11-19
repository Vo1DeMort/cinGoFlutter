import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../models/movie.dart';
import '../models/showtime.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/ui_kit.dart';
import 'confirmation_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.movie,
    required this.showtime,
    required this.seats,
  });

  final Movie movie;
  final SelectedShowtime showtime;
  final List<String> seats;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _promoController = TextEditingController();
  int _paymentMethod = 0;
  bool _promoOpen = false;
  bool _smsOptIn = true;
  bool _paying = false;
  int _secondsLeft = 6 * 60 + 43;
  Timer? _timer;

  double _promoDiscount = 0;

  static const _tax = 2.10;
  static const _formatSurcharge = 3.50;
  static const _seatPrice = 29.50;
  static const _perk = 2.00;
  static const _walletCredit = 34.50;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  String get _timerLabel {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _tickets => widget.seats.length * _seatPrice;

  double get _snackTotal => ref.read(appStateProvider).cartTotal;

  double get _subtotal => _tickets + _formatSurcharge + _snackTotal - _perk - _promoDiscount;

  double get _walletApplied =>
      ref.read(appStateProvider).walletApplied ? _walletCredit : 0;

  double get _grandTotal {
    final total = _subtotal + _tax - _walletApplied;
    return total < 0 ? 0 : total;
  }

  double get _totalSaved => _walletCredit == 0 ? 0 : _walletCredit + _perk + 3;

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      showCineSnack(context, 'Enter a promo code first.');
      return;
    }
    if (code == 'SPICE20' || code == 'CINEGO') {
      setState(() => _promoDiscount = 5.00);
      showCineSnack(
        context,
        'Promo $code applied — \$5.00 off your order.',
        icon: Icons.local_offer_outlined,
      );
    } else {
      setState(() => _promoDiscount = 0);
      showCineSnack(
        context,
        'That code is not valid for this booking.',
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _pay() async {
    if (_paying) return;
    setState(() => _paying = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    final state = ref.read(appStateProvider);
    final booking = Booking(
      id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
      code: '#CG-${DateTime.now().microsecondsSinceEpoch.toString().substring(7)}',
      movie: widget.movie,
      cinema: widget.showtime.cinema,
      auditorium: '${widget.showtime.auditorium} • Screen 1',
      dateLabel: '${widget.showtime.day} • ${widget.showtime.time}',
      time: widget.showtime.time,
      seats: widget.seats,
      total: _grandTotal,
      poster: widget.movie.poster,
      status: BookingStatus.upcoming,
      format: widget.showtime.format,
      countdownLabel: 'STARTS IN 2H 15M',
      gateLabel: 'Gate 4:25 PM',
    );
    state.addBooking(booking);
    state.clearCart();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ConfirmationScreen(
          booking: booking,
          paymentLabel: _paymentLabel,
          smsOptIn: _smsOptIn,
        ),
      ),
    );
  }

  String get _paymentLabel {
    switch (_paymentMethod) {
      case 1:
        return 'Mastercard •••• 4821';
      case 2:
        return 'PayPal';
      default:
        return 'Apple Pay';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final seats = widget.seats.join(', ');
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          SubPageHeader(
            title: 'Secure Checkout',
            subtitle:
                '${widget.movie.title} • ${widget.showtime.auditorium} • Seats $seats',
            trailing: TimerChip(label: _timerLabel),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLow,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
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
                      const SizedBox(width: 7),
                      Text(
                        'Seats Held: ',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        _timerLabel,
                        style: AppText.labelFormat.copyWith(
                          fontSize: 10,
                          color: AppColors.tertiary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 11,
                              color: AppColors.tertiary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '256-BIT ENCRYPTED',
                              style: AppText.labelCaps.copyWith(
                                fontSize: 6.5,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildBookingSummary(seats),
                const SizedBox(height: 12),
                _buildCinePass(),
                const SizedBox(height: 12),
                _buildOrderBreakdown(state),
                const SizedBox(height: 12),
                _buildPromo(),
                const SizedBox(height: 12),
                _buildWallet(state),
                const SizedBox(height: 18),
                _buildPaymentMethods(),
                const SizedBox(height: 18),
                _buildContact(),
                const SizedBox(height: 12),
                _buildAuditorium(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildPayBar(),
    );
  }

  Widget _buildBookingSummary(String seats) {
    return AppCard(
      radius: 18,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 78,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(widget.movie.poster),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const FormatTag('70MM SPECIAL', compact: true),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.movie.certificate,
                              style: AppText.labelCaps.copyWith(
                                fontSize: 7,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.showtime.cinema} • ${widget.showtime.auditorium}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${widget.showtime.day}, Oct 24',
                            style: AppText.bodySmall.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            '  •  ',
                            style: AppText.bodySmall.copyWith(
                              color: AppColors.outline,
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            widget.showtime.time,
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
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.surfaceContainer,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.airline_seat_recline_extra_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Row ${widget.seats.first.substring(0, 1)} • $seats ',
                          style: AppText.monoSmall.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: '(VIP Recliners)',
                          style: AppText.bodySmall.copyWith(
                            fontSize: 9,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'VIP PASS',
                    style: AppText.labelCaps.copyWith(
                      fontSize: 6.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.surfaceHigh.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.room_service_outlined,
                  size: 13,
                  color: AppColors.tertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  'In-Seat Concession Delivery to Seats $seats',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
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

  Widget _buildCinePass() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white06),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryContainer,
            ),
            child: const Icon(
              Icons.stars_rounded,
              size: 20,
              color: AppColors.secondary,
            ),
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
                        'CinePass Gold Perks Active',
                        style: AppText.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'MEMBER',
                        style: AppText.labelCaps.copyWith(
                          fontSize: 6,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Free Popcorn Upgrade ',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: '(-\$2.00)',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiary,
                        ),
                      ),
                      TextSpan(
                        text: ' & Waived Online Booking Fee ',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: '(-\$3.00)',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiary,
                        ),
                      ),
                      TextSpan(
                        text: ' applied automatically.',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLowest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 11,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '+168 CinePass Points earned on checkout',
                        style: AppText.labelCaps.copyWith(
                          fontSize: 6.5,
                          color: AppColors.secondary,
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

  Widget _buildOrderBreakdown(AppState state) {
    final snacks = state.cart.entries.toList();
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Order Breakdown',
                style: AppText.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${2 + snacks.length} items',
                style: AppText.bodySmall.copyWith(
                  fontSize: 9,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _OrderRow(
            title: '2x VIP Ultra Recliner Seats',
            subtitle: 'Seats ${widget.seats.join(', ')} (\$29.50 each)',
            price: _tickets,
          ),
          const _OrderRow(
            title: 'IMAX Laser 70mm Surcharge',
            subtitle: 'Dual 4K Laser Projection',
            price: _formatSurcharge,
          ),
          ...snacks.map((entry) {
            final item = state.itemById(entry.key);
            if (item == null) return const SizedBox.shrink();
            final size = state.sizeOf(entry.key);
            final price = (size?.price ?? item.price) * entry.value;
            return _OrderRow(
              title: '${entry.value}x ${item.name}',
              subtitle: size == null
                  ? item.description
                  : '${size.label} • ${item.flavours.isEmpty ? item.section : item.flavours}',
              price: price,
              perkLabel: item.id == 'artisanal-popcorn' ? '-\$2.00 Perk' : null,
            );
          }),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _FeeRow(
                  label: 'CineGo Stored Wallet Balance',
                  value: _walletApplied == 0
                      ? '\$0.00'
                      : '-\$${_walletCredit.toStringAsFixed(2)}',
                  highlight: _walletApplied > 0,
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Convenience & Service Fee',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      '\$3.00',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.outline,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryContainer,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'FREE (GOLD)',
                        style: AppText.labelCaps.copyWith(
                          fontSize: 5.5,
                          color: AppColors.onTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                _FeeRow(
                  label: 'Estimated State Tax & Surcharge',
                  value: '\$${_tax.toStringAsFixed(2)}',
                ),
                if (_promoDiscount > 0) ...[
                  const SizedBox(height: 7),
                  _FeeRow(
                    label: 'Promo discount',
                    value: '-\$${_promoDiscount.toStringAsFixed(2)}',
                    highlight: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromo() {
    return AppCard(
      radius: 18,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _promoOpen = !_promoOpen),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(
                    Icons.loyalty_outlined,
                    size: 18,
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add Promo Code or Gift Card',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _promoOpen
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 19,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_promoOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.only(left: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              textCapitalization: TextCapitalization.characters,
                              style: AppText.monoSmall.copyWith(
                                color: AppColors.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'ENTER CODE (E.G. SPICE20)',
                                hintStyle: AppText.monoSmall.copyWith(
                                  fontSize: 9,
                                  color: AppColors.outlineVariant,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _applyPromo,
                            child: Container(
                              height: 34,
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Center(
                                child: Text(
                                  'APPLY',
                                  style: AppText.labelCaps.copyWith(
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildWallet(AppState state) {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'CineGo Stored Wallet',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (state.walletApplied)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'APPLIED',
                          style: AppText.labelCaps.copyWith(
                            fontSize: 5.5,
                            color: AppColors.onTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  state.walletApplied
                      ? '-\$34.50 applied • Remaining: \$0.00'
                      : 'Balance available: \$34.50',
                  style: AppText.monoSmall.copyWith(
                    fontSize: 8.5,
                    color: state.walletApplied
                        ? AppColors.tertiary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: state.walletApplied,
            onChanged: (value) {
              state.setWalletApplied(value);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Select Payment Method',
              style: AppText.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              'ONE-TAP READY',
              style: AppText.labelCaps.copyWith(
                fontSize: 7,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        _PaymentTile(
          icon: Icons.phone_iphone_rounded,
          title: 'Apple Pay',
          subtitle:
              'Pays remaining \$${_grandTotal.toStringAsFixed(2)} • Instant Face ID',
          badge: 'DEFAULT',
          selected: _paymentMethod == 0,
          onTap: () => setState(() => _paymentMethod = 0),
        ),
        const SizedBox(height: 8),
        _PaymentTile(
          icon: Icons.credit_card_rounded,
          title: 'Mastercard •••• 4821',
          subtitle: 'Exp 09/27 • Apple Card Titanium',
          selected: _paymentMethod == 1,
          iconColor: AppColors.secondary,
          onTap: () => setState(() => _paymentMethod = 1),
        ),
        const SizedBox(height: 8),
        _PaymentTile(
          icon: Icons.account_balance_rounded,
          title: 'PayPal / Pay in 4',
          subtitle:
              '4 interest-free payments of \$${(_grandTotal / 4).toStringAsFixed(2)}',
          selected: _paymentMethod == 2,
          iconColor: AppColors.tertiary,
          onTap: () => setState(() => _paymentMethod = 2),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => showCineSnack(
            context,
            'Adding new cards is outside this demo.',
            icon: Icons.add_card_rounded,
          ),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle_outline_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  'Add New Debit or Credit Card',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContact() {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Ticket Delivery & Contact',
                style: AppText.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => showCineSnack(
                  context,
                  'Contact editing is not part of this demo.',
                  icon: Icons.edit_outlined,
                ),
                child: Text(
                  'EDIT',
                  style: AppText.labelCaps.copyWith(
                    fontSize: 7,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 17,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alex Chen',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'alex.chen@example.com',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '+1 (415) 555-0192',
                      style: AppText.monoSmall.copyWith(
                        fontSize: 8,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _smsOptIn,
                    onChanged: (value) =>
                        setState(() => _smsOptIn = value ?? false),
                    side: const BorderSide(color: AppColors.outlineVariant),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Send SMS theater entrance pass, auditorium gate barcode & parking validation alert.',
                    style: AppText.bodySmall.copyWith(
                      fontSize: 8.5,
                      height: 1.4,
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

  Widget _buildAuditorium() {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.surfaceHighest,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_activity_outlined,
              size: 18,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.showtime.auditorium} • IMAX',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Doors open 20 mins prior (4:25 PM)',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 8.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'GATE B',
              style: AppText.labelFormat.copyWith(
                fontSize: 8,
                color: AppColors.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayBar() {
    final buttonLabel = _paying
        ? 'Authorizing Secure Payment…'
        : _paymentMethod == 2
            ? 'Pay \$${_grandTotal.toStringAsFixed(2)} with PayPal'
            : _paymentMethod == 1
                ? 'Pay \$${_grandTotal.toStringAsFixed(2)} with •• 4821'
                : 'Pay \$${_grandTotal.toStringAsFixed(2)} with Apple Pay';

    const subtotalBase = 96.10;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withOpacity(0.98),
        border: const Border(top: BorderSide(color: AppColors.white10)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xCC000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GRAND TOTAL',
                          style: AppText.labelCaps.copyWith(
                            fontSize: 7.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${_grandTotal.toStringAsFixed(2)}',
                              style: AppText.displayHeroMobile.copyWith(
                                fontSize: 27,
                                height: 1,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            if (_walletApplied > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '(-\$34.50 Wallet)',
                                  style: AppText.bodySmall.copyWith(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.tertiary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${subtotalBase.toStringAsFixed(2)}',
                        style: AppText.monoSmall.copyWith(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'TOTAL SAVED \$${_totalSaved.toStringAsFixed(2)}',
                          style: AppText.labelCaps.copyWith(
                            fontSize: 5.5,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 7),
              PrimaryButton(
                label: buttonLabel,
                height: 52,
                icon: _paying ? Icons.hourglass_top_rounded : Icons.lock_rounded,
                fontSize: 13,
                onTap: _paying ? null : _pay,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.published_with_changes_rounded,
                    size: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Free cancellation up to 60 min before showtime',
                    style: AppText.bodySmall.copyWith(
                      fontSize: 8,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.title,
    required this.subtitle,
    required this.price,
    this.perkLabel,
  });

  final String title;
  final String subtitle;
  final double price;
  final String? perkLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: AppText.monoSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              if (perkLabel != null)
                Text(
                  perkLabel!,
                  style: AppText.labelCaps.copyWith(
                    fontSize: 6.5,
                    color: AppColors.tertiary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppText.bodySmall.copyWith(
              fontSize: 9,
              color: highlight ? AppColors.tertiary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: AppText.monoSmall.copyWith(
            fontSize: 9.5,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
            color: highlight ? AppColors.tertiary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
    this.iconColor = AppColors.onSurface,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;
  final Color iconColor;

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
                ? AppColors.primaryContainer.withOpacity(0.5)
                : AppColors.white06,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.surfaceLowest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 9),
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
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            badge!,
                            style: AppText.labelCaps.copyWith(
                              fontSize: 5.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
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
            const SizedBox(width: 6),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryContainer
                    : AppColors.surfaceHighest,
                shape: BoxShape.circle,
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
