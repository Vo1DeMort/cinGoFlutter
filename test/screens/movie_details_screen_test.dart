import 'package:cinego/data/mock_data.dart';
import 'package:cinego/screens/movie_details_screen.dart';
import 'package:cinego/screens/seat_selection_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('renders movie metadata and showtimes', (tester) async {
    await pumpScreen(tester, const MovieDetailsScreen(movie: MockData.dune));

    expect(find.text('Dune: Part Two'), findsWidgets);
    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('SELECTED SHOWTIME'), findsOneWidget);
    expect(find.text('IMAX 70MM'), findsWidgets);
    expect(find.text('DIRECTOR & KEY CAST'), findsOneWidget);
  });

  testWidgets('expands and collapses the synopsis', (tester) async {
    await pumpScreen(tester, const MovieDetailsScreen(movie: MockData.dune));

    await tester.ensureVisible(find.text('Read more ↓'));
    await tester.tap(find.text('Read more ↓'));
    await tester.pumpAndSettle();
    expect(find.text('Read less ↑'), findsOneWidget);

    await tester.tap(find.text('Read less ↑'));
    await tester.pumpAndSettle();
    expect(find.text('Read more ↓'), findsOneWidget);
  });

  testWidgets('selects a format and continues to seat selection', (
    tester,
  ) async {
    await pumpScreen(tester, const MovieDetailsScreen(movie: MockData.dune));

    await tester.tap(find.text('Dolby Cinema'));
    await tester.pumpAndSettle();
    expect(find.text('DOLBY CINEMA'), findsWidgets);

    await tester.ensureVisible(find.text('Select Seats'));
    await tester.tap(find.text('Select Seats'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SeatSelectionScreen), findsOneWidget);
    expect(find.text('Seat Selection'), findsOneWidget);
  });

  testWidgets('shows the selected showtime summary', (tester) async {
    await pumpScreen(tester, const MovieDetailsScreen(movie: MockData.dune));

    await tester.ensureVisible(find.text('SELECTED SHOWTIME'));
    expect(find.text('SELECTED SHOWTIME'), findsOneWidget);
    expect(find.textContaining('AMC Metreon 16 & IMAX'), findsWidgets);
  });
}
