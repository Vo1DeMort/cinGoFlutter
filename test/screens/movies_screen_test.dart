import 'package:cinego/screens/movies_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('renders now showing and coming soon tabs', (tester) async {
    await pumpTab(tester, const MoviesScreen());

    expect(find.text('Now Showing'), findsWidgets);
    expect(find.text('Coming Soon'), findsWidgets);
    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(find.text('Oppenheimer'), findsOneWidget);
  });

  testWidgets('searches titles and clears the result set', (tester) async {
    await pumpTab(tester, const MoviesScreen());

    await tester.enterText(find.byType(TextField), 'dune');
    await tester.pumpAndSettle();

    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(find.text('Oppenheimer'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('Oppenheimer'), findsOneWidget);
  });

  testWidgets('switches to coming soon and opens a pre-book details page', (
    tester,
  ) async {
    await pumpTab(tester, const MoviesScreen());

    await tester.tap(find.text('Coming Soon').first);
    await tester.pumpAndSettle();
    expect(find.text('Gladiator II'), findsOneWidget);

    await tester.ensureVisible(find.text('Gladiator II'));
    await tester.tap(find.text('Gladiator II'));
    await tester.pumpAndSettle();
    expect(find.text('Select Date'), findsOneWidget);
  });

  testWidgets('opens the refine results sheet', (tester) async {
    await pumpTab(tester, const MoviesScreen());

    await tester.tap(find.byIcon(Icons.tune_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Refine results'), findsOneWidget);
    expect(find.text('GENRE'), findsOneWidget);
    expect(find.text('SORT BY'), findsOneWidget);

    await tester.tap(find.text('Show 9 results'));
    await tester.pumpAndSettle();
    expect(find.text('Refine results'), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('filters the catalogue by genre chip', (tester) async {
    await pumpTab(tester, const MoviesScreen());

    await tester.tap(find.text('ACTION'));
    await tester.pumpAndSettle();

    expect(find.text('Furiosa: A Mad Max Saga'), findsOneWidget);
    expect(find.text('Dune: Part Two'), findsNothing);
    expect(find.text('ACTION'), findsWidgets);
  });
}
