import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/task_model.dart';
import '../../services/task_controller.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/responsive.dart';
import 'intent_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();
    final dayTasks = c.forDate(_selected);

    return PageList(
      maxWidth: 1180,
      children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Eyebrow('MAKE ROOM FOR WHAT MATTERS'),
              const SizedBox(height: 6),
              Text('Your time, thoughtfully planned.',
                  style: Theme.of(context).textTheme.headlineSmall),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        TwoColumn(
          leftFlex: 6,
          rightFlex: 5,
          left: NeuCard(
          padding: const EdgeInsets.all(8),
          child: TableCalendar<TaskModel>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: _focused,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            selectedDayPredicate: (d) => isSameDay(d, _selected),
            eventLoader: (d) => c.forDate(d),
            onDaySelected: (sel, foc) => setState(() {
              _selected = sel;
              _focused = foc;
            }),
            onPageChanged: (f) => _focused = f,
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
            calendarStyle: const CalendarStyle(
              selectedDecoration:
                  BoxDecoration(color: AppColors.purple, shape: BoxShape.circle),
              todayDecoration:
                  BoxDecoration(color: AppColors.purpleLight, shape: BoxShape.circle),
              markerDecoration:
                  BoxDecoration(color: AppColors.purple, shape: BoxShape.circle),
            ),
          ),
        ),
          right: NeuCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(DateFormat('EEEE, MMM d').format(_selected),
                  style: Theme.of(context).textTheme.titleMedium)),
          TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
            onPressed: () =>
                pushPage(context, IntentScreen(presetDate: _selected)),
          ),
        ]),
        const Text('A little intention for your day.',
            style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 10),
        if (dayTasks.isEmpty)
          EmptyState(
            icon: Icons.calendar_month_rounded,
            title: 'Your day is wide open.',
            message: 'Plan something worth looking forward to.',
            actionLabel: 'Add to this day',
            onAction: () =>
                pushPage(context, IntentScreen(presetDate: _selected)),
          )
        else
          for (final t in dayTasks) _timelineItem(t),
          ])),
        ),
      ],
    );
  }

  Widget _timelineItem(TaskModel t) {
    final s = CategoryStyle.of(t.colorName);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 74,
            child: Text(t.displayTime,
                style: const TextStyle(color: AppColors.muted, fontSize: 12.5))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: s.bg, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.title,
                  style: TextStyle(color: s.fg, fontWeight: FontWeight.w800)),
              Text('${t.category} · ${t.done ? 'Completed' : 'Scheduled'}',
                  style: TextStyle(color: s.fg, fontSize: 12.5)),
            ]),
          ),
        ),
      ]),
    );
  }
}
