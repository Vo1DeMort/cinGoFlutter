import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the app's bundled fonts so widget tests measure real text instead of
/// the default fixed-width Ahem test font.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final jakarta = FontLoader('PlusJakartaSans');
  for (var index = 1; index <= 5; index++) {
    jakarta.addFont(rootBundle.load('assets/fonts/PlusJakartaSans-$index.ttf'));
  }
  await jakarta.load();

  final mono = FontLoader('JetBrainsMono');
  for (var index = 1; index <= 3; index++) {
    mono.addFont(rootBundle.load('assets/fonts/JetBrainsMono-$index.ttf'));
  }
  await mono.load();

  await testMain();
}
