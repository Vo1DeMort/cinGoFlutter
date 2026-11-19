import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/ui_kit.dart';
import 'auth_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _offlinePasses = true;

  void _toast(String message, {IconData? icon}) {
    showCineSnack(context, message, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    return Column(
      children: [
        RootHeader(
          onLocationTap: () => state.selectTab(2),
          onAvatarTap: () => state.selectTab(4),
          onNotificationTap: () => _toast(
            'No new notifications right now.',
            icon: Icons.notifications_none_rounded,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            children: [
              _buildProfileCard(),
              const SizedBox(height: 12),
              _buildTierCard(),
              const SizedBox(height: 18),
              _sectionTitle(Icons.chair_outlined, 'Cinema Experience'),
              const SizedBox(height: 8),
              _buildCinemaExperience(),
              const SizedBox(height: 18),
              _sectionTitle(Icons.payments_outlined, 'Payments & Automation'),
              const SizedBox(height: 8),
              _buildPayments(state),
              const SizedBox(height: 18),
              _sectionTitle(Icons.settings_outlined, 'App Preferences & Support'),
              const SizedBox(height: 8),
              _buildPreferences(state),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final signedOut = await Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => const AuthScreen(initialMode: 1),
                    ),
                  );
                  if (!mounted) return;
                  if (signedOut == true) {
                    ref.read(appStateProvider).signIn();
                  }
                },
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Log Out of CineGo',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Column(
                children: [
                  Text(
                    'CineGo Mobile v2.4.1',
                    style: AppText.labelCaps.copyWith(
                      fontSize: 7,
                      color: AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Flutter 3.24 • Build 842 (Production San Francisco)',
                    style: AppText.labelCaps.copyWith(
                      fontSize: 6.5,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppText.headlineSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2030), Color(0xFF131722), AppColors.surfaceLow],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.tertiary.withOpacity(0.7),
                        width: 1.5,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/avatar_alex.jpg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tertiary.withOpacity(0.18),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.amber,
                        border: Border.all(color: AppColors.surfaceLow, width: 2),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alex Chen',
                      style: AppText.headlineSmall.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'alex.chen@example.com',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CINEPASS VIP MEMBER',
                        style: AppText.labelCaps.copyWith(
                          fontSize: 5.5,
                          color: AppColors.amber,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _toast(
                  'Profile editing is outside this UI demo.',
                  icon: Icons.edit_outlined,
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest.withOpacity(0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _stat('24', 'WATCHED')),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.white10,
                ),
                Expanded(
                  child: _stat('4,850', 'POINTS', color: AppColors.tertiary),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.white10,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.card_giftcard_rounded,
                        size: 13,
                        color: AppColors.amber,
                      ),
                      const SizedBox(width: 4),
                      _stat('3', 'FREE PERKS'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: AppText.headlineSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color ?? AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: AppText.labelCaps.copyWith(
            fontSize: 6.5,
            color: AppColors.outline,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }

  Widget _buildTierCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white06),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  size: 19,
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT TIER',
                      style: AppText.labelCaps.copyWith(
                        fontSize: 6.5,
                        color: AppColors.outline,
                      ),
                    ),
                    Text(
                      'CinePass Gold • Level 3',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#CP-84928',
                  style: AppText.labelFormat.copyWith(
                    fontSize: 7,
                    color: AppColors.tertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Progress to Platinum Tier',
                style: AppText.bodySmall.copyWith(
                  fontSize: 8.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '150 pts left',
                style: AppText.labelCaps.copyWith(
                  fontSize: 7.5,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.86,
              minHeight: 5,
              backgroundColor: AppColors.surfaceHigh,
              valueColor: AlwaysStoppedAnimation(AppColors.tertiary),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                'Gold (4,000)',
                style: AppText.labelCaps.copyWith(
                  fontSize: 6.5,
                  color: AppColors.outline,
                ),
              ),
              const Spacer(),
              Text(
                'Platinum (5,000)',
                style: AppText.labelCaps.copyWith(
                  fontSize: 6.5,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 34,
            width: double.infinity,
            child: Material(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: () => _toast(
                  'Popcorn & soda voucher added to your account.',
                  icon: Icons.local_activity_outlined,
                ),
                borderRadius: BorderRadius.circular(999),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_activity_outlined,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Redeem Free Popcorn & Soda',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaExperience() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white06),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.theaters_outlined,
                  size: 17,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOME THEATER',
                      style: AppText.labelCaps.copyWith(
                        fontSize: 6.5,
                        color: AppColors.outline,
                      ),
                    ),
                    Text(
                      'AMC Metreon 16 & IMAX',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'San Francisco, CA',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 8,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(appStateProvider).selectTab(2),
                child: Row(
                  children: [
                    Text(
                      'Change',
                      style: AppText.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'FAVORITE FORMATS',
              style: AppText.labelCaps.copyWith(
                fontSize: 6.5,
                color: AppColors.outline,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                FormatTag('IMAX 70MM', compact: true),
                FormatTag(
                  'DOLBY CINEMA',
                  color: AppColors.secondary,
                  compact: true,
                ),
                FormatTag(
                  'REALD 3D',
                  color: AppColors.primary,
                  compact: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.event_seat_outlined,
                size: 14,
                color: AppColors.outline,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'SEATING PREFERENCE\n',
                        style: AppText.labelCaps.copyWith(
                          fontSize: 6.5,
                          color: AppColors.outline,
                        ),
                      ),
                      TextSpan(
                        text: 'Center Sweetspot • Recliner Pods',
                        style: AppText.bodySmall.copyWith(
                          fontSize: 9.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(
                Icons.tune_rounded,
                size: 14,
                color: AppColors.outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayments(AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white06),
      ),
      child: Column(
        children: [
          _settingsRow(
            icon: Icons.credit_card_rounded,
            title: 'Payment Methods',
            subtitle: 'Apple Pay (•••• 4821)',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '\$34.50 BAL',
                style: AppText.labelFormat.copyWith(
                  fontSize: 6.5,
                  color: AppColors.tertiary,
                ),
              ),
            ),
            onTap: () => _toast(
              'Manage payment methods in checkout.',
              icon: Icons.credit_card_rounded,
            ),
          ),
          const Divider(color: AppColors.white10, height: 1),
          _settingsRow(
            icon: Icons.notifications_active_outlined,
            title: 'Showtime & Gate Alerts',
            subtitle: 'Instant push 45 min before lights out',
            trailing: Switch(
              value: state.notificationsEnabled,
              onChanged: (value) =>
                  ref.read(appStateProvider).setNotifications(value),
            ),
          ),
          const Divider(color: AppColors.white10, height: 1),
          _settingsRow(
            icon: Icons.event_available_outlined,
            title: 'Auto-Sync to Calendar',
            subtitle: 'Add booked passes to Apple Calendar',
            trailing: Switch(
              value: state.calendarSyncEnabled,
              onChanged: (value) =>
                  ref.read(appStateProvider).setCalendarSync(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences(AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white06),
      ),
      child: Column(
        children: [
          _settingsRow(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Appearance',
            subtitle: 'Always On (Cinema Blackout)',
            trailing: const Icon(
              Icons.check_circle_rounded,
              size: 17,
              color: AppColors.tertiary,
            ),
          ),
          const Divider(color: AppColors.white10, height: 1),
          _settingsRow(
            icon: Icons.download_for_offline_outlined,
            title: 'Download Passes Offline',
            subtitle: 'Access QR gate codes without cell service',
            trailing: Switch(
              value: _offlinePasses,
              onChanged: (value) => setState(() => _offlinePasses = value),
            ),
          ),
          const Divider(color: AppColors.white10, height: 1),
          _settingsRow(
            icon: Icons.support_agent_rounded,
            title: 'Cinema Concierge & Help',
            subtitle: 'Priority 24/7 VIP chat assistance',
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: AppColors.outline,
            ),
            onTap: () => _toast(
              'Concierge chat is not part of this demo.',
              icon: Icons.support_agent_rounded,
            ),
          ),
          const Divider(color: AppColors.white10, height: 1),
          _settingsRow(
            icon: Icons.shield_outlined,
            title: 'Terms of Service & Privacy',
            subtitle: 'CinePass member agreement',
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: AppColors.outline,
            ),
            onTap: () => _toast(
              'Legal documents are outside this demo.',
              icon: Icons.shield_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.bodySmall.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySmall.copyWith(
                      fontSize: 8,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            trailing,
          ],
        ),
      ),
    );
  }
}
