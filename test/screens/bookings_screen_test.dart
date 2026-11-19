import 'package:cinego/screens/bookings_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('shows active and past bookings', (tester) async {
    await pumpTab(tester, const BookingsScreen());

    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('2 ACTIVE'), findsOneWidget);
    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(find.text('Gladiator II'), findsOneWidget);
    expect(find.text('View Digital Pass'), findsOneWidget);

    await tester.tap(find.text('Past History'));
    await tester.pumpAndSettle();
    expect(find.text('VIEWED'), findsWidgets);
  });

  testWidgets('searches bookings by title and code', (tester) async {
    await pumpTab(tester, const BookingsScreen());

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'gladiator');
    await tester.pumpAndSettle();
    expect(find.text('Gladiator II'), findsOneWidget);
    expect(find.text('Dune: Part Two'), findsNothing);

    await tester.enterText(find.byType(TextField), '#CG-89421-DX');
    await tester.pumpAndSettle();
    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(find.text('Gladiator II'), findsNothing);
  });

  testWidgets('opens the digital pass from the active ticket', (tester) async {
    await pumpTab(tester, const BookingsScreen());

    await tester.tap(find.text('View Digital Pass'));
    await tester.pumpAndSettle();

    expect(find.text('Booking Confirmed'), findsOneWidget);
    expect(find.text('#CG-89421-DX'), findsWidgets);
  });

  testWidgets('shows the popcorn perk banner', (tester) async {
    await pumpTab(tester, const BookingsScreen());

    await tester.ensureVisible(find.text('Free Large Popcorn Perk'));
    expect(find.text('Free Large Popcorn Perk'), findsOneWidget);
    expect(find.text('CLAIM'), findsOneWidget);
  });
}
