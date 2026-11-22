import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../main/home_shell.dart';
import 'auth_flow.dart';

/// Single source of truth for navigation based on Firebase auth state:
///   signed out -> welcome / onboarding / login / register
///   signed in  -> the app (HomeShell) for that uid
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return StreamBuilder<User?>(
      stream: auth.userChanges,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snap.data;
        if (user == null) return const AuthFlow();
        return HomeShell(key: ValueKey(user.uid), uid: user.uid);
      },
    );
  }
}
