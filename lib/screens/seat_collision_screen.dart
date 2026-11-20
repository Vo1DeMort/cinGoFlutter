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
import 'seat_selection_screen.dart';

/// Recovery surface shown when a held seat is claimed by another customer.
class SeatCollisionScreen extends ConsumerWidget {
  const SeatCollisionScreen({
    super.key,
    required this.movie,
    required this.showtime,
    required this.seats,
    this.holdLabel = '09:40',
  });

  final Movie movie;
  final SelectedShowtime showtime;
  final List<String> seats;
  final String holdLabel;

  String get _seatLabel => seats.join(' & ');

  double get _total => seats.length * 29.50;

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

  void _openSeatMap(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SeatSelectionScreen(
          movie: movie,
          showtime: showtime,
          initialSeats: const [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          SubPageHeader(
            title: 'Seat Collision Detected',
            subtitle:
                '${movie.title} • ${showtime.auditorium} • '
                'Seats ${seats.join(', ')}',
            trailing: TimerChip(label: holdLabel, icon: Icons.timer_outlined),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [
                const Center(
                  child: GlowIconOrb(
                    icon: Icons.sync_problem_rounded,
                    color: AppColors.error,
                    size: 84,
                    badgeIcon: Icons.close_rounded,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusPill(
                      label: 'Seat Collision Detected',
                      color: AppColors.error,
                      filled: true,
                    ),
                    SizedBox(width: 6),
                    StatusPill(
                      label: '120ms Sync Lock',
                      icon: Icons.bolt_rounded,
                      color: AppColors.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Seats $_seatLabel Were Just Taken',
                  textAlign: TextAlign.center,
                  style: AppText.headlineMedium.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text.rich(
                  TextSpan(
                    text:
                        'Your seat hold elapsed and another moviegoer '
                        'completed checkout for these exact seats milliseconds '
                        'prior. ',
                    children: [
                      TextSpan(
                        text: 'No payment was charged',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text:
                            ', and your selected snacks are safely preserved '
                            'below.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    height: 1.55,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                _buildMiniMap(),
                const SizedBox(height: 18),
                const SectionHeader(
                  title: '1-Tap Quick Fix Options',
                  trailingLabel: 'Fast Re-Lock',
                ),
                const SizedBox(height: 8),
                _buildBestMatch(context),
                const SizedBox(height: 10),
                _buildSameRow(context),
                const SizedBox(height: 10),
                _buildNextShowtime(context),
                const SizedBox(height: 14),
                _buildSnackHold(state),
                const SizedBox(height: 10),
                _buildGoldNotice(),
                const SizedBox(height: 16),
                SecondaryButton(
                  label: 'Open Full Seating Map',
                  icon: Icons.grid_view_rounded,
                  onTap: () => _openSeatMap(context),
                ),
                const SizedBox(height: 8),
                SecondaryButton(
                  label: 'Explore Other Theaters & Showtimes',
                  icon: Icons.calendar_month_rounded,
                  onTap: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => showCineSnack(
                    context,
                    'Live Cinema Concierge is not part of this demo.',
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
                        'Need urgent help? Live Cinema Concierge available',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          color: AppColors.outline,
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

  Widget _buildMiniMap() {
    const rows = ['D', 'E', 'F'];
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white06),
      ),
      child: Column(
        children: [
          Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.tertiary.withValues(alpha: 0.9),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tertiary.withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'IMAX LASER 70MM SCREEN',
            style: AppText.labelFormat.copyWith(
              fontSize: 7.5,
              color: AppColors.tertiary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 12,
                    child: Text(
                      row,
                      style: AppText.labelFormat.copyWith(
                        fontSize: 8,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 1; i <= 8; i++) ...[
                          _miniSeat(row, i),
                          if (i != 8) const SizedBox(width: 4),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 12,
                    child: Text(
                      row,
                      textAlign: TextAlign.right,
                      style: AppText.labelFormat.copyWith(
                        fontSize: 8,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.error, 'Taken $_seatLabel'),
              const SizedBox(width: 12),
              _legendDot(AppColors.primaryContainer, 'Row F Match'),
              const SizedBox(width: 12),
              _legendDot(AppColors.secondary, 'Row E Match'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniSeat(String row, int number) {
    final seat = '$row$number';
    final isCollision = seats.contains(seat);
    final isRowF = row == 'F' && (number == 5 || number == 6) && !isCollision;
    final isRowE = row == 'E' && (number == 7 || number == 8);
    final isTaken =
        !isCollision && ((row == 'E' && (number == 3 || number == 4)));

    Color background = AppColors.surfaceHigh;
    Color? foreground;
    if (isTaken) {
      background = AppColors.surfaceLowest.withValues(alpha: 0.5);
      foreground = AppColors.outline.withValues(alpha: 0.55);
    } else if (isCollision) {
      background = AppColors.errorContainer;
      foreground = Colors.white;
    } else if (isRowF) {
      background = AppColors.primaryContainer;
      foreground = Colors.white;
    } else if (isRowE) {
      background = AppColors.secondaryContainer;
      foreground = Colors.white;
    }

    return Container(
      width: 20,
      height: 17,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isCollision
              ? AppColors.error.withValues(alpha: 0.6)
              : Colors.transparent,
        ),
        boxShadow: isCollision || isRowF
            ? [
                BoxShadow(
                  color:
                      (isCollision
                              ? AppColors.error
                              : AppColors.primaryContainer)
                          .withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: foreground == null
          ? null
          : isTaken || isCollision
          ? Icon(Icons.close_rounded, size: 9, color: foreground)
          : Text(
              '$number',
              style: AppText.labelFormat.copyWith(
                fontSize: 7,
                color: foreground,
              ),
            ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppText.bodySmall.copyWith(
            fontSize: 7.5,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBestMatch(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryContainer.withValues(alpha: 0.24),
            AppColors.surfaceLow,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: StatusPill(
                  label: '★ Best Match • Directly Behind',
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  filled: true,
                  fontSize: 7,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${_total.toStringAsFixed(2)}',
                    style: AppText.headlineSmall.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${seats.length} ${seats.length == 1 ? 'Seat' : 'Seats'}',
                    style: AppText.bodySmall.copyWith(
                      fontSize: 8,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Seats ${_alternateSeats().join(' & ')} (Row F Center)',
            style: AppText.headlineSmall.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Same center vantage • Premium eye-level tilt • Identical '
            '\$${_total.toStringAsFixed(2)} total',
            style: AppText.bodySmall.copyWith(
              fontSize: 9,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Quick-Lock Seats ${_alternateSeats().join(' & ')}',
            icon: Icons.lock_reset_rounded,
            height: 48,
            fontSize: 12,
            onTap: () => _lockSeats(context, _alternateSeats()),
          ),
        ],
      ),
    );
  }

  Widget _buildSameRow(BuildContext context) {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StatusPill(
                label: 'Same Row E • 2 Seats Right',
                color: AppColors.secondary,
                filled: true,
                fontSize: 7,
              ),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Switch to Seats E7 & E8',
            style: AppText.headlineSmall.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Unobstructed screen sightline • Same elevation • '
            '\$${_total.toStringAsFixed(2)}',
            style: AppText.bodySmall.copyWith(
              fontSize: 9,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Hold Seats E7 & E8',
            height: 44,
            fontSize: 11.5,
            onTap: () => _lockSeats(context, const ['E7', 'E8']),
          ),
        ],
      ),
    );
  }

  Widget _buildNextShowtime(BuildContext context) {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StatusPill(
                label: 'Tonight • Next Showtime',
                color: AppColors.tertiary,
                filled: true,
                fontSize: 7,
              ),
              const Spacer(),
              Text(
                '8:15 PM',
                style: AppText.labelFormat.copyWith(
                  fontSize: 9.5,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Move to 8:15 PM ${showtime.format}',
            style: AppText.headlineSmall.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Same ${showtime.cinema.split(' & ').first} ${showtime.auditorium} '
            '• 18 Center Prime seats still wide open',
            style: AppText.bodySmall.copyWith(
              fontSize: 9,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pre-orders transfer automatically',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 9,
                    color: AppColors.outline,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _nextShowtime(context),
                child: Row(
                  children: [
                    Text(
                      'View 8:15 PM',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnackHold(AppState state) {
    final hasSnacks = state.cartCount > 0;
    return AppCard(
      radius: 16,
      padding: const EdgeInsets.all(12),
      child: Row(
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
              Icons.fastfood_outlined,
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
                  'Snacks Cart Held Safe',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  hasSnacks
                      ? '${state.cartCount} × treats • '
                            '\$${state.cartTotal.toStringAsFixed(2)} preserved'
                      : 'No snacks in cart — add treats at checkout.',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 8.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(
            label: holdLabel == '00:00' ? 'Saved' : holdLabel,
            icon: Icons.lock_outline_rounded,
            color: AppColors.tertiary,
            fontSize: 7,
          ),
        ],
      ),
    );
  }

  Widget _buildGoldNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white06),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 16,
            color: AppColors.tertiary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'CinePass Gold Active: ',
                children: [
                  TextSpan(
                    text:
                        'Your 1-tap replacement reservation skips '
                        're-verification queues.',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 9,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _alternateSeats() {
    final first = seats.firstWhere(
      (seat) => seat.isNotEmpty,
      orElse: () => 'E5',
    );
    final letter = String.fromCharCode(first.codeUnitAt(0) + 1);
    return ['${letter}5', '${letter}6'];
  }
}
