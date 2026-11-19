import 'package:cinego/screens/cinemas_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('shows location, featured cinema and tech showcase', (
    tester,
  ) async {
    await pumpTab(tester, const CinemasScreen());

    expect(find.text('San Francisco Bay Area'), findsOneWidget);
    expect(find.text('YOUR HOME THEATER'), findsOneWidget);
    expect(find.text('AMC Metreon 16 & IMAX'), findsOneWidget);
    expect(find.text('Nearby Theaters'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Cinema Tech Showcase'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cinema Tech Showcase'), findsOneWidget);
  });

  testWidgets('toggles between list and map views', (tester) async {
    await pumpTab(tester, const CinemasScreen());

    await tester.tap(find.text('INTERACTIVE MAP'));
    await tester.pumpAndSettle();
    expect(find.text('YOUR HOME THEATER'), findsNothing);
    expect(find.text('Bay Area Radar View'), findsWidgets);

    await tester.tap(find.text('THEATERS LIST'));
    await tester.pumpAndSettle();
    expect(find.text('YOUR HOME THEATER'), findsOneWidget);
  });

  testWidgets('filters cinemas by format', (tester) async {
    await pumpTab(tester, const CinemasScreen());

    await tester.scrollUntilVisible(
      find.text('DOLBY CINEMA'),
      120,
      scrollable: find
          .ancestor(
            of: find.text('ALL THEATERS'),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('DOLBY CINEMA'));
    await tester.pumpAndSettle();

    expect(find.text('FILTERED BY'), findsOneWidget);
    expect(find.text('DOLBY CINEMA'), findsWidgets);
  });

  testWidgets('selects a nearby cinema', (tester) async {
    await pumpTab(tester, const CinemasScreen());

    await tester.scrollUntilVisible(
      find.text('Regal Stonestown & ScreenX'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Regal Stonestown & ScreenX'));
    await tester.pump();

    expect(
      find.text('Regal Stonestown & ScreenX selected as your home theater.'),
      findsOneWidget,
    );
  });
}
