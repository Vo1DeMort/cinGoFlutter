import 'package:cinego/screens/offline_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('renders cached pass, diagnostics and venue guidance', (
    tester,
  ) async {
    await pumpScreen(tester, const OfflineScreen());

    expect(find.text("You're Currently Offline"), findsOneWidget);
    expect(find.text('Offline Cinema Pass Ready'), findsOneWidget);
    expect(find.text('Dune: Part Two'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Connection Diagnostics'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Connection Diagnostics'), findsOneWidget);
    expect(find.text('UNREACHABLE'), findsOneWidget);
    expect(find.text('STANDBY'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Cached Venue Navigation'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('GPS OFFLINE • MAP SAVED'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Retry Connection'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Retry Connection'), findsOneWidget);
    expect(find.text('Browse Cached Movies & Theaters'), findsOneWidget);
  });

  testWidgets('opens the saved QR pass from local cache', (tester) async {
    await pumpScreen(tester, const OfflineScreen());

    await tester.scrollUntilVisible(
      find.text('View Saved Ticket & QR Pass'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('View Saved Ticket & QR Pass'));
    await tester.pump();
    await tester.tap(find.text('View Saved Ticket & QR Pass'));
    await tester.pump();

    expect(find.text('Saved QR pass opened from local cache.'), findsOneWidget);
  });

  testWidgets('retries the connection and confirms the cache synced', (
    tester,
  ) async {
    await pumpScreen(tester, const OfflineScreen());

    await tester.scrollUntilVisible(
      find.text('Retry Connection'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Retry Connection'));
    await tester.pump();
    await tester.tap(find.text('Retry Connection'));
    await tester.pump();
    expect(find.text('Checking Signal…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    expect(
      find.text('Connection restored — offline cache synced.'),
      findsOneWidget,
    );
  });
}
