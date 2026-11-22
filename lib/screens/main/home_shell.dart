import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/task_controller.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/notifications.dart';
import '../../widgets/responsive.dart';
import 'calendar_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'intent_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';

/// Signed-in shell: owns the per-user controllers and picks the layout
/// (desktop/web sidebar layout vs. mobile bottom-nav layout).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskController(uid)),
          ChangeNotifierProvider(create: (_) => ShellController()),
        ],
        child: const _ShellView(),
      );
}

const _navItems = <(String, IconData, IconData)>[
  ('Home', Icons.home_outlined, Icons.home_rounded),
  ('My Tasks', Icons.checklist_rounded, Icons.checklist_rounded),
  ('Calendar', Icons.calendar_month_outlined, Icons.calendar_month_rounded),
  ('History', Icons.history_rounded, Icons.history_rounded),
  ('Profile', Icons.person_outline, Icons.person_rounded),
];

class _ShellView extends StatelessWidget {
  const _ShellView();

  static const _pages = <Widget>[
    HomeScreen(),
    TasksScreen(),
    CalendarScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellController>();
    final pending = context.select<TaskController, int>((c) => c.pending.length);
    final stack = IndexedStack(index: shell.index, children: _pages);

    if (isDesktop(context)) {
      return Scaffold(
        body: Row(children: [
          _Sidebar(index: shell.index, pending: pending, onTap: shell.go),
          Expanded(
            child: Column(children: [
              _TopBar(title: _navItems[shell.index].$1),
              Expanded(child: stack),
            ]),
          ),
        ]),
      );
    }
    return Scaffold(
      body: SafeArea(bottom: false, child: stack),
      bottomNavigationBar: SafeArea(
        child: _NeuBottomNav(
            index: shell.index, pending: pending, onTap: shell.go),
      ),
    );
  }
}

// ------------------------------------------------------------------ mobile
class _NeuBottomNav extends StatelessWidget {
  const _NeuBottomNav(
      {required this.index, required this.onTap, required this.pending});
  final int index;
  final int pending;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: softShadow(.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < _navItems.length; i++)
              Expanded(child: _navButton(i)),
          ],
        ),
      );

  Widget _navButton(int i) {
    final selected = i == index;
    final item = _navItems[i];
    Widget icon = Icon(selected ? item.$3 : item.$2,
        size: 24, color: selected ? Colors.white : AppColors.muted);
    if (i == 1 && pending > 0) {
      icon = Badge(label: Text('$pending'), child: icon);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8F82F0), AppColors.purple])
              : null,
          boxShadow: selected
              ? const [
                  BoxShadow(
                      color: Color(0x556558D3),
                      blurRadius: 12,
                      offset: Offset(0, 6))
                ]
              : null,
        ),
        child: Center(child: icon),
      ),
    );
  }
}

// ----------------------------------------------------------------- desktop
class _Sidebar extends StatelessWidget {
  const _Sidebar(
      {required this.index, required this.pending, required this.onTap});
  final int index;
  final int pending;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName ?? '').isEmpty ? 'Friend' : user!.displayName!;
    return Container(
      width: 272,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: softShadow(.9),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Brand(),
        const SizedBox(height: 30),
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 10),
          child: Text('YOUR WORKSPACE',
              style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700)),
        ),
        for (var i = 0; i < _navItems.length; i++) _item(i),
        const Spacer(),
        NeuSurface(
          inset: true,
          radius: 22,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.auto_awesome, color: AppColors.purple),
            const SizedBox(height: 8),
            const Text('A little less doing.\nA little more living.',
                style: TextStyle(fontWeight: FontWeight.w800, height: 1.25)),
            const SizedBox(height: 4),
            const Text('Let your intent do the work.',
                style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => pushPage(context, const IntentScreen()),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Create an automation'),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => onTap(4),
          child: NeuSurface(
            radius: 20,
            child: Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.purple,
                backgroundImage:
                    user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null
                    ? Text(name[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Text('Personal workspace',
                      style: TextStyle(color: AppColors.muted, fontSize: 11.5)),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _item(int i) {
    final selected = i == index;
    final it = _navItems[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => onTap(i),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: NeuSurface(
            inset: selected,
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(children: [
              Icon(selected ? it.$3 : it.$2,
                  color: selected ? AppColors.purple : AppColors.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(it.$1,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.purple : AppColors.text)),
              ),
              if (i == 1 && pending > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('$pending',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700)),
                ),
              if (selected)
                Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: AppColors.purple, shape: BoxShape.circle)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName ?? '').isEmpty ? 'F' : user!.displayName!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 32, 4),
      child: Row(children: [
        const Text('My workspace',
            style: TextStyle(color: AppColors.muted)),
        const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
        Text(title == 'Home' ? 'Overview' : title,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        const Spacer(),
        Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
                color: Color(0xFF4FA586), shape: BoxShape.circle)),
        const SizedBox(width: 8),
        const Text('All systems in flow',
            style: TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(width: 20),
        NeuIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            dot: true,
            onPressed: () => showNotifications(context)),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: () => context.read<ShellController>().go(4),
          child: CircleAvatar(
            radius: 21,
            backgroundColor: AppColors.purple,
            child: Text(name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}
