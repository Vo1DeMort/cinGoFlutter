import 'package:material_ui/material_ui.dart';

import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.movie,
    this.onTap,
    this.width = 176,
    this.format = 'DOLBY',
    this.showBookButton = true,
  });

  final Movie movie;
  final VoidCallback? onTap;
  final double width;
  final String format;
  final bool showBookButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      movie.poster,
                      fit: BoxFit.cover,
                      errorBuilder: _posterFallback,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.white10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          AppColors.surfaceLowest.withValues(alpha: 0.55),
                        ],
                        stops: const [0, 0.62, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLowest.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppColors.white10),
                      ),
                      child: Text(
                        movie.certificate,
                        style: AppText.labelCaps.copyWith(
                          fontSize: 8,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: RatingPill(
                      rating: movie.rating,
                      compact: true,
                      translucent: true,
                    ),
                  ),
                  Positioned(
                    left: 9,
                    bottom: 9,
                    child: FormatTag(format, compact: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          GestureDetector(
            onTap: onTap,
            child: Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${movie.genreLabel} • ${movie.runtimeLabel}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
            ),
          ),
          if (showBookButton) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              width: double.infinity,
              child: Material(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Center(
                    child: Text(
                      'Book',
                      style: AppText.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BrowseMovieCard extends StatelessWidget {
  const BrowseMovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.format = 'IMAX',
  });

  final Movie movie;
  final VoidCallback? onTap;
  final String format;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    movie.poster,
                    fit: BoxFit.cover,
                    errorBuilder: _posterFallback,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.white06),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.surfaceLowest.withValues(alpha: 0.7),
                      ],
                      stops: const [0, 0.7, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: RatingPill(
                    rating: movie.rating,
                    compact: true,
                    translucent: true,
                  ),
                ),
                if (movie.comingSoon)
                  Positioned(
                    top: 9,
                    left: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(
                          alpha: 0.9,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PRE-BOOK',
                        style: AppText.labelCaps.copyWith(
                          fontSize: 7.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 9,
                  bottom: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLowest,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.tertiary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      format,
                      style: AppText.labelFormat.copyWith(
                        fontSize: 9,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Text(
            movie.genreLabel.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.labelCaps.copyWith(
              fontSize: 8,
              color: AppColors.outline,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                movie.runtimeLabel,
                style: AppText.monoSmall.copyWith(
                  fontSize: 9,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 36,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.filmGradient,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onTap,
                child: Center(
                  child: Text(
                    'Book',
                    style: AppText.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComingSoonCard extends StatelessWidget {
  const ComingSoonCard({
    super.key,
    required this.movie,
    this.onTap,
    this.onReminder,
    this.width = 176,
    this.reminderSet = false,
  });

  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onReminder;
  final double width;
  final bool reminderSet;

  @override
  Widget build(BuildContext context) {
    final parts = (movie.releaseLabel ?? 'SOON').split(' ');
    final month = parts.length > 1 ? parts[0] : 'SOON';
    final day = parts.length > 1 ? parts[1] : '';
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    movie.poster,
                    fit: BoxFit.cover,
                    errorBuilder: _posterFallback,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.white10),
                  ),
                ),
                Positioned(
                  top: 9,
                  left: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLowest.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.white10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          month,
                          style: AppText.labelCaps.copyWith(
                            fontSize: 7,
                            color: AppColors.outline,
                          ),
                        ),
                        Text(
                          day,
                          style: AppText.headlineSmall.copyWith(
                            fontSize: 14,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: GestureDetector(
                    onTap: onReminder,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLowest.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white10),
                      ),
                      child: Icon(
                        reminderSet
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        size: 14,
                        color: reminderSet
                            ? AppColors.tertiary
                            : AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 16, 10, 9),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(18),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.surfaceLowest.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                    child: Text(
                      movie.genres.first.toUpperCase(),
                      style: AppText.labelCaps.copyWith(
                        fontSize: 8,
                        color: AppColors.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Dir. ${movie.director}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodySmall.copyWith(
              fontSize: 10.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            width: double.infinity,
            child: Material(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(999),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_circle_outline_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Trailer',
                      style: AppText.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _posterFallback(BuildContext context, Object error, StackTrace? stack) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.surfaceHigh, AppColors.surfaceContainer],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: const Center(
      child: Icon(
        Icons.movie_creation_outlined,
        color: AppColors.outline,
        size: 34,
      ),
    ),
  );
}
