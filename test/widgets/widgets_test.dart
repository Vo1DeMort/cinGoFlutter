import 'package:cinego/data/mock_data.dart';
import 'package:cinego/theme/app_colors.dart';
import 'package:cinego/widgets/app_header.dart';
import 'package:cinego/widgets/bottom_nav.dart';
import 'package:cinego/widgets/cinego_logo.dart';
import 'package:cinego/widgets/movie_cards.dart';
import 'package:cinego/widgets/ticket_widgets.dart';
import 'package:cinego/widgets/ui_kit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  group('ui kit buttons', () {
    testWidgets('PrimaryButton fires onTap when enabled', (tester) async {
      var taps = 0;
      await pumpWidgetInScaffold(
        tester,
        PrimaryButton(label: 'Continue', onTap: () => taps++),
      );
      await tester.tap(find.text('Continue'));
      expect(taps, 1);
    });

    testWidgets('PrimaryButton ignores taps when disabled', (tester) async {
      var taps = 0;
      await pumpWidgetInScaffold(
        tester,
        PrimaryButton(label: 'Continue', onTap: () => taps++),
      );
      final button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(button.enabled, isTrue);
      await tester.tap(find.text('Continue'));
      expect(taps, 1);
    });

    testWidgets('SecondaryButton renders icon and handles taps', (
      tester,
    ) async {
      var taps = 0;
      await pumpWidgetInScaffold(
        tester,
        SecondaryButton(
          label: 'Share',
          icon: Icons.ios_share_rounded,
          onTap: () => taps++,
        ),
      );
      expect(find.byIcon(Icons.ios_share_rounded), findsOneWidget);
      await tester.tap(find.text('Share'));
      expect(taps, 1);
    });

    testWidgets('RoundIconButton handles taps', (tester) async {
      var taps = 0;
      await pumpWidgetInScaffold(
        tester,
        RoundIconButton(icon: Icons.search_rounded, onTap: () => taps++),
      );
      await tester.tap(find.byIcon(Icons.search_rounded));
      expect(taps, 1);
    });
  });

  group('ui kit labels', () {
    testWidgets('FormatTag uppercases its label', (tester) async {
      await pumpWidgetInScaffold(tester, const FormatTag('IMAX 70mm'));
      expect(find.text('IMAX 70MM'), findsOneWidget);
    });

    testWidgets('RatingPill shows one decimal', (tester) async {
      await pumpWidgetInScaffold(tester, const RatingPill(rating: 9.44));
      expect(find.text('9.4'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('SectionHeader renders and handles trailing tap', (
      tester,
    ) async {
      var taps = 0;
      await pumpWidgetInScaffold(
        tester,
        SizedBox(
          width: 320,
          child: SectionHeader(
            title: 'Now Showing',
            trailingLabel: 'See all',
            onTrailingTap: () => taps++,
          ),
        ),
      );
      expect(find.text('Now Showing'), findsOneWidget);
      expect(find.text('SEE ALL'), findsOneWidget);
      await tester.tap(find.text('SEE ALL'));
      expect(taps, 1);
    });

    testWidgets('AppCard exposes its child', (tester) async {
      await pumpWidgetInScaffold(
        tester,
        const AppCard(child: Text('Card content')),
      );
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('StatBlock uppercases its label', (tester) async {
      await pumpWidgetInScaffold(
        tester,
        const StatBlock(value: '24', label: 'watched'),
      );
      expect(find.text('24'), findsOneWidget);
      expect(find.text('WATCHED'), findsOneWidget);
    });

    testWidgets('GlowOrb renders a sized container', (tester) async {
      await pumpWidgetInScaffold(
        tester,
        const GlowOrb(color: AppColors.tertiary, size: 80),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlowOrb),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.maxWidth, 80);
    });
  });

  group('ui kit inputs', () {
    testWidgets('SearchField reports edits and filter taps', (tester) async {
      String? query;
      var filters = 0;
      await pumpWidgetInScaffold(
        tester,
        SearchField(
          hint: 'Search movies',
          onChanged: (value) => query = value,
          onFilter: () => filters++,
        ),
      );

      await tester.enterText(find.byType(TextField), 'dune');
      expect(query, 'dune');

      await tester.tap(find.byIcon(Icons.tune_rounded));
      expect(filters, 1);
    });

    testWidgets('SegmentedPills changes selection', (tester) async {
      var selected = 0;
      await pumpWidgetInScaffold(
        tester,
        SegmentedPills(
          labels: const ['Upcoming', 'Past'],
          selectedIndex: selected,
          onChanged: (index) => selected = index,
        ),
      );
      await tester.tap(find.text('Past'));
      expect(selected, 1);
    });

    testWidgets('FilterChipPill reports selection and count', (tester) async {
      var taps = 0;
      await pumpWidgetInScaffold(
        tester,
        FilterChipPill(label: 'Drama', count: 4, onTap: () => taps++),
      );
      expect(find.text('DRAMA (4)'), findsOneWidget);
      await tester.tap(find.text('DRAMA (4)'));
      expect(taps, 1);
    });
  });

  group('headers and navigation', () {
    testWidgets('RootHeader exposes location and notification actions', (
      tester,
    ) async {
      var locations = 0;
      var notifications = 0;
      await pumpWidgetInScaffold(
        tester,
        RootHeader(
          onLocationTap: () => locations++,
          onNotificationTap: () => notifications++,
        ),
      );

      expect(find.text('AMC Metreon'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.location_on_rounded));
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      expect(locations, 1);
      expect(notifications, 1);
    });

    testWidgets('SubPageHeader shows title, subtitle and back action', (
      tester,
    ) async {
      var backs = 0;
      await pumpWidgetInScaffold(
        tester,
        SubPageHeader(
          title: 'Seat Selection',
          subtitle: 'AMC Metreon 16',
          trailing: const TimerChip(label: '09:40'),
          onBack: () => backs++,
        ),
      );

      expect(find.text('Seat Selection'), findsOneWidget);
      expect(find.text('AMC Metreon 16'), findsOneWidget);
      expect(find.text('09:40'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      expect(backs, 1);
    });

    testWidgets('TimerChip renders its label', (tester) async {
      await pumpWidgetInScaffold(tester, const TimerChip(label: '10:00'));
      expect(find.text('10:00'), findsOneWidget);
    });

    testWidgets('CineGoWordmark renders brand text', (tester) async {
      await pumpWidgetInScaffold(tester, const CineGoWordmark(fontSize: 20));
      expect(find.text('CineGo'), findsOneWidget);
      expect(find.byIcon(Icons.local_movies_rounded), findsOneWidget);
    });

    testWidgets('CineGoBottomNav reports the tapped index', (tester) async {
      var tapped = -1;
      await pumpWidgetInScaffold(
        tester,
        CineGoBottomNav(selectedIndex: 0, onTap: (index) => tapped = index),
      );

      for (final label in [
        'HOME',
        'MOVIES',
        'CINEMAS',
        'BOOKINGS',
        'PROFILE',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      await tester.tap(find.text('BOOKINGS'));
      expect(tapped, 3);
    });
  });

  group('movie cards', () {
    testWidgets('PosterCard calls onTap from the poster and book button', (
      tester,
    ) async {
      var taps = 0;
      await pumpWidgetInScaffold(
        tester,
        PosterCard(movie: MockData.dune, onTap: () => taps++),
      );

      expect(find.text('Dune: Part Two'), findsOneWidget);
      await tester.tap(find.text('Book'));
      expect(taps, 1);
    });

    testWidgets('PosterCard can hide the book button', (tester) async {
      await pumpWidgetInScaffold(
        tester,
        const PosterCard(movie: MockData.dune, showBookButton: false),
      );
      expect(find.text('Book'), findsNothing);
    });

    testWidgets('BrowseMovieCard calls onTap', (tester) async {
      var taps = 0;
      await pumpWidgetInScaffold(
        tester,
        BrowseMovieCard(movie: MockData.dune, onTap: () => taps++),
      );
      expect(find.text('Dune: Part Two'), findsOneWidget);
      await tester.tap(find.text('Book'));
      expect(taps, 1);
    });

    testWidgets('ComingSoonCard handles card and reminder taps', (
      tester,
    ) async {
      final movie = MockData.comingSoon.first;
      var taps = 0;
      var reminders = 0;
      await pumpWidgetInScaffold(
        tester,
        ComingSoonCard(
          movie: movie,
          onTap: () => taps++,
          onReminder: () => reminders++,
        ),
      );

      expect(find.text(movie.title), findsOneWidget);
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      expect(reminders, 1);
      await tester.tap(find.text(movie.title));
      expect(taps, 1);
    });
  });

  group('ticket widgets', () {
    testWidgets('QrView and MiniQrView paint custom codes', (tester) async {
      await pumpWidgetInScaffold(
        tester,
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrView(size: 120, seed: 4),
            SizedBox(width: 12),
            MiniQrView(size: 60, seed: 2),
          ],
        ),
      );
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('TicketDivider renders notches and a dashed line', (
      tester,
    ) async {
      await pumpWidgetInScaffold(
        tester,
        const SizedBox(width: 320, child: TicketDivider()),
      );
      expect(find.byType(TicketDivider), findsOneWidget);
    });

    testWidgets('MiniStat renders value and label', (tester) async {
      await pumpWidgetInScaffold(
        tester,
        const MiniStat(value: 'E5, E6', label: 'Seats'),
      );
      expect(find.text('E5, E6'), findsOneWidget);
      expect(find.text('SEATS'), findsOneWidget);
    });
  });
}
