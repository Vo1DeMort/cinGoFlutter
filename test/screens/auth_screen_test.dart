import 'package:cinego/screens/auth_screen.dart';
import 'package:cinego/state/app_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Future<void> openAuth(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    buildTestApp(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<bool>(builder: (_) => const AuthScreen()),
              ),
              child: const Text('Open auth'),
            ),
          ),
        ),
      ),
      container: container,
    ),
  );
  await tester.tap(find.text('Open auth'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders sign in form and switches to registration', (
    tester,
  ) async {
    await pumpScreen(tester, const AuthScreen());

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign In to CineGo'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('FULL LEGAL NAME'), findsOneWidget);
    expect(find.text('Create VIP Account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });

  testWidgets('toggles password visibility', (tester) async {
    await pumpScreen(tester, const AuthScreen());

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('validates empty and malformed credentials', (tester) async {
    await pumpScreen(tester, const AuthScreen());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '');
    await tester.enterText(fields.at(1), '');
    await tester.tap(find.text('Sign In to CineGo'));
    await tester.pump();

    expect(find.text('Enter your email or ID'), findsOneWidget);
    expect(find.text('Password must be at least 4 characters'), findsOneWidget);

    await tester.enterText(fields.at(0), 'invalid@');
    await tester.enterText(fields.at(1), 'cinego');
    await tester.tap(find.text('Sign In to CineGo'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('signs in and closes the flow', (tester) async {
    final container = createTestContainer();
    await openAuth(tester, container);

    await tester.tap(find.text('Sign In to CineGo'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Open auth'), findsOneWidget);
    expect(container.read(appStateProvider).loggedIn, isTrue);
  });

  testWidgets('social providers show demo notices', (tester) async {
    await pumpScreen(tester, const AuthScreen());

    await tester.tap(find.byIcon(Icons.apple_rounded));
    await tester.pump();
    expect(
      find.text('Apple sign-in is not wired up in this demo.'),
      findsOneWidget,
    );
  });
}
