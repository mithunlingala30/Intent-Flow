import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme.dart';
import '../../widgets/common.dart';
import 'auth_widgets.dart';
import 'login_screen.dart';
import 'register_screen.dart';

enum _Stage { loading, splash, onboarding, login, register }

/// Splash -> onboarding -> login/register (only shown while signed out).
class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});
  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  static const _seenKey = 'onboarding_seen';
  _Stage _stage = _Stage.loading;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    bool seen = false;
    try {
      seen = (await SharedPreferences.getInstance()).getBool(_seenKey) ?? false;
    } catch (_) {}
    if (!mounted) return;
    setState(() => _stage = seen ? _Stage.login : _Stage.splash);
  }

  Future<void> _markSeen() async {
    try {
      (await SharedPreferences.getInstance()).setBool(_seenKey, true);
    } catch (_) {}
  }

  void _goto(_Stage s) {
    if (s == _Stage.login || s == _Stage.register) _markSeen();
    setState(() => _stage = s);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (_stage) {
        _Stage.loading => const Scaffold(
            key: ValueKey('loading'),
            body: Center(child: CircularProgressIndicator())),
        _Stage.splash => _splash(),
        _Stage.onboarding => _onboarding(),
        _Stage.login => LoginScreen(
            key: const ValueKey('login'),
            onRegister: () => _goto(_Stage.register)),
        _Stage.register => RegisterScreen(
            key: const ValueKey('register'),
            onLogin: () => _goto(_Stage.login)),
      },
    );
  }

  Widget _splash() => AuthFrame(
        key: const ValueKey('splash'),
        child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Brand(),
                const SizedBox(height: 28),
                const Illustration(),
                const SizedBox(height: 28),
                Text('Meet your new flow.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                const Text(
                    'A calmer, smarter way to get things done.\nIt all starts with a little intention.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, height: 1.4)),
                const SizedBox(height: 30),
                PrimaryButton(
                    label: 'Find your flow',
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      _step = 0;
                      _goto(_Stage.onboarding);
                    }),
                TextButton(
                    onPressed: () => _goto(_Stage.login),
                    child: const Text('I already have an account')),
              ],
        ),
      );

  static const _titles = [
    'Tell us what you need.',
    'We understand your intent.',
    'Your tasks, automatically managed.',
  ];
  static const _texts = [
    'A reminder, a meeting, a little me-time. Just tell us in your own words.',
    'We find the what, when, and how — turning your words into a thoughtful plan.',
    'From scheduled tasks to timely nudges. You focus on living; we handle the little things.',
  ];

  Widget _onboarding() => AuthFrame(
        key: const ValueKey('onboarding'),
        child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Eyebrow('HOW IT FLOWS · 0${_step + 1}'),
                const SizedBox(height: 22),
                Illustration(success: _step == 2),
                const SizedBox(height: 26),
                Text(_titles[_step],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 10),
                Text(_texts[_step],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted, height: 1.4)),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 3; i++)
                      GestureDetector(
                        onTap: () => setState(() => _step = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _step == i ? 26 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: _step == i
                                  ? AppColors.purple
                                  : AppColors.purpleLight.withOpacity(.5),
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 26),
                PrimaryButton(
                  label: _step == 2 ? 'Get started' : 'Keep flowing',
                  icon: Icons.arrow_forward,
                  onPressed: () => _step < 2
                      ? setState(() => _step++)
                      : _goto(_Stage.register),
                ),
                TextButton(
                    onPressed: () => _goto(_Stage.login),
                    child: const Text('Skip for now')),
              ],
        ),
      );
}
