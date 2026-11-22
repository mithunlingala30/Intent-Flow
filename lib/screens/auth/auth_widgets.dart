import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/responsive.dart';

/// Responsive frame for every signed-out screen.
/// Desktop/web: split layout (brand panel + neumorphic form card).
/// Mobile: single centered column.
class AuthFrame extends StatelessWidget {
  const AuthFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop(context)) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: NeuCard(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                    child: child),
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: Row(children: [
        Expanded(flex: 5, child: _visualPanel(context)),
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 32, 48, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: NeuCard(
                    padding: const EdgeInsets.fromLTRB(38, 36, 38, 32),
                    child: child),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _visualPanel(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 16, 32),
        child: NeuSurface(
          radius: 40,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Brand(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Illustration(size: 240),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Eyebrow('A LITTLE INTENT CHANGES EVERYTHING.'),
                      const SizedBox(height: 12),
                      Text('Your intent.\nOur automation.',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -1.4)),
                      const SizedBox(height: 12),
                      const Text('Less on your mind.\nMore space for what matters.',
                          style: TextStyle(color: AppColors.muted, fontSize: 16, height: 1.45)),
                      const SizedBox(height: 24),
                      const Text('THOUGHTFULLY BUILT FOR YOUR EVERYDAY.',
                          style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

/// Heading + form column used by login / register.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold(
      {super.key, required this.eyebrow, required this.title, required this.subtitle, required this.child});
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => AuthFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isDesktop(context)) ...[
              const Center(child: Brand()),
              const SizedBox(height: 24),
            ],
            Eyebrow(eyebrow),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 22),
            child,
          ],
        ),
      );
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
  });
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.controller,
        obscureText: _hidden,
        enabled: widget.enabled,
        enableSuggestions: false,
        autocorrect: false,
        autofillHints: widget.autofillHints,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: IconButton(
            tooltip: _hidden ? 'Show password' : 'Hide password',
            icon: Icon(_hidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _hidden = !_hidden),
          ),
        ),
      );
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFFDECEC),
            borderRadius: BorderRadius.circular(14)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13.5))),
        ]),
      );
}

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed, this.busy = false});
  final VoidCallback? onPressed;
  final bool busy;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: Color(0xFFE3E4F3)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: busy ? null : onPressed,
          child: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('G',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Color(0xFF4285F4))),
                  SizedBox(width: 10),
                  Text('Continue with Google',
                      style: TextStyle(
                          color: AppColors.text, fontWeight: FontWeight.w600)),
                ]),
        ),
      );
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(children: [
          Expanded(child: Divider()),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('or keep it simple',
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5))),
          Expanded(child: Divider()),
        ]),
      );
}

/// Dialog that asks for an e-mail and sends a Firebase reset link.
Future<void> showForgotPasswordDialog(
    BuildContext context, Future<void> Function(String email) send,
    {String initialEmail = ''}) async {
  final controller = TextEditingController(text: initialEmail);
  final formKey = GlobalKey<FormState>();
  String? error;
  bool busy = false;
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reset your password'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Enter your account email and we'll send a reset link.",
                style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 14),
            if (error != null) ErrorBanner(error!),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email address'),
              validator: (v) {
                final s = v?.trim() ?? '';
                return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(s)
                    ? null
                    : 'Enter a valid email address';
              },
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: busy ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: busy
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    setState(() {
                      busy = true;
                      error = null;
                    });
                    try {
                      await send(controller.text);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        showToast(context,
                            'If that email has an account, a reset link is on its way.');
                      }
                    } catch (e) {
                      setState(() {
                        busy = false;
                        error = e.toString();
                      });
                    }
                  },
            child: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send link'),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
}
