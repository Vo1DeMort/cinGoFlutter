import 'package:cinego/data/mock_data.dart';
import 'package:cinego/screens/movie_details_screen.dart';
import 'package:cinego/screens/waitlist_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fixtures.dart';
import '../helpers/harness.dart';

WaitlistScreen waitlistScreen() =>
    const WaitlistScreen(movie: MockData.dune, showtime: testShowtime);

void main() {
  testWidgets('renders sold-out queue odds and drop automation', (
    tester,
  ) async {
    await pumpScreen(tester, waitlistScreen());

    expect(find.text('Waitlist & Drop Alert'), findsOneWidget);
    expect(find.text('SHOWTIME 100% SOLD OUT'), findsOneWidget);
    expect(find.text('48 WAITING'), findsWidgets);
    expect(find.text('Queue Odds: High Release'), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);
    expect(find.text('Number of Seats'), findsOneWidget);
    expect(find.text('Preferred Seating Zone'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('FAST-ACTION AUTOMATION'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Auto-Lock & Purchase'), findsOneWidget);
    expect(find.text('Critical Audio Push'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Join Waitlist & Set Drop Alert'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Join Waitlist & Set Drop Alert'), findsOneWidget);
  });

  testWidgets('joins the waitlist and arms the drop alert', (tester) async {
    await pumpScreen(tester, waitlistScreen());

    await tester.scrollUntilVisible(
      find.text('Join Waitlist & Set Drop Alert'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Join Waitlist & Set Drop Alert'));
    await tester.pump();
    await tester.tap(find.text('Join Waitlist & Set Drop Alert'));
    await tester.pump();

    expect(find.text('On the Waitlist • #5 in Line'), findsOneWidget);
    expect(find.text('Drop alert armed — you are #5 in line.'), findsOneWidget);
  });

  testWidgets('switches the preferred seating zone', (tester) async {
    await pumpScreen(tester, waitlistScreen());

    await tester.scrollUntilVisible(
      find.text('Any 2 Together'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Any 2 Together'));
    await tester.pump();

    expect(find.text('Any 2 Together'), findsOneWidget);
  });

  testWidgets('sold-out showtime opens the waitlist from movie details', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const MovieDetailsScreen(movie: MockData.dune),
      settle: false,
    );

    await tester.scrollUntilVisible(
      find.text('11:30 PM'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('11:30 PM'));
    await tester.pump();
    await tester.tap(find.text('11:30 PM'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(WaitlistScreen), findsOneWidget);
    expect(find.text('SHOWTIME 100% SOLD OUT'), findsOneWidget);
  });
}
