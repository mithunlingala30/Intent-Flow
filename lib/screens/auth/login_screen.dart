import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../utils/validators.dart';
import '../../widgets/common.dart';
import 'auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onRegister});
  final VoidCallback onRegister;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _googleBusy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context
          .read<AuthService>()
          .signIn(email: _email.text, password: _password.text);
      // AuthGate reacts to the auth stream and swaps this screen out.
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    setState(() {
      _googleBusy = true;
      _error = null;
    });
    try {
      await context.read<AuthService>().signInWithGoogle();
    } on AuthFailure catch (e) {
      if (mounted && e.code != 'cancelled') setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _googleBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return AuthScaffold(
      eyebrow: 'YOUR CALMER EVERYDAY STARTS HERE',
      title: 'Welcome to your flow.',
      subtitle: 'A little less to do. A little more you.',
      child: Column(children: [
        if (_error != null) ErrorBanner(_error!),
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(children: [
              TextFormField(
                controller: _email,
                enabled: !_busy,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.mail_outline)),
                validator: Validators.email,
              ),
              const SizedBox(height: 14),
              PasswordField(
                controller: _password,
                label: 'Password',
                enabled: !_busy,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: (v) => Validators.required(v, 'Enter your password'),
              ),
            ]),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => showForgotPasswordDialog(
                context, auth.sendPasswordReset,
                initialEmail: _email.text),
            child: const Text('Forgot password?'),
          ),
        ),
        PrimaryButton(
            label: 'Step into your flow',
            icon: Icons.arrow_forward,
            loading: _busy,
            onPressed: _submit),
        const OrDivider(),
        GoogleButton(onPressed: _busy ? null : _google, busy: _googleBusy),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('New to IntentFlow?',
              style: TextStyle(color: AppColors.muted)),
          TextButton(
              onPressed: widget.onRegister,
              child: const Text('Create an account')),
        ]),
      ]),
    );
  }
}
