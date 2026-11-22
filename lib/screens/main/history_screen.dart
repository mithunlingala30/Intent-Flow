import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/task_controller.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/responsive.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'All reminders';
  static const _filters = ['All reminders', 'Completed', 'Scheduled', 'Cancelled', 'Failed'];

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();
    final items = c.tasks.where((t) {
      switch (_filter) {
        case 'Completed':
          return t.done;
        case 'Scheduled':
          return !t.done;
        case 'Cancelled':
        case 'Failed':
          return false;
        default:
          return true;
      }
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return PageList(
      maxWidth: 980,
      children: [
        const Eyebrow('YOUR INTENT, IN ACTION'),
        const SizedBox(height: 6),
        Text('A little history. A lot achieved.',
            style: Theme.of(context).textTheme.headlineSmall),
        const Text('Every small action is part of your bigger picture.',
            style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _filter,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.filter_list)),
          items: [for (final f in _filters) DropdownMenuItem(value: f, child: Text(f))],
          onChanged: (v) => setState(() => _filter = v ?? _filter),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          EmptyState(
              icon: Icons.shield_outlined,
              title: 'Nothing to see here.',
              message: _filter == 'Failed' || _filter == 'Cancelled'
                  ? 'No ${_filter.toLowerCase()} automations yet.'
                  : 'Your activity will show up here.')
        else
          for (final t in items)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: softShadow(.35)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: CategoryStyle.of(t.done ? 'green' : 'purple').bg,
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(t.done ? Icons.check_rounded : Icons.bolt_rounded,
                      color: CategoryStyle.of(t.done ? 'green' : 'purple').fg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                        t.done
                            ? 'Task completed. One less thing on your mind.'
                            : 'Automatically scheduled from your intent.',
                        style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('${DateFormat('MMM d, y').format(t.dateTime)} · ${t.displayTime}',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ]),
                ),
                CategoryTag(
                    category: t.done ? 'Completed' : 'Scheduled',
                    color: t.done ? 'green' : 'purple'),
              ]),
            ),
      ],
    );
  }
}
