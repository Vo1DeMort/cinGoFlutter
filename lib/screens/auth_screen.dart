import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cinego_logo.dart';
import '../widgets/ui_kit.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.initialMode = 0});

  /// 0 = Sign In, 1 = Create Account.
  final int initialMode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late int _mode = widget.initialMode.clamp(0, 1);
  bool _obscure = true;
  bool _remember = true;
  bool _submitting = false;

  final TextEditingController _email = TextEditingController(
    text: 'alex.chen@example.com',
  );
  final TextEditingController _password = TextEditingController(text: 'cinego');
  final TextEditingController _name = TextEditingController(text: 'Alex Chen');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  void _toast(String message, {IconData? icon}) {
    showCineSnack(context, message, icon: icon);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    ref.read(appStateProvider).signIn(remember: _remember);
    _toast(
      _mode == 0 ? 'Welcome back, Alex.' : 'Your CinePass account is ready.',
      icon: Icons.check_circle_outline_rounded,
    );
    Navigator.of(context).pop(true);
  }

  void _close() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      ref.read(appStateProvider).selectTab(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignIn = _mode == 0;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.close_rounded,
                    size: 38,
                    background: AppColors.surfaceLow,
                    onTap: _close,
                  ),
                  const Spacer(),
                  const CineGoWordmark(fontSize: 17),
                  const Spacer(),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'CINEPASS™ READY',
                              style: AppText.labelFormat.copyWith(
                                fontSize: 7,
                                color: AppColors.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Row(
                          children: [
                            Text(
                              'Explore as Guest',
                              style: AppText.bodySmall.copyWith(
                                fontSize: 9.5,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: AppColors.tertiary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildHero(),
                  const SizedBox(height: 16),
                  SegmentedPills(
                    labels: const ['Sign In', 'Create Account'],
                    selectedIndex: _mode,
                    onChanged: (index) => setState(() => _mode = index),
                    height: 46,
                    fontSize: 12.5,
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!isSignIn) ...[
                          _FieldLabel(
                            label: 'Full Legal Name',
                            trailing: 'As printed on CinePass',
                          ),
                          const SizedBox(height: 6),
                          _AuthField(
                            controller: _name,
                            icon: Icons.badge_outlined,
                            hint: 'Alex Chen',
                            textInputType: TextInputType.name,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _FieldLabel(
                          label: 'Email or CinePass ID',
                          trailing: 'user@vip.cinego',
                        ),
                        const SizedBox(height: 6),
                        _AuthField(
                          controller: _email,
                          icon: Icons.confirmation_number_outlined,
                          hint: 'name@example.com or CinePass ID',
                          textInputType: TextInputType.emailAddress,
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) return 'Enter your email or ID';
                            if (text.contains('@') && !text.contains('.')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'PASSWORD',
                              style: AppText.labelCaps.copyWith(
                                fontSize: 6.5,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _toast(
                                'Password reset link sent to ${_email.text.trim()}.',
                                icon: Icons.lock_reset_rounded,
                              ),
                              child: Text(
                                'Forgot?',
                                style: AppText.bodySmall.copyWith(
                                  fontSize: 9,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _AuthField(
                          controller: _password,
                          icon: Icons.lock_outline_rounded,
                          hint: '••••••••••••',
                          obscure: _obscure,
                          trailing: GestureDetector(
                            onTap: () => setState(() => _obscure = !_obscure),
                            child: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: AppColors.outline,
                            ),
                          ),
                          validator: (value) {
                            if ((value ?? '').length < 4) {
                              return 'Password must be at least 4 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _remember = !_remember),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: _remember
                                          ? AppColors.tertiary
                                          : AppColors.surfaceHigh,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: _remember
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 13,
                                            color: AppColors.onTertiary,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    'Keep my session active (30d)',
                                    style: AppText.bodySmall.copyWith(
                                      fontSize: 9.5,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.shield_outlined,
                              size: 12,
                              color: AppColors.tertiary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'SSL 256',
                              style: AppText.ticketCode.copyWith(
                                fontSize: 8.5,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: _submitting
                              ? 'Authenticating…'
                              : isSignIn
                                  ? 'Sign In to CineGo'
                                  : 'Create VIP Account',
                          trailingIcon: Icons.arrow_forward_rounded,
                          height: 52,
                          fontSize: 13,
                          onTap: _submitting ? null : _submit,
                        ),
                        const SizedBox(height: 9),
                        GestureDetector(
                          onTap: () => _toast(
                            'Biometric sign-in is not available in this demo.',
                            icon: Icons.fingerprint_rounded,
                          ),
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLow,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiary.withOpacity(0.14),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.fingerprint_rounded,
                                    size: 15,
                                    color: AppColors.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'Quick Login with Face ID / Passkey',
                                  style: AppText.bodySmall.copyWith(
                                    fontSize: 10.5,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.white10, height: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'OR SIGN IN WITH',
                          style: AppText.labelCaps.copyWith(
                            fontSize: 6.5,
                            color: AppColors.outline,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.white10, height: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _SocialButton(
                        icon: Icons.apple_rounded,
                        label: 'Apple',
                        onTap: () => _toast(
                          'Apple sign-in is not wired up in this demo.',
                          icon: Icons.apple_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SocialButton(
                        icon: Icons.g_mobiledata_rounded,
                        label: 'Google',
                        onTap: () => _toast(
                          'Google sign-in is not wired up in this demo.',
                          icon: Icons.g_mobiledata_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SocialButton(
                        icon: Icons.contactless_rounded,
                        label: 'CinePass',
                        accent: true,
                        onTap: () => _toast(
                          'Hold your CinePass card near the phone (demo).',
                          icon: Icons.contactless_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLowest.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.theaters_outlined,
                          size: 20,
                          color: AppColors.outline,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SUPPORTED FORMATS',
                                style: AppText.labelCaps.copyWith(
                                  fontSize: 6.5,
                                  color: AppColors.outline,
                                ),
                              ),
                              Text(
                                'IMAX • DOLBY • REALD 3D',
                                style: AppText.ticketCode.copyWith(
                                  fontSize: 9.5,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighest,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'LIVE SSO',
                            style: AppText.ticketCode.copyWith(
                              fontSize: 7,
                              color: AppColors.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'By continuing, you agree to CineGo\'s ',
                          style: AppText.bodySmall.copyWith(
                            fontSize: 8.5,
                            height: 1.5,
                            color: AppColors.outline,
                          ),
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: AppText.bodySmall.copyWith(
                            fontSize: 8.5,
                            height: 1.5,
                            color: AppColors.onSurfaceVariant,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: AppText.bodySmall.copyWith(
                            fontSize: 8.5,
                            height: 1.5,
                            color: AppColors.outline,
                          ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppText.bodySmall.copyWith(
                            fontSize: 8.5,
                            height: 1.5,
                            color: AppColors.onSurfaceVariant,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: '.',
                          style: AppText.bodySmall.copyWith(
                            fontSize: 8.5,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'CineGo v2.4.1 • Encrypted CinemaPass Vault',
                    textAlign: TextAlign.center,
                    style: AppText.labelCaps.copyWith(
                      fontSize: 6.5,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white06),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_cinema.jpg',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.3),
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: AppColors.surfaceHigh,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.surfaceLow.withOpacity(0.55),
                    AppColors.surfaceLow.withOpacity(0.92),
                    AppColors.surfaceLow,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighest,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.tertiary.withOpacity(0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.movie_filter_rounded,
                    size: 26,
                    color: AppColors.tertiary,
                  ),
                ),
                const SizedBox(height: 8),
                const CineGoWordmark(fontSize: 27, showMark: false),
                const SizedBox(height: 4),
                Text(
                  'Your front-row seat to the silver screen.',
                  textAlign: TextAlign.center,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 9.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          size: 17,
                          color: AppColors.tertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VIP ADVANTAGE',
                              style: AppText.labelCaps.copyWith(
                                fontSize: 6,
                                color: AppColors.tertiary,
                              ),
                            ),
                            Text(
                              'Earn 200 pts & waived fees on your first 3 tickets',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.bodySmall.copyWith(
                                fontSize: 8.5,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.trailing});

  final String label;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: AppText.labelCaps.copyWith(
            fontSize: 6.5,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const Spacer(),
        Text(
          trailing,
          style: AppText.bodySmall.copyWith(
            fontSize: 8,
            color: AppColors.tertiary,
          ),
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.obscure = false,
    this.trailing,
    this.textInputType,
    this.validator,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: AppColors.white06),
    );
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: textInputType,
      validator: validator,
      cursorColor: AppColors.tertiary,
      style: AppText.bodySmall.copyWith(
        fontSize: 11,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.surfaceLow,
        hintText: hint,
        hintStyle: AppText.bodySmall.copyWith(
          fontSize: 10,
          color: AppColors.outlineVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        prefixIcon: Icon(icon, size: 18, color: AppColors.outline),
        suffixIcon: trailing == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 12),
                child: trailing,
              ),
        suffixIconConstraints: const BoxConstraints(minWidth: 40),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.tertiary.withOpacity(0.7)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.error.withOpacity(0.7)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.error.withOpacity(0.7)),
        ),
        errorStyle: AppText.bodySmall.copyWith(
          fontSize: 8.5,
          color: AppColors.error,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.white06),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: accent ? AppColors.tertiary : AppColors.onSurface,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 9.5,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
