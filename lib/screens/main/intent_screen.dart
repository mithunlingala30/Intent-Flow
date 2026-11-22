import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../services/task_controller.dart';
import '../../theme.dart';
import '../../utils/intent_parser.dart';
import '../../widgets/common.dart';
import '../../widgets/responsive.dart';
import 'success_screen.dart';

class IntentScreen extends StatefulWidget {
  const IntentScreen({super.key, this.initialCommand = '', this.presetDate});
  final String initialCommand;

  /// When set (e.g. from the calendar) the form opens pre-filled for that day.
  final DateTime? presetDate;

  @override
  State<IntentScreen> createState() => _IntentScreenState();
}

class _IntentScreenState extends State<IntentScreen> {
  late final TextEditingController _command =
      TextEditingController(text: widget.initialCommand);
  final _title = TextEditingController();
  IntentDraft? _draft;
  bool _saving = false;

  static const _examples = [
    'Remind me to attend my project meeting tomorrow at 10 AM',
    'Schedule an evening workout today at 6 PM',
    'Remind me to read every day at 8 PM',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.presetDate != null) {
      _draft = IntentDraft(
          title: '',
          date: widget.presetDate!,
          time: const TimeOfDay(hour: 10, minute: 0));
    }
  }

  @override
  void dispose() {
    _command.dispose();
    _title.dispose();
    super.dispose();
  }

  void _analyze() {
    if (_command.text.trim().isEmpty) {
      showToast(context, 'Tell me what you would like to automate first.');
      return;
    }
    final d = IntentParser.parse(_command.text);
    _title.text = d.title;
    setState(() => _draft = d);
  }

  Future<void> _confirm() async {
    final d = _draft!;
    d.title = _title.text.trim();
    if (d.title.isEmpty) {
      showToast(context, 'Please add a task, date, and time.');
      return;
    }
    final hh = d.time.hour.toString().padLeft(2, '0');
    final mm = d.time.minute.toString().padLeft(2, '0');
    final task = TaskModel(
      title: d.title,
      category: d.category,
      date: dateKey(d.date),
      time: '$hh:$mm',
      repeat: d.repeat,
    );
    setState(() => _saving = true);
    try {
      final ctrl = context.read<TaskController>();
      final id = await ctrl.add(task);
      if (!mounted) return;
      final saved = TaskModel(
          id: id,
          title: task.title,
          category: task.category,
          color: CategoryStyle.colorFor(task.category),
          date: task.date,
          time: task.time,
          repeat: task.repeat);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: ctrl,
          child: ChangeNotifierProvider.value(
              value: context.read<ShellController>(),
              child: SuccessScreen(task: saved)),
        ),
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showToast(context, 'Could not save the task. Check your connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart automation')),
      body: SafeArea(
        child: PageList(
          maxWidth: 1100,
          children: [
            const Center(child: Eyebrow('LESS EFFORT. MORE POSSIBILITY.')),
            const SizedBox(height: 8),
            Text('Your words. A little magic.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const Text("Tell us what you need. We'll turn your intent into action.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 18),
            TwoColumn(
              left: _inputCard(),
              right: NeuCard(child: _draft == null ? _empty() : _analysis(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputCard() => NeuCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeading('What would you like to do?'),
                const SizedBox(height: 8),
                TextField(
                  controller: _command,
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (_) => setState(() => _draft = null),
                  decoration: const InputDecoration(
                      hintText: 'Remind me to attend my project meeting tomorrow at 10 AM.'),
                ),
                const SizedBox(height: 8),
                const Row(children: [
                  Icon(Icons.shield_outlined, size: 15, color: AppColors.muted),
                  SizedBox(width: 6),
                  Text('Your intent stays private',
                      style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
                ]),
                const SizedBox(height: 14),
                PrimaryButton(
                    label: 'Understand my intent',
                    icon: Icons.auto_awesome,
                    onPressed: _analyze),
                const SizedBox(height: 16),
                const Eyebrow('A LITTLE INSPIRATION'),
                const SizedBox(height: 6),
                for (final s in _examples)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.add_circle_outline,
                        color: AppColors.purple),
                    title: Text(s, style: const TextStyle(fontSize: 13.5)),
                    onTap: () => setState(() {
                      _command.text = s;
                      _draft = null;
                    }),
                  ),
              ]),
            );

  Widget _empty() => const Column(children: [
        Illustration(size: 130),
        SizedBox(height: 10),
        Text('A little clarity, coming right up.',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        SizedBox(height: 4),
        Text("Add an instruction and we'll break it down into a perfectly planned task.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted)),
      ]);

  Widget _analysis(BuildContext context) {
    final d = _draft!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: SectionHeading('Intent analysis')),
        if (widget.presetDate == null || _command.text.isNotEmpty)
          const Chip(
              avatar: Icon(Icons.check, size: 14),
              label: Text('Understood'),
              visualDensity: VisualDensity.compact),
      ]),
      const Text("Here's what we picked up. Fine-tune anything below.",
          style: TextStyle(color: AppColors.muted)),
      const SizedBox(height: 14),
      TextField(
        controller: _title,
        maxLength: 200,
        decoration: const InputDecoration(labelText: 'Task'),
      ),
      const SizedBox(height: 6),
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(DateFormat('MMM d, y').format(d.date)),
            onPressed: () async {
              final p = await showDatePicker(
                  context: context,
                  initialDate: d.date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100));
              if (p != null) setState(() => d.date = p);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.access_time, size: 18),
            label: Text(d.time.format(context)),
            onPressed: () async {
              final p = await showTimePicker(context: context, initialTime: d.time);
              if (p != null) setState(() => d.time = p);
            },
          ),
        ),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: d.repeat,
            decoration: const InputDecoration(labelText: 'Repeat'),
            items: [for (final r in kRepeats) DropdownMenuItem(value: r, child: Text(r))],
            onChanged: (v) => setState(() => d.repeat = v ?? d.repeat),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: d.category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [for (final c in kCategories) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => setState(() => d.category = v ?? d.category),
          ),
        ),
      ]),
      const SizedBox(height: 18),
      PrimaryButton(
          label: 'Confirm & automate',
          icon: Icons.bolt_rounded,
          loading: _saving,
          onPressed: _confirm),
    ]);
  }
}
