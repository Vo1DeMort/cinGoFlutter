import 'package:cinego/screens/confirmation_screen.dart';
import 'package:cinego/state/app_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/harness.dart';

void main() {
  testWidgets('renders the confirmed e-ticket and payment summary', (
    tester,
  ) async {
    final booking = testBooking();
    await pumpScreen(tester, ConfirmationScreen(booking: booking));

    expect(find.text('Booking Confirmed'), findsOneWidget);
    expect(find.text('Dune: Part Two'), findsWidgets);
    expect(find.text(booking.code), findsOneWidget);
    expect(find.text('E5, E6'), findsOneWidget);
    expect(find.text('Payment Summary'), findsOneWidget);
    expect(find.text('Arrival & Amenities'), findsOneWidget);
  });

  testWidgets('navigates to the bookings tab', (tester) async {
    final container = createTestContainer();
    await pumpScreen(
      tester,
      ConfirmationScreen(booking: testBooking()),
      container: container,
    );

    await tester.scrollUntilVisible(
      find.text('View in My Bookings'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('View in My Bookings'));
    await tester.pumpAndSettle();

    expect(container.read(appStateProvider).tabIndex, 3);
  });

  testWidgets('navigates back to movies', (tester) async {
    final container = createTestContainer();
    await pumpScreen(
      tester,
      ConfirmationScreen(booking: testBooking()),
      container: container,
    );

    await tester.scrollUntilVisible(
      find.text('Back to Movies'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Back to Movies'));
    await tester.pumpAndSettle();

    expect(container.read(appStateProvider).tabIndex, 1);
  });

  testWidgets('shows wallet and calendar actions', (tester) async {
    await pumpScreen(tester, ConfirmationScreen(booking: testBooking()));

    await tester.tap(find.text('Apple Wallet'));
    await tester.pump();
    expect(find.text('Pass added to Apple Wallet (demo).'), findsOneWidget);

    await tester.tap(find.text('Add to Calendar'));
    await tester.pump();
    expect(
      find.text('Showtime added to your calendar (demo).'),
      findsOneWidget,
    );
  });
}
