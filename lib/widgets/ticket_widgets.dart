import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class QrView extends StatelessWidget {
  const QrView({
    super.key,
    this.size = 172,
    this.foreground = AppColors.surfaceLowest,
    this.background = const Color(0xFFF5F7FA),
    this.seed = 1,
  });

  final double size;
  final Color foreground;
  final Color background;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: CustomPaint(
        painter: _QrPainter(foreground: foreground, seed: seed),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter({required this.foreground, required this.seed});

  final Color foreground;
  final int seed;

  static const _modules = 25;

  bool _isFinder(int row, int col) {
    bool inBox(int r, int c, int top, int left) =>
        r >= top && r < top + 7 && c >= left && c < left + 7;
    if (inBox(row, col, 0, 0)) return true;
    if (inBox(row, col, 0, _modules - 7)) return true;
    if (inBox(row, col, _modules - 7, 0)) return true;
    return false;
  }

  bool _finderFilled(int row, int col) {
    int localR = 0;
    int localC = 0;
    if (row < 7) {
      localR = row;
      localC = col >= _modules - 7 ? col - (_modules - 7) : col;
    } else {
      localR = row - (_modules - 7);
      localC = col;
    }
    if (localR == 0 || localR == 6 || localC == 0 || localC == 6) {
      return true;
    }
    if (localR >= 2 && localR <= 4 && localC >= 2 && localC <= 4) {
      return true;
    }
    return false;
  }

  bool _separator(int row, int col) {
    bool band(int r, int c, int top, int left) =>
        r >= top && r < top + 8 && c >= left && c < left + 8;
    if (band(row, col, -1, -1) && row >= 0 && col >= 0) return true;
    if (band(row, col, -1, _modules - 7)) return true;
    if (band(row, col, _modules - 7, -1)) return true;
    return false;
  }

  bool _filled(int row, int col) {
    if (_isFinder(row, col)) return _finderFilled(row, col);
    if (_separator(row, col)) return false;
    final value = (row * 37 + col * 53 + row * col * 7 + seed * 11) % 11;
    return value < 5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final module = size.width / _modules;
    final paint = Paint()..color = foreground;
    for (var row = 0; row < _modules; row++) {
      for (var col = 0; col < _modules; col++) {
        if (!_filled(row, col)) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              col * module,
              row * module,
              module * 0.92,
              module * 0.92,
            ),
            Radius.circular(module * 0.18),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.foreground != foreground;
}

class MiniQrView extends StatelessWidget {
  const MiniQrView({super.key, this.size = 52, this.seed = 3});

  final double size;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return QrView(size: size, seed: seed, background: const Color(0xFFF0F3F8));
  }
}

class TicketDivider extends StatelessWidget {
  const TicketDivider({
    super.key,
    this.notchColor = AppColors.surface,
    this.lineColor = AppColors.white12,
    this.height = 22,
  });

  final Color notchColor;
  final Color lineColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          _notch(alignment: Alignment.centerLeft),
          Expanded(
            child: CustomPaint(
              painter: _DashedLinePainter(color: lineColor),
              child: const SizedBox(height: 1, width: double.infinity),
            ),
          ),
          _notch(alignment: Alignment.centerRight),
        ],
      ),
    );
  }

  Widget _notch({required Alignment alignment}) {
    return SizedBox(
      width: 18,
      height: height,
      child: Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(alignment == Alignment.centerLeft ? -9 : 9, 0),
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: notchColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    const dash = 6.0;
    const gap = 5.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(math.min(x + dash, size.width), size.height / 2),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class MiniStat extends StatelessWidget {
  const MiniStat({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppText.headlineSmall.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppText.labelCaps.copyWith(
            fontSize: 8,
            color: AppColors.outline,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
