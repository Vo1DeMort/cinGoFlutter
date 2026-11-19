import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';
import '../data/mock_data.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/movie_cards.dart';
import '../widgets/ui_kit.dart';
import 'movie_details_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _genres = [
    'ALL',
    'ACTION',
    'SCI-FI',
    'THRILLER',
    'DRAMA',
    'COMEDY',
  ];
  String _selectedGenre = 'ALL';
  final Set<String> _reminders = <String>{};

  List<Movie> get _nowShowing {
    if (_selectedGenre == 'ALL') return MockData.nowShowing;
    return MockData.nowShowing.where((movie) {
      return movie.genres.any(
        (genre) => genre.toUpperCase().contains(_selectedGenre),
      );
    }).toList();
  }

  void _openMovie(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MovieDetailsScreen(movie: movie)),
    );
  }

  void _selectTab(int index) {
    ref.read(appStateProvider).selectTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RootHeader(
          onLocationTap: () => _selectTab(2),
          onAvatarTap: () => _selectTab(4),
          onNotificationTap: () => showCineSnack(
            context,
            'No new notifications — you are all caught up.',
            icon: Icons.notifications_active_outlined,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 116),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: SearchField(
                    onChanged: (_) {},
                    onFilter: () => _selectTab(1),
                    hint: 'Search movies, cinemas, genre',
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _genres.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final genre = _genres[index];
                      return FilterChipPill(
                        label: genre,
                        selected: _selectedGenre == genre,
                        onTap: () => setState(() => _selectedGenre = genre),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _HeroCard(
                    movie: MockData.dune,
                    onTap: () => _openMovie(MockData.dune),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Now Showing',
                    trailingLabel: 'SEE ALL',
                    onTrailingTap: () => _selectTab(1),
                    trailingWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '14 IN THEATERS',
                            style: AppText.labelCaps.copyWith(
                              fontSize: 7.5,
                              color: AppColors.tertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _selectTab(1),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SEE ALL',
                                style: AppText.labelCaps.copyWith(
                                  fontSize: 9,
                                  color: AppColors.tertiary,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: AppColors.tertiary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 382,
                  child: _nowShowing.isEmpty
                      ? _EmptyGenreState(genre: _selectedGenre)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: _nowShowing.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final movie = _nowShowing[index];
                            return PosterCard(
                              movie: movie,
                              width: 176,
                              format: index.isEven ? 'DOLBY' : 'IMAX 3D',
                              onTap: () => _openMovie(movie),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 22),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _DolbyPromoCard(),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Coming Soon',
                    trailingLabel: 'SEE ALL',
                    trailingColor: AppColors.secondary,
                    onTrailingTap: () {
                      _selectTab(1);
                    },
                    trailingWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withValues(
                              alpha: 0.35,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PRE-BOOK',
                            style: AppText.labelCaps.copyWith(
                              fontSize: 7.5,
                              color: AppColors.secondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _selectTab(1),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SEE ALL',
                                style: AppText.labelCaps.copyWith(
                                  fontSize: 9,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 360,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: MockData.comingSoon.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final movie = MockData.comingSoon[index];
                      return ComingSoonCard(
                        movie: movie,
                        reminderSet: _reminders.contains(movie.id),
                        onReminder: () {
                          setState(() {
                            if (!_reminders.add(movie.id)) {
                              _reminders.remove(movie.id);
                            }
                          });
                          showCineSnack(
                            context,
                            _reminders.contains(movie.id)
                                ? 'Reminder set for ${movie.title}.'
                                : 'Reminder removed.',
                            icon: Icons.notifications_active_outlined,
                          );
                        },
                        onTap: () => _openMovie(movie),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.movie, required this.onTap});

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 390,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.white10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 30,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/dune_hero.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.15),
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: AppColors.surfaceHigh),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.heroScrim),
              ),
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  children: [
                    const FormatTag('IMAX 70MM', icon: Icons.theaters_outlined),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLowest.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: AppColors.amber,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: AppText.labelFormat.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ' /10',
                            style: AppText.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _heroMeta(movie.genres.first.toUpperCase()),
                        const SizedBox(width: 14),
                        _heroMeta(movie.genres.last.toUpperCase()),
                        const SizedBox(width: 14),
                        _heroMeta(movie.runtimeLabel.toUpperCase()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.title,
                      style: AppText.displayHeroMobile.copyWith(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movie.synopsis,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 11.5,
                        height: 1.45,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Book Tickets',
                            icon: Icons.confirmation_number_outlined,
                            height: 48,
                            fontSize: 14,
                            onTap: onTap,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => showCineSnack(
                            context,
                            'Trailer playback is not part of this demo.',
                            icon: Icons.play_circle_outline_rounded,
                          ),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white12),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26,
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
      ),
    );
  }

  Widget _heroMeta(String text) {
    return Text(
      text,
      style: AppText.labelCaps.copyWith(
        fontSize: 8.5,
        color: Colors.white.withValues(alpha: 0.92),
        letterSpacing: 0.7,
      ),
    );
  }
}

class _DolbyPromoCard extends StatelessWidget {
  const _DolbyPromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF201640), Color(0xFF111A33), Color(0xFF0B1526)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -30,
            top: -40,
            child: GlowOrb(color: AppColors.secondary, size: 170, opacity: 0.2),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const FormatTag(
                            'DOLBY ATMOS',
                            color: AppColors.tertiary,
                            compact: true,
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(
                                alpha: 0.18,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'IMAX LASER',
                              style: AppText.labelCaps.copyWith(
                                fontSize: 7.5,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Feel Every Frequency',
                        style: AppText.headlineSmall.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Experience next-gen cinema with 64-channel spatial sound and dual 4K laser.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodySmall.copyWith(
                          fontSize: 10.5,
                          height: 1.4,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceLowest.withValues(alpha: 0.5),
                    border: Border.all(
                      color: AppColors.tertiary.withValues(alpha: 0.45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.tertiary.withValues(alpha: 0.18),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.speaker_rounded,
                    color: AppColors.tertiary,
                    size: 28,
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

class _EmptyGenreState extends StatelessWidget {
  const _EmptyGenreState({required this.genre});

  final String genre;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.movie_filter_outlined,
            color: AppColors.outline,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'No $genre titles showing right now.',
            style: AppText.bodySmall.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}
