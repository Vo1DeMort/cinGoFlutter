import 'package:material_ui/material_ui.dart';

import '../data/mock_data.dart';
import '../models/movie.dart';
import '../models/showtime.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';
import 'seat_selection_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  int _selectedDay = 0;
  int _formatFilter = 0;
  bool _expanded = false;
  bool _saved = false;
  SelectedShowtime? _selected;

  static const _formatFilters = ['All Formats', 'IMAX 70mm', 'Dolby Cinema'];

  @override
  void initState() {
    super.initState();
    final listing = MockData.homeShowtimes[0];
    _selected = SelectedShowtime(
      cinema: listing.name,
      format: 'IMAX 70MM',
      time: '4:45 PM',
      price: 24.50,
      day: 'Today',
      auditorium: 'Auditorium 1',
    );
  }

  void _selectShowtime(
    CinemaListing listing,
    ShowtimeFormat format,
    ShowtimeOption option,
  ) {
    if (!option.available) {
      showCineSnack(
        context,
        '${option.time} is unavailable — try another showtime.',
        icon: Icons.event_busy_outlined,
      );
      return;
    }
    setState(() {
      _selected = SelectedShowtime(
        cinema: listing.name,
        format: format.format,
        time: option.time,
        price: format.price,
        day: _selectedDay == 0 ? 'Today' : 'Fri, Oct 25',
        auditorium: listing.name.contains('Alamo')
            ? 'Theater 4'
            : 'Auditorium 1',
      );
    });
  }

  void _selectDay(int index) {
    setState(() {
      _selectedDay = index;
      if (_selected != null) {
        _selected = SelectedShowtime(
          cinema: _selected!.cinema,
          format: _selected!.format,
          time: _selected!.time,
          price: _selected!.price,
          day: index == 0 ? 'Today' : 'Sun, Oct 27',
          auditorium: _selected!.auditorium,
        );
      }
    });
  }

  void _openSeats() {
    final selected = _selected;
    if (selected == null) {
      showCineSnack(
        context,
        'Pick a showtime to choose your seats.',
        icon: Icons.event_seat_outlined,
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SeatSelectionScreen(movie: widget.movie, showtime: selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 116),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(movie),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCast(movie),
                        const SizedBox(height: 22),
                        _buildSynopsis(movie),
                        const SizedBox(height: 24),
                        _buildDateSection(),
                        const SizedBox(height: 16),
                        _buildFormatFilters(),
                        const SizedBox(height: 14),
                        ..._buildCinemas(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBookingBar(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.92),
        border: const Border(bottom: BorderSide(color: AppColors.white06)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 46,
            child: Row(
              children: [
                RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => showCineSnack(
                    context,
                    'Trailer playback is not part of this demo.',
                    icon: Icons.play_circle_outline_rounded,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLow,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 15,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Trailer',
                          style: AppText.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                RoundIconButton(
                  icon: Icons.ios_share_rounded,
                  iconSize: 17,
                  size: 38,
                  background: AppColors.surfaceContainer,
                  onTap: () => showCineSnack(
                    context,
                    'Share link copied to clipboard (demo).',
                    icon: Icons.ios_share_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                RoundIconButton(
                  icon: _saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  iconSize: 18,
                  size: 38,
                  foreground: _saved ? AppColors.tertiary : AppColors.onSurface,
                  background: AppColors.surfaceContainer,
                  onTap: () {
                    setState(() => _saved = !_saved);
                    showCineSnack(
                      context,
                      _saved
                          ? 'Added to your watchlist.'
                          : 'Removed from watchlist.',
                      icon: Icons.bookmark_added_outlined,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(Movie movie) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            movie.backdrop ?? movie.poster,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: AppColors.surfaceHigh),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x330A0E17),
                  Color(0x800A0E17),
                  Color(0xF20A0E17),
                  AppColors.surface,
                ],
                stops: [0.0, 0.5, 0.84, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 106,
                  height: 158,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.white24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x99000000),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.asset(
                      movie.poster,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const ColoredBox(color: AppColors.surfaceHigh),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const FormatTag(
                            'IMAX 70MM',
                            icon: Icons.theaters_outlined,
                            compact: true,
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.outlineVariant,
                              ),
                            ),
                            child: Text(
                              movie.certificate,
                              style: AppText.labelCaps.copyWith(
                                fontSize: 7.5,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.headlineLarge.copyWith(
                          fontSize: 25,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${movie.runtimeLabel} • ${movie.genres.join(' / ')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodySmall.copyWith(
                          fontSize: 10.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          RatingPill(rating: movie.rating, compact: true),
                          const SizedBox(width: 7),
                          if (movie.tomatoScore != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLowest,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.white10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.spa_rounded,
                                    size: 10,
                                    color: AppColors.tomato,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Rotten Tomatoes',
                                    style: AppText.labelCaps.copyWith(
                                      fontSize: 7,
                                      color: AppColors.onSurfaceVariant,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ],
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
        ],
      ),
    );
  }

  Widget _buildCast(Movie movie) {
    if (movie.cast.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DIRECTOR & KEY CAST',
          style: AppText.labelCaps.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movie.cast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final member = movie.cast[index];
              return SizedBox(
                width: 96,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white10),
                        image: DecorationImage(
                          image: AssetImage(member.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.bodySmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            member.role,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.bodySmall.copyWith(
                              fontSize: 8.5,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSynopsis(Movie movie) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.synopsis,
            maxLines: _expanded ? 20 : 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodySmall.copyWith(
              fontSize: 12,
              height: 1.6,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _expanded ? 'Read less ↑' : 'Read more ↓',
            style: AppText.bodySmall.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: AppColors.tertiary,
            ),
            const SizedBox(width: 7),
            Text(
              'Select Date',
              style: AppText.headlineSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              'OCTOBER 2024',
              style: AppText.labelCaps.copyWith(
                color: AppColors.outline,
                fontSize: 8,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: MockData.showtimeDays.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final day = MockData.showtimeDays[index];
              final selected = index == _selectedDay;
              return GestureDetector(
                onTap: () => _selectDay(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 63,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.filmGradient : null,
                    color: selected ? null : AppColors.surfaceLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? Colors.transparent : AppColors.white06,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryContainer.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.shortLabel,
                        style: AppText.labelCaps.copyWith(
                          fontSize: 8,
                          color: selected
                              ? Colors.white.withValues(alpha: 0.85)
                              : AppColors.outline,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        day.day,
                        style: AppText.headlineSmall.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        day.month,
                        style: AppText.labelCaps.copyWith(
                          fontSize: 7,
                          color: selected
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormatFilters() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _formatFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final selected = _formatFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _formatFilter = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: selected ? AppColors.filmGradient : null,
                color: selected ? null : AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected ? Colors.transparent : AppColors.white10,
                ),
              ),
              child: Text(
                _formatFilters[index],
                style: AppText.bodySmall.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCinemas() {
    final widgets = <Widget>[];
    for (final listing in MockData.homeShowtimes) {
      final formats = listing.formats.where((format) {
        if (_formatFilter == 0) return true;
        if (_formatFilter == 1) return format.format.contains('IMAX');
        return format.format.contains('DOLBY');
      }).toList();
      if (formats.isEmpty) continue;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _CinemaShowtimeCard(
            listing: listing,
            formats: formats,
            selected: _selected,
            onSelect: (format, option) =>
                _selectShowtime(listing, format, option),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildBookingBar() {
    final selected = _selected;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.97),
        border: const Border(top: BorderSide(color: AppColors.white10)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xB3000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: selected == null
                    ? Text(
                        'Select a showtime',
                        style: AppText.bodySmall.copyWith(
                          color: AppColors.outline,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
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
                                'SELECTED SHOWTIME',
                                style: AppText.labelCaps.copyWith(
                                  fontSize: 7.5,
                                  color: AppColors.tertiary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${selected.cinema} •',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.bodySmall.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            '${selected.auditorium} • ${selected.time}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.bodySmall.copyWith(
                              fontSize: 9.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 158,
                child: PrimaryButton(
                  label: 'Select Seats',
                  trailingIcon: Icons.arrow_forward_rounded,
                  height: 50,
                  fontSize: 13.5,
                  onTap: _openSeats,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CinemaShowtimeCard extends StatelessWidget {
  const _CinemaShowtimeCard({
    required this.listing,
    required this.formats,
    required this.selected,
    required this.onSelect,
  });

  final CinemaListing listing;
  final List<ShowtimeFormat> formats;
  final SelectedShowtime? selected;
  final void Function(ShowtimeFormat, ShowtimeOption) onSelect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.name,
                      style: AppText.headlineSmall.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.near_me_outlined,
                          size: 12,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${listing.distance} • ${listing.address}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.bodySmall.copyWith(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.local_parking_rounded,
                size: 19,
                color: AppColors.outline,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...listing.badges
                  .take(3)
                  .map(
                    (badge) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        badge.toUpperCase(),
                        style: AppText.labelFormat.copyWith(
                          fontSize: 8,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ),
                  ),
              ...listing.amenities
                  .take(2)
                  .map(
                    (amenity) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 11,
                          color: AppColors.outline,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          amenity,
                          style: AppText.bodySmall.copyWith(
                            fontSize: 9,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 14),
          ...formats.map((format) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        format.format,
                        style: AppText.labelFormat.copyWith(
                          fontSize: 9.5,
                          color: AppColors.tertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          format.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodySmall.copyWith(
                            fontSize: 9,
                            color: AppColors.outline,
                          ),
                        ),
                      ),
                      Text(
                        '\$${format.price.toStringAsFixed(2)}',
                        style: AppText.labelFormat.copyWith(
                          fontSize: 9.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: format.times.map((option) {
                      final isSelected =
                          selected != null &&
                          selected!.cinema == listing.name &&
                          selected!.format == format.format &&
                          selected!.time == option.time;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: option == format.times.last ? 0 : 6,
                          ),
                          child: _TimeChip(
                            option: option,
                            selected: isSelected,
                            onTap: () => onSelect(format, option),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ShowtimeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = !option.available;
    final statusColor = selected
        ? Colors.white.withValues(alpha: 0.8)
        : option.status == 'Filling Fast'
        ? AppColors.amber
        : option.status == 'Almost Full' || option.status == 'Few Left'
        ? AppColors.error
        : AppColors.success;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        decoration: BoxDecoration(
          gradient: selected ? AppColors.filmGradient : null,
          color: selected ? null : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : disabled
                ? AppColors.outlineVariant.withValues(alpha: 0.3)
                : AppColors.white06,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              option.time,
              style: AppText.labelFormat.copyWith(
                fontSize: 10.5,
                color: disabled
                    ? AppColors.outline.withValues(alpha: 0.45)
                    : selected
                    ? Colors.white
                    : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              option.status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.labelCaps.copyWith(
                fontSize: 6.5,
                letterSpacing: 0,
                color: disabled
                    ? AppColors.outline.withValues(alpha: 0.4)
                    : statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
