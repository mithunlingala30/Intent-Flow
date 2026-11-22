import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../services/task_controller.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/responsive.dart';
import 'intent_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filter = 'All Tasks';
  String _category = 'All';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();
    final visible = c.tasks.where((t) {
      final okFilter = _filter == 'All Tasks' ||
          (_filter == 'Completed' ? t.done : !t.done);
      final okCat = _category == 'All' || t.category == _category;
      final okSearch = t.title.toLowerCase().contains(_search.toLowerCase());
      return okFilter && okCat && okSearch;
    }).toList();

    return PageList(
      maxWidth: 980,
      children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Eyebrow('A LITTLE STRUCTURE.'),
              const SizedBox(height: 6),
              Text('My tasks', style: Theme.of(context).textTheme.headlineSmall),
              const Text('A home for everything on your mind.',
                  style: TextStyle(color: AppColors.muted)),
            ]),
          ),
          FilledButton.icon(
              onPressed: () => pushPage(context, const IntentScreen()),
              icon: const Icon(Icons.add),
              label: const Text('New')),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _stat(Icons.checklist_rounded, c.tasks.length, 'Total'),
          const SizedBox(width: 10),
          _stat(Icons.access_time, c.pending.length, 'In progress'),
          const SizedBox(width: 10),
          _stat(Icons.check_circle_outline, c.completed.length, 'Completed'),
        ]),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: [
            for (final f in ['All Tasks', 'Pending', 'Completed'])
              ButtonSegment(value: f, label: Text(f, style: const TextStyle(fontSize: 12.5)))
          ],
          selected: {_filter},
          onSelectionChanged: (s) => setState(() => _filter = s.first),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => setState(() => _search = v),
          decoration: const InputDecoration(
              hintText: 'Search your tasks...', prefixIcon: Icon(Icons.search)),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: [
          for (final cat in ['All', ...kCategories])
            ChoiceChip(
              label: Text(cat),
              selected: _category == cat,
              onSelected: (_) => setState(() => _category = cat),
            ),
        ]),
        const SizedBox(height: 14),
        if (c.loading)
          const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()))
        else if (c.error != null)
          EmptyState(icon: Icons.cloud_off_rounded, title: 'Offline?', message: c.error!)
        else if (visible.isEmpty)
          EmptyState(
            icon: Icons.checklist_rounded,
            title: 'A little breathing room.',
            message: 'No tasks here. Try another filter or create something new.',
            actionLabel: 'Create a task',
            onAction: () => pushPage(context, const IntentScreen()),
          )
        else
          for (final t in visible) TaskCard(key: ValueKey(t.id), task: t, management: true),
      ],
    );
  }

  Widget _stat(IconData icon, int n, String label) => Expanded(
        child: NeuCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(children: [
            Icon(icon, color: AppColors.purple),
            const SizedBox(height: 4),
            Text('$n', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
          ]),
        ),
      );
}
