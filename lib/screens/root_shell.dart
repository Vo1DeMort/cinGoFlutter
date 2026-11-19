import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';
import '../widgets/bottom_nav.dart';
import 'bookings_screen.dart';
import 'cinemas_screen.dart';
import 'home_screen.dart';
import 'movies_screen.dart';
import 'profile_screen.dart';

class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(
      appStateProvider.select((state) => state.tabIndex),
    );
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0F131C),
      body: IndexedStack(
        index: tabIndex,
        children: const [
          HomeScreen(),
          MoviesScreen(),
          CinemasScreen(),
          BookingsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: CineGoBottomNav(
          selectedIndex: tabIndex,
          onTap: (index) => ref.read(appStateProvider).selectTab(index),
        ),
      ),
    );
  }
}
