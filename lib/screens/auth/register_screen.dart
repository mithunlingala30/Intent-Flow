import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../utils/validators.dart';
import '../../widgets/common.dart';
import 'auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onLogin});
  final VoidCallback onLogin;
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _googleBusy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
      await context.read<AuthService>().register(
          name: _name.text, email: _email.text, password: _password.text);
      // AuthGate swaps in the app as soon as Firebase signs the user in.
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
  Widget build(BuildContext context) => AuthScaffold(
        eyebrow: 'YOUR CALMER EVERYDAY STARTS HERE',
        title: 'A fresh start. Your way.',
        subtitle: 'Create a little space for what matters.',
        child: Column(children: [
          if (_error != null) ErrorBanner(_error!),
          Form(
            key: _form,
            child: AutofillGroup(
              child: Column(children: [
                TextFormField(
                  controller: _name,
                  enabled: !_busy,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: Validators.name,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newUsername],
                  decoration: const InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: Icon(Icons.mail_outline)),
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                PasswordField(
                  controller: _password,
                  label: 'Password (8+ characters, letters & numbers)',
                  enabled: !_busy,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                  validator: Validators.newPassword,
                ),
                const SizedBox(height: 14),
                PasswordField(
                  controller: _confirm,
                  label: 'Confirm password',
                  enabled: !_busy,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (v) =>
                      v != _password.text ? 'Passwords must match' : null,
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
              label: 'Create account',
              icon: Icons.arrow_forward,
              loading: _busy,
              onPressed: _submit),
          const OrDivider(),
          GoogleButton(onPressed: _busy ? null : _google, busy: _googleBusy),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Already found your flow?',
                style: TextStyle(color: AppColors.muted)),
            TextButton(onPressed: widget.onLogin, child: const Text('Log in')),
          ]),
        ]),
      );
}
