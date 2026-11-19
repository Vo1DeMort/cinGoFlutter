import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CineGoWordmark extends StatelessWidget {
  const CineGoWordmark({
    super.key,
    this.fontSize = 21,
    this.showMark = true,
  });

  final double fontSize;
  final bool showMark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMark) ...[
          Container(
            width: fontSize * 1.5,
            height: fontSize * 1.5,
            decoration: BoxDecoration(
              gradient: AppColors.cyanGradient,
              borderRadius: BorderRadius.circular(fontSize * 0.45),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.local_movies_rounded,
              size: fontSize * 0.86,
              color: Colors.white,
            ),
          ),
          SizedBox(width: fontSize * 0.34),
        ],
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Cine',
                style: TextStyle(color: AppColors.onSurface, fontSize: fontSize),
              ),
              TextSpan(
                text: 'Go',
                style: TextStyle(color: AppColors.tertiary, fontSize: fontSize),
              ),
            ],
          ),
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            height: 1,
          ),
        ),
      ],
    );
  }
}
