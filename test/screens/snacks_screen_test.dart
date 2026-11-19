import 'package:cinego/data/mock_data.dart';
import 'package:cinego/screens/checkout_screen.dart';
import 'package:cinego/screens/snacks_screen.dart';
import 'package:cinego/state/app_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/harness.dart';

void main() {
  testWidgets('seeds the cart and renders concessions', (tester) async {
    final container = await pumpScreen(
      tester,
      const SnacksScreen(
        movie: MockData.dune,
        showtime: testShowtime,
        seats: ['E5', 'E6'],
      ),
    );

    expect(find.text('Pre Order Snacks & Concessions'), findsOneWidget);
    expect(find.text("Dune: Part Two Collector's Combo"), findsOneWidget);
    expect(find.text('Warm Artisanal Popcorn'), findsOneWidget);
    expect(find.text('2 ITEMS'), findsOneWidget);
    expect(find.text('\$33.50'), findsWidgets);
    expect(container.read(appStateProvider).cartCount, 2);
  });

  testWidgets('adds another snack and updates totals', (tester) async {
    final container = await pumpScreen(
      tester,
      const SnacksScreen(
        movie: MockData.dune,
        showtime: testShowtime,
        seats: ['E5', 'E6'],
      ),
    );

    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();

    expect(container.read(appStateProvider).cartCount, 3);
    expect(find.text('3 ITEMS'), findsOneWidget);
    expect(find.textContaining('Review & Pay'), findsOneWidget);
  });

  testWidgets('continues to checkout with the cart', (tester) async {
    await pumpScreen(
      tester,
      const SnacksScreen(
        movie: MockData.dune,
        showtime: testShowtime,
        seats: ['E5', 'E6'],
      ),
    );

    await tester.tap(find.textContaining('Review & Pay'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CheckoutScreen), findsOneWidget);
    expect(find.text('Secure Checkout'), findsOneWidget);
  });

  testWidgets('skips concessions and clears the cart', (tester) async {
    final container = await pumpScreen(
      tester,
      const SnacksScreen(
        movie: MockData.dune,
        showtime: testShowtime,
        seats: ['E5', 'E6'],
      ),
    );

    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CheckoutScreen), findsOneWidget);
    expect(container.read(appStateProvider).cart, isEmpty);
  });
}
