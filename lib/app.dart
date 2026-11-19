import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/root_shell.dart';
import 'theme/app_theme.dart';

class CineGoApp extends StatelessWidget {
  const CineGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'CineGo',
        debugShowCheckedModeBanner: false,
        theme: buildCineGoTheme(),
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          physics: const BouncingScrollPhysics(),
        ),
        home: const RootShell(),
      ),
    );
  }
}
