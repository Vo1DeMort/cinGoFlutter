import 'package:cinego/models/booking.dart';
import 'package:cinego/screens/cancellation_screen.dart';
import 'package:cinego/state/app_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/harness.dart';

void main() {
  testWidgets('renders eligibility, breakdown and payout choices', (
    tester,
  ) async {
    await pumpScreen(tester, CancellationScreen(booking: testBooking()));

    expect(find.text('Ticket Cancellation & Refund'), findsOneWidget);
    expect(find.text('Eligible for 100% Full Refund'), findsOneWidget);
    expect(find.text('Refund Breakdown'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Original Methods'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('CineGo Wallet'), findsWidgets);
    expect(find.text('Original Methods'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('CinePass Gold Notice'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('CinePass Gold Notice'), findsOneWidget);
  });

  testWidgets('switches payout and updates the refund amount', (tester) async {
    await pumpScreen(tester, CancellationScreen(booking: testBooking()));

    await tester.scrollUntilVisible(
      find.text('Original Methods'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('\$101.10'), findsWidgets);

    await tester.tap(find.text('Original Methods'));
    await tester.pump();

    expect(find.textContaining('\$96.10'), findsWidgets);
  });

  testWidgets('selects a cancellation reason', (tester) async {
    await pumpScreen(tester, CancellationScreen(booking: testBooking()));

    await tester.scrollUntilVisible(
      find.text('SCHEDULE CONFLICT'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('SCHEDULE CONFLICT'));
    await tester.pump();

    expect(find.text('SCHEDULE CONFLICT'), findsOneWidget);
  });

  testWidgets('confirms cancellation and updates Riverpod state', (
    tester,
  ) async {
    final container = createTestContainer();
    final booking = testBooking();
    await pumpScreen(
      tester,
      CancellationScreen(booking: booking),
      container: container,
    );
    expect(container.read(appStateProvider).upcomingBookings, hasLength(2));

    await tester.scrollUntilVisible(
      find.textContaining('Confirm Cancellation'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.textContaining('Confirm Cancellation'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel this booking?'), findsOneWidget);

    await tester.tap(find.text('Confirm cancellation'));
    await tester.pumpAndSettle();

    expect(container.read(appStateProvider).upcomingBookings, hasLength(1));
    expect(
      container
          .read(appStateProvider)
          .bookings
          .firstWhere((b) => b.id == booking.id)
          .status,
      BookingStatus.cancelled,
    );
  });

  testWidgets('can keep the reservation from the dialog', (tester) async {
    final container = createTestContainer();
    await pumpScreen(
      tester,
      CancellationScreen(booking: testBooking()),
      container: container,
    );

    await tester.scrollUntilVisible(
      find.textContaining('Confirm Cancellation'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.textContaining('Confirm Cancellation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep reservation'));
    await tester.pumpAndSettle();

    expect(container.read(appStateProvider).upcomingBookings, hasLength(2));
  });
}
