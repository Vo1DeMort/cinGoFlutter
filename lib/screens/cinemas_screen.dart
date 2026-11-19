import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/showtime.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/ui_kit.dart';

class CinemasScreen extends ConsumerStatefulWidget {
  const CinemasScreen({super.key});

  @override
  ConsumerState<CinemasScreen> createState() => _CinemasScreenState();
}

class _CinemasScreenState extends ConsumerState<CinemasScreen> {
  int _view = 0;
  int _filter = 0;
  static const _filters = [
    'All Theaters',
    'IMAX Laser',
    'Dolby Cinema',
    'ScreenX',
    '4DX',
  ];

  List<CinemaListing> get _theaters {
    if (_filter == 0) return MockData.cinemas;
    final needle = _filters[_filter].toUpperCase();
    return MockData.cinemas.where((cinema) {
      return cinema.badges.any((badge) => badge.toUpperCase().contains(needle)) ||
          cinema.formats.any((format) => format.format.contains(needle));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RootHeader(
          onLocationTap: () => showCineSnack(
            context,
            'You are browsing cinemas near San Francisco.',
            icon: Icons.location_on_outlined,
          ),
          onAvatarTap: () => ref.read(appStateProvider).selectTab(4),
          onNotificationTap: () => showCineSnack(
            context,
            'No new notifications right now.',
            icon: Icons.notifications_none_rounded,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.white06),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.my_location_rounded,
                      size: 15,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 7),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOCATION PROXIMITY',
                          style: AppText.labelCaps.copyWith(
                            fontSize: 6.5,
                            color: AppColors.outline,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'San Francisco Bay Area',
                          style: AppText.bodySmall.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => showCineSnack(
                        context,
                        'Radius set to within 15 miles.',
                        icon: Icons.radar_rounded,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Within 15 mi',
                              style: AppText.bodySmall.copyWith(
                                fontSize: 9,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 13,
                              color: AppColors.outline,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SearchField(
                hint: 'Search cinemas, neighbourhood, ZIP',
                height: 48,
                onFilter: () => showCineSnack(
                  context,
                  'Cinema filters are shown above.',
                  icon: Icons.tune_rounded,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedPills(
                labels: const ['THEATERS LIST', 'INTERACTIVE MAP'],
                selectedIndex: _view,
                onChanged: (index) => setState(() => _view = index),
                fontSize: 10,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return FilterChipPill(
                      label: _filters[index],
                      selected: _filter == index,
                      onTap: () => setState(() => _filter = index),
                    );
                  },
                ),
              ),
              if (_filter != 0) ...[
                const SizedBox(height: 7),
                Row(
                  children: [
                    Text(
                      'FILTERED BY',
                      style: AppText.labelCaps.copyWith(
                        fontSize: 6.5,
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const FormatTag('FORMAT', compact: true),
                    const SizedBox(width: 5),
                    Text(
                      _filters[_filter],
                      style: AppText.labelFormat.copyWith(
                        fontSize: 8,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              if (_view == 0) ...[
                _buildFeaturedCinema(),
                const SizedBox(height: 14),
                _buildMapCard(),
              ] else ...[
                _buildMapCard(expanded: true),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Nearby Theaters',
                    style: AppText.headlineSmall.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_theaters.length} CLOSE BY',
                      style: AppText.labelCaps.copyWith(
                        fontSize: 6.5,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => showCineSnack(
                      context,
                      'Sorted by distance from your location.',
                      icon: Icons.near_me_outlined,
                    ),
                    child: Text(
                      'Sort: Distance',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._theaters.map(
                (cinema) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NearbyCinemaCard(
                    cinema: cinema,
                    onTap: () => showCineSnack(
                      context,
                      '${cinema.name} selected as your home theater.',
                      icon: Icons.location_on_rounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    size: 13,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'STANDARD OF EXCELLENCE',
                    style: AppText.labelCaps.copyWith(
                      fontSize: 7,
                      color: AppColors.outline,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Cinema Tech Showcase',
                style: AppText.headlineSmall.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _buildTechList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCinema() {
    final cinema = MockData.homeShowtimes[0];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 178,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: Image.asset(
                    'assets/images/cinema_hall.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: AppColors.surfaceHigh,
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x330A0E17), Color(0x000A0E17), Color(0xD90A0E17)],
                      stops: [0, 0.4, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 11,
                  left: 11,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 9,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'YOUR HOME THEATER',
                          style: AppText.labelCaps.copyWith(
                            fontSize: 6,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 11,
                  right: 11,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLowest.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white12),
                    ),
                    child: const Icon(
                      Icons.star_outline_rounded,
                      size: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 9,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Open • Closes 12:30 AM',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 8.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.near_me_outlined,
                        size: 11,
                        color: AppColors.tertiary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '1.2 mi',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 8.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cinema.name,
                  style: AppText.headlineSmall.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  cinema.address,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 8.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    const FormatTag('IMAX 70MM LASER', compact: true),
                    const FormatTag(
                      'PRIME 30',
                      color: AppColors.secondary,
                      compact: true,
                    ),
                    const FormatTag(
                      'DINE-IN LOUNGE',
                      color: AppColors.primary,
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    _actionChip(Icons.near_me_outlined, 'Navigate'),
                    const SizedBox(width: 6),
                    _actionChip(Icons.confirmation_number_outlined, 'Box Office'),
                    const SizedBox(width: 6),
                    _actionChip(Icons.room_service_outlined, 'Dine-In'),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.white10, height: 1),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(
                      Icons.play_circle_outline_rounded,
                      size: 13,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Now Showing',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '35 today',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 7.5,
                        color: AppColors.outline,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'View All',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 8.5,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _miniNowShowing(
                        poster: 'assets/images/poster_dune_cinema.jpg',
                        title: 'Dune: Part Two',
                        format: 'IMAX 70MM',
                        time: '4:45 PM',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _miniNowShowing(
                        poster: 'assets/images/poster_oppenheimer.jpg',
                        title: 'Oppenheimer',
                        format: '70MM',
                        time: '6:00 PM',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodySmall.copyWith(
                  fontSize: 8.5,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniNowShowing({
    required String poster,
    required String title,
    required String format,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              poster,
              width: 38,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 38,
                height: 54,
                color: AppColors.surfaceHigh,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  format,
                  style: AppText.labelFormat.copyWith(
                    fontSize: 6,
                    color: AppColors.tertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.filmGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    time,
                    style: AppText.labelFormat.copyWith(
                      fontSize: 7,
                      color: Colors.white,
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

  Widget _buildMapCard({bool expanded = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white06),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.radar_rounded,
                size: 15,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 5),
              Text(
                'Bay Area Radar View',
                style: AppText.bodySmall.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'LIVE GEO STATUS',
                style: AppText.labelCaps.copyWith(
                  fontSize: 6,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: expanded ? 240 : 132,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/map_cinema.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: AppColors.surfaceHigh,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.tertiary.withOpacity(0.55),
                      ),
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      size: 14,
                      color: AppColors.tertiary,
                    ),
                  ),
                ),
                Positioned(
                  right: 7,
                  bottom: 7,
                  child: GestureDetector(
                    onTap: () => showCineSnack(
                      context,
                      'Full interactive map is not part of this demo.',
                      icon: Icons.map_outlined,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLowest.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: AppColors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.open_in_full_rounded,
                            size: 9,
                            color: AppColors.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Full Map',
                            style: AppText.bodySmall.copyWith(
                              fontSize: 8,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildTechList() {
    const items = [
      (
        Icons.high_quality_outlined,
        'IMAX Dual 4K Laser',
        '1.43:1 expanded cinematic ratio delivering 40% more visible image canvas with dual-laser sharpness.',
      ),
      (
        Icons.surround_sound_rounded,
        'Dolby Atmos 64-Channel',
        'Individual audio object placement moving around you in three-dimensional theater acoustic.',
      ),
      (
        Icons.airline_seat_recline_extra_rounded,
        'Plush Heated Recliners',
        'Heated seats with in-seat service, food trays, dual USB-C charging points and quiet staff call buttons.',
      ),
    ];
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.white06),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.$1, size: 18, color: AppColors.tertiary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$2,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.$3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 8,
                        height: 1.35,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _NearbyCinemaCard extends StatelessWidget {
  const _NearbyCinemaCard({required this.cinema, required this.onTap});

  final CinemaListing cinema;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white06),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    cinema.name,
                    style: AppText.bodySmall.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.star_rounded,
                  size: 12,
                  color: AppColors.amber,
                ),
                const SizedBox(width: 2),
                Text(
                  (cinema.rating ?? 4.2).toStringAsFixed(1),
                  style: AppText.labelFormat.copyWith(
                    fontSize: 8,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  cinema.distance,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 8,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
            Text(
              cinema.address,
              style: AppText.bodySmall.copyWith(
                fontSize: 8.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ...cinema.badges
                    .take(2)
                    .map(
                      (badge) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: AppText.labelFormat.copyWith(
                              fontSize: 6,
                              color: AppColors.tertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                const Spacer(),
                Text(
                  '${cinema.badges.length + 10} showtimes',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 7,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 11,
                  color: AppColors.outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
