import 'package:cinego/data/mock_data.dart';
import 'package:cinego/screens/checkout_screen.dart';
import 'package:cinego/state/app_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/harness.dart';

CheckoutScreen checkoutScreen() => const CheckoutScreen(
  movie: MockData.dune,
  showtime: testShowtime,
  seats: ['E5', 'E6'],
);

void main() {
  testWidgets('renders totals, wallet and payment options', (tester) async {
    await pumpScreen(tester, checkoutScreen(), settle: false);

    await tester.scrollUntilVisible(
      find.text('Select Payment Method'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Select Payment Method'), findsOneWidget);
    expect(find.text('Apple Pay'), findsOneWidget);
    expect(find.text('Mastercard •••• 4821'), findsOneWidget);
    expect(find.text('PayPal / Pay in 4'), findsOneWidget);
    expect(find.text('CineGo Stored Wallet'), findsOneWidget);
    expect(find.textContaining('GRAND TOTAL'), findsOneWidget);
  });

  testWidgets('toggles wallet credit through Riverpod', (tester) async {
    final container = await pumpScreen(tester, checkoutScreen(), settle: false);
    expect(container.read(appStateProvider).walletApplied, isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(container.read(appStateProvider).walletApplied, isFalse);
  });

  testWidgets('changes the payment method and pay button label', (
    tester,
  ) async {
    await pumpScreen(tester, checkoutScreen(), settle: false);

    await tester.scrollUntilVisible(
      find.text('PayPal / Pay in 4'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('PayPal / Pay in 4'));
    await tester.pump();
    expect(find.textContaining('with PayPal'), findsOneWidget);

    await tester.tap(find.text('Mastercard •••• 4821'));
    await tester.pump();
    expect(find.textContaining('with •• 4821'), findsOneWidget);
  });

  testWidgets('applies a valid promo code and rejects an invalid one', (
    tester,
  ) async {
    await pumpScreen(tester, checkoutScreen(), settle: false);

    await tester.scrollUntilVisible(
      find.text('Add Promo Code or Gift Card'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Add Promo Code or Gift Card'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'SPICE20');
    await tester.tap(find.text('APPLY'));
    await tester.pump();
    expect(
      find.text('Promo SPICE20 applied — \$5.00 off your order.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'NOPE');
    await tester.tap(find.text('APPLY'));
    await tester.pump();
    expect(
      find.text('That code is not valid for this booking.'),
      findsOneWidget,
    );
  });

  testWidgets('pays, stores a booking and clears the cart', (tester) async {
    final container = createTestContainer();
    final state = container.read(appStateProvider);
    state.addSnack(MockData.snacks.first);
    final before = state.bookings.length;

    await pumpScreen(
      tester,
      checkoutScreen(),
      container: container,
      settle: false,
    );

    await tester.tap(find.textContaining('with Apple Pay'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Booking Confirmed'), findsOneWidget);
    expect(container.read(appStateProvider).bookings, hasLength(before + 1));
    expect(container.read(appStateProvider).cart, isEmpty);
  });
}
