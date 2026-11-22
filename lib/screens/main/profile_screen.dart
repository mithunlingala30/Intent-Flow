import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../services/task_controller.dart';
import '../../theme.dart';
import '../../utils/validators.dart';
import '../../widgets/common.dart';
import '../../widgets/responsive.dart';
import '../auth/auth_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  bool _saving = false;
  bool _notify = true;

  @override
  void initState() {
    super.initState();
    _name.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _notify = p.getBool('notify') ?? true);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthService>().updateName(_name.text);
      if (mounted) showToast(context, 'Profile updated');
    } on AuthFailure catch (e) {
      if (mounted) showToast(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    final auth = context.read<AuthService>();
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final key = GlobalKey<FormState>();
    String? error;
    bool busy = false;
    final done = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.bg,
          title: const Text('Change password'),
          content: SingleChildScrollView(
            child: Form(
              key: key,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (error != null) ErrorBanner(error!),
                PasswordField(
                    controller: current,
                    label: 'Current password',
                    validator: (v) => Validators.required(v, 'Enter your current password')),
                const SizedBox(height: 12),
                PasswordField(
                    controller: next,
                    label: 'New password',
                    validator: Validators.newPassword),
                const SizedBox(height: 12),
                PasswordField(
                    controller: confirm,
                    label: 'Confirm new password',
                    validator: (v) => v != next.text ? 'Passwords must match' : null),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: busy ? null : () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (!key.currentState!.validate()) return;
                      setS(() {
                        busy = true;
                        error = null;
                      });
                      try {
                        await auth.changePassword(current: current.text, next: next.text);
                        if (ctx.mounted) Navigator.pop(ctx, true);
                      } on AuthFailure catch (e) {
                        setS(() {
                          busy = false;
                          error = e.message;
                        });
                      }
                    },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
    current.dispose();
    next.dispose();
    confirm.dispose();
    if (done == true && mounted) showToast(context, 'Password updated');
  }

  Future<void> _deleteAccount(User user) async {
    final auth = context.read<AuthService>();
    final pw = TextEditingController();
    final needsPw = AuthService.usesPassword(user);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg,
        title: const Text('Delete account?'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
              'This permanently deletes your account and all your tasks. This cannot be undone.'),
          if (needsPw) ...[
            const SizedBox(height: 14),
            PasswordField(controller: pw, label: 'Confirm your password'),
          ],
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    final password = pw.text;
    pw.dispose();
    if (ok != true) return;
    try {
      await auth.deleteAccount(password: needsPw ? password : null);
    } on AuthFailure catch (e) {
      if (mounted) showToast(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final user = FirebaseAuth.instance.currentUser;
    final c = context.watch<TaskController>();
    final displayName = (user?.displayName ?? '').isEmpty ? 'Friend' : user!.displayName!;

    return PageList(
      maxWidth: 1100,
      children: [
        const Eyebrow('YOUR FLOW, YOUR WAY'),
        const SizedBox(height: 6),
        Text("A space that's uniquely you.",
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TwoColumn(
          leftFlex: 4,
          rightFlex: 6,
          left: NeuCard(
          child: Column(children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.purple,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? Text(displayName[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800))
                  : null,
            ),
            const SizedBox(height: 10),
            Text(displayName, style: Theme.of(context).textTheme.titleLarge),
            Text(user?.email ?? '', style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _num('${c.tasks.length}', 'Intentions set'),
              _num('${c.completed.length}', 'Tasks completed'),
            ]),
            const SizedBox(height: 6),
            TextButton.icon(
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Log out'),
              onPressed: () => auth.signOut(),
            ),
          ]),
        ),
          right: NeuCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Personal information', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Form(
              key: _form,
              child: TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: Validators.name,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: user?.email ?? '',
              enabled: false,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
                label: 'Save changes',
                icon: Icons.check,
                loading: _saving,
                onPressed: _saveName),
            const SizedBox(height: 20),
            Text('Make yourself at home', style: Theme.of(context).textTheme.titleMedium),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('In-app notifications'),
              subtitle: const Text('A gentle nudge when it matters'),
              value: _notify,
              onChanged: (v) async {
                setState(() => _notify = v);
                (await SharedPreferences.getInstance()).setBool('notify', v);
              },
            ),
            if (user != null && AuthService.usesPassword(user))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.shield_outlined, color: AppColors.purple),
                title: const Text('Change password'),
                subtitle: const Text('Keep your account secure'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _changePassword,
              ),
            if (user != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_forever_outlined, color: AppColors.danger),
                title: const Text('Delete account',
                    style: TextStyle(color: AppColors.danger)),
                subtitle: const Text('Remove your account and all data'),
                onTap: () => _deleteAccount(user),
              ),
          ]),
        ),
        ),
      ],
    );
  }

  Widget _num(String n, String label) => Column(children: [
        Text(n, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ]);
}
