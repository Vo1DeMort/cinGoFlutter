import 'package:cinego/app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the home screen and bottom navigation', (tester) async {
    await tester.pumpWidget(const CineGoApp());
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('MOVIES'), findsWidgets);
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('switches between all five tabs', (tester) async {
    await tester.pumpWidget(const CineGoApp());
    await tester.pumpAndSettle();

    for (final label in ['MOVIES', 'CINEMAS', 'BOOKINGS', 'PROFILE', 'HOME']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'tab $label');
    }
  });
}
