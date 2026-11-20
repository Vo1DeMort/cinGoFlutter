import 'package:cinego/screens/auth_screen.dart';
import 'package:cinego/screens/offline_screen.dart';
import 'package:cinego/screens/profile_screen.dart';
import 'package:cinego/state/app_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('renders the member profile and preferences', (tester) async {
    await pumpTab(tester, const ProfileScreen());

    expect(find.text('Alex Chen'), findsOneWidget);
    expect(find.text('CinePass Gold • Level 3'), findsOneWidget);
    expect(find.text('Progress to Platinum Tier'), findsOneWidget);
    expect(find.text('Cinema Experience'), findsOneWidget);
    expect(find.text('Payments & Automation'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Log Out of CineGo'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Log Out of CineGo'), findsOneWidget);
  });

  testWidgets('toggles notification preferences through Riverpod', (
    tester,
  ) async {
    final container = await pumpTab(tester, const ProfileScreen());
    expect(container.read(appStateProvider).notificationsEnabled, isTrue);

    await tester.ensureVisible(find.text('Showtime & Gate Alerts'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(container.read(appStateProvider).notificationsEnabled, isFalse);
  });

  testWidgets('opens the offline cache screen from preferences', (
    tester,
  ) async {
    await pumpTab(tester, const ProfileScreen());

    await tester.scrollUntilVisible(
      find.text('Connection & Offline Cache'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Connection & Offline Cache'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connection & Offline Cache'));
    await tester.pumpAndSettle();

    expect(find.byType(OfflineScreen), findsOneWidget);
    expect(find.text("You're Currently Offline"), findsOneWidget);
  });

  testWidgets('opens the auth screen from log out', (tester) async {
    await pumpTab(tester, const ProfileScreen());

    await tester.scrollUntilVisible(
      find.text('Log Out of CineGo'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Log Out of CineGo'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Create VIP Account'), findsOneWidget);
  });
}
