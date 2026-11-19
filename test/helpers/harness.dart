import 'package:cinego/theme/app_colors.dart';
import 'package:cinego/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a container that is disposed automatically at the end of the test.
ProviderContainer createTestContainer() => ProviderContainer.test();

Widget buildTestApp(Widget home, {ProviderContainer? container}) {
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildCineGoTheme(),
    home: home,
  );
  if (container != null) {
    return UncontrolledProviderScope(container: container, child: app);
  }
  return ProviderScope(child: app);
}

/// Pumps a root-tab screen (which expects to live inside a Scaffold body).
Future<ProviderContainer> pumpTab(
  WidgetTester tester,
  Widget screen, {
  ProviderContainer? container,
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final scope = container ?? createTestContainer();
  await tester.pumpWidget(
    buildTestApp(
      Scaffold(backgroundColor: AppColors.surface, body: screen),
      container: scope,
    ),
  );
  await tester.pumpAndSettle();
  return scope;
}

/// Pumps a full-page screen that provides its own Scaffold.
Future<ProviderContainer> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  ProviderContainer? container,
  Size size = const Size(430, 932),
  bool settle = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final scope = container ?? createTestContainer();
  await tester.pumpWidget(buildTestApp(screen, container: scope));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }
  return scope;
}

/// Pumps a single widget inside a Scaffold for component tests.
Future<void> pumpWidgetInScaffold(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildCineGoTheme(),
      home: Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: child),
      ),
    ),
  );
  await tester.pump();
}
