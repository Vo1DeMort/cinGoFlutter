import 'package:cinego/data/mock_data.dart';
import 'package:cinego/screens/seat_collision_screen.dart';
import 'package:cinego/screens/seat_selection_screen.dart';
import 'package:cinego/screens/snacks_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fixtures.dart';
import '../helpers/harness.dart';

SeatCollisionScreen collisionScreen() => const SeatCollisionScreen(
  movie: MockData.dune,
  showtime: testShowtime,
  seats: ['E5', 'E6'],
);

void main() {
  testWidgets('renders the collision and quick-fix options', (tester) async {
    await pumpScreen(tester, collisionScreen());

    expect(find.text('Seats E5 & E6 Were Just Taken'), findsOneWidget);
    expect(find.text('SEAT COLLISION DETECTED'), findsOneWidget);
    expect(find.text('120MS SYNC LOCK'), findsOneWidget);
    expect(find.text('1-Tap Quick Fix Options'), findsOneWidget);
    expect(find.text('Seats F5 & F6 (Row F Center)'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Snacks Cart Held Safe'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Snacks Cart Held Safe'), findsOneWidget);
    expect(find.text('Open Full Seating Map'), findsOneWidget);
  });

  testWidgets('quick-locks the recommended row-F seats', (tester) async {
    await pumpScreen(tester, collisionScreen());

    await tester.scrollUntilVisible(
      find.text('Quick-Lock Seats F5 & F6'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Quick-Lock Seats F5 & F6'));
    await tester.pump();
    await tester.tap(find.text('Quick-Lock Seats F5 & F6'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SeatSelectionScreen), findsOneWidget);
    expect(find.text('Seats: F5, F6'), findsOneWidget);
  });

  testWidgets('holds the same-row alternate seats', (tester) async {
    await pumpScreen(tester, collisionScreen());

    await tester.scrollUntilVisible(
      find.text('Hold Seats E7 & E8'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Hold Seats E7 & E8'));
    await tester.pump();
    await tester.tap(find.text('Hold Seats E7 & E8'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SeatSelectionScreen), findsOneWidget);
    expect(find.text('Seats: E7, E8'), findsOneWidget);
  });

  testWidgets('opens a fresh seat map from the collision state', (
    tester,
  ) async {
    await pumpScreen(tester, collisionScreen());

    await tester.scrollUntilVisible(
      find.text('Open Full Seating Map'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Open Full Seating Map'));
    await tester.pump();
    await tester.tap(find.text('Open Full Seating Map'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SeatSelectionScreen), findsOneWidget);
    expect(find.text('No seats chosen'), findsOneWidget);
  });

  testWidgets('seat hold expiry opens collision recovery', (tester) async {
    await pumpScreen(
      tester,
      const SeatSelectionScreen(
        movie: MockData.dune,
        showtime: testShowtime,
        holdSeconds: 1,
      ),
      settle: false,
    );

    expect(find.text('Seat Selection'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SeatCollisionScreen), findsOneWidget);
    expect(find.text('Seats E5 & E6 Were Just Taken'), findsOneWidget);
    expect(find.byType(SnacksScreen), findsNothing);
  });
}
