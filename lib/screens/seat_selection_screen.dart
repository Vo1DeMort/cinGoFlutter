import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../models/movie.dart';
import '../models/showtime.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/ui_kit.dart';
import 'snacks_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({
    super.key,
    required this.movie,
    required this.showtime,
  });

  final Movie movie;
  final SelectedShowtime showtime;

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  static const _rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  static const _taken = <String>{
    'A3',
    'A4',
    'A7',
    'B9',
    'B10',
    'C3',
    'C8',
    'D3',
    'D4',
    'E3',
    'E4',
    'E9',
    'E10',
    'F6',
    'F9',
    'F10',
    'G5',
    'G6',
  };

  final Set<String> _selected = {'E5', 'E6'};
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = 9 * 60 + 40;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _total {
    double total = 0;
    for (final seat in _selected) {
      total += seat.startsWith('E') || seat.startsWith('F') ? 29.50 : 24.50;
    }
    return total;
  }

  int get _vipCount => _selected
      .where((seat) => seat.startsWith('E') || seat.startsWith('F'))
      .length;

  void _toggleSeat(String seat) {
    setState(() {
      if (_selected.contains(seat)) {
        _selected.remove(seat);
      } else {
        if (_selected.length >= 6) {
          showCineSnack(
            context,
            'You can choose up to 6 seats per booking.',
            icon: Icons.event_seat_outlined,
          );
          return;
        }
        _selected.add(seat);
      }
    });
  }

  void _proceed() {
    if (_selected.isEmpty) {
      showCineSnack(
        context,
        'Choose at least one seat to continue.',
        icon: Icons.event_seat_outlined,
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SnacksScreen(
          movie: widget.movie,
          showtime: widget.showtime,
          seats: _selected.toList()..sort(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          SubPageHeader(
            title: 'Seat Selection',
            subtitle:
                '${widget.showtime.cinema.split(' & ').first} • ${widget.showtime.day}, ${widget.showtime.time}',
            trailing: TimerChip(label: _timerLabel),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        const FormatTag(
                          'IMAX 70MM',
                          icon: Icons.theaters_outlined,
                          compact: true,
                        ),
                        const SizedBox(width: 7),
                        const FormatTag(
                          '12-CH ATMOS',
                          icon: Icons.surround_sound_outlined,
                          color: AppColors.secondary,
                          compact: true,
                        ),
                        const Spacer(),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.showtime.auditorium,
                          style: AppText.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 92, child: _ScreenArc()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.white06),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _LegendItem(
                            label: 'Available',
                            swatch: _Swatch.available,
                          ),
                          _legendSeparator(),
                          const _LegendItem(
                            label: 'Taken',
                            swatch: _Swatch.taken,
                          ),
                          _legendSeparator(),
                          const _LegendItem(
                            label: 'Selected',
                            swatch: _Swatch.selected,
                          ),
                          _legendSeparator(),
                          const _LegendItem(
                            label: 'VIP Pod',
                            swatch: _Swatch.vip,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _buildSeatMap(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildVipCard(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildSummaryBar(),
    );
  }

  Widget _legendSeparator() {
    return Container(width: 1, height: 12, color: AppColors.white10);
  }

  Widget _buildSeatMap() {
    return Column(
      children: [
        for (final row in _rows) ...[
          _buildRow(row),
          if (row == 'D') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.white10)),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 10,
                        color: AppColors.tertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'OPTIMAL SIGHTLINE',
                        style: AppText.labelCaps.copyWith(
                          fontSize: 7,
                          color: AppColors.tertiary,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.white10)),
              ],
            ),
            const SizedBox(height: 10),
          ] else
            const SizedBox(height: 6),
        ],
      ],
    );
  }

  Widget _buildRow(String row) {
    final isVipRow = row == 'E' || row == 'F';
    return SizedBox(
      height: isVipRow ? 32 : 28,
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: Text(
              row,
              style: AppText.labelFormat.copyWith(
                fontSize: 10,
                color: isVipRow ? AppColors.tertiary : AppColors.outline,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bank(row, 1, 2, isVipRow),
                const SizedBox(width: 10),
                _bank(row, 3, 8, isVipRow),
                const SizedBox(width: 10),
                _bank(row, 9, 10, isVipRow),
              ],
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 14,
            child: Text(
              row,
              textAlign: TextAlign.right,
              style: AppText.labelFormat.copyWith(
                fontSize: 10,
                color: isVipRow ? AppColors.tertiary : AppColors.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bank(String row, int start, int end, bool isVipRow) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = start; i <= end; i++) ...[
          _buildSeat('$row$i', isVipRow),
          if (i != end) const SizedBox(width: 4),
        ],
      ],
    );
  }

  Widget _buildSeat(String seat, bool isVip) {
    final taken = _taken.contains(seat);
    final selected = _selected.contains(seat);
    final size = isVip ? 25.0 : 22.0;
    final radius = isVip ? 7.0 : 4.5;

    return GestureDetector(
      key: ValueKey('seat-$seat'),
      onTap: taken ? null : () => _toggleSeat(seat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: isVip ? size : size - 2,
        decoration: BoxDecoration(
          gradient: selected ? AppColors.cyanGradient : null,
          color: selected
              ? null
              : taken
              ? AppColors.surfaceLowest.withValues(alpha: 0.45)
              : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : isVip && !taken
                ? AppColors.tertiary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.9),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: taken
            ? Icon(
                Icons.close_rounded,
                size: isVip ? 12 : 10,
                color: AppColors.outline.withValues(alpha: 0.6),
              )
            : selected
            ? Icon(
                Icons.check_rounded,
                size: isVip ? 15 : 13,
                color: Colors.white,
              )
            : isVip
            ? const Icon(
                Icons.chair_outlined,
                size: 12,
                color: AppColors.tertiary,
              )
            : null,
      ),
    );
  }

  Widget _buildVipCard() {
    final hasVip = _vipCount > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white06),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0x334D8EFF), Color(0x2247D6FF)],
              ),
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.airline_seat_recline_extra_rounded,
              color: AppColors.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'VIP Ultra Recliner',
                        style: AppText.bodyMedium.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (hasVip) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SELECTED',
                          style: AppText.labelCaps.copyWith(
                            fontSize: 6.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Full 180° recline, heated seating & swivel table',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 9.5,
                    color: AppColors.outline,
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
                '\$29.50',
                style: AppText.headlineSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '/ seat',
                style: AppText.bodySmall.copyWith(
                  fontSize: 8,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    final seats = _selected.toList()..sort();
    final label = seats.isEmpty
        ? 'No seats chosen'
        : 'Seats: ${seats.join(', ')}';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.98),
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
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 13,
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Seats held for: ',
                    style: AppText.bodySmall.copyWith(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
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
                  const Icon(
                    Icons.settings_outlined,
                    size: 12,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Instant E-Ticket',
                    style: AppText.bodySmall.copyWith(
                      fontSize: 9.5,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.bodyMedium.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${seats.length} ${seats.length == 1 ? 'Seat' : 'Seats'}',
                              style: AppText.bodySmall.copyWith(
                                fontSize: 9.5,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${_total.toStringAsFixed(2)}',
                              style: AppText.displayHeroMobile.copyWith(
                                fontSize: 28,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Text(
                                _selected.isEmpty
                                    ? ''
                                    : '(\$29.50 × ${_selected.length})',
                                style: AppText.bodySmall.copyWith(
                                  fontSize: 9,
                                  color: AppColors.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 158,
                    child: PrimaryButton(
                      label: 'Proceed',
                      trailingIcon: Icons.arrow_forward_rounded,
                      height: 54,
                      onTap: _proceed,
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

enum _Swatch { available, taken, selected, vip }

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.swatch});

  final String label;
  final _Swatch swatch;

  @override
  Widget build(BuildContext context) {
    Widget box;
    switch (swatch) {
      case _Swatch.available:
        box = Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(3),
          ),
        );
        break;
      case _Swatch.taken:
        box = Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.surfaceLowest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 9,
            color: AppColors.outline.withValues(alpha: 0.6),
          ),
        );
        break;
      case _Swatch.selected:
        box = Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            gradient: AppColors.cyanGradient,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.6),
                blurRadius: 6,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
        );
        break;
      case _Swatch.vip:
        box = Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: AppColors.tertiary.withValues(alpha: 0.5),
            ),
          ),
          child: const Icon(
            Icons.star_rounded,
            size: 9,
            color: AppColors.tertiary,
          ),
        );
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        box,
        const SizedBox(width: 5),
        Text(
          label,
          style: AppText.bodySmall.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: switch (swatch) {
              _Swatch.selected => AppColors.primary,
              _Swatch.vip => AppColors.tertiary,
              _ => AppColors.onSurfaceVariant,
            },
          ),
        ),
      ],
    );
  }
}

class _ScreenArc extends StatelessWidget {
  const _ScreenArc();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 24,
          left: 30,
          right: 30,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(220),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryContainer.withValues(alpha: 0.3),
                  AppColors.tertiary.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  blurRadius: 30,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 22,
          left: 24,
          right: 24,
          child: CustomPaint(
            painter: _ArcPainter(),
            child: const SizedBox(width: double.infinity, height: 28),
          ),
        ),
        Positioned(
          top: 58,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.blur_on_rounded,
                size: 15,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 5),
              Text(
                'IMAX CURVED SCREEN',
                style: AppText.labelFormat.copyWith(
                  fontSize: 10,
                  color: AppColors.tertiary,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.tertiary,
          AppColors.primaryContainer,
          AppColors.tertiary,
          Colors.transparent,
        ],
        stops: [0, 0.2, 0.5, 0.8, 1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 8))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);

    final path = Path()
      ..moveTo(0, 8)
      ..quadraticBezierTo(size.width / 2, -18, size.width, 8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
