import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();
  runApp(const IntentFlowApp());
}

class IntentFlowApp extends StatelessWidget {
  const IntentFlowApp({super.key});

  @override
  Widget build(BuildContext context) => Provider<AuthService>(
        create: (_) => AuthService(),
        child: MaterialApp(
          title: 'IntentFlow',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          home: const AuthGate(),
        ),
      );
}
