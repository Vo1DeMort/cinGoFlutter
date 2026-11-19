import 'package:cinego/data/mock_data.dart';
import 'package:cinego/screens/seat_selection_screen.dart';
import 'package:cinego/screens/snacks_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/harness.dart';

void main() {
  testWidgets('renders preselected seats, timer and pricing', (tester) async {
    await pumpScreen(
      tester,
      const SeatSelectionScreen(movie: MockData.dune, showtime: testShowtime),
      settle: false,
    );

    expect(find.text('Seat Selection'), findsOneWidget);
    expect(find.text('Seats: E5, E6'), findsOneWidget);
    expect(find.text('\$59.00'), findsOneWidget);
    expect(find.text('VIP Ultra Recliner'), findsOneWidget);
    expect(find.text('Proceed'), findsOneWidget);
  });

  testWidgets('toggles a seat on and off', (tester) async {
    await pumpScreen(
      tester,
      const SeatSelectionScreen(movie: MockData.dune, showtime: testShowtime),
      settle: false,
    );

    await tester.tap(find.byKey(const ValueKey('seat-E5')));
    await tester.pump();
    expect(find.text('Seats: E6'), findsOneWidget);
    expect(find.text('\$29.50'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('seat-E5')));
    await tester.pump();
    expect(find.text('Seats: E5, E6'), findsOneWidget);
  });

  testWidgets('does not select an occupied seat', (tester) async {
    await pumpScreen(
      tester,
      const SeatSelectionScreen(movie: MockData.dune, showtime: testShowtime),
      settle: false,
    );

    await tester.tap(find.byKey(const ValueKey('seat-A3')));
    await tester.pump();
    expect(find.text('Seats: E5, E6'), findsOneWidget);
  });

  testWidgets('proceeds to concessions with the chosen seats', (tester) async {
    await pumpScreen(
      tester,
      const SeatSelectionScreen(movie: MockData.dune, showtime: testShowtime),
      settle: false,
    );

    await tester.tap(find.text('Proceed'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SnacksScreen), findsOneWidget);
    expect(find.text('Pre Order Snacks & Concessions'), findsOneWidget);
  });
}
