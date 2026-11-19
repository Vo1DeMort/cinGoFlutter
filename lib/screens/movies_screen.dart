import 'package:flutter/material.dart';
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

class MoviesScreen extends ConsumerStatefulWidget {
  const MoviesScreen({super.key});

  @override
  ConsumerState<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends ConsumerState<MoviesScreen> {
  final TextEditingController _searchController = TextEditingController();
  static const _genres = ['ALL', 'ACTION', 'SCI-FI', 'DRAMA', 'COMEDY', 'HORROR'];
  static const _sorts = ['Highest Rated', 'Newest', 'A → Z'];

  int _tab = 0;
  String _genre = 'ALL';
  String _sort = 'Highest Rated';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Movie> get _results {
    final source = _tab == 0 ? MockData.nowShowing : MockData.comingSoon;
    var list = source.where((movie) {
      final matchesGenre = _genre == 'ALL' ||
          movie.genres.any((g) => g.toUpperCase().contains(_genre));
      final matchesQuery = _query.isEmpty ||
          movie.title.toLowerCase().contains(_query.toLowerCase()) ||
          movie.genres.any(
            (g) => g.toLowerCase().contains(_query.toLowerCase()),
          );
      return matchesGenre && matchesQuery;
    }).toList();

    switch (_sort) {
      case 'Newest':
        list = list.reversed.toList();
        break;
      case 'A → Z':
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      default:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  void _openMovie(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MovieDetailsScreen(movie: movie),
      ),
    );
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: const BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: AppColors.white10),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Refine results', style: AppText.headlineSmall),
                    const SizedBox(height: 16),
                    Text(
                      'GENRE',
                      style: AppText.labelCaps.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _genres
                          .map(
                            (genre) => FilterChipPill(
                              label: genre,
                              selected: _genre == genre,
                              onTap: () {
                                setSheetState(() => _genre = genre);
                                setState(() {});
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'SORT BY',
                      style: AppText.labelCaps.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sorts
                          .map(
                            (sort) => FilterChipPill(
                              label: sort,
                              selected: _sort == sort,
                              onTap: () {
                                setSheetState(() => _sort = sort);
                                setState(() {});
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: 'Show ${_results.length} results',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
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
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                sliver: SliverList.list(
                  children: [
                    SearchField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      onFilter: _openFilters,
                      hint: 'Search movies, cinemas, genre',
                      height: 48,
                    ),
                    const SizedBox(height: 14),
                    SegmentedPills(
                      labels: const ['Now Showing', 'Coming Soon'],
                      counts: [
                        MockData.nowShowing.length,
                        MockData.comingSoon.length,
                      ],
                      selectedIndex: _tab,
                      onChanged: (index) => setState(() => _tab = index),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _genres.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final genre = _genres[index];
                          return FilterChipPill(
                            label: genre,
                            selected: _genre == genre,
                            onTap: () => setState(() => _genre = genre),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          size: 14,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'FORMAT: IMAX / 3D / 2D',
                          style: AppText.labelCaps.copyWith(
                            fontSize: 8,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _openFilters,
                          child: Row(
                            children: [
                              Text(
                                'SORT: ${_sort.toUpperCase()}',
                                style: AppText.labelCaps.copyWith(
                                  fontSize: 8,
                                  color: AppColors.tertiary,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 15,
                                color: AppColors.tertiary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              if (results.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 42,
                            color: AppColors.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No films match your filters',
                            style: AppText.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try another genre or clear your search.',
                            style: AppText.bodySmall.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SecondaryButton(
                            label: 'Reset filters',
                            expanded: false,
                            icon: Icons.restart_alt_rounded,
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _genre = 'ALL';
                                _sort = 'Highest Rated';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth =
                          (constraints.crossAxisExtent - 14) / 2;
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 20,
                          mainAxisExtent: cardWidth * 1.5 + 104,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final movie = results[index];
                            return BrowseMovieCard(
                              movie: movie,
                              format: movie.comingSoon
                                  ? 'DOLBY'
                                  : (index.isEven ? 'IMAX' : 'DOLBY'),
                              onTap: () => _openMovie(movie),
                            );
                          },
                          childCount: results.length,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
