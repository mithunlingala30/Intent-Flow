import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/task_model.dart';
import '../../services/task_controller.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/notifications.dart';
import '../../widgets/responsive.dart';
import 'intent_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _command = TextEditingController();
  bool _completedOpen = false;

  @override
  void dispose() {
    _command.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    return h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');
  }

  void _openIntent([String text = '']) {
    pushPage(context, IntentScreen(initialCommand: text));
    _command.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();
    final desktop = isDesktop(context);

    final left = <Widget>[
      _hero(desktop),
      const SizedBox(height: 22),
      _commandCard(),
      const SizedBox(height: 22),
      _todaySection(c),
    ];
    final right = <Widget>[
      _flowCard(c, vertical: desktop),
      if (desktop) ...[const SizedBox(height: 22), _miniCalendar(c)],
      const SizedBox(height: 22),
      _upcomingSection(c),
    ];

    return PageList(
      maxWidth: 1320,
      children: [
        _header(c, desktop),
        const SizedBox(height: 22),
        if (desktop)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 7, child: Column(children: left)),
            const SizedBox(width: 26),
            Expanded(flex: 3, child: Column(children: right)),
          ])
        else ...[
          ...left.take(3),
          const SizedBox(height: 22),
          right.first,
          const SizedBox(height: 22),
          left.last,
          const SizedBox(height: 22),
          right.last,
        ],
      ],
    );
  }

  // ---------------------------------------------------------------- header
  Widget _header(TaskController c, bool desktop) {
    final user = FirebaseAuth.instance.currentUser;
    final first = (user?.displayName ?? '').trim().split(' ').first;
    final name = first.isEmpty ? 'there' : first;
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Eyebrow(DateFormat('EEEE, MMMM d, y').format(DateTime.now()).toUpperCase()),
          const SizedBox(height: 6),
          Text('${_greeting()}, $name ☀️',
              style: (desktop
                      ? Theme.of(context).textTheme.headlineMedium
                      : Theme.of(context).textTheme.headlineSmall)
                  ?.copyWith(letterSpacing: -.8)),
          const SizedBox(height: 4),
          const Text('A clear mind. A little intention. A more productive day.',
              style: TextStyle(color: AppColors.muted)),
        ]),
      ),
      if (desktop)
        GestureDetector(
          onTap: () => context.read<ShellController>().go(2),
          child: NeuSurface(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.calendar_today, size: 17, color: AppColors.purple),
              const SizedBox(width: 8),
              Text('Today, ${DateFormat('MMM d').format(DateTime.now())}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
          ),
        )
      else
        NeuIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            dot: true,
            onPressed: () => showNotifications(context)),
    ]);
  }

  // ------------------------------------------------------------------ hero
  Widget _hero(bool desktop) {
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('YOUR DAY, SIMPLIFIED',
          style: TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Text('Big intentions.\nEffortless execution.',
          style: TextStyle(
              color: Colors.white,
              fontSize: desktop ? 34 : 24,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -.8)),
      const SizedBox(height: 10),
      const Text("Let's make today productive.\nYou bring the intent. We'll take care of the rest.",
          style: TextStyle(color: Colors.white70, height: 1.4)),
      const SizedBox(height: 18),
      FilledButton.icon(
        style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.purple,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
        onPressed: () => _openIntent(),
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Make something happen'),
      ),
    ]);
    return Container(
      padding: EdgeInsets.all(desktop ? 34 : 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9A8EF2), AppColors.purple, Color(0xFF574BC4)]),
        boxShadow: const [
          BoxShadow(color: Color(0x556558D3), blurRadius: 30, offset: Offset(0, 16)),
          BoxShadow(color: Colors.white, blurRadius: 18, offset: Offset(-8, -8)),
        ],
      ),
      child: desktop
          ? Row(children: [
              Expanded(child: text),
              const SizedBox(width: 20),
              const Illustration(size: 210),
            ])
          : text,
    );
  }

  // ------------------------------------------------------------ command
  Widget _commandCard() => NeuCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            NeuSurface(
                radius: 14,
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.auto_awesome, color: AppColors.purple)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("What's on your mind?",
                    style: Theme.of(context).textTheme.titleMedium),
                const Text('Just say it. Consider it done.',
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ]),
            ),
            const Chip(
                label: Text('AI POWERED', style: TextStyle(fontSize: 10.5)),
                visualDensity: VisualDensity.compact),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _command,
            textInputAction: TextInputAction.send,
            onSubmitted: _openIntent,
            decoration: InputDecoration(
              hintText: 'Tell me what you want to do...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_circle_right_rounded,
                    color: AppColors.purple, size: 32),
                onPressed: () => _openIntent(_command.text),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
            const Text('TRY SAYING',
                style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700)),
            ActionChip(
              label: const Text('“Remind me about my meeting tomorrow”'),
              onPressed: () => _openIntent(
                  'Remind me to attend my project meeting tomorrow at 10 AM'),
            ),
          ]),
        ]),
      );

  // ------------------------------------------------------------ today
  Widget _todaySection(TaskController c) {
    final todayPending = c.today.where((t) => !t.done).toList();
    return NeuCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeading("Today's tasks",
            action: 'View all tasks',
            onAction: () => context.read<ShellController>().go(1)),
        const SizedBox(height: 6),
        if (c.loading)
          const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()))
        else if (c.error != null)
          EmptyState(icon: Icons.cloud_off_rounded, title: 'Offline?', message: c.error!)
        else ...[
          Row(children: [
            Expanded(
              child: Text.rich(TextSpan(children: [
                const TextSpan(text: 'You have '),
                TextSpan(
                    text: '${todayPending.length} tasks',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const TextSpan(text: ' to make things happen.'),
              ])),
            ),
            TextButton.icon(
                onPressed: () => _openIntent(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add task')),
          ]),
          const SizedBox(height: 10),
          if (todayPending.isEmpty)
            const EmptyState(
                icon: Icons.check_circle_outline,
                title: 'All clear. Enjoy the flow.',
                message: "You've completed everything planned for today.")
          else
            for (final t in todayPending) TaskCard(key: ValueKey(t.id), task: t),
          TextButton.icon(
            onPressed: () => setState(() => _completedOpen = !_completedOpen),
            icon: Icon(_completedOpen ? Icons.expand_less : Icons.expand_more),
            label: Text('${c.completed.length} completed tasks'),
          ),
          if (_completedOpen)
            for (final t in c.completed) TaskCard(key: ValueKey('d${t.id}'), task: t),
        ],
      ]),
    );
  }

  // ------------------------------------------------------- daily flow
  Widget _flowCard(TaskController c, {required bool vertical}) {
    final ring = SizedBox(
      width: vertical ? 150 : 86,
      height: vertical ? 150 : 86,
      child: Stack(alignment: Alignment.center, children: [
        NeuSurface(
          radius: 100,
          inset: true,
          padding: EdgeInsets.zero,
          child: const SizedBox.expand(),
        ),
        Padding(
          padding: EdgeInsets.all(vertical ? 10 : 6),
          child: SizedBox.expand(
            child: CircularProgressIndicator(
              value: c.todayProgress / 100,
              strokeWidth: vertical ? 12 : 9,
              strokeCap: StrokeCap.round,
              backgroundColor: const Color(0xFFE0DCF6),
              color: AppColors.purple,
            ),
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${c.todayProgress}%',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: vertical ? 28 : 18)),
          if (vertical)
            const Text('of your day, done',
                style: TextStyle(color: AppColors.muted, fontSize: 11.5)),
        ]),
      ]),
    );
    final stats = Wrap(spacing: 14, runSpacing: 6, children: [
      _stat('${c.tasks.length}', 'Total', AppColors.purple),
      _stat('${c.completed.length}', 'Done', const Color(0xFF65AD91)),
      _stat('${c.pending.length}', 'Pending', const Color(0xFFCDA16F)),
    ]);
    return NeuCard(
      child: vertical
          ? Column(children: [
              const SectionHeading('Your daily flow'),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Small steps. Meaningful progress.',
                      style: TextStyle(color: AppColors.muted, fontSize: 13))),
              const SizedBox(height: 18),
              ring,
              const SizedBox(height: 14),
              const Text('✦ You\'re building momentum!',
                  style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              stats,
            ])
          : Row(children: [
              ring,
              const SizedBox(width: 18),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Your daily flow',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Text('Small steps. Meaningful progress.',
                      style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 10),
                  stats,
                ]),
              ),
            ]),
    );
  }

  Widget _stat(String n, String label, Color dot) => Column(children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(n, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ]),
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
      ]);

  // ------------------------------------------------ mini calendar (web)
  Widget _miniCalendar(TaskController c) => NeuCard(
        padding: const EdgeInsets.all(10),
        child: TableCalendar<TaskModel>(
          firstDay: DateTime(2020),
          lastDay: DateTime(2100),
          focusedDay: DateTime.now(),
          rowHeight: 40,
          startingDayOfWeek: StartingDayOfWeek.monday,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          eventLoader: c.forDate,
          onDaySelected: (_, __) => context.read<ShellController>().go(2),
          headerStyle: const HeaderStyle(
              formatButtonVisible: false, titleCentered: true),
          calendarStyle: const CalendarStyle(
            todayDecoration:
                BoxDecoration(color: AppColors.purple, shape: BoxShape.circle),
            markerDecoration:
                BoxDecoration(color: AppColors.purpleLight, shape: BoxShape.circle),
          ),
        ),
      );

  // ------------------------------------------------------- upcoming
  Widget _upcomingSection(TaskController c) => NeuCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeading('Coming up',
              action: 'See all', onAction: () => context.read<ShellController>().go(2)),
          const SizedBox(height: 8),
          if (c.upcoming.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Nothing scheduled ahead.',
                  style: TextStyle(color: AppColors.muted)),
            )
          else
            for (final t in c.upcoming) _upcomingRow(t),
        ]),
      );

  Widget _upcomingRow(TaskModel t) {
    final s = CategoryStyle.of(t.colorName);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.notifications_none_rounded, color: s.fg, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('${DateFormat('MMM d').format(t.dateTime)} · ${t.displayTime}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
          ]),
        ),
      ]),
    );
  }
}
