import 'package:cinego/screens/home_screen.dart';
import 'package:cinego/widgets/ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('shows discovery sections and movie shelves', (tester) async {
    await pumpTab(tester, const HomeScreen());

    expect(find.text('Now Showing'), findsOneWidget);
    expect(find.text('Coming Soon'), findsOneWidget);
    expect(find.text('Dune: Part Two'), findsWidgets);
    expect(find.text('Book Tickets'), findsOneWidget);
    expect(find.text('Feel Every Frequency'), findsOneWidget);
  });

  testWidgets('filters the now showing shelf by genre', (tester) async {
    await pumpTab(tester, const HomeScreen());

    await tester.tap(find.widgetWithText(FilterChipPill, 'SCI-FI'));
    await tester.pumpAndSettle();

    expect(find.text('Dune: Part Two'), findsWidgets);
    expect(find.text('Challengers'), findsNothing);
    expect(find.text('No SCI-FI titles showing right now.'), findsNothing);
  });

  testWidgets('opens movie details from the hero booking action', (
    tester,
  ) async {
    await pumpTab(tester, const HomeScreen());

    await tester.ensureVisible(find.text('Book Tickets'));
    await tester.tap(find.text('Book Tickets'));
    await tester.pumpAndSettle();

    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('Select Seats'), findsOneWidget);
  });
}
