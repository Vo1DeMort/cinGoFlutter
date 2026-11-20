import 'package:cinego/data/mock_data.dart';
import 'package:cinego/screens/checkout_screen.dart';
import 'package:cinego/screens/payment_timeout_screen.dart';
import 'package:cinego/screens/seat_selection_screen.dart';
import 'package:cinego/state/app_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/harness.dart';

PaymentTimeoutScreen timeoutScreen() => const PaymentTimeoutScreen(
  movie: MockData.dune,
  showtime: testShowtime,
  seats: ['E5', 'E6'],
);

void main() {
  testWidgets('renders the expired booking and zero-charge protection', (
    tester,
  ) async {
    await pumpScreen(tester, timeoutScreen());

    expect(find.text('Booking Expired & Unpaid'), findsOneWidget);
    expect(find.text('EXPIRED • 00:00'), findsOneWidget);
    expect(find.text('ERR_AUTH_TIMEOUT'), findsOneWidget);
    expect(find.text('Zero Charges Incurred'), findsOneWidget);
    expect(find.text('Preserved Order Details'), findsOneWidget);
    expect(find.text('No items saved'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('SUGGESTED RECOVERY OPTIONS'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Try Re-locking Seats E5, E6'), findsOneWidget);
    expect(find.text('Switch to Seats F5, F6 (Row Behind)'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Re-select Seats & Try Again'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Re-select Seats & Try Again'), findsOneWidget);
  });

  testWidgets('preserves the snacks cart in the order details', (tester) async {
    final container = createTestContainer();
    final state = container.read(appStateProvider);
    state.addSnack(MockData.snacks.first);
    state.addSnack(MockData.snacks.first);

    await pumpScreen(tester, timeoutScreen(), container: container);

    expect(find.text('2 Items Saved'), findsOneWidget);
    expect(
      find.textContaining("Dune: Part Two Collector's Combo"),
      findsWidgets,
    );
    expect(find.text('\$45.00'), findsOneWidget);
  });

  testWidgets('re-selects seats and returns to the seat map', (tester) async {
    await pumpScreen(tester, timeoutScreen());

    await tester.scrollUntilVisible(
      find.text('Re-select Seats & Try Again'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Re-select Seats & Try Again'));
    await tester.pump();
    await tester.tap(find.text('Re-select Seats & Try Again'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SeatSelectionScreen), findsOneWidget);
    expect(find.text('Seats: E5, E6'), findsOneWidget);
  });

  testWidgets('offers a fresh checkout for updating payment', (tester) async {
    await pumpScreen(tester, timeoutScreen());

    await tester.scrollUntilVisible(
      find.text('Update Payment Method'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Update Payment Method'));
    await tester.pump();
    await tester.tap(find.text('Update Payment Method'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CheckoutScreen), findsOneWidget);
    expect(find.text('Secure Checkout'), findsOneWidget);
  });

  testWidgets('checkout hold expiry opens the timeout screen', (tester) async {
    await pumpScreen(
      tester,
      const CheckoutScreen(
        movie: MockData.dune,
        showtime: testShowtime,
        seats: ['E5', 'E6'],
        holdSeconds: 1,
      ),
      settle: false,
    );

    expect(find.text('Secure Checkout'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PaymentTimeoutScreen), findsOneWidget);
    expect(find.text('Booking Expired & Unpaid'), findsOneWidget);
  });
}
